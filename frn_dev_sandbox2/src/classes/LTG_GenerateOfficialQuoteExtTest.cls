@isTest
private class LTG_GenerateOfficialQuoteExtTest {
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

		 Pay_Agreement_Worksheet__c testPayAgrmnt = new Pay_Agreement_Worksheet__c();
		 testPayAgrmnt.Opportunity__c = testOppty.id;
		 testPayAgrmnt.Patient_Insurance__c = testPatientIns2.id;
		 testPayAgrmnt.Status__c = 'Open';
		 insert testPayAgrmnt;
	}

	@isTest static void nullCheckMethod() {
		Opportunity objOpp = [SELECT id  from opportunity];
		Pay_Agreement_Worksheet__c objPAW = [SELECT Opportunity__c,Status__c
                 							FROM Pay_Agreement_Worksheet__c];
		Patient_Insurance__c objPatIns = [select id from Patient_Insurance__c where VOB_status__c = 'Benefits Submitted'];

		test.startTest();
		PageReference pageRef = Page.LTG_Generate_Official_Quote;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',objPAW.id);
		ApexPages.StandardController sc = new ApexPages.standardController(objPAW);
		String redirect1 = BenefitsVOBStatus.VOBStatusCheck(objPAW.Opportunity__c);
		String st = objPAW.Status__c;
		Boolean generateQuoteButton ;
		String redirect = GenerateQuoteCont.createQuote(objPAW.id,generateQuoteButton);
		LTG_GenerateOfficialQuoteExt controller = new LTG_GenerateOfficialQuoteExt(sc);
		controller.generateOfficialQuoteMethod();

		System.assert(controller.generateOfficialQuoteMethod() != null);

	}

	@isTest static void test_method_two() {
		// Implement test code
	}

}