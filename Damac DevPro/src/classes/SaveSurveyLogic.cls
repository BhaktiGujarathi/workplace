/**
 * Logic class for SaveSurveyWebService
 */
public class SaveSurveyLogic {

    /**
     * Method to process request and send the response
     */
    public static void processSaveSurveyRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        SaveSurveyRequestBody request = (SaveSurveyRequestBody) JSON.deserializeStrict(
            requestBody,
            SaveSurveyRequestBody.Class
        );
        System.debug('===== request : ' + request);

        // Create a dummy response
        SaveSurveyResponseBody response = new SaveSurveyResponseBody();
        response.status = 'Call Record Saved';
        System.debug('===== response : ' + response);

        // Set dummy response to response body
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        Restcontext.response.statusCode = 200;
    }

    /**
     * Wrapper class for SaveSurveyWebService request body
     */
    public class SaveSurveyRequestBody {
        public String callingNumber {get; set;}
        public String extension {get; set;}
        public String calledDateTime {get; set;}
        public String rating {get; set;}

        public SaveSurveyRequestBody() {
            this.callingNumber = '';
            this.extension = '';
            this.calledDateTime = '';
            this.rating = '';
        }
    }

    /**
     * Wrapper class for SaveSurveyWebService response body
     */
    public class SaveSurveyResponseBody {
        public String status;
        public String errorCode;
        public String errorMessage;

        public SaveSurveyResponseBody() {
            this.status = '';
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
}