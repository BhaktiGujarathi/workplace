trigger UFHTCampaignHistoryTrackTrigger On Campaign (after Update) { 
 if(!UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('Campaign') && trigger.isAfter && trigger.isUpdate) {
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'Campaign'); }

}