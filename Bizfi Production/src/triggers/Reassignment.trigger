trigger Reassignment on Account (after update) {
    
    StorageAccountReassign.storeOpps(Trigger.newMap, Trigger.oldMap);
}