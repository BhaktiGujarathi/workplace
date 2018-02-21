trigger StipsTrigger on Stips__c (after delete, after insert, after update) {
	
	StipsHandler objHandler = new StipsHandler();
	if(trigger.isAfter){
		if(trigger.isInsert){
			objHandler.onAfterInsert(trigger.new);
		}
		
	}
}