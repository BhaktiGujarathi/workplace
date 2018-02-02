trigger ReservationTrigger on Reservation__c (after insert,after update,after delete,after undelete) {
    TriggerFactory.createAndExecuteHandler(ReservationHandler.class);
}