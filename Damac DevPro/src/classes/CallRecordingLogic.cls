/**
 * Logic class for CallRecordingWebService
 */
public class CallRecordingLogic {

    /**
     * Method to process request and send the response
     */
    public static void processCallRecordingRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        CallRecordingRequestBody request = (CallRecordingRequestBody) JSON.deserializeStrict(
            requestBody,
            CallRecordingRequestBody.Class
        );
        System.debug('===== request : ' + request);

        // Create a dummy response
        CallRecordingResponseBody response = new CallRecordingResponseBody();
        response.status = 'Call Record Saved';
        System.debug('===== response : ' + response);

        // Set dummy response to response body
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        Restcontext.response.statusCode = 200;
    }

    /**
     * Wrapper class for CallRecordingWebService request body
     */
    public class CallRecordingRequestBody {
        public String caseNumber {get; set;}
        public String url {get; set;}
        public String callStartTime {get; set;}
        public String callEndTime {get; set;}
        public String creAgent {get; set;}

        public CallRecordingRequestBody() {
            this.caseNumber = '';
            this.url = '';
            this.callStartTime = '';
            this.callEndTime = '';
            this.creAgent = '';
        }
    }

    /**
     * Wrapper class for CallRecordingWebService response body
     */
    public class CallRecordingResponseBody {
        public String status;
        public Integer errorCode;
        public String errorMessage;

        public CallRecordingResponseBody() {
            this.status = '';
            this.errorCode = 200;
            this.errorMessage = '';
        }
    }
}