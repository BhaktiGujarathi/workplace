trigger LeadMCATrigger on Lead (after update, before insert, before update) {

    LeadHandler objHandler = new LeadHandler();

    if(trigger.isAfter && trigger.isUpdate){
       objHandler.onAfterUpdate(trigger.oldMap, trigger.new);
    }

    if(trigger.isBefore) {
        if(trigger.isInsert) {
            objHandler.onBeforeInsert();
        }
        
        if(trigger.isUpdate) {
            objHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
        }
    }
}