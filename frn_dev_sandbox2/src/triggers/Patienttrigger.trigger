trigger Patienttrigger on Medical_Equipment__c (after undelete, after insert, after update, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(PatientHandler.class);
}