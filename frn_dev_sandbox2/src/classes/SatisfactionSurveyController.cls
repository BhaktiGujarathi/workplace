public class SatisfactionSurveyController {

public Account_Satisfaction_Survey__c s { get; set; }
	
	public SatisfactionSurveyController () {
		s = new Account_Satisfaction_Survey__c();
    }

	public PageReference submitAccountSurvey() {
				INSERT s;
                return new PageReference('/surveysubmissioncomplete');
		}
	
}