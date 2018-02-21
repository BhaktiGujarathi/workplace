trigger UFHTUserHistoryTrackTrigger On User (after Update) { 
 if(trigger.isAfter && trigger.isUpdate) { 
 UFHT.DynamicTriggerGenericHandler.verifyRecursiveCallForAnObject('User') ;
 new UFHT.DynamicTriggerGenericHandler().onUpdateStoreHistoryData(trigger.newMap, trigger.oldMap, 'User'); }

}