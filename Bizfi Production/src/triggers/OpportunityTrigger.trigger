trigger OpportunityTrigger on Opportunity (before insert, after insert, after update,before update, after delete) {
    
    OpportunityAuditOnUpdate handler = new OpportunityAuditOnUpdate();
    OpportunityDeduplication deduplicator = new OpportunityDeduplication();

    if(trigger.isAfter)
    {
        
        if(trigger.isUpdate)
        {
        
            if(checkRecursiveOppToAudTrail.runOnceForAfterOppToAudTrail())
            {   //Added by Merul For Audit Trail.
                handler.onOpportunityOwnerStatusUpdate(trigger.oldMap, trigger.new);
            }
            
            deduplicator.onOpportunityStageUpdate(trigger.oldMap, trigger.new);

            if(BFIUtility.checkRecursive==false){
                BFIUtility.checkRecursive = true;
                Opportunity_CMB_Utility.createPayables(trigger.newMap,trigger.oldmap);
            }

            //for(Opportunity oppty : trigger.new){
            //    if(trigger.oldMap.containsKey(oppty.Id) && trigger.oldMap.get(oppty.id).OwnerId != oppty.OwnerId){
            //        if(UpdateOpportunityCount.firstRun) { 
            //            UpdateOpportunityCount.updateScorecardsForChangedOpportunityOwners(trigger.new, trigger.old);
            //            UpdateOpportunityCount.firstRun = false;
            //        }                  
            //    }

            //    if(trigger.oldMap.containsKey(oppty.Id) && trigger.oldMap.get(oppty.id).StageName != oppty.StageName){
            //        if(UpdateOpportunityCount.firstRun) { 
            //            UpdateOpportunityCount.updateScorecardsForChangedOpportunityStage(trigger.new, trigger.old);
            //            UpdateOpportunityCount.firstRun = false;
            //        }                  
            //    }
            //}
        }         
    
        
        if(trigger.isInsert)
        {
            //Added by Merul For Audit Trail.
            OpportunityAuditOnInsert oppAuditInsert = new OpportunityAuditOnInsert();
            oppAuditInsert.onOpportunityInsertAuditTrailRecord();

            deduplicator.onOpportunityStageUpdate(trigger.oldMap, trigger.new);
            

            //UpdateOpportunityCount.incrementOpportunityCountForNewLeadsOnScorecard(trigger.new);
        }
    }


    //Added code for Before Insert by Charan Vuyyuru
    if(trigger.isBefore){
        RecordType recOpportunity = [Select id from RecordType where sobjectType='Opportunity' and developerName='Read_Only'];
        Set<String> keys2check = new Set<String>();
        for(Opportunity opp: trigger.new){
            if(trigger.isInsert && opp.Funded_Date_Key__c != null ){
                keys2check.add(opp.Funded_Date_Key__c);
            }
            if(trigger.isUpdate && opp.Funded_Date_Key__c != null && trigger.oldmap.get(opp.Id).Funded_Date_Key__c  != opp.Funded_Date_Key__c){
               keys2check.add(opp.Funded_Date_Key__c);
            }
        }
        
        if(!keys2check.isEmpty()){
            Set<string> keysLocked = new Set<String>();
            for(Accounting_Calendar_Month__c acm: [Select id,locked__c,Key__c from Accounting_Calendar_Month__c where Key__c in: keys2check]){
                if(acm.Locked__c){
                    keysLocked.add(acm.Key__c);
                }
            }
            
            for(Opportunity opp: trigger.new){
                if(opp.Funded_Date_Key__c != null && keysLocked.contains(opp.Funded_Date_Key__c) ){
                    opp.addError(System.Label.OppReadOnlyError);
                }
            }
        }
    }
    
    
    
    //if(trigger.isDelete){
    //    UpdateOpportunityCount.updateScorecardsForDeletedOpportunities(trigger.old);
    //}
    
     if(trigger.isBefore && trigger.isUpdate)
     {
     
       if(CheckRecursiveDeDupBeforeUpdate.runOnceDeDupBeforeUpdate())
       {
                
                List<Id> opptyIds = new List<Id>();
                List<Id> leadIds = new List<Id>();
        
                for(Opportunity myOppty : trigger.new){
                    opptyIds.add(myOppty.DupRefOppID__c);
                    leadIds.add(myOppty.DupRefLeadId2__c);
                }
        
                Map<id, Opportunity> opptyMap = new Map<id, Opportunity>([select id, Campaign_Source__c,Account.Name from Opportunity where id IN: opptyIds]);
                Map<id, Lead>        leadMap  = new Map<id, Lead>([select id, Campaign_Source__c,Company from Lead where id IN: leadIds]);
                /*
        
                    When DupRefLeadID is populated or changed on the Lead
                
                        - DupRefLeadLink is populated with Left($Api.Enterprise_Server_URL_190,(find('/services',$Api.Enterprise_Server_URL_190))) + DupRefLeadId__r.Id
        
                        - DupRefLeadCampaign is populated with DupRefLeadId__r.Original_Campaign__c.Name
        
                        - DupRefLeadCompany is populated with DupRefLeadId__r.Company
        
                    When DupRefLeadID is null, all of the above three fields are null
        
                */
                for(Opportunity myOppty : trigger.new){
                    Lead refLead = leadMap.get(myOppty.DupRefLeadId2__c);
                    //Check if DupRefLeadID is populated or changed on the Lead
                    if(trigger.oldMap.containsKey(myOppty.Id) && (myOppty.DupRefLeadId2__c != trigger.oldMap.get(myOppty.Id).DupRefLeadId2__c)){
                        // If the field is not null
                        if(!String.isBlank(myOppty.DupRefLeadId2__c)){
                            myOppty.DupRefLeadLink__c     = myOppty.SalesforceInstance__c + refLead.Id;
               //             myOppty.DupRefLeadCampaign__c = refLead.Campaign_Source__c;
                            myOppty.DupRefLeadCompany__c  = refLead.Company;
                        }else{
                            myOppty.DupRefLeadLink__c     = '';
                            myOppty.DupRefLeadCampaign__c = '';
                            myOppty.DupRefLeadCompany__c  = '';
                        }
                    }
        
                    /*            
        
                        When DupRefOppID is populated or changed on the Lead
        
                            - DupRefOppLink is populated with Left($Api.Enterprise_Server_URL_190,(find('/services',$Api.Enterprise_Server_URL_190))) + DupRefOppId__r.Id
        
                            - DupRefOppCampaign is populated with DupRefOppId__r.Primary_Campaign__c.Name
        
                            - DupRefOppAccount is populated with DupRefAccountId__r.Name
        
                        When DupRefOppID is null, all of the above three fields are null
                    */
                    if(trigger.oldMap.containsKey(myOppty.Id) && (myOppty.DupRefOppID__c != trigger.oldMap.get(myOppty.Id).DupRefOppID__c)){
                        
                        Opportunity opp = opptyMap.get(myOppty.DupRefOppID__c);
                        // If the field is not null
                        if(!String.isBlank(myOppty.DupRefOppID__c)){
                            myOppty.DupRefOppLink__c     = myOppty.SalesforceInstance__c + opp.Id;
                //            myOppty.DupRefOppCampaign__c = opp.Campaign_Source__c;
                            myOppty.DupRefOppAccount__c  = opp.Account.Name;
                        }else{
                            myOppty.DupRefOppLink__c     = '';
                            myOppty.DupRefOppCampaign__c = '';
                            myOppty.DupRefOppAccount__c  = '';
                        }
                    }
                }
       
       /////
       }
        
        
    }


    if (Trigger.isAfter && !System.isBatch() && !System.isFuture()) {

        Set<Id> salesRepsIds = new Set<Id>();

        if (Trigger.new != null) {

            for (Opportunity o : Trigger.new) {

                salesRepsIds.add(o.OwnerId);
            }
        }

        if (Trigger.old != null) {

            for (Opportunity o : Trigger.old) {

                salesRepsIds.add(o.OwnerId);

                if (o.OwnerId != Trigger.oldMap.get(o.Id).OwnerId) {

                    salesRepsIds.add(Trigger.oldMap.get(o.Id).OwnerId);
                }
            }
        }

        if (!salesRepsIds.isEmpty()) {

            UpdateUserWorkloadBatch.start(salesRepsIds);
        }
    }
}