@isTest
private class LTG_SubmitBenefitTest {

	@testSetup static void setup() {

		Call_in_Code__c testCallingCode = new Call_in_Code__c();
		testCallingCode.Name = 'calling code';
		insert testCallingCode;

		Contact testcont = new Contact();
		testcont.LastName = 'test contact';
		testcont.Gender__c = 'Male';
		insert testcont;

	 	Id strRecordTypeId = [Select Id From RecordType Where SobjectType = 'opportunity' and Name = 'Residential Treatment'].Id;

		Opportunity  testOppty = new Opportunity();
		  testOppty.name='testOppty';
		 // testOppty.AccountId=acc.id;
		  testOppty.StageName='Open';
		  testOppty.CloseDate=System.today();
		  testOppty.Call_in_Code__c = testCallingCode.id;
		  testOppty.Probability = 10;
		  testOppty.RecordTypeId = strRecordTypeId;
		  insert testOppty;

		  Patient_Insurance__c testPatientIns = new Patient_Insurance__c();
		  testPatientIns.VOB_status__c = 'VOB over 10 days' ;
		  testPatientIns.Opportunity__c = testOppty.id;
		  insert testPatientIns;

		  Patient_Insurance__c testPatientIns2 = new Patient_Insurance__c();
		 testPatientIns2.VOB_status__c = 'Benefit Submitted' ;
		 testPatientIns2.Opportunity__c = testOppty.id;
		 insert testPatientIns2;





	}

	@isTest static void test_method_one() {

		List<Contact> contactList = new List<Contact>();
	        contactList = FRNTestDataFactory.createContactList(1);
	        insert contactList;

	        // List<Opportunity> opportunityList = new List<Opportunity>();
	        // opportunityList = FRNTestDataFactory.createOpportunityList(1);
			Opportunity objOpp = [SELECT Id FROM Opportunity WHERE Name = 'testOppty'];
	        objOpp.Contact__c = contactList[0].Id;
	        objOpp.Readmit__c = 'Yes';
	        update objOpp;


		test.startTest();
		PageReference pageRef = Page.LTG_Submit_Benefits;
		Test.setCurrentPage(pageRef);
   		pageRef.getParameters().put('id',objOpp.Id);
   		ApexPages.StandardController sc = new ApexPages.standardController(objOpp);
   		LTG_SubmitBenefits  controller = new LTG_SubmitBenefits(sc);
		String resultStr = OpportunityFieldValidationService.validateForNullValue(objOpp.Id);
   		System.assertNotEquals(null,controller.SubmitBenefits());
		test.stopTest();

		// Implement test code
	}
	@isTest static void test_method_two() {

		List<Contact> contactList = new List<Contact>();
        contactList = FRNTestDataFactory.createContactList(1);
        insert contactList;

		contactList[0].Social_Security_Number__c = 'test#';
		update contactList[0];

        // List<Opportunity> opportunityList = new List<Opportunity>();
        // opportunityList = FRNTestDataFactory.createOpportunityList(1);

		Opportunity objOpp = [SELECT Id FROM Opportunity WHERE Name = 'testOppty'];
        objOpp.Contact__c = contactList[0].Id;
        objOpp.Readmit__c = 'Yes';
        update objOpp;
		String oppid = objOpp.id;

		String uid = UserInfo.getUserId();
		User u1 = [Select id from User where id =: uid];
		System.runAs(u1) {
		UserRole r = new UserRole(Name = 'CEO');
		insert r;

		 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
	     User u = new User(Alias = 'standt', UserRoleId = r.Id, Email='test1234@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testorg.com');

		test.startTest();

		PageReference pageRef = Page.LTG_Submit_Benefits;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',objOpp.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(objOpp);
		LTG_SubmitBenefits  controller = new LTG_SubmitBenefits(sc);
		String resultStr = OpportunityFieldValidationService.validateForNullValue(objOpp.Id);
		string redirect = OppShareContr.shareOpportunity(oppid);
		System.assertNotEquals(null,controller.SubmitBenefits());
		test.stopTest();

	// Implement test code
}


}
}