/*
 * Description: This Apex Class exposes method(s) that can be utilized by 
 * other Apex Classes to create Persistent Logs of type Error or
 * Information as opposed to native Debug Logs. 
 * 
 * Created By: Merul S. 
 * Created Date: Apr 17, 2017
 * 
 * Revisions: NIL
*/
global class ApexDebugLog
{

    public static final List<String> REQUEST_HEADERS_TOLOG = new List<String>{'Authorization','METHOD'};
    public static List<Apex_Debug_Log__c> lstApxDbg;
    /*
        A Virtual Class that Defines the 
        Structure of a Log
    */
    public virtual class Log
    {
        public String Type;
        public String ApexClass;
        public String Method;
        public String RecordId;
        public String Message;
        public String StackTrace;
        public Integer LineNumber;
        public DateTime TimeStamp;
    }
    
    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Error
    */
    public class Error extends Log
       {
        public Error(String cls, String routine, String recId, Integer LineNumber, DateTime timeStamp,Exception ex){
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = ex.getMessage();
            this.LineNumber = LineNumber;
            this.timeStamp= timeStamp;
            this.StackTrace = ex.getStackTraceString();
        }
    }

    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Information
    */
    public class Information extends Log{
        public Information(String cls, String routine, String recId, Integer LineNumber, DateTime timeStamp, String msg){
            this.Type = 'Information';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = msg;
            this.LineNumber = LineNumber;
            this.timeStamp = timeStamp;
            this.StackTrace = NULL;
        }

        public Information setStacktrace(Exception exp){
            String exceptionDetails = '';
            exceptionDetails += '\n Exception Type: '+exp.getTypeName();
            exceptionDetails += '\n Exception Message : '+exp.getMessage();
            exceptionDetails += '\n Exception Line : '+exp.getLineNumber();
            exceptionDetails += '\n Stack Trace : \n'+exp.getStackTraceString();

            this.StackTrace = exceptionDetails;
            return this;
        }
    }

   
    /*
        A Public Method that can be utilized by
        other Apex Classes to create a record into
        the Apex Debug Log object stating the Error
        or Information.
    */
    public static Apex_Debug_Log__c createLog(Log logToCreate)
    {
        try{
            /*
                Ensure that we're well within the Governor Limits.
                The creation of the Log shouldn't disturb the execution
                of that Apex Class that utilizes this method to
                create a log.
            */
           if(system.label.FRNActivateDebug =='True')
            {
                if((Limits.getDMLRows() < Limits.getLimitDMLRows()) && (Limits.getDMLStatements() < Limits.getLimitDMLStatements()))
                {
                    Apex_Debug_Log__c apexDebuglog = new Apex_Debug_Log__c(
                                                                            Type__c         = logToCreate.Type,
                                                                            Apex_Class__c   = logToCreate.ApexClass,
                                                                            Method__c       = logToCreate.Method,
                                                                            Record_Id__c    = logToCreate.RecordId,
                                                                            Message__c      = logToCreate.Message,
                                                                            Stack_Trace__c  = logToCreate.StackTrace,
                                                                            Time_Stamp__c   = logToCreate.timeStamp,
                                                                            Line__c = logToCreate.LineNumber
                                                                          );
                
                    return apexDebuglog;
                   
                }
                else
                {
                    System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
                    
                }
            
            }
            
            
        }
        catch(DMLException ex)
        {
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
            
        }
        
        return null;
    }

    public static String logHTTPResponse(HttpResponse response){
 
        String message = '';
 
        if( response == null ){
            return 'Response is null.';
        }

        message += 'Status Details : \n';
        ConcurErrorHandler.ConcurStatusDetails conStatusDetails =  ConcurErrorHandler.getStatusDetails(response);

        message += 'Cause : \n'+conStatusDetails.cause;
        message += 'Technical Reason : \n'+conStatusDetails.technicalReason;
 
        message += 'Response Headers : \n'; 
        message += 'Response Status :'+response.getStatus()+'\n';
        message += 'Response Status Code :'+response.getStatusCode()+'\n';
 
        for(String key : response.getHeaderKeys()){
            message += key +':'+response.getHeader(key)+'\n';
        }
        message += 'Response Body : \n'+response.getBody();
        
        return message;
    }
   
    public static String logHTTPRequest(HttpRequest request){
 
        String message = '';
        message += 'Request Headers : \n';
        message += 'Request Endpoint :'+request.getEndpoint()+'\n';
        message += 'Request Method :'+request.getMethod()+'\n';
        for(String key : REQUEST_HEADERS_TOLOG){
            message += key +':'+request.getHeader(key)+'\n';
        }
        message += 'Request Body : \n'+request.getBody();
        
        return message;
    }

    public static String getHttpTransactionLog(HttpRequest request , HttpResponse response){
        String message = '';
        message += '--------- HTTP Request    -----   \n';
        message += logHTTPRequest(request);
        message += '--------- Request Log End -----   \n';
        message += '\n\n';
        message += '--------- HTTP Response    -----   \n';
        message += logHTTPResponse(response);
        message += '--------- Response Log End -----   \n';

        return message;
    }

}