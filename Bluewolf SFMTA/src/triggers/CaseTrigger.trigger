trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
    	CaseService.validateBusinessHours(Trigger.New);
    }
    else if(Trigger.isAfter) {
        if(Trigger.isInsert)
            CaseTriggerHandler.handleAfterInsert(trigger.new);
        else if(Trigger.isUpdate)
             CaseTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
    }
}