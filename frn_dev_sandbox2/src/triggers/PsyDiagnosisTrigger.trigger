trigger PsyDiagnosisTrigger on Psychiatric_Diagnosis__c (before insert,before update,before delete,after insert, after update) {
    TriggerFactory.createAndExecuteHandler(PsyDiagnosisHandler.class);
}