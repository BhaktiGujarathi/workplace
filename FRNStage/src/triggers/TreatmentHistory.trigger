trigger TreatmentHistory on Treatment_History__c (before insert,before update,after insert,after update,after delete) {
    TriggerFactory.createAndExecuteHandler(PsyTreatmentHistoryHandler.class);
}