trigger StipsTrigger on Stips__c (after delete, after insert, after update, before delete) {
	
	StipsHandler objHandler = new StipsHandler();
	if(trigger.isAfter){
		if(trigger.isInsert){
			objHandler.onAfterInsert(trigger.new);
		}
		
		/*if(trigger.isDelete) {
		    System.debug('---Into trigger--->');
		    objHandler.onAfterDelete();
		}*/
		
	}
	if(trigger.isBefore) {
	    if(trigger.isDelete) {
            objHandler.onBeforeDelete();
        }
	}
}