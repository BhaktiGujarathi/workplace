global class OpportunityOnInsertFutureClass
{
    
    
    @future
    public static void onAfterInsertFutureCall(Set<ID> sOfOppID)
    {
        
        Map<String,Opportunity> mapOfIdOpp = new Map<String,Opportunity>();
        Map<ID,String> mapOfNewOppIDLeadID = new Map<ID,String>();
        Map<ID,ID> mapOfLeadIDLeadOwnerID = new Map<ID,ID>();
        List<Opportunity> lOfOppID = new  List<Opportunity>();
        
        lOfOppID  = [select id,Lead_ID__c,ownerId,StageName,LastModifiedDate from opportunity where id IN: sOfOppID];
        
        if(lOfOppID != null && lOfOppID.size() > 0)
        {
            
            
           
            for(Opportunity newOpp: lOfOppID){
                
                mapOfIdOpp.put(newOpp.id,newOpp);
                if(!String.isBlank(newOpp.Lead_ID__c))
                {
                    mapOfNewOppIDLeadID.put(newOpp.id,newOpp.Lead_ID__c);
                }
                
            }
            
            for(Lead tempLead : [Select id,ownerID from Lead where id IN : mapOfNewOppIDLeadID.values()])
            {
                
                mapOfLeadIDLeadOwnerID.put(tempLead.id,tempLead.ownerID);
                
            }
            
            
            //Checking whether the oppertunity is created manually or by lead convert.
            List<Audit_Trail__c> lAuditTrail = new  List<Audit_Trail__c>();
            for(Opportunity newOpp: lOfOppID )
            {
                
                
               Audit_Trail__c tempAuditTrail = new Audit_Trail__c(New_owner__c = newOpp.ownerId,
                                                                   New_Status_Stage_value__c = newOpp.StageName,
                                                                   Opportunity__c = newOpp.Id,
                                                                   Object__c = 'Opportunity',
                                                                   Date_Time_change_was_made__c = newOpp.LastModifiedDate,
                                                                   Type__c = 'Create');
                
                if(!String.isBlank(newOpp.Lead_ID__c))
                {
                   if(newOpp.ownerId != mapOfLeadIDLeadOwnerID.get(newOpp.Lead_ID__c))
                   {
                    tempAuditTrail.old_owner__c = mapOfLeadIDLeadOwnerID.get(newOpp.Lead_ID__c);
                   } 
                }
                                                        
             
                
                
                lAuditTrail.add(tempAuditTrail);
                
            }
            
            
            
            try
            {  
               // insert lAuditTrail;
                database.insert(lAuditTrail,false);
                
            }
            catch(Exception ex)
            {
                system.debug('$$$$$ Exception in auditTrailCreationAfterInsertLead'+ex);
            }
            
            
        }
    }
}