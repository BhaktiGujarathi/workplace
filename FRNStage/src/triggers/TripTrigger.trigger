trigger TripTrigger on Trip__c ( before insert, before update){
    TriggerFactory.createAndExecuteHandler(TripHandler.class);
}