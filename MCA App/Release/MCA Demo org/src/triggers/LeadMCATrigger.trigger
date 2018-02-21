trigger LeadMCATrigger on Lead (after update, before insert) {
    
    LeadHandler objHandler = new LeadHandler();
    
    if(trigger.isAfter && trigger.isUpdate){
        objHandler.onAfterUpdate(trigger.oldMap, trigger.new);
    }
     
}