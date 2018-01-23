global class GenerateQuoteCont {  
    
    webservice static string createQuote(String agreementID,boolean generateQuoteButton){
        Pay_Agreement_Worksheet__c payAgreement = [SELECT name, 
                                                          Patient_Insurance__r.opportunity__c,
                                                          Patient_Insurance__r.Insurance_Company__c,
                                                          Patient_Insurance__r.opportunity__r.name,
                                                          Patient_Insurance__r.opportunity__r.StageName,
                                                          Facility_Program__c,
                                                          FRN_Facility__c,
                                                          Co_Insurance_Amount_Requested__c,
                                                          Deductible_Amount_Requested__c,
                                                          Related_Pay_Agreement_Worksheet__c,
                                                          Related_Pay_Agreement_Worksheet__r.Patient_Insurance__r.Insurance_Company__c //Bhakti : 8thOct2017
                                                     FROM Pay_Agreement_Worksheet__c 
                                                    where id =:  agreementID]; 

        if(payAgreement.Patient_Insurance__r.opportunity__c != null)
        {
            if(payAgreement.Patient_Insurance__r.Opportunity__r.StageName != 'Pending Admission'){
                datetime myDateTime = datetime.now();
                string localTime = mydatetime.format();
                Quote quote = new Quote();
                quote.Secondary_Pay_Agreement_Worksheet__c = payAgreement.Related_Pay_Agreement_Worksheet__c; //Bhakti : 8thOct2017
                quote.name= payAgreement.Patient_Insurance__r.opportunity__r.name; //+'_'+localTime;
                quote.opportunityId= payAgreement.Patient_Insurance__r.opportunity__c;
                quote.Pay_Agreement_Worksheet__c = agreementID;
                if(payAgreement.Patient_Insurance__r.Insurance_Company__c!= null || payAgreement.Patient_Insurance__r.Insurance_Company__c != '' ) {    
                    quote.Insurance_Company__c = payAgreement.Patient_Insurance__r.Insurance_Company__c;
                }
                if(payAgreement.Related_Pay_Agreement_Worksheet__r.Patient_Insurance__r.Insurance_Company__c != null
                || payAgreement.Related_Pay_Agreement_Worksheet__r.Patient_Insurance__r.Insurance_Company__c != '') {
                    quote.Secondary_Insurance_Company__c = payAgreement.Related_Pay_Agreement_Worksheet__r.Patient_Insurance__r.Insurance_Company__c;
                }
                if(payAgreement.FRN_Facility__c!= null || payAgreement.FRN_Facility__c != '' ) {    
                    quote.FRN_Facility__c = payAgreement.FRN_Facility__c;
                }
                
                if(payAgreement.Facility_Program__c!= null || payAgreement.Facility_Program__c != '' ) {
                    quote.Facility_Program__c = payAgreement.Facility_Program__c;
                }                     
                    
                if(generateQuoteButton==True){
                    quote.Type__c='Draft'; 
                }else{
                    quote.Type__c='Official';                 
                }
                Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
                if(pricebookName!=null){
                    List<PriceBook2> pricebooks = [select id, name, isActive from Pricebook2 where Name=:pricebookName.Default_Pricebook_Name__c limit 1];
                    System.debug('pricebooksId[0]_____________________ '+pricebooks[0].Id);
                    if(pricebooks!=null && pricebooks.size()>0){
                        quote.Pricebook2Id = pricebooks[0].Id;
                    }
                }
                quote.Status__c = 'Open';
                System.debug(quote);
                try{
                    
                    Set<Id> vobProfileId = new Set<Id>();
                    for(Profile prf:[SELECT Id FROM Profile WHERE Name Like 'FRN - Verification of Benefits (VOB)%']){
                        vobProfileId.add(prf.Id);
                    }
                    if(payAgreement.Patient_Insurance__r.Opportunity__r.StageName == 'Determination Complete' && vobProfileId.contains(Userinfo.getProfileId())){
                        return 'error';
                    }
                    
                    insert quote;
                } catch (Exception e){
                    return 'error1';
                }
                
                return string.valueof(quote.Id); 
            }else{              
                return 'PendingAdmission';
            }           
        }
        return null; 
    } 
}