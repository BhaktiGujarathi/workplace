global class AccountCalendarPayableLockBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Set<String> lockMonths;
    private Boolean isDelete;
    
    
    global AccountCalendarPayableLockBatch(Set<String> lockMonths, Boolean isDelete) {
        
        this.lockMonths = lockMonths;
        this.isDelete = isDelete;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT RecordTypeId FROM McaApp__Payable__c WHERE Payable_Date_Key__c IN :lockMonths';

        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        AccountingCalendarMonthHandler.getInstance().lockPayables(scope, isDelete);
    }
    
    
    global void finish(Database.BatchableContext BC) {

        AccountCalendarReceivableLockBatch.start(lockMonths, isDelete);
    }   


    public static void start(Set<String> lockMonths, Boolean isDelete) {

        Database.executeBatch(new AccountCalendarPayableLockBatch(lockMonths, isDelete), 100);
    }
}