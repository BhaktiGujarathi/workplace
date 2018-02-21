global class DedupeApplicantProcessSchedule implements Schedulable {

    
    global void execute(SchedulableContext sc) {

        DedupeApplicantProcessBatch.start();
    }


    public static void start() {

        System.schedule('Applicant Dedupe Process', '0 0 2 * * ?', new DedupeApplicantProcessSchedule());
    }
}