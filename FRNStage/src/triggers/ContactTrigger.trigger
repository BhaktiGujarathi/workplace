trigger ContactTrigger on Contact (after update) {
	TriggerFactory.createAndExecuteHandler(ContactHandler.class);
}