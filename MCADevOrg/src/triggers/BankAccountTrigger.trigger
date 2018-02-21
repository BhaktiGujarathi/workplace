trigger BankAccountTrigger on Bank_Account__c (before insert, before update, after delete, after insert, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert && CheckRecursive.runOnceForBefore()){
            new BankAccountHandler().onBeforeInsert();
        }else if(trigger.isUpdate && CheckRecursive.runOnceForBefore()){
            new BankAccountHandler().onBeforeUpdate();
        }
    }
    // after trigger
    else if(trigger.isAfter){
         if(trigger.isInsert && CheckRecursive.runOnceForAfter()){
            new BankAccountHandler().onAfterInsert();   
        }else if(trigger.isUpdate && CheckRecursive.runOnceForAfter()){
            new BankAccountHandler().onAfterUpdate();
        }else if(trigger.isDelete && CheckRecursive.runOnceForAfter()){
            new BankAccountHandler().onAfterDelete();
        }else if(trigger.isUndelete && CheckRecursive.runOnceForAfter()) {
            new BankAccountHandler().onAfterUndelete();
        }
    }
}