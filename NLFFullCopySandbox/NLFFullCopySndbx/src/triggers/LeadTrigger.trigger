/* 
 *  Add the Audit Trail record when Lead Owner or Status updates
 *  Revision History: 
 * 
 *  Version           Author                 Date(DD/MM/YYYY)               Description 
 *  1.0               Shraddha P.               20/7/2015                   Initial Draft 
 *  2.0               Merul Shah                08/19/2015                  On creation of Lead 
 */  
               
trigger LeadTrigger on Lead (after update, before update,after insert) {
        LeadAuditOnUpdate handler = new LeadAuditOnUpdate();
        LeadAuditOnInsert handlerForInsert = new LeadAuditOnInsert();
         
         // After Insert bolck added by merul
         if(trigger.isAfter)
         {
             if(trigger.isInsert)
             {
                  handlerForInsert.auditTrailCreationAfterInsertLead();
             
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
            if(mapConvertedLead.size() > 0 && checkRecursiveOppToAudTrail.runOnceForBeforeOppToAudTrail())
                handler.onLeadConversion(mapConvertedLead, oldmap);
        }
        
        
        
        
        
        if(trigger.isAfter && trigger.isUpdate){
            Map<Id,Lead> oldmap = new Map<Id,Lead>();
            List<Lead> newList = new List<Lead>();
            List<Id> ownerId = new List<Id>();
            for(Lead lead: trigger.new){
                //if Lead Owner changes
                if(trigger.oldMap.containsKey(lead.Id) && lead.OwnerId != trigger.oldMap.get(lead.Id).OwnerId && lead.IsConverted != true){
                    oldmap.put(lead.Id,trigger.oldMap.get(lead.Id));
                    newList.add(lead);
                }
                //if Lead Status changes
                if(trigger.oldMap.containsKey(lead.Id) && lead.Status != trigger.oldMap.get(lead.Id).Status && lead.IsConverted != true){
                    if(!oldmap.containsKey(lead.Id)){
                        oldmap.put(lead.Id,trigger.oldMap.get(lead.Id));
                        newList.add(lead);
                        ownerId.add(lead.OwnerId);
                    }
                }
            }
            if(oldmap.size() > 0 && checkRecursiveOppToAudTrail.runOnceForAfterOppToAudTrail())
                handler.onLeadOwnerStatusUpdate(oldmap, newList);
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
}