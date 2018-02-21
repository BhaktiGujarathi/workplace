public class SurveyProcessController {
    
    public List<SurveyQuestion> allQuestions    {get; set;}
    public String userId                        {get; set;}
    public String userName                      {get; set;}
    public String  surveyThankYouText           {get; set;}
    public Boolean thankYouRendered             {get; set;}
    public Boolean isError                      {get; set;}
    public Survey__c survey                     {get; set;}
    public Boolean isPortalSurvey               {get; set;}
    public Survey_Taken__c surveyTaken          {get; set;}
    
    public SurveyProcessController() {
        isPortalSurvey = false;
        String surveyType = ApexPages.currentPage().getParameters().get('type');
        if(surveyType != null && surveyType.equalsIgnoreCase('Portal')){
            isPortalSurvey = true;
        }else{
            surveyType = 'Walk-In';
        }
        
        List<Survey__c> surveyList = [Select Id,Name,Hide_Survey_Name__c,Survey_Header__c,Thank_You_Text__c,Description__c from Survey__c
                                      where Is_Active__c = True and Type__c =: surveyType and End_Date__c > :System.Today() and Start_Date__c < :System.Today()];
                                      
        
        surveyTaken = new Survey_Taken__c();
        
        if(surveyList != null && surveyList.size()>0){
            
            
            survey = surveyList[0];
            
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SurveyQuestion>();
            getQuestion();
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
            
            thankYouRendered = false;
            isError = false;
        }

    }
    
    /** Fills up the List of questions to be displayed on the Visualforce page
    */   
    public List<SurveyQuestion> getQuestion() {
        
        List<Survey_Question__c> allQuestionsObject = [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, s.Order_Number_Displayed__c,
                                                       s.OrderNumber__c, s.Name, s.Choices__c,Choice_for_Additional_Textbox__c,Survey_Question__c,Additional_Description__c
                                                       From Survey_Question__c s 
                                                       WHERE s.Survey__c =: survey.Id ORDER BY s.OrderNumber__c];
        allQuestions = new List<SurveyQuestion>();
        List<Survey_Question__c> parentQuestions = new List<Survey_Question__c>();
        Map<Id,List<Survey_Question__c>> mapParentIdToChildQuestions = new Map<Id,List<Survey_Question__c>>();
        for (Survey_Question__c q : allQuestionsObject){ 
            if(q.Survey_Question__c == null){
                parentQuestions.add(q);
            }else{
                if(mapParentIdToChildQuestions.get(q.Survey_Question__c) == null){
                    mapParentIdToChildQuestions.put(q.Survey_Question__c,new List<Survey_Question__c>());
                }
                mapParentIdToChildQuestions.get(q.Survey_Question__c).add(q);
            }
        }
        
        for (Survey_Question__c q : parentQuestions){ 

            List<SurveyQuestion> subQuestionWrapper = new List<SurveyQuestion>();
            List<Survey_Question__c> subQuestions = mapParentIdToChildQuestions.get(q.Id);
            if(subQuestions != null && subQuestions.size() >0){
                for (Survey_Question__c question : subQuestions){
                    subQuestionWrapper.add(new SurveyQuestion(question,NULL));
                }
            }
  
            SurveyQuestion theQ = new SurveyQuestion(q,subQuestionWrapper);
            allQuestions.add(theQ);
        }
        return allQuestions;
    }  
    
    public void checkLoamsQuestions(){
        allQuestions = new List<SurveyQuestion>();
        List<Survey__c> surveyList = new List<Survey__c>();
        if(surveyTaken.Purpose_of_Visit__c != null && surveyTaken.Purpose_of_Visit__c.equalsIgnoreCase('LOAMS')){
            surveyList = [Select Id,Name,Hide_Survey_Name__c,Survey_Header__c,Thank_You_Text__c,Description__c
                          from Survey__c where Is_Active__c = True and Type__c = 'Portal - LOAMS' and End_Date__c > :System.Today() and Start_Date__c < :System.Today()];
        } else {
            surveyList = [Select Id,Name,Hide_Survey_Name__c,Survey_Header__c,Thank_You_Text__c,Description__c
                          from Survey__c where Is_Active__c = True and Type__c = 'Portal' and End_Date__c > :System.Today() and Start_Date__c < :System.Today()];
        }
        
        if(surveyList != null && surveyList.size()>0){
            
            
            survey = surveyList[0];
            
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SurveyQuestion>();
            getQuestion();
        }
    }
    
    public void populateCustomerDetails(){
        
        List<Booking_Unit__c> listBookingUnit = [Select Id,Inventory__r.Property__c,Booking__r.Account__c ,Booking__r.Account__r.Phone
                                                 from Booking_Unit__c where Id = : surveyTaken.Booking_Unit__c];
        if(listBookingUnit != null && listBookingUnit.size() > 0){
            if(surveyTaken.Property__c == null){
                surveyTaken.Property__c = listBookingUnit[0].Inventory__r.Property__c;
            }
            if(surveyTaken.Customer_taking_Survey__c == null){
                surveyTaken.Customer_taking_Survey__c = listBookingUnit[0].Booking__r.Account__c;
            }
            if(surveyTaken.Phone__c == null){
                surveyTaken.Phone__c = listBookingUnit[0].Booking__r.Account__r.Phone;
            }
        }
    }

    public void submitResults() {
        
        try {
            List <Survey_Question_Response__c> sqrList = new List<Survey_Question_Response__c>();
            
            List<SurveyQuestion> allCombinedQuestions = new List<SurveyQuestion>();
            allCombinedQuestions.addAll(allQuestions);
            
            for (SurveyQuestion question : allQuestions) {
                if(question.isSubQuestion){
                    allCombinedQuestions.addAll(question.subQuestions);
                }
            }
            
            for (SurveyQuestion q : allCombinedQuestions) {
                if(q.surveyQuestion.Type__c != 'Section'){
                    Survey_Question_Response__c sqr = new Survey_Question_Response__c();
                    if(q.choiceForAdditionalTextbox != null && q.choiceForAdditionalTextbox != '' && q.additionalResponse != ''){
                        sqr.Additional_Response__c = q.additionalResponse;
                    }
                    if (q.renderSelectRadio) {
    
                        if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                            isError = true;
                            return;
                        }
    
                        if (q.selectedOption == null || q.selectedOption == '') {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    } else if (q.renderPicklist) {
    
                        if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                            isError = true;
                            return;
                        }
    
                        if (q.selectedOption == null || q.selectedOption == '') {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    } else if (q.renderFreeText) {
                        if (q.required && q.choices == '') {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                            isError = true;
                            return;
                        }
    
                        sqr.Response__c = q.choices;
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    } else if (q.renderSelectCheckboxes) {
                        if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                            isError = true;
                            return;
                        }
    
                        for (String opt : q.selectedOptions) {
                            sqr = new Survey_Question_Response__c();
                            if (opt == '' || opt == null) {
                                sqr.Response__c = '';
                            } else {
                                sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                            }
                            sqr.Survey_Question__c = q.Id;
                        }
                        sqrList.add(sqr);
                    } else if (q.renderSelectRow) {
                        if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                            isError = true;
                            return;
                        }
    
                        if (q.selectedOption == null || q.selectedOption == '') {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    }
                }
            }
            if(isPortalSurvey){
                surveyTaken.User_taking_Survey__c = UserInfo.getUserId();
            } else {
                system.debug(' isError : ' + isError );
                system.debug(' surveyTaken.Booking_Unit__c : ' + surveyTaken.Booking_Unit__c );
                if ( surveyTaken.Booking_Unit__c == null  ) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                    isError = true;
                    return;
                }

                if ( surveyTaken.Customer_taking_Survey__c == null  ) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                    isError = true;
                    return;
                }

                if ( surveyTaken.Property__c == null  ) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                    isError = true;
                    return;
                }            

                if ( surveyTaken.Phone__c == null  ) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields marked with asterisk'));
                    isError = true;
                    return;
                }
            }
            surveyTaken.Survey__c = survey.Id;
            insert surveyTaken;
            
            for (Survey_Question_Response__c sqr : sqrList)
            {
                sqr.Survey_Taker__c = surveyTaken.Id;
            }
            insert sqrList;
            isError = false;
            thankYouRendered=true;

            
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'));
        }

    }
    
}