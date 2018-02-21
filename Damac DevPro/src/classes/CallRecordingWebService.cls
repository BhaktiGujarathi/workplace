/**
 * Call Recording web-service will save call recording sent from 3cx.
 */
@RestResource(urlMapping='/callRecording/*')
global class CallRecordingWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        CallRecordingLogic.processCallRecordingRequest();
    }
}