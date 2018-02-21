global class SCScheduler implements Schedulable{

    public static String sched = '0 15 00 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        SCScheduler  SC = new SCScheduler();
        return System.schedule('SC Collector Scheduler', sched, SC );
    }

    global void execute(SchedulableContext sc) {

        SCAuditTrailBatchCollector  batchCollector = new SCAuditTrailBatchCollector(SCQuerySelector.querySelectorForAuditTrail());
        ID batchprocessid = Database.executeBatch(batchCollector,Integer.valueOf(system.label.SCBatchChunkSize));           
    }
}