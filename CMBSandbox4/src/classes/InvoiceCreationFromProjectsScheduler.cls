/*
 * Description: Scheduler to schedule InvoiceCreationFromProjectsBatch.
 *
 * Revision History: 
 *
 * Version     Author           Date         Description 
 * 1.0         Ashwini Singh    25/01/2016   Initial Draft
 */
public with sharing class InvoiceCreationFromProjectsScheduler implements Schedulable{
    public InvoiceCreationFromProjectsScheduler(){
    }
    public void execute(SchedulableContext sContext) {
       Database.executeBatch(new InvoiceCreationFromProjectsBatch());
    }

}