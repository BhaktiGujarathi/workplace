trigger VolumeBonusTierTrigger on Volume_Bonus_Tier__c (before insert, before update) {

	VolumeBonusTierTriggerHandler volumeBonusTierHandler = new VolumeBonusTierTriggerHandler();

	if (Trigger.isInsert || Trigger.isUpdate) {

		volumeBonusTierHandler.validateRecords(Trigger.new);
	}
}