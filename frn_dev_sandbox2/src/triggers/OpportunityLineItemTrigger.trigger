trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert) {
	if(Util.flag == true)
    TriggerFactory.createAndExecuteHandler(OpportunityLineItemHandler.class);
}