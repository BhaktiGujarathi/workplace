trigger LineItemTrigger on Line_Item__c (before insert,before update, after insert,after update,before delete,after delete) {
    
    LineItemHandler objHandler = new LineItemHandler();
    InvoiceLineItemHandler invoiceLineItmHandler = new InvoiceLineItemHandler();
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            objHandler.onBeforeInsert(trigger.new);
        }           
        else if(trigger.isUpdate){
            objHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
            
        }
        else if(trigger.isDelete){
            objHandler.onBeforeDelete(trigger.oldMap);            
        }           
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            objHandler.onAFterInsert(trigger.newMap);
            invoiceLineItmHandler.onAfterInsert(trigger.new);
        }
        else if(trigger.isUpdate){
            objHandler.onAfterUpdate(trigger.newMap);
            invoiceLineItmHandler.onAfterUpdate(trigger.new);   
        }
        else if(trigger.isDelete){
            invoiceLineItmHandler.onAfterDelete(trigger.old);   
        }
    }
}