public class CCPullReservationConcurQueuebleJob implements Queueable, Database.AllowsCallouts {

    private Map<String,Trip__c> mapIdConcurTrip = new Map<String,Trip__c>();
    private String accessToken;
    public CCPullReservationConcurQueuebleJob (
              Map<String,Trip__c> pMapIdConcurTrip
            , String pAccessToken
    ) {
        this.mapIdConcurTrip = pMapIdConcurTrip;
        this.accessToken = pAccessToken;
    }

    public void execute(QueueableContext context) {
        Integer jobs = Utils.getJobCount();
        if ( jobs != null && jobs > 4 ) {
            CCPullTripFromConcurAndSF.rescheduleConcurPullTripIds();
        } else {
            Database.executeBatch(new CCPullReservationConcurBatch(mapIdConcurTrip,accessToken), 10);
        }
    }
}