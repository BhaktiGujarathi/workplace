/**************************************************************************************************
* Name               : ServiceRequestTrigger                                                      *
* Description        : This is a trigger on Service Request object.                               *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Vineet      12/01/2017                                                              *
**************************************************************************************************/
trigger ServiceRequestTrigger on NSIBPM__Service_Request__c (before insert, before update, after insert, after update) {
  //  TriggerFactoryCls.createHandler(NSIBPM__Service_Request__c.sObjectType);
}// End of trigger