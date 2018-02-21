global class DedupeProspectProcessSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {

        DedupeProspectProcessBatch.start();
    }

    public static void start() {
        System.schedule('Prospect Dedupe Process', '0 0 2 * * ?', new DedupeProspectProcessSchedule());
    }
}