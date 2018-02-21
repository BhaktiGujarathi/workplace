/**
 * @description Trigger for McaApp__Receivable__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion
 *
 * @group Triggers
 *
 */
trigger ReceivableTrigger on McaApp__Receivable__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            ReceivableTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            ReceivableTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete) {
            ReceivableTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            ReceivableTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            ReceivableTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete) {
            ReceivableTriggerHandler.onAfterDelete(Trigger.old);
        }
        if(Trigger.isUndelete) {
            ReceivableTriggerHandler.onAfterUndelete(Trigger.new);
        }
    }
}