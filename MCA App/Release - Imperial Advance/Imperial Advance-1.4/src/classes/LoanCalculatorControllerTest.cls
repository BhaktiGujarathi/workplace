/**
 * Test class for LoanCalculatorController
 * 
 */
@isTest
private class LoanCalculatorControllerTest {

    static testmethod void testCallout() {
       
        // Set mock callout class 
        
        Opportunity  opp = new Opportunity (Name = 'Test Opp',Amount_Requested__c = 10000, Term_Requested__c = 12,
        									StageName= 'Prospecting', CloseDate = system.today());
        insert opp;

        test.startTest();
        	
        	PageReference pageRef = Page.LoanCalculator;
       		pageRef.getParameters().put('id', opp.Id);
       		test.setCurrentPageReference(pageRef);
       		
       		// Call method to test.
	        // This causes a fake response to be sent
	        // from the class that implements HttpCalloutMock. 
       		Test.setMock(HttpCalloutMock.class, new LoanCalculatorMockCallout());
       		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
       		new LoanCalculatorController(sc);
       		
         test.stopTest();
    }
}