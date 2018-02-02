trigger PatientInsuranceTrigger on Patient_Insurance__c (before insert,before update) {
    TriggerFactory.createAndExecuteHandler(PatientInsuranceHandler.class); 
}