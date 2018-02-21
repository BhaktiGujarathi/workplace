/**************************************************************************************************
* Name               : OptionTrigger 
* Description        : 
* Created Date       : 05/07/2017                                                                 
* Created By         : Naresh Kaneriya ( Accely )                                                      
**************************************************************************************************/
trigger OptionTrigger on Option__c (after update) {

 OptionTriggerHandler obj =  new OptionTriggerHandler();

   if(Trigger.isAfter){
       if(Trigger.isUpdate){
          obj.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
     }
  }