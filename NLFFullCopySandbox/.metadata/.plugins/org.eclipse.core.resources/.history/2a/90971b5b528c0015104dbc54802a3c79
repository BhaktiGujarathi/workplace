public with sharing class LeadAuditOnUpdate {
private List<Audit_Trail__c> lstAuditTrail;

    public LeadAuditOnUpdate(){
        lstAuditTrail = new List<Audit_Trail__c>();
    }
    
    public void onLeadOwnerStatusUpdate(Map<Id,Lead> oldmap, List<Lead> newList){
      
          
        for(Lead lead: newList)
        {
            Audit_Trail__c auditTrail = new Audit_Trail__c();
            auditTrail.Object__c = 'Lead';
            auditTrail.Lead__c = lead.Id;
            auditTrail.Date_Time_change_was_made__c = lead.LastModifiedDate;
            
            if(oldmap.containsKey(lead.Id) && lead.OwnerId != oldmap.get(lead.Id).OwnerId && !lead.IsConverted)
            {
                
                auditTrail.Old_owner__c = (oldmap.get(lead.Id).OwnerId);
                auditTrail.New_owner__c = (lead.OwnerId);
                audittrail.Type__c = 'Owner';
                audittrail.Current_Stage__c = Lead.status;
            }
            if(oldmap.containsKey(lead.Id) && lead.Status != oldmap.get(lead.Id).Status && !lead.IsConverted)
            {
                auditTrail.Old_Status_Stage_value__c = oldmap.get(lead.Id).Status;
                auditTrail.New_Status_Stage_value__c = lead.Status;
                audittrail.Type__c = 'Status / Stage';
                audittrail.Current_Owner__c = (Lead.OwnerId);
            }
            
            lstAuditTrail.add(auditTrail);
        }
        try
            {
                if(lstAuditTrail.size() > 0)
                   database.upsert(lstAuditTrail,false);
            }
            catch(Exception e)
            {
                system.debug('****'+e);
            }
    }

    public void onLeadConversion(Map<Id, Lead> mapConvertedLead, Map<Id,Lead> oldmap){
        
        lstAuditTrail = [Select Id, Lead__c From Audit_Trail__c where Lead__c IN: mapConvertedLead.keySet()];
        
        for(Audit_Trail__c audit: lstAuditTrail)
        {
            if(mapConvertedLead.get(audit.Lead__c).ConvertedOpportunityId != null)
                audit.Opportunity__c = mapConvertedLead.get(audit.Lead__c).ConvertedOpportunityId;
        }
       
        for(Lead lead: mapConvertedLead.values()){
            Audit_Trail__c auditTrail = new Audit_Trail__c(Object__c = 'Lead',
                                                           Lead__c = lead.Id,
                                                           Date_Time_change_was_made__c = system.now());
           
            
            if(oldmap.containsKey(lead.Id) && lead.OwnerId != oldmap.get(lead.Id).OwnerId){
                auditTrail.Old_owner__c = (oldmap.get(lead.Id).OwnerId);
                auditTrail.New_owner__c = (lead.OwnerId);
            }
            else
            {
                auditTrail.Current_owner__c = (lead.OwnerId);
            }
            if(oldmap.containsKey(lead.Id) && lead.Status != oldmap.get(lead.Id).Status){
                   auditTrail.Old_Status_Stage_value__c = oldmap.get(lead.Id).Status;
                   auditTrail.New_Status_Stage_value__c = lead.Status;
            }
            else
            {
                  auditTrail.Current_Stage__c = lead.Status;
                
            }
            
            
            if(lead.IsConverted == true){
                    auditTrail.type__c = 'Convert';
                  
                if(lead.ConvertedOpportunityId != null)
                    auditTrail.Opportunity__c = lead.ConvertedOpportunityId;
            }
            
            lstAuditTrail.add(auditTrail);
        }
       
        try{
            if(lstAuditTrail.size() > 0)
             database.upsert(lstAuditTrail,false);
        }catch(Exception e){
            system.debug('****'+e);
        }
    }
}