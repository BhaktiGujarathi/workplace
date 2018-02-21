global class DedupeProspectAccountsProcessBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global DedupeProspectAccountsProcessBatch(String query) {      
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        DedupeProspectProcessServiceForAccounts service = new DedupeProspectProcessServiceForAccounts((Account[]) scope);
        service.initDedupe();
    }

    global void finish(Database.BatchableContext BC) {} 

    public static void start() {
        Database.executeBatch(new DedupeProspectAccountsProcessBatch('select Id from Account where Opportunity_Stage_Category__c = \'Apped Opp\' order by createdDate asc'), 1);
    } 
}