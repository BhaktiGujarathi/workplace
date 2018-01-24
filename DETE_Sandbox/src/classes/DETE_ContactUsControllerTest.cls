
@isTest
private class DETE_ContactUsControllerTest {

    static testMethod void validtest() {
    	
        // TO DO: implement unit test
        DETE_ContactUsController controller = new DETE_ContactUsController();
        controller.stdCase.First_Name__c = 'first name';
        //controller.saveCommunityCase();
        controller.stdCase.SuppliedEmail = 'test@test.com';
        //controller.saveCommunityCase();
        //controller.stdCase.SuppliedEmail = 'test.com';
        controller.saveCommunityCase();
    }
}