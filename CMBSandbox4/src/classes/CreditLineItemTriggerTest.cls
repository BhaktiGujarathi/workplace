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
private class CreditLineItemTriggerTest {

    static testMethod void testCreditLineItem() {
        // TO DO: implement unit test
        list<Account> listAccount = TestUtility.getAccountRecords(1);
        insert listAccount;
        system.assertNotEquals(null,listAccount[0].Id);
        
        list<Contact> listContact = TestUtility.getContactRecords(1,listAccount[0].Id);
        insert listContact;
        system.assertNotEquals(null,listContact[0].Id);
        
        list<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1,listAccount[0].Id);
        insert listOpportunity;
        system.assertNotEquals(null,listOpportunity[0].Id);
        
        list<HarvestProject__c> listHarvestProject = TestUtility.insertHarvestProjects(2,listOpportunity[0].Id,listAccount[0].Id,listContact[0].Id);
        insert listHarvestProject;
        system.assertNotEquals(null,listHarvestProject[0].Id);
        system.assertNotEquals(null,listHarvestProject[1].Id);
        
        list<Credit__c> listCredit = TestUtility.insertCredit(1,listAccount[0].Id);
        insert listCredit;
        system.assertNotEquals(null,listCredit[0].Id);
        
        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(1, listAccount[0].Id, listContact[0].Id, listOpportunity[0].Id);
        insert listInvoice;
        system.assertNotEquals(null,listInvoice[0].Id);
        
        list<Credit_Line_Item__c> listCreditLineItem = TestUtility.insertCreditLineItem(1,listHarvestProject[0].Id,listCredit[0].Id);
        listCreditLineItem[0].Invoice__c = listInvoice[0].Id;
        
        
        CheckRecursive.runAfter = true;
        Test.startTest();
            insert listCreditLineItem;

            CheckRecursive.runAfter = true;
            list<Credit_Line_Item__c> queryListCreditLineItem = [SELECT Id,Project__c FROM Credit_Line_Item__c LIMIT 1];
            queryListCreditLineItem[0].Project__c = listHarvestProject[1].Id;
            Date myDate = Date.newInstance(2016, 2, 17);
            queryListCreditLineItem[0].Credited_Date__c = myDate;
            update queryListCreditLineItem;

            CheckRecursive.runAfter = true;
            for(Credit_Line_Item__c objCreditLine : queryListCreditLineItem) {
                delete objCreditLine;
            }
            
        Test.stopTest();
        system.assertNotEquals(null,listCreditLineItem[0].Id);
        system.debug('-->listCreditLineItem[0].Id '+listCreditLineItem[0].Id);
        //system.assertEquals(queryListCreditLineItem[0].Project__c,listHarvestProject[1].Id);
        list<Credit_Line_Item__c> deleteListCreditLineItem = [SELECT Id FROM Credit_Line_Item__c LIMIT 1];
        system.debug('-->deleteListCreditLineItem.size()'+deleteListCreditLineItem.size());
        system.debug('-->deleteListCreditLineItem'+deleteListCreditLineItem);
        system.assertEquals(0,deleteListCreditLineItem.size());
    }
}