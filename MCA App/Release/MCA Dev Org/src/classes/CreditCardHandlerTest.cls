/**
 *
 * Description :
 *  1.Test class to test the functionality of the trigger service class.
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0
 *
 *    1.1      Ashwini Singh          27/10/2015            To update the average fields on account
 *                                                         in correspondence to the associated credit
 *                                                         card records.
 *
 **/
@isTest
public class CreditCardHandlerTest {

    //method to test the functionality of trigger on insertion of credit card records
    static testMethod void insertionCreditCard() {
        List<Account> lstAccount = TestDataUtility.getAccountRecords(1);
        insert lstAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = lstAccount[0].Id;
        insert listOpportunity;
        List<Credit_Card__c> lstCreditCard = TestDataUtility.getCreditCardRecords(5, listOpportunity[0].Id);
        lstCreditCard[0].Month__c = '03 - March';
        lstCreditCard[1].Month__c = '03 - March';
        Test.StartTest();
          insert lstCreditCard;
        Test.stopTest(); 
     }
     
     //method to test the functionality of trigger on updation of credit card records
     static testMethod void updationCreditCard() {
        List<Account> lstAccount = TestDataUtility.getAccountRecords(1);
        insert lstAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = lstAccount[0].Id;
        insert listOpportunity;
        List<Opportunity> listOpportunity2 = TestDataUtility.getOpportunityRecords(1);
        listOpportunity2[0].AccountId = lstAccount[0].Id;
        insert listOpportunity2;
        List<Credit_Card__c> lstCreditCard = TestDataUtility.getCreditCardRecords(5, listOpportunity[0].Id);
        insert lstCreditCard;
        lstCreditCard[0].Month__c = '03 - March';
        lstCreditCard[1].Month__c = '03 - March';
        lstCreditCard[1].Opportunity__c = listOpportunity2[0].Id;
        CheckRecursive.runAfter = true;
        CheckRecursive.runBefore = true;
        Test.StartTest();
          update lstCreditCard;
        Test.stopTest(); 
     }
     
     //method to test the functionality of trigger on deletion of credit card records
     static testMethod void deletionCreditCard() {
        List<Account> lstAccount = TestDataUtility.getAccountRecords(1);
        insert lstAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = lstAccount[0].Id;
        insert listOpportunity;
        List<Credit_Card__c> lstCreditCard = TestDataUtility.getCreditCardRecords(5, listOpportunity[0].Id);
        lstCreditCard[0].Month__c = '03 - March';
        insert lstCreditCard;
        CheckRecursive.runAfter = true;
        Test.StartTest();
          delete lstCreditCard[0];
        Test.stopTest(); 
     }
     
     //method to test the functionality of trigger on undeleting of credit card records
     static testMethod void undeletionCreditCard() {
        List<Account> lstAccount = TestDataUtility.getAccountRecords(1);
        insert lstAccount;
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(1);
        listOpportunity[0].AccountId = lstAccount[0].Id;
        insert listOpportunity;
        List<Credit_Card__c> lstCreditCard = TestDataUtility.getCreditCardRecords(5, listOpportunity[0].Id);
        lstCreditCard[0].Month__c = '03 - March';
        insert lstCreditCard;
        CheckRecursive.runAfter = true;
        delete lstCreditCard[0];
        CheckRecursive.runAfter = true;
        Test.StartTest();
          undelete lstCreditCard[0];
        Test.stopTest(); 
     }
}