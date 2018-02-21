/**************************************************************************************************
* Name               : CommissionTrigger                                                          *
* Description        : This is a trigger on Agent_Commission__c object.                           *
* Created Date       : 22/02/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         22/02/2017                                                              *
**************************************************************************************************/
trigger CommissionTrigger on Agent_Commission__c (before insert, before update) {
	TriggerFactoryCls.createHandler(Agent_Commission__c.sObjectType);    
}// End of trigger.