@isTest
private class PrintQuotePDFController_Test 
{
 
    Static testMethod void Test()
    { 
	
	Opportunity opp = new Opportunity(Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting');
	insert opp;
	
	Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c=opp.Id,Lifetime_Max__c=10.00,Annual_Max__c=10.00,Co_Pay__c=10.00,Out_of_Pocket_Max__c=10.00,Out_of_Pocket_Max_Met__c=10.00,Co_Pay_Met__c=10.00,Co_Pay_Remaining__c=10.00,Deductible__c=10.00,Deductible_Included_in_OOP__c='No',Deductible_Met__c=10.00);  
    insert paw;
		
	 Account acc = new Account(Name='test',Phone='12345',Type='TV',Master_Referral_Type__c='Judge');
	insert acc;
		
	Facility_Program__c fc = new Facility_Program__c(Name='test',FRN_Facility__c=acc.Id);
	insert fc;
	
	
	
	Quote QuoteObj = new Quote (Name='test',Type__c='Draft',Determination_Script_Read_to_Patient__c='Yes',Select_as_Final_Quote__c=true,FRN_Facility__c=acc.Id,Facility_Program__c=fc.Id,OpportunityId=opp.Id);		
	insert QuoteObj;
	
		
	ApexPages.StandardController  sc = new ApexPages.StandardController(QuoteObj);
		PrintQuotePDFController pqc = new PrintQuotePDFController();
	
	}
	
	
}