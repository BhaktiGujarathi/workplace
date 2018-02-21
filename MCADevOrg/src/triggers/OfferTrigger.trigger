trigger OfferTrigger on Offer__c (before insert, before update, after insert, after update, after delete, after undelete) {
    OfferHandler objHandler = new OfferHandler();
    if(trigger.isBefore){
        if(trigger.isInsert){
            objHandler.onBeforeInsert(trigger.newMap, trigger.new);
            //FutureClass.testCall();
        }else if(trigger.isUpdate){
            objHandler.onBeforeUpdate(trigger.new);
        }
    }if(trigger.isAfter){        
        //if record is Inserted fire the following trigger condition
        if(trigger.isInsert){
            objHandler.onAfterInsert(trigger.new);            
        }
        //if record is Updated fire the following trigger condition
        else if(trigger.isUpdate){
            objHandler.onAfterUpdate(trigger.new);            
        }
        //if record is Deleted fire the following trigger condition
        else if(trigger.isDelete){
            objHandler.onAfterDelete(trigger.old);
               
        }
        else if(trigger.isUndelete){
            objHandler.onAfterUndelete(trigger.new);
        }
    }
}