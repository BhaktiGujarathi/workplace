/**
 * Record Call After Working Hours web-service will save call information sent by 3cx.
 */
@RestResource(urlMapping='/recordCallAfterWorkingHours/*')
global class RecordCallAfterWorkingHoursWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        RecordCallAfterWorkingHoursLogic.processRecordCallAfterWorkingHoursRequest();
    }
}