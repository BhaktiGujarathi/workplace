global class ReferralRequesteExt {
    webservice static string request(Id oppId,String stage,String proName,string Recordtype) { 
    string ErrorMsg ='';
        System.debug('oppId.>> '+oppId); 
        System.debug('stage.>> '+stage); 
        System.debug('proName.>> '+proName); 
        String rooID = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
        String rtcId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        
        if(oppId != null){
            
            if(proName.contains('FRN - Admissions Coordinator') || Recordtype == 'Residential Treatment' || Recordtype == 'Refer Out Only' ){
                System.debug('inside if');
                Opportunity oppObj = [Select id,StageName, RecordTypeId, Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Social_Security_Number__c,Contact__r.Preferred_Method_of_Contact__c,LeadSource,Refer_Out_Reason__c,Contact__r.Birthdate,Contact__r.MailingCity,Contact__r.MailingState from Opportunity where ID=:oppId];
                if(oppObj.RecordTypeId == rooId || oppObj.RecordTypeId == rtcId){ 
                    if(oppObj.contact__r.FirstName == null){
                       ErrorMsg = 'Patient\'s  First Name is required.\n'; 
                    }
                    if(oppObj.contact__r.LastName == null){
                        ErrorMsg += 'Patient\'s  Last Name is required.\n'; 
                    }
                    if(oppObj.contact__r.Birthdate == null){
                        ErrorMsg += 'Patient\'s  Birthdate is required.\n'; 
                    }
                    if(oppObj.contact__r.MailingCity == null){
                        ErrorMsg += 'Patient\'s  City is required.\n'; 
                    }
                    if(oppObj.contact__r.MailingState == null){
                        ErrorMsg += 'Patient\'s  State is required.\n'; 
                    }
                    
                    if(oppObj.Refer_Out_Reason__c == null || oppObj.Refer_Out_Reason__c == '--None--'){
                       ErrorMsg += 'Refer Out Reason is required.\n'; 
                    }
                    if(oppObj.LeadSource == null || oppObj.LeadSource == '--None--'){
                        ErrorMsg += 'Pre-Screening Source is required.'; 
                    }
                    if(ErrorMsg != ''){
                        return ErrorMsg;
                    }
                    
                }
                Opportunity opp = new Opportunity();
                opp.id = oppObj.Id;
                opp.StageName = 'Referral Requested';
                update opp;
                
                List<Pay_Agreement_Worksheet__c> pawList = new List<Pay_Agreement_Worksheet__c>();
                List<Quote> estimateList = new List<Quote>();
                
                for(Pay_Agreement_Worksheet__c p:[SELECT Id,Status__c,Opportunity__c  FROM Pay_Agreement_Worksheet__c where Opportunity__c =:opp.id]){
                    Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c();
                    paw.Id = p.Id;
                    paw.Status__c = 'Cancelled';
                    pawList.add(paw);
                }
                for(Quote e :[SELECT Id,Status__c,OpportunityId FROM Quote where OpportunityId =:opp.id]){
                    Quote est = new Quote();
                    est.Id = e.Id;
                    est.Status__c = 'Cancelled';
                    estimateList.add(est);
                }
                
                if(pawList.size() > 0){
                    update pawList;
                }
                if(estimateList.size() > 0){
                    update estimateList;
                }
                return '';
            }else{
                System.debug('inside else');
                return '';
            }
        }
        return '';
    }
}