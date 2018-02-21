global class DedupeProspectProcessForAccountsSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {

        DedupeProspectAccountsProcessBatch.start();
    }

    public static void start() {
        System.schedule('Prospect for Accounts Dedupe Process', '0 0 2 * * ?', new DedupeProspectProcessForAccountsSchedule());
    }
}