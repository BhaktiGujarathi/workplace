global with sharing class ResetProjectHoursThisMonthSchedualable implements Schedulable{
    public ResetProjectHoursThisMonthSchedualable(){
    }
    
    global void execute(SchedulableContext sContext) {
       Database.executeBatch(new ResetProjectHoursThisMonthBatchable());
    }
}