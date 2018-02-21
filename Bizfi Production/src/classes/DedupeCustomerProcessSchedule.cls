global class DedupeCustomerProcessSchedule implements Schedulable {

    
    global void execute(SchedulableContext sc) {

        DedupeCustomerProcessBatch.start();
    }


    public static void start() {

        System.schedule('Customer Dedupe Process', '0 0 2 * * ?', new DedupeCustomerProcessSchedule());
    }
}