trigger VolumeBonusRollupTriggerOffer on McaApp__Offer__c (after insert, after update, after delete, after undelete) {

	McaApp__Offer__c[] offers;

	if (Trigger.new != null) {

		offers = Trigger.new;
	}
	else if (Trigger.old != null) {
		
		offers = Trigger.old;
	}


	if (offers != null) {

		Set<Id> opportunityIds = new Set<Id>();

		for (McaApp__Offer__c offer : offers) {

			if (offer.McaApp__Opportunity__c != null) {

				opportunityIds.add(offer.McaApp__Opportunity__c);
			}
		}

		
		Set<Id> accountIds = new Set<Id>();

		for (Opportunity opp : [select McaApp__Bank_Name__c from Opportunity where Id in :opportunityIds]) {

			if (opp.McaApp__Bank_Name__c != null) {

				accountIds.add(opp.McaApp__Bank_Name__c);
			}
		}		


		if (!accountIds.isEmpty()) {

			Database.executeBatch(new VolumeBonusRollUpHandlerBatch(accountIds), 1);
		}
	}
	


	if (Trigger.isAfter) {

		if (Trigger.isInsert || Trigger.isUpdate) {

			MaxOfferedAmount maxOfferedAmount = new MaxOfferedAmount(Trigger.new);
			maxOfferedAmount.updateOpportunities();
		}
	}	
}