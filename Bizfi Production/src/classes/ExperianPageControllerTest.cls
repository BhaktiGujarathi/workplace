@isTest
private class ExperianPageControllerTest {

	@testSetup
	static void dataSetup() {
		// data setup
		ExperianContactTestSetup.acctOppCon();

	}
	
	@isTest 
	static void test_method_one() {

		Callout_Settings__c cs = new Callout_Settings__c();
		cs.Experian__c = true;
		insert cs;
		
		Opportunity o = [SELECT Id, AccountId
						 FROM Opportunity 
						 ORDER BY Name LIMIT 1];

		ExperianContactTestSetup.conRoles(o);
		
		Integer conCount = [SELECT count() FROM OpportunityContactRole WHERE OpportunityId = :o.Id];
		System.assertEquals(2, conCount);


		test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(o);
		ExperianPageController epc = new ExperianPageController(sc);

		PageReference ref = Page.ExperianCalloutPage;
		ref.getParameters().put('id', o.Id);
		Test.setCurrentPage(ref);

		epc.autoRun();
		test.stopTest();

		Opportunity opp = [SELECT Send_to_Experian__c
						   FROM Opportunity 
						   ORDER BY Name LIMIT 1];

		System.assert(opp.Send_to_Experian__c);

	}
	
	@isTest 
	static void test_method_two() {
		
		Callout_Settings__c cs = new Callout_Settings__c();
		cs.Experian__c = false;
		insert cs;
		
		Opportunity o = [SELECT Id, AccountId
						 FROM Opportunity 
						 ORDER BY Name LIMIT 1];

		ExperianContactTestSetup.conRoles(o);
		
		Integer conCount = [SELECT count() FROM OpportunityContactRole WHERE OpportunityId = :o.Id];
		System.assertEquals(2, conCount);


		test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(o);
		ExperianPageController epc = new ExperianPageController(sc);

		PageReference ref = Page.ExperianCalloutPage;
		ref.getParameters().put('id', o.Id);
		Test.setCurrentPage(ref);

		epc.autoRun();
		test.stopTest();

		Opportunity opp = [SELECT Send_to_Experian__c
						   FROM Opportunity 
						   ORDER BY Name LIMIT 1];

		System.assert(!opp.Send_to_Experian__c);

	}

	@isTest
	static void test_method_three() {
		String errorMessage = 'There are no contacts related to this opportunity.  Add contacts if you want to pull credit';

		Callout_Settings__c cs = new Callout_Settings__c();
		cs.Experian__c = true;
		insert cs;
		
		Opportunity o = [SELECT Id, AccountId
						 FROM Opportunity 
						 ORDER BY Name LIMIT 1];


		test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(o);
		ExperianPageController epc = new ExperianPageController(sc);

		PageReference ref = Page.ExperianCalloutPage;
		ref.getParameters().put('id', o.Id);
		Test.setCurrentPage(ref);

		try{
			epc.autoRun();
		} catch (Exception e) {
			System.assertEquals(e.getMessage(), errorMessage);
		}
		
		test.stopTest();

	}
	
}