trigger UnderwriterAssignmentRuleTrigger on Underwriter_Assignment_Rule__c (before insert, before update) {
	
	UnderwriterSortOrderTriggerHandler handler = new UnderwriterSortOrderTriggerHandler();

    if (UnderwriterSortOrderTriggerHandler.runOnce()) {

        handler.reorder(trigger.new, Trigger.oldMap, trigger.isInsert);
    }
}