trigger UFHTCampaignHistoryTrackTrigger On Campaign (after Update) { 
 if(trigger.isAfter && trigger.isUpdate) { 
 UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('Campaign') ;
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'Campaign'); }

}