global class AccountCalendarOpportunityLockBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Set<String> lockMonths;
    private Boolean isDelete;
    
    
    global AccountCalendarOpportunityLockBatch(Set<String> lockMonths, Boolean isDelete) {
        
        this.lockMonths = lockMonths;
        this.isDelete = isDelete;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT RecordTypeId FROM Opportunity WHERE StageName = \'Funded\' AND Funded_Date_Key__c IN :lockMonths';

        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        AccountingCalendarMonthHandler.getInstance().lockOpportunities(scope, isDelete);
    }
    
    
    global void finish(Database.BatchableContext BC) {

        AccountCalendarPayableLockBatch.start(lockMonths, isDelete);
    }   


    public static void start(Set<String> lockMonths, Boolean isDelete) {

        Database.executeBatch(new AccountCalendarOpportunityLockBatch(lockMonths, isDelete), 100);
    }
}