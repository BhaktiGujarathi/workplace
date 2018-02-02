global class CCPullReservationConcurBatch implements  Database.Batchable<Trip__c>
                                                    , Database.Stateful
                                                    , Database.AllowsCallouts
{

    private Map<String,Trip__c> mapIdConcurNewTrip;
    global String accessToken;
    global Map<String,Trip__c> mapCncIDTrip;
    global Map<String,List<Reservation__c>> mapCncIDReservation;
    global Map<Trip__c,List<Reservation__c>> mapTripReservation;
    global Map<String,String> mapCncIDoppID;
    global List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>();

    public CCPullReservationConcurBatch(Map<String,Trip__c> mapIdConcurTrip,String accessTokenParam) {

            mapIdConcurNewTrip = mapIdConcurTrip;
            accessToken = accessTokenParam;
            mapCncIDTrip = new Map<String,Trip__c>();
            mapCncIDReservation = new Map<String,List<Reservation__c>>();
            mapCncIDoppID = new Map<String,String>();
            mapTripReservation = new Map<Trip__c,List<Reservation__c>>();
    }

    global Iterable<trip__c> start(Database.BatchableContext BC) {

        return new CCTripIteratable(mapIdConcurNewTrip);

    }

    global void execute(Database.BatchableContext BC,List<trip__c> scope) {

        new CCPullReservationConcurBatchService().CCPullReservationConcurBatchExecute(
            scope,
            accessToken,
            mapCncIDTrip,
            mapCncIDReservation,
            mapCncIDoppID,
            lstApxlog
        );


    }

    global void finish(Database.BatchableContext BC) {

        if( false == lstApxlog.isEmpty() ){
            insert CCUtility.cleanNullFrmLst(lstApxlog);
        }

        CCPullTripFromConcurAndSF.rescheduleConcurPullTripIds();
    }

    /*
    Schedulable_Batch_Context

    public void execute(SchedulableContext ctx) {
    //Database.executeBatch(new ConcurnintegrationBatch());

    }*/

}