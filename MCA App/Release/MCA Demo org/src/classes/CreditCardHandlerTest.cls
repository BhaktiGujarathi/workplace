public with sharing class CreditCardHandlerTest {
	// Create test data for Credit Card
	static list<Credit_Card__c> prepareCreditCardTestData(Integer no){
		list<Credit_Card__c> lstCreditCard = new list<Credit_Card__c>();
		Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount;
        Credit_Card__c objCreditCard = new Credit_Card__c();
        for(Integer i=0; i<no; ++i)
        {
        	objCreditCard = new Credit_Card__c(Account__c=objAccount.Id, Year__c='2013'+i, Month__c='July');
        	lstCreditCard.add(objCreditCard);
        }
        insert lstCreditCard;
		return lstCreditCard;
		
	}
	// Create test data for Bank Account
	static list<Bank_Account__c> prepareBankStmtsTestData(Integer no){
		list<Bank_Account__c> lstBankAccount = new list<Bank_Account__c>();
		Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount;
        Bank_Account__c objBankAccount = new Bank_Account__c();
        for(Integer i=0; i<no; ++i)
        {
        	objBankAccount = new Bank_Account__c(Account__c=objAccount.Id, Year__c='2013'+i, Month__c='July');
        	lstBankAccount.add(objBankAccount);
        }
        insert lstBankAccount;
		return lstBankAccount;
	}
	//Test whether count of Credit Card Statements is increasing or decreasing on creation or deletion of Credit card record.
	 static testMethod void testNumberofCreditCardStatements(){
	 	
	 	list<Credit_Card__c> lstCreditCard = prepareCreditCardTestData(2);
	 	Account objAcc;
	 	Test.startTest(); 
		objAcc = [Select Name,Number_CC_Statements_Available__c from Account where Id =: lstCreditCard[0].Account__c];
		//Test the count of Credit Card at inially
		system.assertEquals(2, objAcc.Number_CC_Statements_Available__c);
		
		delete lstCreditCard[1];
		objAcc = [Select Name,Number_CC_Statements_Available__c from Account where Id =: lstCreditCard[0].Account__c];
		//Test the count of Credit Card after deleting a record of Credit card
		system.assertEquals(1, objAcc.Number_CC_Statements_Available__c);
		
		Account objAccount = new Account(Name='TestAccount', Type='Analyst', Industry='Energy');
        insert objAccount;
        
		lstCreditCard[0].Account__c = objAccount.Id;
		update lstCreditCard[0];
		
		objAcc = [Select Name,Number_CC_Statements_Available__c from Account where Id =: lstCreditCard[0].Account__c];
		//Test the count of Credit Card after changing the account lookup
		system.assertEquals(1, objAcc.Number_CC_Statements_Available__c);
		
		Test.stopTest();
	 }
	 //Test whether count of Bank Statements is increasing or decreasing on creation or deletion of Bank Account record.
	 static testMethod void testNumberofBankStatements(){
	 	list<Bank_Account__c> lstBankAccount = prepareBankStmtsTestData(2);
	 	Account objAcc;
	 	Test.startTest(); 
		objAcc = [Select Name,Number_Bank_Statements_Available__c from Account where Id =: lstBankAccount[0].Account__c];
		//Test the count of Bank Stmts at initially
		system.assertEquals(2, objAcc.Number_Bank_Statements_Available__c);
		
		delete lstBankAccount[1];
		objAcc = [Select Name,Number_Bank_Statements_Available__c from Account where Id =: lstBankAccount[0].Account__c];
		//Test the count of Bank Stmts after deleting a record of Bank Stmt
		system.assertEquals(1, objAcc.Number_Bank_Statements_Available__c);
		
		Account objAccount = new Account(Name='TestAccount', Type='Analyst', Industry='Energy');
        insert objAccount;
        
		lstBankAccount[0].Account__c = objAccount.Id;
		update lstBankAccount[0];
		
		objAcc = [Select Name,Number_Bank_Statements_Available__c from Account where Id =: lstBankAccount[0].Account__c];
		system.assertEquals(1, objAcc.Number_Bank_Statements_Available__c);
		
		Test.stopTest();
	 }
}