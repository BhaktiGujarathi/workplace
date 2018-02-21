/* 
 *  Add the Audit Trail record when Lead Owner or Status updates
 *  Revision History: 
 * 
 *  Version           Author                 Date(DD/MM/YYYY)               Description 
 *  1.0               Shraddha P.               20/7/2015                   Initial Draft 
 *  2.0               Merul Shah                08/19/2015                  On creation of Lead 
 */  
               
trigger LeadTrigger on Lead (after update, before update,after insert, after delete) {
    LeadAuditOnUpdate handler = new LeadAuditOnUpdate();
    LeadAuditOnInsert handlerForInsert = new LeadAuditOnInsert();  
    boolean isRunning = false;      
         
    // After Insert bolck added by merul
    if(trigger.isAfter){
        if(trigger.isInsert){
            List<Lead> myLeadsList = new List<Lead>();
            List<Lead> checkedList = new List<Lead>();

            for (Lead myLead : Trigger.new){                       
                if (myLead.Status == 'Closed - Lost' || myLead.Status == 'Open - Not Contacted' || myLead.Status ==  'Open - Attempting Contact' || myLead.Status == 'Working - Contacted' || myLead.Status == 'Closed - Future Client'){
                    myLeadsList.add(myLead);
                }
            }
            
            if(!myLeadsList.isEmpty()){
                DedupeProspectProcessService dedupProspect = new DedupeProspectProcessService(myLeadsList);
                dedupProspect.deduplicate();
            }

            handlerForInsert.auditTrailCreationAfterInsertLead();

            for(Lead myLead : Trigger.new){
                if(myLead.Counts_Against_Pipeline__c){
                    checkedList.add(myLead);
                }

                //UpdateLeadCount.incrementLeadCountForNewLeadsOnScorecard(checkedList);
            }
        }         
    }
        
    //if Lead is converted
    if(trigger.isBefore && trigger.isUpdate){
        Map<Id,Lead> oldmap = new Map<Id,Lead>();
        List<Id> ownerId = new List<Id>();
        Map<Id, Lead> mapConvertedLead = new Map<Id, Lead>();
           
        for(Lead convertedLead: Trigger.new){
            if(convertedLead.IsConverted == true){// && convertedLead.ConvertedOpportunityId != NULL){
                mapConvertedLead.put(convertedLead.Id, convertedLead);
                oldmap.put(convertedLead.Id,trigger.oldMap.get(convertedLead.Id));
            }
        }
            
        if (!mapConvertedLead.isEmpty() && !BizFiEngineIntegrationLeadConversion.isRunning) {

            BizFiEngineIntegrationLeadConversion.isRunning = true;

            BizFiEngineIntegrationLeadConversion leadConversion = new BizFiEngineIntegrationLeadConversion();
            leadConversion.createContacts(mapConvertedLead);
        }
            
        if(mapConvertedLead.size() > 0 && checkRecursiveOppToAudTrail.runOnceForBeforeOppToAudTrail())
            handler.onLeadConversion(mapConvertedLead, oldmap);
    }
        
    if(trigger.isAfter && trigger.isUpdate){
        Map<Id,Lead> oldmap   = new Map<Id,Lead>();
        List<Lead>   newList  = new List<Lead>();
        List<Id>     ownerId  = new List<Id>();
        List<Lead>   oldLeads = new List<Lead>();
        List<Lead>   newLeads = new List<Lead>();
        List<Lead>   checkedList   = new List<Lead>();
        List<Lead>   uncheckedList = new List<Lead>();
            
        for(Lead lead: trigger.new){
            if(trigger.oldMap.containsKey(lead.Id) && !lead.IsConverted){
                Lead oldLead = trigger.oldMap.get(lead.Id);
                //if Lead Owner changes
                if(lead.OwnerId !=oldLead.OwnerId ){
                    oldmap.put(lead.Id,trigger.oldMap.get(lead.Id));
                    newList.add(lead);

                    // Count against pipeline was checked and continues to be.
                    if(lead.Counts_Against_Pipeline__c && lead.Counts_Against_Pipeline__c == oldLead.Counts_Against_Pipeline__c){
                        oldLeads.add(oldLead);
                        newLeads.add(lead);
                    }      
                }

                //if Lead Status changes
                if(lead.Status != oldLead.Status){
                    if(!oldmap.containsKey(lead.Id)){
                        oldmap.put(lead.Id,trigger.oldMap.get(lead.Id));
                        newList.add(lead);
                        ownerId.add(lead.OwnerId);
                    }
                }

                //if(UpdateLeadCount.firstRun) { 
                //    // If Count against pipeline changes.
                //    if(lead.Counts_Against_Pipeline__c != oldLead.Counts_Against_Pipeline__c){
                //        if(lead.Counts_Against_Pipeline__c){
                //            checkedList.add(lead);
                //        }else{
                //            uncheckedList.add(lead);
                //        }
                //    }
                //}
            }
        }

        if(oldmap.size() > 0 && checkRecursiveOppToAudTrail.runOnceForAfterOppToAudTrail()){
            handler.onLeadOwnerStatusUpdate(oldmap, newList);
        }

        //UpdateLeadCount.updateScorecardsForChangedLeadOwners(newLeads, oldLeads);
        //UpdateLeadCount.incrementLeadCountForNewLeadsOnScorecard(checkedList);
        //UpdateLeadCount.updateScorecardsForDeletedLeads(uncheckedList);
        //UpdateLeadCount.firstRun = false;
    }

    // Push new API Leads to Inside Sales
    if (Trigger.isAfter && Trigger.isInsert) {

        Lead[] leads = new Lead[]{};

        for (Lead lead : Trigger.new) {

            if (lead.Send_to_InsideSales__c) {

                leads.add(lead);
            }
        }

        if (!leads.isEmpty()) {
            SendToInsideSales client = new SendToInsideSales(leads);
            client.send(true); 
        }               
    }
    
    if(Trigger.isDelete){
        //UpdateLeadCount.updateScorecardsForDeletedLeads(trigger.old);
    }
    
     /*

        When DupRefLeadID is populated or changed on the Lead

            - DupRefLeadLink is populated with Left($Api.Enterprise_Server_URL_190,(find('/services',$Api.Enterprise_Server_URL_190))) + DupRefLeadId__r.Id

            - DupRefLeadCampaign is populated with DupRefLeadId__r.Original_Campaign__c.Name

            - DupRefLeadCompany is populated with DupRefLeadId__r.Company

        When DupRefLeadID is null, all of the above three fields are null

    */
    if(trigger.isUpdate && trigger.isBefore){
        List<Id> opptyIds = new List<Id>();
        List<Id> leadIds = new List<Id>();

        for(Lead myLead : trigger.new){
            opptyIds.add(myLead.DupRefOppID__c);
            leadIds.add(myLead.DupRefLeadID__c);
        }

        Map<id, Opportunity> opptyMap = new Map<id, Opportunity>([select id, Campaign_Source__c,Account.Name from Opportunity where id IN: opptyIds]);
        Map<id, Lead>        leadMap  = new Map<id, Lead>([select id, Campaign_Source__c, Company from Lead where id IN: leadIds]);

        
        for(Lead myLead : trigger.new){

            Lead refLead = leadMap.get(myLead.DupRefLeadID__c);

            //Check if DupRefLeadID is populated or changed on the Lead
            if(trigger.oldMap.containsKey(myLead.Id) && (myLead.DupRefLeadID__c != trigger.oldMap.get(myLead.Id).DupRefLeadID__c)){
                // If the field is not null
                if(!String.isBlank(myLead.DupRefLeadID__c)){
                    myLead.DupRefLeadLink__c     = myLead.SalesforceInstance__c + refLead.Id;
                    myLead.DupRefLeadCampaign__c = refLead.Campaign_Source__c;
                    myLead.DupRefLeadCompany__c  = refLead.Company;
                }else{
                    myLead.DupRefLeadLink__c     = '';
                    myLead.DupRefLeadCampaign__c = '';
                    myLead.DupRefLeadCompany__c  = '';
                }
            }

            /*
                
                When DupRefOppID is populated or changed on the Lead

                    - DupRefOppLink is populated with Left($Api.Enterprise_Server_URL_190,(find('/services',$Api.Enterprise_Server_URL_190))) + DupRefOppId__r.Id

                    - DupRefOppCampaign is populated with DupRefOppId__r.Primary_Campaign__c.Name

                    - DupRefOppAccount is populated with DupRefAccountId__r.Name

                When DupRefOppID is null, all of the above three fields are null

            */
            Opportunity opp = opptyMap.get(myLead.DupRefOppID__c);
            if(trigger.oldMap.containsKey(myLead.Id) && (myLead.DupRefOppID__c != trigger.oldMap.get(myLead.Id).DupRefOppID__c)){
                // If the field is not null
                if(!String.isBlank(myLead.DupRefOppID__c)){
                    myLead.DupRefOppLink__c     = myLead.SalesforceInstance__c + opp.id;
                    myLead.DupRefOppCampaign__c = opp.Campaign_Source__c;
                    myLead.DupRefOppAccount__c  = opp.Account.Name;
                }else{
                    myLead.DupRefOppLink__c     = '';
                    myLead.DupRefOppCampaign__c = '';
                    myLead.DupRefOppAccount__c  = '';
                }
            }
        }
    }


    if (Trigger.isAfter && !System.isBatch() && !System.isFuture()) {

        Set<Id> salesRepsIds = new Set<Id>();

        if (Trigger.new != null) {

            for (Lead l : Trigger.new) {

                salesRepsIds.add(l.OwnerId);
            }
        }

        if (Trigger.old != null) {

            for (Lead l : Trigger.old) {                

                salesRepsIds.add(l.OwnerId);

                if (l.OwnerId != Trigger.oldMap.get(l.Id).OwnerId) {

                    salesRepsIds.add(Trigger.oldMap.get(l.Id).OwnerId);
                }
            }
        }

        if (!salesRepsIds.isEmpty()) {

            UpdateUserWorkloadBatch.start(salesRepsIds);
        }
    }
}