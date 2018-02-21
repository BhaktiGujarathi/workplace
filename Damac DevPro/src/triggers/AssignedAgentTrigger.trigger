/**************************************************************************************************
* Name               : AssignedAgentTrigger                                                       *
* Description        : This is a Assigned Agent junction object.                                  *
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *   
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.                                    *
**************************************************************************************************/
trigger AssignedAgentTrigger on Assigned_Agent__c (before insert,before update,before delete,after delete, after insert, after update) {
	TriggerFactoryCls.createHandler(Assigned_Agent__c.sObjectType);        
}// End of trigger