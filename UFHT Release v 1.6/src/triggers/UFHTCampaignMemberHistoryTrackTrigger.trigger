trigger UFHTCampaignMemberHistoryTrackTrigger On CampaignMember (after Update) { 
 if(!UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('CampaignMember') && trigger.isAfter && trigger.isUpdate) {
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'CampaignMember'); }

}