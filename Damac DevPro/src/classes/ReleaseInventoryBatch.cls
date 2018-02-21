global class ReleaseInventoryBatch extends InquiryService implements Database.Batchable <sObject>{ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,name,Campaign__c,End_Date__c,Start_Date__c,Inventory__c,UniqueID__c from Campaign_Inventory__c where End_Date__c < TODAY';
        System.debug('Query----'+query); 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Campaign_Inventory__c> scope) {
        savepoint sp = Database.setSavepoint();
        try{
            Map<Id,Inventory__c> InvtobeReleased = new Map<Id,Inventory__c>();
            List<Campaign_Inventory__c> rectobeDeleted = new List<Campaign_Inventory__c>();
            for(Campaign_Inventory__c camInv : scope){
                if(camInv.End_Date__c < date.today()){
                    InvtobeReleased.put(camInv.Inventory__c,new Inventory__c(id=camInv.Inventory__c,Is_Assigned__c = false));
                    rectobeDeleted.add(camInv);
                }
            }
            DAMAC_Constants.skip_InventoryTrigger = true;
            if(InvtobeReleased != null && !InvtobeReleased.isempty()){
                update InvtobeReleased.values();
            }
            if(rectobeDeleted != null && !rectobeDeleted.isempty()){
                delete rectobeDeleted;
                database.emptyRecycleBin(rectobeDeleted);
            }
        }
        catch(exception ex){
            database.rollback(sp);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    //select id,name,Campaign__c,End_Date__c,Start_Date__c,Inventory__r.Is_Assigned__c,UniqueID__c,createddate from Campaign_Inventory__c where End_Date__c < TODAY order by createddate desc limit 10
}