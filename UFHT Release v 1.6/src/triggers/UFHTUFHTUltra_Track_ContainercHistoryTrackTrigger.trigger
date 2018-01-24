trigger UFHTUFHTUltra_Track_ContainercHistoryTrackTrigger On UFHT__Ultra_Track_Container__c (after Update) { 
 if(!UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('UFHT__Ultra_Track_Container__c') && trigger.isAfter && trigger.isUpdate) {
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'UFHT__Ultra_Track_Container__c'); }

}