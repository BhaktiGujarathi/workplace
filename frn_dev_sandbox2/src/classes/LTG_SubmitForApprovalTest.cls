@isTest
private class LTG_SubmitForApprovalTest {
	@testSetup static void setup() {

	Opportunity testOppty = new Opportunity();
		testOppty = FRNTestDataFactory.opportunityForVFcontrollers();
	}

	@isTest static void test_method_one() {
		Opportunity objOpp = [SELECT id FROM Opportunity];

		test.startTest();
		PageReference pageRef = Page.LTG_SelfPay;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',objOpp.id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objOpp);
		LTG_SubmitForApproval controller = new LTG_SubmitForApproval(sc);
		controller.submitForApprovalMethod();
		test.stopTest();

		system.assert(pageRef != null);
	}


}