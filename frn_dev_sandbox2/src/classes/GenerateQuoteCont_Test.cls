@isTest
private class GenerateQuoteCont_Test
{

    static testMethod void test1 () 
    {
		opportunity opp = new opportunity();
		opp.Name = 'test';
		opp.CloseDate = System.today();
		opp.StageName = 'Prospecting';
		insert opp;
		
		Account acc = new Account();
		acc.Name = 'test';
		insert acc;
		
		Facility_Program__c fat = new Facility_Program__c();
		fat.Name = 'test';
		fat.FRN_Facility__c = acc.Id;
		insert fat;
		
		Patient_Insurance__c pat = new Patient_Insurance__c();
		pat.Name = 'test';
		pat.Insurance_Company__c = acc.Id;
		pat.opportunity__c = opp.Id;
		insert pat;
		
		Pay_Agreement_Worksheet__c pay = new Pay_Agreement_Worksheet__c();
		pay.Facility_Program__c=fat.Id;
		pay.FRN_Facility__c=acc.Id;
		pay.Patient_Insurance__c=pat.Id;
		insert pay;
		Pricebook2 pb = new Pricebook2( name ='FRN Price Book', isActive =true);
		insert pb;
		  
		 GenerateQuoteCont.createQuote(pay.id+'',false);
		 GenerateQuoteCont.createQuote(pay.id+'',true);
		
	}
 }