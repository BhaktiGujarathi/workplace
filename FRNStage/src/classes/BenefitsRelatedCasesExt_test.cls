@isTest
private class BenefitsRelatedCasesExt_test {
	
	static testMethod void myUnitTest(){

		String accRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
		Account acc = new Account();
			acc.Name = 'test_AccountName';
			acc.RecordTypeId  = accRT;
			acc.Phone  = '(012)-345-6769';
			insert acc;
			
		Contact con = new Contact();
			con.LastName='test';
			insert con;
	
		Opportunity opp = new Opportunity();
			opp.Name = 'test_OpportunityName';
			opp.AccountId = acc.Id;
			opp.StageName = 'Prospecting';
			opp.Probability = 70;
			opp.CloseDate = system.today();
			insert opp;
		
		Case ca = new Case();
			ca.Status = 'New';
			ca.Origin = 'Phone';
			ca.Subject = 'test_Subject';
			ca.AccountId = acc.id;
			ca.Opportunity__c = opp.id;
			insert ca;
			
		Patient_Insurance__c paIN = new Patient_Insurance__c();
			
			paIN.Name = 'test_patInsurance';
			paIN.Opportunity__c = opp.Id;
			paIN.Patient__c = con.Id;
			insert paIN;

		String inBenRT = Schema.SObjectType.Insurance_Benefit__c.getRecordTypeInfosByName().get('In Network').getRecordTypeId();		
		Insurance_Benefit__c inBen = new Insurance_Benefit__c();
			inBen.Patient_Insurance__c = paIN.id;			
			inBen.RecordTypeId  = inBenRT;		
			insert inBen;

		ApexPages.CurrentPage().getparameters().put('id',inBen.id);
		ApexPages.StandardController controller = new ApexPages.StandardController(inBen);	
		BenefitsRelatedCasesExt bRCE = new BenefitsRelatedCasesExt(controller);
         bRCE.caseDetail();
		
	}

}