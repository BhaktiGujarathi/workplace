trigger OfferTrigger on Offer__c (before insert, before update, after insert, after update, after delete) {
    OfferHandler objHandler = new OfferHandler();
    if(trigger.isBefore){
        if(trigger.isInsert){
            objHandler.onBeforeInsert(trigger.new);
            FutureClass.testCall();
        }else if(trigger.isUpdate){
            objHandler.onBeforeUpdate(trigger.new);
        }
    }if(trigger.isAfter){
        if(trigger.isInsert){
            objHandler.onAfterInsert(trigger.new);              
        }else if(trigger.isUpdate){
            objHandler.onAfterUpdate(trigger.new);
        }else if(trigger.isDelete){
            objHandler.onAfterDelete(trigger.old);
        }
    }
}