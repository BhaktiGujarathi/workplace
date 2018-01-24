/*
 *  Description -  Test Class for PayableTriggerHandler.Specific for CalculatePayableRollup class.
 *
 *  Version     Author                 Date(mm/dd/yyyy)     Description
 *  1.0         Nachiket R. Deshpande  04/11/2014           Initial Draft
 *  2.0         Ajinkya Hingne         01/06/2017           Added test method for undelete
 *
 */


@isTest
private class PayableTriggerHandlerTest {

    //Test Method to test Rollup count onInsert of Payable Record
    static testMethod void testRollupOfPayableOnInsert() {

        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;



        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(10);

        lstPayable.addAll(TestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(TestDataUtility.getPayableRecordsForExternalISO(10));

        for(Payable__c Payable : lstPayable){
            Payable.Opportunity__c = lstOpportunity[0].Id;

        }//End for

        //Insert Payable
        Test.startTest();
        insert lstPayable;
        Test.stopTest();



    }//End testRollupOfPayableOnInsert

    //Test Method to test Rollup count onUpdate of Payable Record
    static testMethod void testRollupOfPayableOnUpdate() {

        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;

        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(10);
        //For Internal/External ISO
        lstPayable.addAll(TestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(TestDataUtility.getPayableRecordsForExternalISO(10));

        for(Payable__c Payable : lstPayable){
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//for

        //Insert Payable
        insert lstPayable;

        //Update Amount of Payable
        for(Payable__c Payable : lstPayable){
            Payable.Amount_Due__c = 40;
        }//for

        //Update Payable Records
        Test.startTest();
        update lstPayable;
        Test.stopTest();



    }//End testRollupOfPayableOnUpdate

    //Test Method to test Rollup count onDelete of Payable Record
    static testMethod void testRollupOfPayableOnDelete() {

        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;

        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(10);
        List<Payable__c> lstPayableWithNoOpp = TestDataUtility.getPayableRecords(5);
        //For Internal/External ISO
        lstPayable.addAll(TestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(TestDataUtility.getPayableRecordsForExternalISO(10));

        for(Payable__c Payable : lstPayable){
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//End for

        //Insert Payable
        insert lstPayable;
        insert lstPayableWithNoOpp;

        //Query Payable Record
        list<Payable__c> listPayable = [Select Id,
                                               Amount_Due__c,
                                               Type__c
                                        From Payable__c Where Id = :lstPayable[0].Id];
        list<Payable__c> listPayable2 = [Select Id,
                                               Amount_Due__c,
                                               Type__c
                                        From Payable__c Where Id = :lstPayableWithNoOpp[0].Id];
        //Delete Payable record
        Test.startTest();
        delete listPayable;
        delete listPayable2;
        Test.stopTest();


    }//End testRollupOfPayableOnDelete

    //Test Method to test Rollup count on undelete of Payable Record
    static testMethod void testRollupOfPayableOnUndelete() {

        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;

        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(10);
        List<Payable__c> lstPayableWithNoOpp = TestDataUtility.getPayableRecords(5);
        //For Internal/External ISO
        lstPayable.addAll(TestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(TestDataUtility.getPayableRecordsForExternalISO(10));

        for(Payable__c Payable : lstPayable){
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//End for

        //Insert Payable
        insert lstPayable;
        insert lstPayableWithNoOpp;

        //Query Payable Record
        list<Payable__c> listPayable = [Select Id,
                                               Amount_Due__c,
                                               Type__c
                                        From Payable__c Where Id = :lstPayable[0].Id];
        list<Payable__c> listPayable2 = [Select Id,
                                               Amount_Due__c,
                                               Type__c
                                        From Payable__c Where Id = :lstPayableWithNoOpp[0].Id];
        //Delete Payable record
        Test.startTest();
        delete listPayable;
        delete listPayable2;
        undelete listPayable;
        Test.stopTest();


    }//End testRollupOfPayableOnDelete
}//End PayableTriggerHandlerTest