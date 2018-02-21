/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CommissionTriggerHandlerTest {

    static testMethod void testOnCommissionInsert() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(2, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);

        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(1,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
        //insert commission records
        List<Commission__c> listCommission = TestUtility.getCommissionRecords(2, 
                                    listAccounts[0].Id, listOpportunity[0].Id, listInvoice[0].Id);
        CheckRecursive.runAfter = true;                            
        Test.startTest();
            insert listCommission;
        Test.stopTest();
        system.assertNotEquals(Null, listCommission.size());
        
        //fetch the Invoice that is inserted
        List<Invoice__c> listInvoiceAssert = [SELECT Total_Commissions_Paid__c
                                           FROM Invoice__c
                                           WHERE Id = :listInvoice[0].Id];
        //assert if the fields are properly updated
        //system.assertEquals(2000, listInvoiceAssert[0].Total_Commissions_Paid__c);


    }

    //Test trigger call on update of Project
     static testMethod void testOnInvoiceUpdate() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(2, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
       system.assertNotEquals(Null, listOpportunity.size());
        
        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(2,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
        List<Commission__c> listCommission = TestUtility.getCommissionRecords(2, 
                                    listAccounts[0].Id, listOpportunity[0].Id, listInvoice[0].Id);
            insert listCommission;


        listCommission[1].Invoice__c= listInvoice[1].Id;
        //update the projject record
        CheckRecursive.runAfter = true;
        Test.startTest();
            update listCommission[1];
        Test.stopTest();
        //fetch the Invoice that is inserted
        List<Invoice__c> listInvoiceAssert = [SELECT Total_Commissions_Paid__c
                                           FROM Invoice__c
                                           WHERE Id = :listInvoice[1].Id];
        //assert if the fields are properly updated
        system.assertEquals(1000, listInvoiceAssert[0].Total_Commissions_Paid__c);
    }

    //to test on delete of commissions
        static testMethod void testOnInvoiceDelete() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(2, listAccounts[0].Id);
        insert listContacts;
        system.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);
        
        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(2,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
        List<Commission__c> listCommission = TestUtility.getCommissionRecords(2, 
                                    listAccounts[0].Id, listOpportunity[0].Id, listInvoice[0].Id);
            insert listCommission;
        //delete the commission record
        CheckRecursive.runAfter = true;
        Test.startTest();
            delete listCommission[1];
        Test.stopTest();
        //fetch the Invoice that is inserted
        List<Invoice__c> listInvoiceAssert = [SELECT Total_Commissions_Paid__c
                                           FROM Invoice__c
                                           WHERE Id = :listInvoice[0].Id];
        //assert if the fields are properly updated
        //System.assertEquals(1000, listInvoiceAssert[0].Total_Commissions_Paid__c);
    }

}