public class GenerateWalkInSurveyExcelController {
    
    public Survey__c survey                     {get; set;}
    public SurveyReport surveyReportWrap        {get; set;}
    public Map<String,List<String>> surveyQuestionWithResponse {get;set;}

    public GenerateWalkInSurveyExcelController() {

      
        List<Survey__c> surveyList = [Select Id,Name,Hide_Survey_Name__c,Survey_Header__c,Thank_You_Text__c,Description__c from Survey__c
                                      where Is_Active__c = True and Type__c = 'Walk-In' and End_Date__c > :System.Today() and Start_Date__c < :System.Today() LIMIT 1];
                                      

        surveyReportWrap = new SurveyReport(new Survey_Question__c(),new Survey_Question_Response__c(),new List<String>(),new List<SurveyResponse>(),new Map<String,List<String>>());
        //surveyReportWrap.fieldsToDisplayInCol = new List<String>();
        surveyReportWrap.surveyResponse = new List<SurveyResponse>();
        surveyQuestionWithResponse  = new Map<String,List<String>>();
        if( false == surveyList.isEmpty() ){
            survey = surveyList.get(0);
            surveyQuestionWithResponse = getExcelData();
        }
        System.debug('surveyQuestionWithResponse >>> ' + surveyQuestionWithResponse);
    }

    // Instance fields
    public String searchTerm {get; set;}
    public String selectedMovie {get; set;}
    
    
    // JS Remoting action called when searching for a movie name
    @RemoteAction
    public static List<Account> searchMovie(String searchTerm) {
        System.debug('Account Name is: '+searchTerm );
        List<Account> movies = Database.query('Select Id, Name from Account where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return movies;
    }

    public Map<String,List<String>> getExcelData() {
        system.debug( 'survey : ' + survey.Id);
        List<String> lstFieldToDisplay  = new List<String>();
        List<SurveyResponse> surveyResponse   = new List<SurveyResponse>();
        //Map<String,List<String>> surveyQuestionWithResponse = new Map<String,List<String>>();
        List<Survey_Question__c> allQuestionsObject = [ Select Survey__r.Name, Survey__c, Question__c, Name
                                                      , ( Select Question__c From Survey_Questions__r where Survey__c =: survey.Id)
                                                      , ( Select Response__c,Survey_Taker__r.Purpose_of_Visit__c 
                                                        , Survey_Taker__r.Other_Please_Specify__c , Survey_Taker__r.Booking_Unit__r.Name
                                                        , Survey_Taker__r.Property__r.Name,Survey_Taker__r.Customer_taking_Survey__r.Name 
                                                        , Survey_Taker__r.CreatedBy.Name , Survey_Taker__r.CreatedDate From Survey_Question_Answers__r )
                                                        From Survey_Question__c where Survey__c =: survey.Id];
        System.debug('allQuestionsObject >>> ' + allQuestionsObject);                                                        
        for ( Survey_Question__c objSurveyQuestion : allQuestionsObject ) {
            if( objSurveyQuestion.Question__c != '' && objSurveyQuestion.Question__c != null ) {
                System.debug('objSurveyQuestion.Question__c >>> ' + objSurveyQuestion.Question__c);
                //surveyReportWrap.fieldsToDisplayInCol.add( objSurveyQuestion.Question__c );
                lstFieldToDisplay.add(objSurveyQuestion.Question__c);
                for( Survey_Question_Response__c objSurveyResponse : objSurveyQuestion.Survey_Question_Answers__r ) {
                    //if( objSurveyResponse.Response__c != '' && objSurveyResponse.Response__c != null ) {      
                    //    surveyReportWrap.surveyResponse.add(new SurveyResponse(objSurveyQuestion,objSurveyResponse));
                    //}
                    if( objSurveyResponse.Response__c != '' && objSurveyResponse.Response__c != null ) {  
                       surveyResponse.add( new SurveyResponse(objSurveyQuestion,objSurveyResponse) );
                       list<string> templist = new list<string>();
                       if(surveyQuestionWithResponse.containskey(objSurveyQuestion.Question__c)){
                                templist = surveyQuestionWithResponse.get(objSurveyQuestion.Question__c);
                                templist.add( objSurveyResponse.Response__c );
                                surveyQuestionWithResponse.put( objSurveyQuestion.Question__c,templist);
                        }
                        else{
                            templist = new list<string>();
                            templist.add(  objSurveyResponse.Response__c );
                            surveyQuestionWithResponse.put(objSurveyQuestion.Question__c,templist);
                        }
                    }
                    surveyReportWrap = new SurveyReport(objSurveyQuestion,objSurveyResponse,lstFieldToDisplay,surveyResponse,surveyQuestionWithResponse);
                }
            }

        }
        return surveyQuestionWithResponse;                                 
    }

    public class SurveyReport {
        public String               name                      {get; set;}
        public DateTime             createdDate               {get; set;}
        public List<String>         fieldsToDisplayInCol      {get; set;}
        public List<SurveyResponse> surveyResponse            {get; set;}
        public String               purposeOfVisit            {get; set;}
        public String               otherPleaseSpecify        {get; set;}
        
        public String               custName                  {get; set;}

        public String               projectName               {get; set;}
        public String               bookingId                 {get; set;}
        public Map<String,List<String>> surveyQuestionWithResponse  {get;set;}
        public SurveyReport( Survey_Question__c objSurveyQuestion 
                           , Survey_Question_Response__c objSurveyResponse
                           , List<String> lstFieldToDisplay
                           , List<SurveyResponse> surveyResponse 
                           , Map<String,List<String>> surveyQuestionWithResponse ) {
        
            surveyResponse = surveyResponse.isEmpty() == false ? surveyResponse : new List<SurveyResponse>();
            surveyQuestionWithResponse  = surveyQuestionWithResponse.isEmpty() == false ? surveyQuestionWithResponse : new Map<String,List<String>>();
            fieldsToDisplayInCol    = lstFieldToDisplay.isEmpty() == false ? lstFieldToDisplay : new List<String>();
            name                    = objSurveyResponse.Survey_Taker__r.CreatedBy.Name != '' && objSurveyResponse.Survey_Taker__r.CreatedBy.Name != null  ? objSurveyResponse.Survey_Taker__r.CreatedBy.Name : '';
            createdDate             = objSurveyResponse.Survey_Taker__r.CreatedDate != null ? objSurveyResponse.Survey_Taker__r.CreatedDate : null ;
            purposeOfVisit          = objSurveyResponse.Survey_Taker__r.Purpose_of_Visit__c != '' && objSurveyResponse.Survey_Taker__r.Purpose_of_Visit__c != null ? objSurveyResponse.Survey_Taker__r.Purpose_of_Visit__c : '';
            otherPleaseSpecify      = objSurveyResponse.Survey_Taker__r.Other_Please_Specify__c != '' && objSurveyResponse.Survey_Taker__r.Other_Please_Specify__c != null ? objSurveyResponse.Survey_Taker__r.Other_Please_Specify__c : '';
            
            custName                = objSurveyResponse.Survey_Taker__r.Customer_taking_Survey__r.Name != '' && objSurveyResponse.Survey_Taker__r.Customer_taking_Survey__r.Name  != null ? objSurveyResponse.Survey_Taker__r.Customer_taking_Survey__r.Name : '';

            projectName             = objSurveyResponse.Survey_Taker__r.Property__r.Name != '' && objSurveyResponse.Survey_Taker__r.Property__r.Name != null ? objSurveyResponse.Survey_Taker__r.Property__r.Name: '';
            bookingId               = objSurveyResponse.Survey_Taker__r.Booking_Unit__r.Name != '' && objSurveyResponse.Survey_Taker__r.Booking_Unit__r.Name != null ? objSurveyResponse.Survey_Taker__r.Booking_Unit__r.Name : '' ;
        }        

    }
    public class SurveyResponse {

        public String   response                    {get; set;}
        public SurveyResponse( Survey_Question__c objSurveyQuestion 
                             , Survey_Question_Response__c objSurveyResponse) {
            response                = objSurveyResponse.Response__c;
        }   


    }

}