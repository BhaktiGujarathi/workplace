trigger ScorecardsTrigger on Sales_Rep_Report_Card__c (after update,after insert, after delete) {

	if(trigger.isInsert || trigger.isUpdate){
		UpdateUsersForScorecards.updateUsers(trigger.new, false);
	}else{
		UpdateUsersForScorecards.updateUsers(trigger.old, true);
	}

}