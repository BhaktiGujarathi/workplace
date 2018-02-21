public class InventoryReleaseTriggerHandler implements TriggerFactoryInterface {
    
    public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){
        
        set<String> unitIds = new set<string>();
        for(Sobject sobj: lstNewRecords){
            Inventory_Release__c irelease = (Inventory_Release__c) sobj;
            if(irelease.Unit_ID__c != null)
                unitIds.add(irelease.Unit_ID__c);
        }
        
        Map<String,ID> mpInventory = new Map<String,Id>();
        for(Inventory__c inv: [Select id, Inventory_ID__c from Inventory__c where Inventory_ID__c in: unitIds]){
            mpInventory.put(inv.Inventory_ID__c, inv.Id);
        }
      
        List<Inventory__c> lstReleases2Update = new List<Inventory__c>();
        for(Sobject sobj: lstNewRecords){
            Inventory_Release__c irelease = (Inventory_Release__c) sobj;
            if(irelease.Unit_ID__c != null && mpInventory.containsKey(irelease.Unit_ID__c))
                sobj.put('Inventory__c', mpInventory.get(irelease.Unit_ID__c));
            if(mpInventory.containsKey(irelease.Unit_ID__c)){
                if(irelease.status_flag__c == '1')    
                    lstReleases2Update.add(new Inventory__c(Id=mpInventory.get(irelease.Unit_ID__c), status__c='Available'));
                
            }   
        }
        
        if(!lstReleases2Update.isempty())
            update lstReleases2Update;
    }
    
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
         set<String> unitIds = new set<string>();
        for(Sobject sobj: mapNewRecords.values()){
            Inventory_Release__c irelease = (Inventory_Release__c) sobj;
            if(irelease.Unit_ID__c != null)
                unitIds.add(irelease.Unit_ID__c);
        }
        
        Map<String,ID> mpInventory = new Map<String,Id>();
        for(Inventory__c inv: [Select id, Inventory_ID__c from Inventory__c where Inventory_ID__c in: unitIds]){
            mpInventory.put(inv.Inventory_ID__c, inv.Id);
        }
      
        List<Inventory__c> lstReleases2Update = new List<Inventory__c>();
        for(Sobject sobj: mapNewRecords.values()){
            Inventory_Release__c irelease = (Inventory_Release__c) sobj;
            if(irelease.Unit_ID__c != null && mpInventory.containsKey(irelease.Unit_ID__c))
                sobj.put('Inventory__c', mpInventory.get(irelease.Unit_ID__c));
            if(mpInventory.containsKey(irelease.Unit_ID__c)){
                if(irelease.status_flag__c == '1')    
                    lstReleases2Update.add(new Inventory__c(Id=mpInventory.get(irelease.Unit_ID__c), status__c='Available'));
                
            }   
        }
        
        if(!lstReleases2Update.isempty())
            update lstReleases2Update;
    }
    
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords,map<Id,sObject> mapOldRecords){
        map<Id,Account> mapOldSRRecords = new map<Id,Account>();
        if(mapOldRecords != null)
            mapOldSRRecords = (map<Id,Account>)mapOldRecords;
    }
    
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
        
    }
    
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        
    }
    
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
}