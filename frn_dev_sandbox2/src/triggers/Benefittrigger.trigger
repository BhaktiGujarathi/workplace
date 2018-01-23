trigger Benefittrigger on Insurance_Benefit__c (after undelete, after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(BenefitHandler.class);

}