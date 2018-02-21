/**
 * Call Log web-service will save the call details send from 3cx.
 */
@RestResource(urlMapping='/callLog/*')
global class CallLogWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        CallLogLogic.processCallLogRequest();
    }
}