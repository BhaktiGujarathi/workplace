trigger InvoiceTrigger on Invoice__c (after insert, before delete, after update, after delete){

    InvoiceHandler objHandler = new InvoiceHandler();

    if(trigger.isBefore && trigger.isDelete){
        objHandler.onBeforeDelete(trigger.oldMap);
    }else if(trigger.isAfter){
        if(trigger.isUpdate && checkRecursive.runOnceForAfter()){
            objHandler.onAfterUpdate(trigger.oldMap,trigger.new);
             new InvoiceTriggerHandler().onafterUpdate();
        }
        else if(trigger.isInsert && checkRecursive.runOnceForAfter()){
            new InvoiceTriggerHandler().onafterInsert();
        }
        else if(trigger.isDelete && checkRecursive.runOnceForAfter()){
            new InvoiceTriggerHandler().onafterDelete();
        }
    }
}