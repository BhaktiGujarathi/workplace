trigger CreditLineItemTrigger on Credit_Line_Item__c (after delete, after insert, after update, 
                                                                    before insert, before update) {
    if(trigger.isBefore) {
        if(trigger.isInsert ) {
            new CreditlineTriggerHandler().onBeforeInsert();
        }
        
        if(trigger.isUpdate && CheckRecursive.runOnceForBefore()) {
            new CreditlineTriggerHandler().onBeforeUpdate();
        }
    }
    if(trigger.isAfter) {
        if(trigger.isInsert && CheckRecursive.runOnceForAfter()) {
            new CreditlineTriggerHandler().onAfterInsert();
        }
        
        if(trigger.isUpdate && CheckRecursive.runOnceForAfter()) {
            new CreditlineTriggerHandler().onAfterUpdate();
        }
        
        if(trigger.isDelete && CheckRecursive.runOnceForAfter()) {
            new CreditlineTriggerHandler().onAfterDelete();
        }
    }
}