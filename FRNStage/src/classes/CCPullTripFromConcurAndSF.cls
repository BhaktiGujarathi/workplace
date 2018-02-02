public Class CCPullTripFromConcurAndSF implements Schedulable
{
   //Constant
   public static String accessToken;
   //Declaration of Variables

   //Declaration of collections
   public static List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>();

   //Declaration of methods
   @future(callout=true)
   public static void pullTripFromConcurAndSFExecute() {

        CCPullTripFromConcurAndSFService.PullTripResponse pullTripResponse = new CCPullTripFromConcurAndSFService.PullTripResponse();

        if ( String.isBlank(accessToken) ) {
            accessToken = CCPullTripFromConcurAndSFService.loginToConcurSystem();
        }

        if ( false == String.isBlank(accessToken) ) {
            pullTripResponse = CCPullTripFromConcurAndSFService.fetchTripsAndInsertRecords(accessToken);
        } else {
            //as access token is null reschedule the batch. this may happen if the server is down.
            pullTripResponse.reSchedulePull = true;
        }


        if ( pullTripResponse.reSchedulePull ) {
            rescheduleConcurPullTripIds();
        }

        insert CCUtility.cleanNullFrmLst(CCPullTripFromConcurAndSF.lstApxlog);
   }


    /*
        Schedulable_Batch_Context
     */
     public void execute(SchedulableContext ctx)
     {
       // CCPullTripFromConcurAndSF a = new CCPullTripFromConcurAndSF();
        CCPullTripFromConcurAndSF.pullTripFromConcurAndSFExecute();

     }


   // Declaration of wrapper class

    /**
     * Method to reschedule CCPullTripFromConcurAndSF
     */
    public static String rescheduleConcurPullTripIds() {

        Integer inNextMinutes = Integer.valueOf(System.Label.CCMinuteForReschedulingTripBatch);

        return rescheduleConcurPullTripIds( inNextMinutes );
    }

    /**
     * Method to reschedule rescheduleConcurPullTripIds
     */
    public static String rescheduleConcurPullTripIds(Integer inNextMinutes) {

        //sanity check
        inNextMinutes = inNextMinutes == null || inNextMinutes< 0 ? 0 :  inNextMinutes;

        DateTime now  = System.now();

        DateTime nextRunTime = now.addMinutes(
            inNextMinutes
        );

        String cronString = '' +   nextRunTime.second() + ' '   + nextRunTime.minute() + ' ' +
                                   nextRunTime.hour()   + ' '   + nextRunTime.day()    + ' ' +
                                   nextRunTime.month()  + ' ? ' + nextRunTime.year();

        if (!Test.isRunningTest()) {
            String jobId = System.schedule(
                CCPullTripFromConcurAndSF.class.getName() + '-' + now.format(),
                cronString,
                new CCPullTripFromConcurAndSF()
            );
            return jobId;
        } else {
            return null;
        }

    }
}