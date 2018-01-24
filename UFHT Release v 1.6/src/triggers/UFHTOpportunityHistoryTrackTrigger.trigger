trigger UFHTOpportunityHistoryTrackTrigger On Opportunity (after Update) { 
 if(!UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('Opportunity') && trigger.isAfter && trigger.isUpdate) {
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'Opportunity'); }

}