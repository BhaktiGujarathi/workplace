/*
 *  Description -  Test Class for ReceivableTriggerHandler
 *
 *  Version     Author                 Date(mm/dd/yyyy)     Description
 *  1.0         Nachiket R. Deshpande  04/11/2014           Initial Draft
 *  2.0         Ajinkya Hingne         01/06/2017           Added test method for undelete
 */
@isTest
private class ReceivableTriggerHandlerTest {

    //Test Method to test Rollup count onInsert of Receivable Record
    static testMethod void testRollupOfReceivableOnInsert() {

        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;

        //Creating Test Receivable Records using utility class
        List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(200);

        for(Receivable__c receivable : lstReceivable){
            receivable.Opportunity__c = lstOpportunity[0].Id;
        }//End for

        //Insert Receivable records
        Test.startTest();
        insert lstReceivable;
        Test.stopTest();
        //Query Total Commission Receivable and Total Receivable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Receivable__c,
                                                    Total_Receivables__c
                                             From Opportunity Where Id =: lstOpportunity[0].Id];

        //Asserts to check Rollup of Amount on Opportunity by Receivable
        system.assertEquals(listOpportunity[0].Total_Commissions_Receivable__c, 6000);
        system.assertEquals(listOpportunity[0].Total_Receivables__c, 18000);

    }//End testRollupOfReceivableOnInsert

    //Test Method to test Rollup count onUpdate of Receivable Record
    static testMethod void testRollupOfReceivableOnUpdate() {

        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;

        //Creating Test Receivable Records using utility class
        List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(200);

        for(Receivable__c receivable : lstReceivable){
            receivable.Opportunity__c = lstOpportunity[0].Id;
        }//for

        //Insert Receivable
        insert lstReceivable;

        for(Receivable__c receivable : lstReceivable){
            receivable.Amount__c = 40;
            receivable.Status__c = 'Pending';
        }//for

        //Update Receivable
        Test.startTest();
        update lstReceivable;

        Opportunity newOpp = createOpportunity();
        insert newOpp;
        system.assertEquals(false,newOpp.Id==null);

        Test.stopTest();

        //Query Total Commission Payable and Total Receivable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Receivable__c,
                                                    Total_Receivables__c
                                             From Opportunity Where Id =: lstOpportunity[0].Id];

        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listOpportunity[0].Total_Commissions_Receivable__c, 8000);
        system.assertEquals(listOpportunity[0].Total_Receivables__c, 24000);

    }//End testRollupOfReceivableOnUpdate

    //Test Method to test Rollup count onDelete of Receivable Record
    static testMethod void testRollupOfReceivableOnDelete() {

        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;

        //Creating Test Receivable Records using utility class
        List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(200);

        for(Receivable__c receivable : lstReceivable){
            receivable.Opportunity__c = lstOpportunity[0].Id;
            receivable.Status__c = 'Pending';
        }//for

        //Insert Receivable
        insert lstReceivable;
        //Query Receivable record
        list<Receivable__c> listReceivable = [Select Id,
                                                     Amount__c,
                                                     Type__c,
                                                     Status__c
                                              From Receivable__c Where Id =: lstReceivable[0].Id AND Type__c = 'Commission'];

        //Delete Receivable record
        Test.startTest();

        delete listReceivable;

        Receivable__c newReceivable = createReceivable();
        insert newReceivable;
        system.assertEquals(false,newReceivable.Id==null);
        Test.stopTest();

        //Query Total Commission Payable and Total Receivable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Receivable__c,
                                                    Total_Receivables__c
                                             From Opportunity Where Id =: lstOpportunity[0].Id];

        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listOpportunity[0].Total_Commissions_Receivable__c, 5970);
        //system.assertEquals(listOpportunity[0].Total_Receivables__c, 11970);
        system.assertEquals(17970, listOpportunity[0].Total_Receivables__c);

    }//End testRollupOfReceivableOnDelete

    //Test Method to test Rollup count on undelete of Receivable Record
    static testMethod void testRollupOfReceivableOnUndelete() {

        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;

        //Creating Test Receivable Records using utility class
        List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(200);

        for(Receivable__c receivable : lstReceivable){
            receivable.Opportunity__c = lstOpportunity[0].Id;
            receivable.Status__c = 'Pending';
        }//for

        //Insert Receivable
        insert lstReceivable;
        //Query Receivable record
        list<Receivable__c> listReceivable = [Select Id,
                                                     Amount__c,
                                                     Type__c,
                                                     Status__c
                                              From Receivable__c Where Id =: lstReceivable[0].Id AND Type__c = 'Commission'];

        //Delete Receivable record
        Test.startTest();

        delete listReceivable;
        undelete listReceivable;
        Test.stopTest();
    }

    //Insert Opportunity without any Receivables or Payables.
    public static Opportunity createOpportunity() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.StageName = 'Prospecting';
        objOpportunity.CloseDate = date.today();
        return objOpportunity;
    }// End of createOpportunity

    //Insert Receivable__c without any Receivables or Payables.
    public static Receivable__c createReceivable() {
        Receivable__c objReceivable = new Receivable__c();
        objReceivable.Amount__c = 30.00;
        objReceivable.Status__c = 'Pending';
        objReceivable.Type__c = 'Commission';
        return objReceivable;
    }// End of createReceivable
}//End ReceivableTriggerHandlerTest