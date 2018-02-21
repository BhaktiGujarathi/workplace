@isTest
public with sharing class BankDirectoryServiceTest {
	
	
	private static void setup(Boolean isAPIExposed) {
		Bank__c[] banks = new Bank__c[]{};
		for (Integer i = 0; i < 100; i++) {
		    Bank__c bank = new Bank__c();
		    bank.Name = 'Test Bank' + String.valueOf(i);
		    bank.Billing_City__c = 'Test city ' + String.valueOf(i);
			bank.Billing_Postal_Code__c = 'Test Postal Code ' + String.valueOf(i);
			bank.Billing_State__c = 'Test State ' + String.valueOf(i);
			bank.Billing_Street__c = 'Test Street ' + String.valueOf(i);
			bank.Email__c = 'Test' + String.valueOf(i) + '@Test.com';
			bank.Phone__c = '12345667890';
			bank.WebSite__c = 'Test WebSite ' + String.valueOf(i);    
			bank.API_Exposed__c = isAPIExposed;
		    banks.add(bank);
		}
		insert banks;

		banks = [select Id, Bank_Id__c, Name from Bank__c where Id = :banks];

		Program__c[] programs = new Program__c[]{};
		for (Bank__c b : banks) {
    		for (Integer i = 0; i < 2; i++) {
		        Program__c program = new Program__c();
		        program.Name = 'Test Program ' + String.valueOf(i) + ' ' + b.Name;
		        program.External_Bank__c = b.Id;
		        program.BK_Policy__c = 'Test Policy ' + String.valueOf(i);
		        program.Funding_Amt_of_Monthly_Gross_Sales__c = 1000;
		        program.Max_Amount__c = 1000;
		        program.Max_No_NSFs__c = 10000;
		        program.Methods_of_Repayment__c = 'Test Repayment Method ' + String.valueOf(i);
		        program.Min_Avg_Daily_Bal__c = 10000;
		        program.Credit_Score__c = 10000;
		        program.Min_Credit_Score__c = 10000;
		        program.Minimum_Deposit_Count__c = 1000;
		        program.Min_Monthly_CC_Avg__c = 2000;
		        program.Min_Monthly_Deposits__c = i;
		        program.Years_in_Business__c = i;
		        program.Minimum_Advance__c = 100000;
		        program.Notes__c = 'Test Notes ' + String.valueOf(i);
		        program.Ownership_Percentage_Requirement__c = 50;
		        program.Percentage_Net_After_Payoff__c = 20;
		        program.Restricted_Industry_List__c = 'Test Restricted Industry ' + String.valueOf(i);
		        program.Restricted_States__c = 'Test Restricted States ' + String.valueOf(i);
		        program.Site_Inspection__c = true;
		        program.Submission_Email__c = 'test' + String.valueOf(i) + '@test.com';
		        program.Tax_Lean_Policy__c = 'Test Tax ' + String.valueOf(i);
		        program.Trade_References__c = 'Test Trade References ' + String.valueOf(i);
		        program.Transaction_Count__c = i;
		        program.Turnaround_Time__c = i;
		        program.Ready_To_Send__c = true;
		        programs.add(program);
    		}
		}
		insert programs;
		
		programs = [select Id, Program_Id__c, Name from Program__c where Id = :programs];

		Required_Documents__c[] requiredDocuments = new Required_Documents__c[]{};

		for (Program__c prog : programs) {
		    for (Integer i = 0; i < 2; i++) {
		        Required_Documents__c document = new Required_Documents__c();
		        document.Name = 'Test Required Document ' + String.valueOf(i) + prog.Name;
		        document.Program__c = prog.Id;
		        requiredDocuments.add(document);
		    }
		}

		insert requiredDocuments;	
	}


	@isTest
	public static void testBankDirectoryServiceNoExposed() {
		setup(false);

		Test.startTest();

		Bank[] banks = BankDirectoryService.doGet(0);
		System.assertEquals(banks.size(), 0);

		Test.stopTest();
	}


	@isTest
	public static void testBankDirectoryServiceExposed() {
		setup(true);

		Test.startTest();

		Bank[] banks = BankDirectoryService.doGet(0);
		System.assertEquals(banks.size(), 100);

		Test.stopTest();
	}	
}