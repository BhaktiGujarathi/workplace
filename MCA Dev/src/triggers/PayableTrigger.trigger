/* The Trigger to calculate the Roll-up of Payables
 *
 *
 * Revision History:
 *
 * Version     Author                   Date(mm/dd/yyyy)    Description
 * 1.0         Nachiket R. Deshpande    11/04/2014          Initial Draft
 * 2.0         Ajinkya Hingne           01/06/2017          Added after undelete event for rollup
 */


trigger PayableTrigger on Payable__c (after delete, after insert, after update, after undelete) {

    PayableTriggerHandler PayableHandler = new PayableTriggerHandler();

    if(trigger.isAfter){

        if(trigger.isInsert){
            PayableHandler.OnAfterInsert(trigger.oldMap, trigger.new);
        }

        if(trigger.isUpdate){
            PayableHandler.OnAfterUpdate(trigger.old, trigger.new);
        }

        if(trigger.isDelete){
            PayableHandler.OnAfterDelete(trigger.old, trigger.new);
        }

        if(trigger.isUndelete) {
            PayableHandler.onAfterUndelete(trigger.old, trigger.new);
        }
    }

}