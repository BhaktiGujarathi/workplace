trigger ContactTrigger on Contact (after update) {

	if((SingleTriggerRun.contactTrigger || Test.isRunningTest())
		&& !System.isBatch() && !System.isFuture()) {
        SingleTriggerRun.contactTrigger = false;
		ExperianContactCallout.idList(Trigger.newMap, Trigger.oldMap);
	}
	
}