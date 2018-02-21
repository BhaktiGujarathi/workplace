trigger StipsTrigger on Stips__c (after delete, after insert, after update, before delete, after unDelete) {
    
    StipsHandler objHandler = new StipsHandler();
    if(trigger.isAfter){
        if(trigger.isInsert){
            objHandler.onAfterInsert(trigger.new);
        }
        else if(trigger.isUpdate){
            objHandler.onAfterUpdate(trigger.new);
        }
        else if(trigger.isUnDelete ){
            objHandler.onAfterUndelete(trigger.new);
        }
        else if(trigger.isDelete) {
            objHandler.onAfterDelete(trigger.old);
        }
        /*if(trigger.isDelete) {
            System.debug('---Into trigger--->');
            objHandler.onAfterDelete();
        }*/
        
    }
    /*if(trigger.isBefore) {
        if(trigger.isDelete) {
            objHandler.onBeforeDelete();
        }
    }*/
}