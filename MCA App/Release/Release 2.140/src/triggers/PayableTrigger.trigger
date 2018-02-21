/* The Trigger to calculate the Roll-up of Payables
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/04/2014                              Initial Draft
 */ 


trigger PayableTrigger on Payable__c (after delete, after insert, after update) {
	
	PayableTriggerHandler PayableHandler = new PayableTriggerHandler(); 
	
	if(trigger.isAfter){
		
		if(trigger.isInsert){
			PayableHandler.OnAfterInsert(trigger.oldMap, trigger.new);
		}
		
		if(trigger.isUpdate){
			PayableHandler.OnAfterUpdate(trigger.old, trigger.new);
		} 
		
		if(trigger.isDelete){
			PayableHandler.OnAfterDelete(trigger.old, trigger.new);
		}
	}

}