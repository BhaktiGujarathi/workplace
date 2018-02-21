trigger TransactionLineDebitTrigger on Transaction_Line_Debit__c (after delete) {
	
	TansactionLineDebitHandler objHandler = new TansactionLineDebitHandler();
	if(trigger.isAfter && trigger.isDelete){
		objHandler.onAfterDelete(trigger.old);
	}
}