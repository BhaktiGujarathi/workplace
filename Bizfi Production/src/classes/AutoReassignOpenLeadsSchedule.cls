global class AutoReassignOpenLeadsSchedule implements Schedulable{


    global void execute(SchedulableContext sc) {

        AutoReassignOpenLeadsBatch.start();
    }


    public static void start() {

        System.schedule('Set Reassign Lead when 48 Hour Rule True', '0 0 * * * ?', new AutoReassignOpenLeadsSchedule());
    }
}