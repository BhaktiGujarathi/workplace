/**************************************************************************************************
* Name               : UserTrigger                                                                *
* Description        : This is a trigger on user object.                                          *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE                                                              *
* 1.0         NSI - Vineet      17/01/2017                                                        *
**************************************************************************************************/
trigger UserTrigger on User (after insert, after update, before insert, before update) {
    if(DAMAC_Constants.userExtForBreak.isEmpty() && DAMAC_Constants.userExtForBreak.size() == 0)
    	TriggerFactoryCls.createHandler(User.sObjectType);         
}// End of trigger.