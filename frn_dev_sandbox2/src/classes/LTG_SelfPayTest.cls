@isTest
private class LTG_SelfPayTest {
	@testSetup static void setup() {

	Opportunity testOppty = new Opportunity();
	testOppty = FRNTestDataFactory.opportunityForVFcontrollers();

	 Patient_Insurance__c testPatientIns2 = new Patient_Insurance__c();
	 testPatientIns2.VOB_status__c = 'Benefits Submitted' ;
	 testPatientIns2.Opportunity__c = testOppty.id;
	 insert testPatientIns2;

	 Patient_Insurance__c testPatientIns = new Patient_Insurance__c();
	 testPatientIns.VOB_status__c = 'VOB over 10 days' ;
	 testPatientIns.Opportunity__c = testOppty.id;

	 insert testPatientIns;
	 //Approval.lock(testPatientIns.id);

 }



	@isTest static void test_method_one() {
		// Implement test code
		Patient_Insurance__c objPatIns = [select id from Patient_Insurance__c where VOB_status__c = 'Benefits Submitted'];
		test.startTest();
		PageReference pageRef = Page.LTG_SelfPay;
		Test.setCurrentPage(pageRef);
   		pageRef.getParameters().put('id',objPatIns.id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objPatIns);
		LTG_SelfPay controller = new LTG_SelfPay(sc);
		controller.selfPAyMethod();

	}

	@isTest static void test_method_two() {
	// Implement test code
	Patient_Insurance__c objPatIns = [select id from Patient_Insurance__c where VOB_status__c = 'VOB over 10 days'];
	 //Approval.lock(objPatIns.id);
	test.startTest();
	PageReference pageRef = Page.LTG_SelfPay;
	Test.setCurrentPage(pageRef);
	pageRef.getParameters().put('id',objPatIns.id);
	ApexPages.StandardController sc = new ApexPages.standardController(objPatIns);
	LTG_SelfPay controller = new LTG_SelfPay(sc);
	controller.selfPAyMethod();

}

}