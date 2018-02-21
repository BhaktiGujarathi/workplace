/**************************************************************************************************
* Name               : AssignedPcTrigger                                                          *
* Description        : This is a Assigned PC junction object.                                     *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         17/01/2017                                                              *
**************************************************************************************************/
trigger AssignedPcTrigger on Assigned_PC__c (after delete, after insert, after update) {
	TriggerFactoryCls.createHandler(Assigned_PC__c.sObjectType);        
}// End of trigger