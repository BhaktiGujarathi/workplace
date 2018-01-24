/**
 * This class contains unit tests for validating the behavior of AdminPageController
 * 
 *	Date - 12-02-2014
 *
 *	Created By - Sneha P.
 */
@isTest
private class AdminPageControllerTest {
	static testMethod void myUnitTest() {
		AdminAccountingSetting__c adminSetting = new AdminAccountingSetting__c(Name = 'Test',URL__c ='www.google.com' );
		insert adminSetting;
		
		AdminPipelineSetting__c pipelineSetting = new AdminPipelineSetting__c(Name = 'Test',URL__c ='www.yahoo.com'  );
		insert pipelineSetting;
		
		AdminReportSetting__c reportSetting = new AdminReportSetting__c(Name = 'Test Report Setting', URL__c ='www.test.com');
		insert reportSetting;
		
		AdminSetupSetting__c setupSetting = new AdminSetupSetting__c(Name = 'Test Setup Setting', URL__c ='www.gmail.com');
		insert setupSetting;
		
		AdminPageController cntl = new AdminPageController();
		
		system.assert(cntl.mapReportSetting.size() == 1);
	}
}