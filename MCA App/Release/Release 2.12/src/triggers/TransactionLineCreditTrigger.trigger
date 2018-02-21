trigger TransactionLineCreditTrigger on Transaction_Line_Credit__c (after delete) {

	TransactionLineCreditHandler objHandler = new TransactionLineCreditHandler();
	if(trigger.isAfter && trigger.isDelete){
		objHandler.onAfterDelete(trigger.old);	
	}
}