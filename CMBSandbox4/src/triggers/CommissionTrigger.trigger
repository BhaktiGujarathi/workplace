trigger CommissionTrigger on Commission__c (after delete, after insert, after update) {

    system.Debug('*******************Hi**********');
    if(Trigger.isAfter && checkRecursive.runOnceForAfter()) {
        if(Trigger.isInsert) {
           new CommissionTriggerHandler().onAfterInsert();
        }
        if(Trigger.isUpdate) {
            new CommissionTriggerHandler().onAfterUpdate();
        }
        if(Trigger.isDelete) {
            new CommissionTriggerHandler().onAfterDelete();
        }
    }

}