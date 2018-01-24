/* The Trigger to update 'Activity Count' Field on Lead and Opportunity Object. 
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Ajay Singh Solanki                       17/06/2013                              Initial Draft
 * 1.1             Ajay Singh Solanki                       03/04/2014                              Added functionality for maintaining Activity count 
 * 1.2             Neena Tiwari                             24/06/2014                              Calling a task handler class after insert of Task                                                                  for Opportunity.
 */ 
trigger TaskTrigger on Task (before delete, before insert, before update, after insert) {
  
  ActivityCountHandler activityCountHandler = new ActivityCountHandler();
  ActivityCountHandlerForOpportunity oppActivityCountHandler = new ActivityCountHandlerForOpportunity();
  
  if(trigger.isBefore && trigger.isInsert){
    //The method will increase the Activity Count related to a Lead.
    activityCountHandler.onTaskInsertIncreaseActivityCount(trigger.new);
    
    //V1.1
    //The method will increase the Activity Count related to an Opportunity. 
    oppActivityCountHandler.onTaskInsertIncreaseActivityCount(trigger.new);
    //This method will update the stage of Opportunity when appication sent via conga
    oppActivityCountHandler.onTaskInsertUpdateOpportunityStage(trigger.new);
  }//End if.
   
  if(trigger.isBefore && trigger.isUpdate){
    //The method will increase or decrease the Activity Count related to a Lead.
    activityCountHandler.onEditTaskIncreaseOrDecreaseActivityCount(trigger.new, trigger.old);
  }//End if.
  
  if(trigger.isBefore && trigger.isDelete){
    //The method will decrease the Activity Count related to a Lead.
    activityCountHandler.OnTaskDeleteDecreaseActivityCount(trigger.old);
        
    //V1.1
    //The method will decrease the Activity Count related to an Opportunity.
    oppActivityCountHandler.OnTaskDeleteDecreaseActivityCount(trigger.old);
    
  }//End if.
  
  if(trigger.isAfter){
      
    if(trigger.isInsert){
        //Version 1.2
        TaskHandler handler =  new TaskHandler();
        activityCountHandler.updateOffers(trigger.new); 
        //Version 1.2
        
        handler.onAfterInsertTask(trigger.newmap);  
         //V1.1
      //The method will increase the Activity Count related to an Opportunity. 
        oppActivityCountHandler.onTaskInsertIncreaseActivityCount(trigger.new);
    }   
  }
}//End TaskTrigger.