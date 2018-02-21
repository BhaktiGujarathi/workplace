@isTest
private class VerificationActionLinkTest {
	
	@isTest static void testActionLink() {
		
		VerificationMaster__c vMaster = new VerificationMaster__c();
        vMaster.Action_Link__c = 'http://google.com/{!Id}';
        insert vMaster;

        UWVerification__c verification = new UWVerification__c();
        verification.VerificationMaster__c = vMaster.Id;
        insert verification;

        ApexPages.currentpage().getParameters().put('vid', verification.Id);

		ApexPages.StandardController std = new ApexPages.StandardController(verification);
		VerificationActionLinkController controller = new VerificationActionLinkController(std);
		controller.goToUrl();
	}

	@isTest static void testActionLinkWithoutParams() {
		
		VerificationMaster__c vMaster = new VerificationMaster__c();
        vMaster.Action_Link__c = 'www.google.com/{!Sort_Order__c}';
        insert vMaster;

        UWVerification__c verification = new UWVerification__c();
        verification.VerificationMaster__c = vMaster.Id;
        insert verification;

        ApexPages.currentpage().getParameters().put('vid', verification.Id);

		ApexPages.StandardController std = new ApexPages.StandardController(verification);
		VerificationActionLinkController controller = new VerificationActionLinkController(std);
		controller.goToUrl();
	}

	@isTest static void testActionLinkWithoutMaster() {
		
        UWVerification__c verification = new UWVerification__c();
        verification.VerificationMaster__c = null;
        insert verification;

        ApexPages.currentpage().getParameters().put('vid', verification.Id);

		ApexPages.StandardController std = new ApexPages.StandardController(verification);
		VerificationActionLinkController controller = new VerificationActionLinkController(std);
		controller.goToUrl();
	}

	@isTest static void testActionLinkWithoutMasterAndVid() {
		
        UWVerification__c verification = new UWVerification__c();
        verification.VerificationMaster__c = null;
        insert verification;

        //ApexPages.currentpage().getParameters().put('vid', 'null');

		ApexPages.StandardController std = new ApexPages.StandardController(verification);
		VerificationActionLinkController controller = new VerificationActionLinkController(std);
		controller.goToUrl();
	}



	
}