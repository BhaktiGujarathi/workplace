/**
 * Logic class for RecordCallAfterWorkingHoursWebService
 */
public class RecordCallAfterWorkingHoursLogic {

    /**
     * Method to process request and send the response
     */
    public static void processRecordCallAfterWorkingHoursRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        RecordCallAfterWorkingHoursRequestBody request =
            (RecordCallAfterWorkingHoursRequestBody) JSON.deserializeStrict(
                requestBody,
                RecordCallAfterWorkingHoursRequestBody.Class
            );
        System.debug('===== request : ' + request);

        // Create a dummy response
        RecordCallAfterWorkingHoursResponse response = new RecordCallAfterWorkingHoursResponse();
        response.status = 'Call Record Saved';
        System.debug('===== response : ' + response);

        // Set dummy response to response body
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        Restcontext.response.statusCode = 200;
    }

    /**
     * Wrapper class for RecordCallAfterWorkingHoursWebService request body
     */
    public class RecordCallAfterWorkingHoursRequestBody {
        public String calledDateTime {get; set;}
        public String calledNumber {get; set;}
        public String callingNumber {get; set;}
        public Boolean callback {get; set;}

        public RecordCallAfterWorkingHoursRequestBody() {
            this.calledDateTime = '';
            this.calledNumber = '';
            this.callingNumber = '';
            this.callback = false;
        }
    }

    /**
     * Wrapper class for RecordCallAfterWorkingHoursWebservice response body
     */
    public class RecordCallAfterWorkingHoursResponse {
        public String status;
        public String errorCode;
        public String errorMessage;

        public RecordCallAfterWorkingHoursResponse() {
            this.status = '';
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
}