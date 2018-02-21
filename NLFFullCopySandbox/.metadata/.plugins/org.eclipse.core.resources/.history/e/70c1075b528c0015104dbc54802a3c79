public Class LeadAuditOnInsert 
{


 public void auditTrailCreationAfterInsertLead()
 {
     List<Audit_Trail__c> lAuditTrail = new  List<Audit_Trail__c>();
      for(Lead newLead:(List<Lead>)trigger.new)
      {
         
         Audit_Trail__c tempAuditTrail = new Audit_Trail__c(New_owner__c = newLead.ownerId,
                                                            New_Status_Stage_value__c = newLead.status,
                                                            Lead__c = newLead.Id,
                                                            Object__c = 'Lead',
                                                            Date_Time_change_was_made__c = newLead.LastModifiedDate,
                                                            Type__c = 'Create');
         
           
         lAuditTrail.add(tempAuditTrail);
      }
       
      try
      {
         database.insert(lAuditTrail,false);
      }
      catch(Exception ex)
      {
         system.debug('$$$$$ Exception in auditTrailCreationAfterInsertLead'+ex);
      }
 }



}