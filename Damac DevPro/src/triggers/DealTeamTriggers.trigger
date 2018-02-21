/**************************************************************************************************
* Name               : DealTeamTriggers                                                           *
* Description        : This is a trigger on Deal Team object.                                     *
*                      Has the below function:                                                    *
*					   - Include HOS and DOS to the deal team.                                    *
* *					   - Sharing deal to the newly added HOS and DOS.                             *
* Created Date       : 01/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         01/04/2017 
**************************************************************************************************/
trigger DealTeamTriggers on Deal_Team__c (before insert, before update, after insert, after update ) {
    TriggerFactoryCls.createHandler(Deal_Team__c.sObjectType);
}// End of trigger