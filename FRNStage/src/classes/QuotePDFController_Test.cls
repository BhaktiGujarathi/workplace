@isTest
public class QuotePDFController_Test{
	static testMethod void test1(){
		String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance Company').getRecordTypeId(); 
		Account acc = new Account(RecordTypeId = acRT,Name = 'Name_test');
		insert acc;

		String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
		Contact con = new Contact(AccountId  = acc.Id,RecordTypeId  = coRT,LastName = 'test__fName',FirstName  = 'test__lName',Birthdate  = system.today());
		insert con;

		String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();   
		Opportunity opp = new Opportunity(Name = 'test_OpportunityName',Contact__c = con.Id,StageName = 'Prospecting',Probability = 70,CloseDate = system.today(),RecordTypeId  = opRT);
		insert opp;

		Facility_Program__c fP = new Facility_Program__c(FRN_Facility__c = acc.Id,Name = 'Name_test');
		insert fP;

		Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Deductible__c = 40,Deductible_Met__c = 80,Plan_Coverage__c = 500,Room_and_Board_Fees__c = 700);
		insert PAW;

		Quote quo = new Quote(OpportunityId = opp.Id,Name = 'Test',FRN_Facility__c = acc.Id,Facility_Program__c = fp.Id,Insurance_Company_Contract_Type__c = 'In Network',Pay_Agreement_Worksheet__c = PAW.Id);
		insert quo;

		Facility_Program_Determination_Script__c fpds = new Facility_Program_Determination_Script__c(Determination_Script__c = 'Test {Quote.Name} and {Quote.Pay_Agreement_Worksheet__r.Name}',Facility_Program__c = fp.Id , Contract_Type__c='In Network');
		insert fpds;

		PageReference pageRef = Page.QuotePDF;
		Test.setCurrentPage(pageRef); 
		//pageRef.getParameters().put('Id', quo.id);
		ApexPages.currentPage().getParameters().put('id', quo.id);

		QuotePDFController obj = new QuotePDFController();		
		//obj.getFinalValue();
		obj.savePdf();
	} 
}