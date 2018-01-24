Public Class CallLoggingService
{
  public static void processNotCompletedTask(List<Task> lstOfNotCompletedTask, Map<Id,Opportunity> oppsMap)
  {
        Map<Id,Opportunity> mapOpportunityToUpdate = new Map<Id,Opportunity>();
         
         for(Task notCompletedTask :lstOfNotCompletedTask)
         {
           Opportunity opp = oppsMap.get(notCompletedTask.whatID == null? '': notCompletedTask.whatID);
           if(opp.Tasks != null  && opp.Tasks.size() > 0)
           {
               opp = setOppNextFields(opp,opp.Tasks[0].Activity_Type__c,
                                      opp.Tasks[0].OwnerID,
                                      opp.Tasks[0].ActivityDate,
                                      opp.Tasks[0].Description);         
           }
           mapOpportunityToUpdate.put(opp.Id,opp);
           
         }       
        
           update mapOpportunityToUpdate.values();
  }
  
  public static void processCompletedTask(List<Task> lstOfCompletedTask, Map<Id,Opportunity> oppsMap)
  {
         Map<Id,Opportunity> mapOpportunityToUpdate = new Map<Id,Opportunity>();
         for(Task completedTask : lstOfCompletedTask)
         {
               Opportunity opp = oppsMap.get(completedTask.whatID == null? '': completedTask.whatID);
               Datetime ActivityDate = system.now();                 
               opp = setOppLastFields(opp,completedTask.Activity_Type__c,
                                      opp.stagename,
                                      ActivityDate,
                                      completedTask.OwnerId,
                                      completedTask.Description);      
               
              
               if(opp.Tasks != null && opp.Tasks.size() > 0)
               {
                   opp = setOppNextFields(opp,opp.Tasks[0].Activity_Type__c,
                                          opp.Tasks[0].OwnerID,
                                          opp.Tasks[0].ActivityDate,
                                          opp.Tasks[0].Description);
                   
               }
               else
               {
                   opp = setOppNextFields(opp,null,null,null,null);
               
               }
               
            if(opp.Activities_in_Current_Stage__c != Null)
            {   
               opp.Activities_in_Current_Stage__c = opp.Activities_in_Current_Stage__c + 1;
            }
            else
            {
              opp.Activities_in_Current_Stage__c = 1;
            }       
               
           mapOpportunityToUpdate.put(opp.Id,opp);
         }        
           update mapOpportunityToUpdate.values();
  }
  
  public static Opportunity setOppNextFields(Opportunity oppObj,
                                             String ActivityType,
                                             String OwnerId,
                                             Date ActivityDate,
                                             String Description)
  {
        oppObj.Next_Activity_Type__c = ActivityType;
        oppObj.Next_Activity_Assigned_To__c = OwnerID;
        oppObj.Next_Activity_Date__c = ActivityDate;
        oppObj.Next_Activity_Comments__c= getActivityComment(Description);
        return oppObj;
  }
  
  public static Opportunity setOppLastFields(Opportunity oppObj,
                                             String ActivityType,
                                             String stageName,
                                             Datetime ActivityDateTime,
                                             String ActivityUser,
                                             String ActivityComment)
  {
        oppObj.Last_Activity_Type__c = ActivityType;
        oppObj.Last_Activity_Stage__c = stageName;
        oppObj.Last_Activity_Date_Time__c= ActivityDateTime;
        oppObj.Last_Activity_User__c = ActivityUser;
        oppObj.Last_Activity_Comments__c = getActivityComment(ActivityComment);
        return oppObj;
  }
  
  public static String getActivityComment(String activityComment) {
      if(String.isNotBlank(activityComment) && activityComment.length() >= 255) {
          Integer trimMsgLen = Label.Activity_Comment_trimmed_message.length();
          activityComment = activityComment.left(255 - (trimMsgLen + 1)) + Label.Activity_Comment_trimmed_message;
      }
      return activityComment;
  }
}