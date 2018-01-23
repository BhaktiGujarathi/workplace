public class AccountSurveyUpload {


    Public Account_Satisfaction_Survey__c objSurvey {get; set;}
    Public AccountSurveyUpload(SatisfactionSurveyController stdCon){
        objSurvey = new Account_Satisfaction_Survey__c();
    }
    Public PageReference saveSurvey(){
        insert objSurvey;
       
        return new PageReference('/surveysubmissioncomplete');
    }
}