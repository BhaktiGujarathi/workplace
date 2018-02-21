global with sharing class LineItemUpdatesProjectScheduler implements Schedulable{
    public LineItemUpdatesProjectScheduler(){
    
    }
    
    global void execute(SchedulableContext sContext) {
       Database.executeBatch(new LineItemUpdatesProjectBatchable());
    }

}