Public Class TaskHandlers
{
  
  public static void onAfterInsert()
  {
    
     filterCallLoggingTask();
    
  }
  
  public static void onAfterUpdate()
  {
    
     filterCallLoggingTask();
   
  }
   
  
  
    
  public static void filterCallLoggingTask()
  {
     List<Task> lstOfCompletedTask = new  List<Task>();
     List<Task> lstOfNotCompletedTask = new List<Task>();
     Set<ID> OppIDs = new  Set<ID>();
     Map<Id, Opportunity > oppsMap;
     date mydate = date.today();
     
     for(Task nTask : (List<Task>)trigger.new)
     {
     
           if(nTask.whatId != null)
           {
                                         
                        if(((String)nTask.whatId).substring(0,3) =='006')
                        {
                             if(nTask.status <> 'Completed')
                             {
                               lstOfNotCompletedTask.add(nTask);
                             }
                             else if(nTask.status == 'Completed')
                             {
                               lstOfCompletedTask.add(nTask);
                             }
                             
                             OppIDs.add(nTask.whatId);
    
                        }
            }
                
            
     }
     
     
    
      oppsMap = new Map<Id, Opportunity >([select id,
                                                  Last_Activity_Comments__c,
                                                  Last_Activity_Date_Time__c,
                                                  Last_Activity_Type__c,
                                                  Last_Activity_Stage__c,
                                                  Activities_in_Current_Stage__c,
                                                  Last_Activity_User__c,
                                                  Next_Activity_Type__c,
                                                  Next_Activity_Assigned_To__c,
                                                  Next_Activity_Comments__c,
                                                  Next_Activity_Date__c,
                                                  stagename,
                                                        (select id,
                                                                subject,
                                                                Activity_Type__c,
                                                                Description,
                                                                OwnerID,
                                                                ActivityDate 
                                                        from tasks 
                                                        where status!=null 
                                                        and status != 'Completed'
                                                        and ActivityDate != Null
                                                       /* and (activityDate >=: mydate) */
                                                        order by ActivityDate,CreatedDate ASC /*NULLS LAST*/) 
                                                  from Opportunity 
                                                  where id in : OppIDs]);
                                                  
                                                  
         
     if(lstOfNotCompletedTask!= NULL && lstOfNotCompletedTask.size() > 0)
     {
       CallLoggingService.processNotCompletedTask(lstOfNotCompletedTask,oppsMap);
     }
     
     if(lstOfCompletedTask != NULL && lstOfCompletedTask.size() > 0)
     {
       CallLoggingService.processCompletedTask(lstOfCompletedTask,oppsMap);
     }
     
  }
  
  
}