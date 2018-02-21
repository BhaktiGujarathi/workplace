/**
 * Logic class for Call Log Webservice
 */
public class CallLogLogic {

    /**
     * Method to process request and send the response
     */
    public static void processCallLogRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        CallLogRequestBody request = (CallLogRequestBody) JSON.deserializeStrict(
            requestBody,
            CallLogRequestBody.Class
        );
        System.debug('===== request : ' + request);

        // Create a dummy response
        CallLogResponseBody response = new CallLogResponseBody();
        response.status = 'Call Log Created';
        System.debug('===== response : ' + response);

        // Set dummy response to response body
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        Restcontext.response.statusCode = 200;
    }

    /**
     * Wrapper class for CallLogWebService request body
     */
    public class CallLogRequestBody {
        public String callingNumber {get; set;}
        public String agentExtension {get; set;}
        public String startTime {get; set;}
        public String endTime {get; set;}
        public String callDuration {get; set;}
        public String terminationParty {get; set;}
        public String callStatus {get; set;}
        public String callRecordingUrl {get; set;}
        public String description {get; set;}
        public String callType {get; set;}
        public String waitTime {get; set;}
        public String holdTime {get; set;}

        public CallLogRequestBody() {
            this.callingNumber = '';
            this.agentExtension = '';
            this.startTime = '';
            this.endTime = '';
            this.callDuration = '';
            this.terminationParty = '';
            this.callStatus = '';
            this.callRecordingUrl = '';
            this.description = '';
            this.callType = '';
            this.waitTime = '';
            this.holdTime = '';
        }
    }

    /**
     * Wrapper class for CallLogWebService response body
     */
    public class CallLogResponseBody {
        public String status;
        public String errorCode;
        public String errorMessage;

        public CallLogResponseBody() {
            this.status = '';
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
}