/* The Trigger to update 'Activity Count' Field on Lead and Opportunity Object. 
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Ajay Singh Solanki                       18/06/2013                              Initial Draft
 * 1.1             Ajay Singh Solanki                       03/04/2014                              Added functionality for maintaining Activity count 
 *                                                                                                  for Opportunity.
 */

trigger EventTrigger on Event (before delete, before insert, before update) {
  
  ActivityCountHandler activityCountHandler = new ActivityCountHandler();
  ActivityCountHandlerForOpportunity oppActivityCountHandler = new ActivityCountHandlerForOpportunity();
  
  if(trigger.isBefore && trigger.isInsert){
    
    //The method will increase the Activity Count related to a Lead.
    activityCountHandler.onEventInsertIncreaseActivityCount(trigger.new);
    
    //The method will increase the Activity Count related to an Opportunity. 
    oppActivityCountHandler.onEventInsertIncreaseActivityCount(trigger.new);
  }//End if.
  
  if(trigger.isBefore && trigger.isUpdate){
   
    //The method will increase or decrease the Activity Count related to a Lead.
     activityCountHandler.onEditEventIncreaseOrDecreaseActivityCount(trigger.new, trigger.old);
  }//End if.
  
  
  if(trigger.isBefore && trigger.isDelete){
    
    //The method will decrease the Activity Count related to a Lead.
    activityCountHandler.OnEventDeleteDecreaseActivityCount(trigger.old);
    
    //The method will decrease the Activity Count related to an Opportunity.
    oppActivityCountHandler.OnEventDeleteDecreaseActivityCount(trigger.old);
  }//End if.
  
}//End EventTrigger.