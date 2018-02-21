/**
 *
 * Description :
 *  1.Test class to test the functionality of the trigger service class.
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0
 *
 *    1.1      Ashwini Singh          26/10/2015            Test class to test the functionality of 
 *                                                          the trigger service class
 *
 **/
 
@isTest
private class BankAccountHandlerServiceAfterTest {

    //method to test the functionality of trigger on insertion of Bank Account statement records
    static testMethod void insertationOfBankStatement() {
        
        List<Account> listAccount = TestDataUtility.getAccountRecords(1);
        insert listAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = listAccount[0].Id;
        insert listOpportunity;
        List<Bank_Account__c> listBankStatement = TestDataUtility.getBankStatementRecords(5, listOpportunity[0].id);
        listBankStatement[0].Month__c = '03 - March';
        listBankStatement[1].Month__c = '03 - March';
        Test.startTest();
            insert listBankStatement;
        Test.stopTest();
    }
    
    //method to test the functionality of trigger on updation of Bank Account statement records
    static testMethod void updationOfBankStatement() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(1);
        insert listAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = listAccount[0].Id;
        insert listOpportunity;
        List<Bank_Account__c> listBankStatement = TestDataUtility.getBankStatementRecords(5, listOpportunity[0].id);
        insert listBankStatement;
        listBankStatement[0].Month__c = '03 - March';
        listBankStatement[1].Month__c = '03 - March';
        CheckRecursive.runAfter = true;
        CheckRecursive.runBefore = true;
        Test.startTest();
            update listBankStatement;
        Test.stopTest();
    }
    
    //method to test the functionality of trigger on deletion of Bank Account statement records
    static testMethod void deletionOfBankStatement() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(1);
        insert listAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = listAccount[0].Id;
        insert listOpportunity;
        List<Bank_Account__c> listBankStatement = TestDataUtility.getBankStatementRecords(5, listOpportunity[0].id);
        listBankStatement[0].Month__c = '03 - March';
        listBankStatement[1].Month__c = '03 - March';
        insert listBankStatement;
        CheckRecursive.runBefore = true;
        CheckRecursive.runAfter = true;
        Test.startTest();
            delete listBankStatement[0];
        Test.stopTest();
    }
    
    //method to test the functionality of trigger on undeleting of Bank Account statement records
    static testMethod void undeletionOfBankStatement() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(1);
        insert listAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = listAccount[0].Id;
        insert listOpportunity;
        List<Bank_Account__c> listBankStatement = TestDataUtility.getBankStatementRecords(5, listOpportunity[0].id);
        listBankStatement[0].Month__c = '03 - March';
        listBankStatement[1].Month__c = '03 - March';
        insert listBankStatement;
        CheckRecursive.runBefore = true;
        CheckRecursive.runAfter = true;
        delete listBankStatement[0];
        CheckRecursive.runAfter = true;
        CheckRecursive.runBefore = true;
        Test.startTest();
            undelete listBankStatement[0];
        Test.stopTest();
    }
}