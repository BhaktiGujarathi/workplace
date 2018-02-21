@isTest
private class AchReturnsControllerTest {

    private static testMethod void myUnitTest() {
    	AchTestUtility utility = new AchTestUtility();
        utility.getTestReturn('test');
    	
    	ACHCredentials__c credential = new ACHCredentials__c();
    	credential.Active__c = true;
    	credential.company__c = 'Test company';
    	credential.companykey__c = 'test company key';
    	credential.LocID__c = '1234';
    	credential.Name = 'Test credential';
    	credential.sss__c = 'sss';
    	insert credential;
    	
    	
    }
}