/**************************************************************************************************
* Name               : OptionTriggerHandler
* Description        : Trigger Handler Class for Option Onject
* Created Date       : 07/07/2017                                                                 
* Created By         : Naresh Kaneriya (Accely)                                                     
**************************************************************************************************/

public class OptionTriggerHandler{

public void afterUpdate(Map<Id, Option__c> newOption , Map<Id,Option__c> OldOption){
  
  AsyncOptionWebserviceHandler.AfterUpdate(newOption,OldOption);

} 

}