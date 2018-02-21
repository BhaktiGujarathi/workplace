/* The Trigger to calculate the Roll-up of Receivalbes
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/03/2014                              Initial Draft
 */ 


trigger ReceivableTrigger on Receivable__c (after delete, after insert, after update) {
	
	ReceivableTriggerHandler receivableHandler = new ReceivableTriggerHandler(); 
	
	if(trigger.isAfter){
		
		if(trigger.isInsert){
			receivableHandler.OnAfterInsert(trigger.oldMap, trigger.new , trigger.newMap);
		} 
		
		if(trigger.isUpdate){
			receivableHandler.OnAfterUpdate(trigger.old, trigger.new , trigger.newMap,trigger.oldMap);
		} 
		
		if(trigger.isDelete){
			receivableHandler.OnAfterDelete(trigger.old, trigger.new , trigger.newMap,trigger.oldMap);
		}
	}

}