trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update) {
    if(Util.flag == true)
    TriggerFactory.createAndExecuteHandler(OpportunityHandler.class);
}