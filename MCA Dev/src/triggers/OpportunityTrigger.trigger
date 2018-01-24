trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {


    if(![select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OpportunityTrigger'].IsActivate__c){
        return;
    }

    OpportunityHandler handler = new OpportunityHandler();
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            handler.OnAfterInsert(trigger.oldMap, trigger.new);
        }
        if(trigger.isUpdate) {
            handler.onAfterUpdate(trigger.oldMap, trigger.New);
        }
    }

    if(trigger.isBefore && CheckRecursive.runOnceForBefore()){
       if(trigger.isInsert) {
           handler.onBeforeInsert();
       }
       if(trigger.isUpdate) {
           handler.onBeforeUpdate();
       }
    }
    /*if(Trigger.isAfter && Trigger.isUpdate){
        controller.onAfterUpdate(trigger.oldMap, trigger.New);
    }*/
}