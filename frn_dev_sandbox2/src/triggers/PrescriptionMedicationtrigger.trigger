trigger PrescriptionMedicationtrigger on Prescription_Medication__c (after undelete, after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(PrescriptionMedicationHandler.class);
}