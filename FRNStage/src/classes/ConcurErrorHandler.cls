public class ConcurErrorHandler {   

    public static final String CONCUR_ERROR     = 'Concur_Integration_Error';
    public static final String RESPONSENULL     = 'Response null';
    public static final String UNKNOWN_ERROR    = 'Unknown error'; 
    public static final String SERVER_ERROR     = 'Server side error'; 
    public static final String CLIENT_ERROR     = 'Client request error'; 
    public static final String REDIRECTION      = 'Redirection'; 
    public static final String SUCCESS          = 'Success'; 
    public static final String INFO_RESPONSE    = 'Informational response';


     public class ConcurStatusDetails {
        public Integer statusCode;
        public String cause; 
        public String technicalReason;
        public String actions;
        //if this variable value is set to true, we can try to recover from the error by retrying the request again.
        public Boolean isRecoverable;
        public Boolean isSuccess;
        public String statusCodeType;

        public ConcurStatusDetails(Integer statusCodeValue){
            this.statusCode      =  statusCodeValue;
            this.statusCodeType  =  ConcurErrorHandler.getStatusType(statusCodeValue);
        }

        public ConcurStatusDetails setCause(String value){
            this.cause = value;
            return this;
        }

        public ConcurStatusDetails setTechnicalReason(String value){
            this.technicalReason = value;
            return this;
        }

        public ConcurStatusDetails setActions(String value){
            this.actions = value;
            return this;
        }

        public ConcurStatusDetails setIsRecoverable(Boolean value){
            this.isRecoverable = value;
            return this;
        }

        public ConcurStatusDetails setIsSuccess(Boolean value){
            this.isSuccess = value;
            return this;
        }
    }
    
    public static Map<Integer,ConcurStatusDetails> ERRORSTATUSDETAILS = new Map<Integer,ConcurStatusDetails>{
            400 => new ConcurStatusDetails(400)
                .setCause('Bad Request') 
                .setTechnicalReason(
                     'The specified URI is invalid.\n'
                    +'The request is not formatted correctly.\n'
                    +'The request is missing a required field.\n'
                    +'The number of requests received exceed the request limit.\n'
                ),
            401 => new ConcurStatusDetails(401)
                .setCause('Unauthorized') 
                .setTechnicalReason(
                     'The Authorization header is not included in the request.\n'
                ),
            403 => new ConcurStatusDetails(403)
                .setCause('Forbidden') 
                .setTechnicalReason(
                      'The Authorization header is included but it fails validation.\n'
                     +'The Oauth token has expired or been revoked. \n'
                ).setIsRecoverable(true), 
            404 => new ConcurStatusDetails(404)
                .setCause('Not Found') 
                .setTechnicalReason(
                      'The Trip ID or Booking ID specified in the URI is invalid.\n'
                ),
            409 => new ConcurStatusDetails(409)
                .setCause('Conflict') 
                .setTechnicalReason(
                      'A job for the specified definition is already queued or running.\n'
                ),
            500 =>  new ConcurStatusDetails(500)
                .setCause('Internal Server Error') 
                .setTechnicalReason(
                      'The system is unable to serve the request currently.\n'
                ).setIsRecoverable(true),
            503 =>  new ConcurStatusDetails(503)
                .setCause('Service Unavailable') 
                .setTechnicalReason(
                       'This response is returned when the web service is down for maintenance.\n'
                      +'The partner application should sleep for 5 minutes then retry the request.\n'
                      +'If the request continues to fail after a few retries, the developer should contact concurconnecttech@concur.com.\n'
                ).setIsRecoverable(true),
            302 =>  new ConcurStatusDetails(302)
                .setCause('Redirect') 
                .setTechnicalReason(
                       ' Server requesting redirect to another resource. \n'
                )  
    };

    public static String getStatusType(Integer statusValue){
        Double statusTypeDouble = Math.floor(statusValue / 100);
        Integer statusCodeType = statusTypeDouble !=null ? Integer.valueOf(statusTypeDouble) : 0;

        if( statusCodeType == 1 ){
           return  INFO_RESPONSE;
        } if( statusCodeType == 2 ){
            return SUCCESS;
        } else if( statusCodeType == 3 ) {
            return REDIRECTION;
        } else if( statusCodeType == 4 ) {
            return CLIENT_ERROR;
        } else if( statusCodeType == 5 ) {
            return SERVER_ERROR;
        } else {
            return UNKNOWN_ERROR;
        }
    }
    
    public static ConcurStatusDetails getStatusDetails(HttpResponse httpResponse){
        if( httpResponse == null){
            return new ConcurStatusDetails(0)
                    .setCause(RESPONSENULL)
                    .setIsSuccess(false);
        }

        return getStatusDetails(httpResponse.getStatusCode());
    }
    
    public static ConcurStatusDetails getStatusDetails(Integer statusValue){
        ConcurStatusDetails concurStatusDetails = ERRORSTATUSDETAILS.get(statusValue);
        if( concurStatusDetails == null ){
            
            concurStatusDetails = new ConcurStatusDetails(statusValue)
                                  .setCause(
                                      getStatusType(statusValue)
                                );

            if( 'Success'.equalsIgnoreCase( concurStatusDetails.cause )  ){
                concurStatusDetails.isSuccess = true;
            } else {
                concurStatusDetails.isSuccess = false;
            }   
        } else {
            concurStatusDetails.isSuccess = false;
        }

        return concurStatusDetails; 
    }
}