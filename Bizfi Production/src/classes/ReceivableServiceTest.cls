@isTest
public with sharing class ReceivableServiceTest {

    private static testMethod void testPayableAdjustmentsCreatedCorrectly() {
        // set up data
        Account acct = ATTestDataUtility.generateAccounts(1)[0];
        insert acct;
        Opportunity opp = ATTestDataUtility.generateOpportunities(1, acct.Id)[0];
        insert opp;
        List<McaApp__Receivable__c> receivables = ATTestDataUtility.generateReceivables(5, opp.Id);
        insert receivables;
        List<McaApp__Payable__c> payables = new List<McaApp__Payable__c>();
        for(McaApp__Receivable__c receivable : receivables) {
            payables.addAll(ATTestDataUtility.generatePayables(5, opp.Id, receivable.Id));
        }
        insert payables;

        // insert new receivable adjustments
        List<McaApp__Receivable__c> receivableAdjustments = new List<McaApp__Receivable__c>();
        for(McaApp__Receivable__c receivable : receivables) {
            receivableAdjustments.add(ATTestDataUtility.generateReceivables(1, opp.Id, receivable.Id)[0]);
        }

        System.assertEquals(0, [SELECT COUNT() FROM McaApp__Payable__c WHERE IsAdjustment__c = true]);

        Test.startTest();

        insert receivableAdjustments;

        Test.stopTest();

        // assert that payable adjustments were created

        List<McaApp__Payable__c> payableAdjustments = [SELECT Id FROM McaApp__Payable__c WHERE IsAdjustment__c = true];

        System.assertEquals(25, payableAdjustments.size());
    }

}