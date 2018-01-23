global class InsCloseAfterScheduler implements Schedulable
{
    global static void scheduleMe()
    {
       String strJobName = 'Job-InsCloseAfterScheduler-'+system.Now()+'';
       String strSchedule = '0 10 0 1/1 * ? *';
       System.schedule(strJobName, strSchedule, new InsCloseAfterScheduler());
    }
    
    
    global void execute(SchedulableContext SC) 
    {
        InsCloseAfterNDays insCloseAfetrDays = new InsCloseAfterNDays();
        database.executebatch(insCloseAfetrDays);
       
    } 
}