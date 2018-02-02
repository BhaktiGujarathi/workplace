trigger medicalprobHandlertrigger on Medical_Problem_Symptom__c (after undelete, after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(medicalprobHandler.class);
}