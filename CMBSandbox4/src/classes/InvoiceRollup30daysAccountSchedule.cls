/*
* Version       Date             Author         Description
*   1.0         06/10/2015       Ashwini S      For Roll up on Account (Total_30_Days_Past_Due__c) from Invoice on daily basis   
*   1.1         19/10/2015       Ashwini S      For 00 and 90 days on daily basis
*/

global with sharing class InvoiceRollup30daysAccountSchedule implements Schedulable {
    
    global final integer dayspastdue;
    
    public InvoiceRollup30daysAccountSchedule(integer days){
    dayspastdue=days;
    }
    
    global void execute(SchedulableContext SC) {
        string schedulerQuery= SchedulerQueryGenenrator.queryFetch(dayspastdue);
        ID batchprocessid = Database.executeBatch(new InvoiceRollupAmountonAccountBatch(dayspastdue,schedulerQuery));
    }

}