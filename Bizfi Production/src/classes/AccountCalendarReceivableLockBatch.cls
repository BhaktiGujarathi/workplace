global class AccountCalendarReceivableLockBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Set<String> lockMonths;
    private Boolean isDelete;
    
    
    global AccountCalendarReceivableLockBatch(Set<String> lockMonths, Boolean isDelete) {
        
        this.lockMonths = lockMonths;
        this.isDelete = isDelete;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT RecordTypeId FROM McaApp__Receivable__c WHERE Receivable_Invoice_Key__c IN :lockMonths';

        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        AccountingCalendarMonthHandler.getInstance().lockReceivable(scope, isDelete);
    }
    
    
    global void finish(Database.BatchableContext BC) {}   


    public static void start(Set<String> lockMonths, Boolean isDelete) {

        Database.executeBatch(new AccountCalendarReceivableLockBatch(lockMonths, isDelete), 100);
    }
}