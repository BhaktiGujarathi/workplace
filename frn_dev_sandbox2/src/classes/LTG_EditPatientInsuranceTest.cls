@isTest
private class LTG_EditPatientInsuranceTest {
	@testSetup static void setup() {

		Opportunity testOppty = new Opportunity();
	    testOppty = FRNTestDataFactory.opportunityForVFcontrollers();

		 Patient_Insurance__c testPatientIns2 = new Patient_Insurance__c();
		 testPatientIns2.VOB_status__c = 'Benefits Submitted' ;
		 testPatientIns2.VOB_Assigned__c = UserInfo.getUserId();
		 testPatientIns2.Opportunity__c = testOppty.id;
		 insert testPatientIns2;

		 Patient_Insurance__c testPatientIns = new Patient_Insurance__c();
		 testPatientIns.VOB_status__c = 'VOB over 10 days' ;
		 testPatientIns.Opportunity__c = testOppty.id;
		 insert testPatientIns;
	}
	@isTest static void test_method_one() {
		Patient_Insurance__c objPatIns = [SELECT id from Patient_Insurance__c where VOB_status__c = 'Benefits Submitted'];
		test.startTest();
		Approval.lock(objPatIns.Id);
		PageReference pageRef = Page.LTG_EditPatientInsurance;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',objPatIns.id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objPatIns);
		LTG_EditPatientInsurance controller = new LTG_EditPatientInsurance(sc);
		controller.editPatientInsuranceMethod();
		test.stopTest();
		//system.assert(pageRef != null);
	}

	@isTest static void test_method_two() {
		Patient_Insurance__c objPatIns = [SELECT id from Patient_Insurance__c where VOB_status__c = 'VOB over 10 days'];
		test.startTest();
		Approval.lock(objPatIns.Id);
		PageReference pageRef = Page.LTG_EditPatientInsurance;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',objPatIns.id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objPatIns);
		LTG_EditPatientInsurance controller = new LTG_EditPatientInsurance(sc);
		controller.vobEuqalsNullMethod();
		test.stopTest();
		//system.assert(pageRef != null);
	}

}