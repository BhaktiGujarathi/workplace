global class UpdateTripDetail{
    
    webservice static string updateQLIs(String qoteId){     
        List<QuoteLineItem> qliToDelete = new List<QuoteLineItem>();
        List<QuoteLineItem> qliToUpsert = new List<QuoteLineItem>();
        
        try{
            String oppId = [Select OpportunityId
                              FROM Quote
                             WHERE Id=:qoteId].OpportunityId;   
            // get the opp id for the quote

            Map<String,decimal> productPriceMap = new Map<String,decimal>();

            for(Reservation__c res: [SELECT Id
                                           , RecordType.Name
                                           , Trip__r.Opportunity__r.Name
                                           , Rate__c
                                           , Name
                                           , Total_Amount_Charged__c
                                        FROM Reservation__c
                                       WHERE Trip__r.Opportunity__c = : oppId 
                                         AND Trip__r.Status__c = 'Open' 
                                        AND (RecordType.Name = 'Car Service' 
                                          OR RecordType.Name = 'Airfare')]){ 
                
                if(res.RecordType.Name=='Car Service' && res.Rate__c!=null && res.Rate__c>0){ 
                    if(productPriceMap.containsKey('Car Service')){
                        decimal tempRate = productPriceMap.get('Car Service');
                        tempRate += res.Rate__c;
                        productPriceMap.put('Car Service',tempRate);
                    } else {
                        productPriceMap.put('Car Service',res.Rate__c);
                    }
                } else if(res.RecordType.Name=='Airfare' && res.Total_Amount_Charged__c!=null && res.Total_Amount_Charged__c>0){ 
                    if(productPriceMap.containsKey('Airfare')){
                        decimal tempCharge = productPriceMap.get('Airfare');
                        tempCharge += res.Total_Amount_Charged__c;
                        productPriceMap.put('Airfare',tempCharge);
                    } else {
                        productPriceMap.put('Airfare',res.Total_Amount_Charged__c);
                    }
                }
            }

            System.debug('productPriceMap ::>'+productPriceMap);
            
            List<String> quoteIds = new List<String>();
            for(Quote qut:[Select Id FROM Quote WHERE OpportunityId =:oppId]){
                quoteIds.add(qut.Id);
            }
            
            Map<String,List<QuoteLineItem>> oppQLIMap = new Map<String,List<QuoteLineItem>>();
            //Map of Opportunity and list of QLIs with product name Product2.Name = 'Car Service' OR Product2.Name = 'Airfare'          
            for(QuoteLineItem qli:[Select Id
                                        , Product2Id
                                        , QuoteId
                                        , Product2.Name
                                        , Quote.OpportunityId
                                        , Auto_Added__c
                                        , UnitPrice 
                                     from QuoteLineItem 
                                    WHERE Quote.OpportunityId =: oppId 
                                      AND (Product2.Name = 'Car Service' OR Product2.Name = 'Airfare')]){

                if(oppQLIMap.containsKey(qli.QuoteId)){
                    oppQLIMap.get(qli.QuoteId).add(qli);
                } else {
                    oppQLIMap.put(qli.QuoteId,new List<QuoteLineItem>{qli});
                }
            }

            System.debug('oppQLIMap ::>'+oppQLIMap);
            
            //Default price book id
            Id FRN_PriceBookId ;
            Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
            if(pricebookName!=null)
                FRN_PriceBookId = [SELECT Id 
                                     FROM Pricebook2 
                                    WHERE Name =:pricebookName.Default_Pricebook_Name__c].Id;
            
            Map<String,PricebookEntry> productRelatedPBE = new Map<String,PricebookEntry> ();
            if(FRN_PriceBookId!=null){
                for(PricebookEntry pbe : [Select id
                                               , Pricebook2Id,Product2.Name
                                               , Product2Id,UnitPrice 
                                            FROM PricebookEntry 
                                           WHERE Pricebook2Id =: FRN_PriceBookId 
                                             AND Product2.Auto_Add_to_Quote_Line_Items__c = true 
                                             AND (Product2.Name = 'Car Service' OR Product2.Name = 'Airfare')]){
                    productRelatedPBE.put(pbe.Product2.Name,pbe);
                }
            }
            
            boolean isCarServiceExisted = false;
            boolean isAirfareExisted = false;   
            for(String qotId:quoteIds){
                isCarServiceExisted = false;
                isAirfareExisted = false;
                if(oppQLIMap.containsKey(qotId)){
                    for(QuoteLineItem qli:oppQLIMap.get(qotId)){
                        //qli.UnitPrice = 0;
                        System.debug('qli ::>'+qli);
                        if(qli.Product2.Name == 'Car Service'){
                            isCarServiceExisted = true;
                            if(productPriceMap.containsKey(qli.Product2.Name)){
                                qli.UnitPrice = productPriceMap.get(qli.Product2.Name);
                                qliToUpsert.add(qli);
                            } else {
                                qliToDelete.add(qli);
                            }                   
                        } else if(qli.Product2.Name == 'Airfare'){
                            isAirfareExisted = true;
                            if(productPriceMap.containsKey(qli.Product2.Name)){
                                qli.UnitPrice = productPriceMap.get(qli.Product2.Name);
                                qliToUpsert.add(qli);
                            } else {
                                qliToDelete.add(qli);
                            }   
                        }                   
                    }
                }

                System.debug('**** isCarServiceExisted'+isCarServiceExisted);
                System.debug('**** productRelatedPBE.containsKey(Car Service) '+productRelatedPBE.containsKey('Car Service') );
                System.debug('**** productPriceMap.containsKey(Car Service) '+productPriceMap.containsKey('Car Service') );

                // if QLI of type Car Service not exist in this quote
                if(    !isCarServiceExisted 
                    && productRelatedPBE.containsKey('Car Service') 
                    && productPriceMap.containsKey('Car Service')){
                    QuoteLineItem newQLI = new QuoteLineItem();
                    newQLI.QuoteId = qotId;
                    newQLI.PriceBookentryId = productRelatedPBE.get('Car Service').Id;
                    newQLI.Product2Id = productRelatedPBE.get('Car Service').Product2Id;
                    newQLI.Quantity = 1;
                    newQLI.Auto_Added__c = true;
                    newQLI.UnitPrice = productPriceMap.get('Car Service');
                    System.debug('qli ::>'+newQLI);
                    qliToUpsert.add(newQLI);                    
                }

                System.debug('**** isAirfareExisted'+isAirfareExisted);
                System.debug('**** productRelatedPBE.containsKey(Car Service) '+productRelatedPBE.containsKey('Airfare') );
                System.debug('**** productPriceMap.containsKey(Car Service) '+productPriceMap.containsKey('Airfare') );


                // if QLI of type Airfare not exist in this quote
                if(     !isAirfareExisted 
                     && productRelatedPBE.containsKey('Airfare') 
                     && productPriceMap.containsKey('Airfare')){
                    QuoteLineItem newQLI = new QuoteLineItem();
                    newQLI.QuoteId = qotId;
                    newQLI.PriceBookentryId = productRelatedPBE.get('Airfare').Id;
                    newQLI.Product2Id = productRelatedPBE.get('Airfare').Product2Id;
                    newQLI.Quantity = 1;
                    newQLI.Auto_Added__c = true;
                    newQLI.UnitPrice = productPriceMap.get('Airfare');
                    System.debug('qli ::>'+newQLI);
                    qliToUpsert.add(newQLI);
                }
            }   
            
            System.debug('qliToDelete.size() ::>'+qliToDelete.size());
            if(qliToDelete.size()>0){
                delete qliToDelete;
            }
            System.debug('qliToUpsert.size() ::>'+qliToUpsert.size());
            System.debug('qliToUpsert.size() ::>'+qliToUpsert);
            if(qliToUpsert.size()>0){
                upsert qliToUpsert;
            }
        } catch(Exception e) {
            return e.getMessage();
        }
        return 'Trip details have been updated successfully';
    }
}