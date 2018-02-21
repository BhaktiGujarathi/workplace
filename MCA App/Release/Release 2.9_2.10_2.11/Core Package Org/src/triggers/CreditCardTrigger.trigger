/**
 *
 * Description :
 *  1.Trigger to make call to the handler methods on respective events.
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0
 *
 *    1.1      Ashwini Singh          27/10/2015            To update the average fields on account
 *                                                         in correspondence to the associated credit
 *                                                         card records.
 *
 **/
trigger CreditCardTrigger on Credit_Card__c (before insert, before update, after delete, after insert, after update, after undelete) {
    CreditCardHandler objHandler = new CreditCardHandler();
    
    if(trigger.isBefore){
        if(trigger.isInsert && CheckRecursive.runOnceForBefore()){
            new CreditCardHandler().onBeforeInsert();
        }else if(trigger.isUpdate && CheckRecursive.runOnceForBefore()){
            new CreditCardHandler().onBeforeUpdate();
        }
    }
    else if(trigger.isAfter){
        if(trigger.isInsert && CheckRecursive.runOnceForAfter()){
            new CreditCardHandler().onAfterInsert();
        }else if(trigger.isUpdate && CheckRecursive.runOnceForAfter()){
            new CreditCardHandler().onAfterUpdate();
        }else if(trigger.isDelete && CheckRecursive.runOnceForAfter()){
            new CreditCardHandler().onAfterDelete();
        }else if(trigger.isUndelete && CheckRecursive.runOnceForAfter()) {
            new CreditCardHandler().onAfterUndelete();
        }
    }
}