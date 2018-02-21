/**************************************************************************************************
* Name               : AccountTrigger                                                             *
* Description        : This is a trigger on account object.                                       *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Vineet      12/01/2017                                                              *
**************************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    TriggerFactoryCls.createHandler(Account.sObjectType);
    
    if( trigger.isBefore ) {
        if( trigger.isInsert ) {
            CreAllocationHandler.allocateCreToCustomer( trigger.new, trigger.oldMap );
        }
        if( trigger.isUpdate ) {
            system.debug('== Account Trigger Called ==');
            CreAllocationHandler.allocateCreToCustomer( trigger.new, trigger.oldMap );
        }
    }
    else if( trigger.isAfter ) {
    }
}// End of trigger