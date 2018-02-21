trigger UnderwriterAssignmentRuleEntryTrigger on Underwriter_Assignment_Rule_Entry__c (before insert, before update) {

	for (Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry : trigger.new) {

		if (!UnderwriterAssignmentRuleEntryValidator.checkForNulls(assignmentRuleEntry)) {
			
			if (!UnderwriterAssignmentRuleEntryValidator.checkOperator(assignmentRuleEntry)) {
			
				assignmentRuleEntry.addError('The operator you have selected is invalid for the field you have selected.');
			}
			else{
				
				UnderwriterAssignmentRuleEntryValidator.checkValue(assignmentRuleEntry);
			}
		}		
	}

}