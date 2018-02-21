global class DedupeCustomerProcessBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global DedupeCustomerProcessBatch(String query) {
        
        this.query = query;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        DedupeCustomerProcessService service = new DedupeCustomerProcessService((Account[]) scope);
        service.initDedupe();
    }

    
    global void finish(Database.BatchableContext BC) {} 


    public static void start() {

        Database.executeBatch(new DedupeCustomerProcessBatch('select Id from Account where Opportunity_Stage_Category__c = \'Funded Opp\' '), 1);
    }
}