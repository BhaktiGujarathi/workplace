trigger Documenttrigger on Document__c (before insert, before update) {
    TriggerFactory.createAndExecuteHandler(Documenthandler.class);
}