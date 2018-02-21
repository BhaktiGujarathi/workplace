public class ATAfterInsertTaskHandler
{
    
    public List< Audit_Trail__c> lAuditTrail;
    
    public ATAfterInsertTaskHandler()
    {
        lAuditTrail = new List< Audit_Trail__c>();
    }
    
    public void afterInsertOfCallTask()
    { 
        Audit_Trail__c callTrackAudtr;
        for(Task  newTask :(List<Task>)trigger.new)
        {
            
            if(newTask.CallType == 'Outbound'
               && newTask.Type == 'Call')
            {
                    callTrackAudtr = basicAuditTrailInfo(newTask);
                    if(newTask.WhatId != null && ((String)newTask.WhatId).startsWithIgnoreCase('006'))
                    {
                           callTrackAudtr.opportunity__c = newTask.WhatId;
                    }
                    else if(newTask.WhoId != null && ((String)newTask.WhoId).startsWithIgnoreCase('00Q'))
                    {
                           callTrackAudtr.Lead__c = newTask.WhoId;
                          
                    }
            
                
                callTrackAudtr.Type__c = 'Outbound Call';
                callTrackAudtr.Current_Owner__c = newTask.OwnerID;
                
                lAuditTrail.add(callTrackAudtr);
            }
        }
        
        try
        {
            if(lAuditTrail != null && lAuditTrail.size() > 0)
            {  
                database.insert(lAuditTrail,false);
            }
        }
        catch(Exception Ex)
        {
            system.debug('@@@@ ATAfterInsertTaskHandler.afterInsertOfCallTask'+ex);
        }
        
    }
    
    public Audit_Trail__c basicAuditTrailInfo(Task  newTask)
    {
        return new Audit_Trail__c(Object__c = 'Task',
                                  Date_Time_change_was_made__c = newTask.LastModifiedDate);
        
    }
    
    
}