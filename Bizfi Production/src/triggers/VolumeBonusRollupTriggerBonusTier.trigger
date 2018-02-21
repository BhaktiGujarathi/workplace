trigger VolumeBonusRollupTriggerBonusTier on Volume_Bonus_Tier__c (after insert, after update, after delete, after undelete) {

	Volume_Bonus_Tier__c[] bonuses;

	if (Trigger.new != null) {

		bonuses = Trigger.new;
	}
	else if (Trigger.old != null) {
		
		bonuses = Trigger.old;
	}


	if (bonuses != null) {
		
		Set<Id> accountIds = new Set<Id>();

		for (Volume_Bonus_Tier__c bonus : bonuses) {

			if (bonus.Bank__c != null) {

				accountIds.add(bonus.Bank__c);
			}
		}		


		if (!accountIds.isEmpty()) {

			Database.executeBatch(new VolumeBonusRollUpHandlerBatch(accountIds), 1);
		}
	}
}