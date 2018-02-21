trigger BankAccountTrigger on Bank_Account__c (before insert, before update, after delete, after insert, after update) {

	BankAccountHandler objHandler = new BankAccountHandler();
	
	if(trigger.isBefore){
		if(trigger.isInsert){
			objHandler.onBeforeInsert(trigger.new);
		}else if(trigger.isUpdate){
			objHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
		}
	}
	else if(trigger.isAfter){
		if(trigger.isInsert){
			objHandler.onAfterInsert(trigger.new);	
		}else if(trigger.isUpdate){
			objHandler.onAfterUpdate(trigger.oldMap, trigger.new);
		}else if(trigger.isDelete){
			objHandler.onAfterDelete(trigger.old);
		}
	}
}