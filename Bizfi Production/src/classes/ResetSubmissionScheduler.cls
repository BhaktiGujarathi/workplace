global class ResetSubmissionScheduler implements Database.Batchable<sobject>, Schedulable {
    
    global void execute(SchedulableContext sc){
        ResetSubmissionScheduler obj = new ResetSubmissionScheduler();
        database.executeBatch(obj);
    }
    
    global database.querylocator start(Database.BatchableContext bc){
        
        return database.getQueryLocator('Select id from Sales_Rep_Report_Card__c');
    }
    
    global void execute(Database.BatchableContext bc, List<Sales_Rep_Report_Card__c> lstCards){
        
        for(Sales_Rep_Report_Card__c rep: lstCards){
            rep.Submissions_Today__c = 0;
        }
        
        update lstCards;
        
    }
    
    global void finish(Database.BatchableContext bc){
        
        
    }
    
}