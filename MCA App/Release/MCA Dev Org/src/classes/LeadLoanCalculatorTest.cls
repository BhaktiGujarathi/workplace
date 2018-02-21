@isTest
private  class LeadLoanCalculatorTest {
	static testmethod void testCallout() {
       
        // Set mock callout class 
        
		Lead objLead = new Lead(LastName = 'Test lead', Company = 'Test Cmp', Amount_Requested__c = 10000, Term_Requested__c = 12);
		insert objLead;
		
        test.startTest();
        	
       		PageReference pageReference = Page.LeadLoanCalculator;
       		pageReference.getParameters().put('id', objLead.Id);
       		test.setCurrentPageReference(pageReference);
       		Test.setMock(HttpCalloutMock.class, new LeadLoanCalculatorMockCallout());
       		ApexPages.StandardController scc = new ApexPages.StandardController(objLead);
       		new LeadLoanCalculatorController(scc);
       		
         test.stopTest();
    }
}