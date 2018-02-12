@isTest
private class LTG_NewPatientInsuranceTest {

	@testSetup static void setup() {
		Call_in_Code__c testCallingCode = new Call_in_Code__c();
		testCallingCode.Name = 'calling code';
		insert testCallingCode;

		Id strRecordTypeId = [Select Id From RecordType Where SobjectType = 'opportunity' and Name = 'Residential Treatment'].Id;


		Opportunity  testOppty = new Opportunity();
		  testOppty.name='testOppty';
		 // testOppty.AccountId=acc.id;
		  testOppty.StageName='Open';
		  testOppty.CloseDate=System.today();
		  testOppty.Call_in_Code__c = testCallingCode.id;
		  testOppty.RecordTypeId = strRecordTypeId;
		  insert testOppty;
	}

	@isTest static void test_method_one() {
		// Implement test code
		Opportunity objOpp = [SELECT id FROM Opportunity WHERE name = 'testOppty'];

		test.startTest();
		PageReference pageRef = Page.LTG_Submit_Benefits;
		Test.setCurrentPage(pageRef);
   		pageRef.getParameters().put('id',objOpp.id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objOpp);
		LTG_NewPatientInsurance controller = new LTG_NewPatientInsurance(sc);
		controller.NewPatientInsuranceMethod();
	}


}