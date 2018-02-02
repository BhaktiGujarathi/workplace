@isTest
public class SatisfactionSurveyControllerTest {
  Static testMethod void SatisfactionSurveyController_Test()
    {
        SatisfactionSurveyController ssc= new SatisfactionSurveyController();  
        ssc.submitAccountSurvey();
        AccountSurveyUpload aas = new AccountSurveyUpload(ssc); 
         aas.saveSurvey();
    }
}