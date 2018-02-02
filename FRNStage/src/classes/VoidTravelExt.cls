global class VoidTravelExt {
    webservice static void request(Id oppId,String stage,String proName) 
    { 
         
       
        if(oppId != null)
        {

                List<Quote> estimateList = new List<Quote>();
                List<trip__c> tripList = new List<trip__c>();
                Set<ID> quoteID = new Set<ID>();
                List<QuoteLineItem> qltToDelete = new List<QuoteLineItem>();
                
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.StageName = 'Determination Complete';
                update opp; 
                 
                for(trip__c trip : [SELECT id FROM Trip__c
                                              WHERE Opportunity__c =:opp.id])
                {
                    trip.Status__c = 'Cancelled';
                    tripList.add(trip);
                }
                update tripList;                

                for(Quote e :[SELECT Id,Status__c,OpportunityId FROM Quote where OpportunityId =:opp.id])
                {
                    Quote est = new Quote();
                    est.Id = e.Id;
                    est.Status__c = 'Open';
                    quoteID.add(e.Id);
                    estimateList.add(est);
                }
                
                for(QuoteLineItem qtLineItem : [SELECT id,product2ID,product2.name FROM QuoteLineItem 
                                                          WHERE QuoteId =: quoteID])
                {
                    if(qtLineItem.product2.name == 'Car Service' || qtLineItem.product2.name == 'Airfare')  
                    {
                        qltToDelete.add(qtLineItem);
                    }
                }
                
                if(qltToDelete.size() > 0)
                {
                    delete qltToDelete;
                }
                
                if(estimateList.size() > 0)
                {
                    update estimateList;
                }

        }
    }
}