/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * Version       Date             Author         Description
 * 1.0           05/10/2015       Ashwini S      For Roll up on Account from Invoice  
 */
@isTest
private class InvoiceTriggerHandlerTest {

    static testMethod void testonInvoiceInsert() {
        // TO DO: implement unit test
       //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(1, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);
        //insert invoice record
        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(1,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listInvoice;
        
        //insert commission records
        List<Commission__c> listCommisssion = TestUtility.getCommissionRecords(3, 
                                listAccounts[0].Id, listOpportunity[0].Id, listInvoice[0].Id);
        insert listCommisssion;
         List<Invoice__c> listInvoice1 = TestUtility.getInvoiceRecords(1,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
         CheckRecursive.runAfter = true;                            
        Test.startTest();
        insert listInvoice1;
         Test.stopTest();
        System.assertNotEquals(Null, listInvoice1[0].Id);
    }
    
     static testMethod void testonInvoiceUpdate() {
        // TO DO: implement unit test
       //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(2);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(1, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(2, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);
        
        List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(2,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        CheckRecursive.runAfter = true;                 
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
        
        List<Transaction__c> listTransaction = TestUtility.getTransactionRecords(1,
                                listAccounts[0].Id);
        CheckRecursive.runAfter = true;
        insert listTransaction;
        System.assertNotEquals(Null, listTransaction[0].Id);
        
        List<Transaction_Line_Credit__c>listTransactionLinecredit = TestUtility.getTransactionLineCreditRecords(1,
                                          listTransaction[0].Id,listInvoice[0].Id);
        listTransactionLinecredit[0].Amount__c = 10000.00;
        
        CheckRecursive.runAfter = true;
        insert listTransactionLinecredit;
        System.assertNotEquals(Null, listTransactionLinecredit[0].Id);
        
        HarvestProject__c objProject = new HarvestProject__c();
        objProject.Account__c = listAccounts[0].Id;
        objProject.Opportunity__c = listOpportunity[0].Id;
        objProject.ClientProjectManager__c = listContacts[0].Id;
        objProject.ProjectType__c = 'Implementation';
        insert objProject;
        System.assertNotEquals(null, objProject.Id);
        
        List<Line_Item__c> listInvoiceLineItem = createInvoiceLineItem(2, objProject.Id,
                                 listOpportunity[0].Id,listInvoice[0].Id);
        
        CheckRecursive.runAfter = true;
        insert listInvoiceLineItem;
        System.assertNotEquals(Null, listInvoiceLineItem[0].Id);
        Invoice__c InvoiceObj = [Select Id, Total_Amount_Due__c, Amount_Due__c, Price_Conga__c From Invoice__c  where Id =:listInvoice[0].Id Limit 1];
        
        List<Transaction_Line_Credit__c>listTransactionLinecredit1 = TestUtility.getTransactionLineCreditRecords(1,
                                          listTransaction[0].Id,listInvoice[0].Id);
        listTransactionLinecredit1[0].Amount__c = 5467.00;
        CheckRecursive.runAfter = true;
        insert listTransactionLinecredit1;
        
        Invoice__c InvoiceObj1 = [Select Id, isPaid__c, Total_Amount_Due__c,Amount_Due__c,Price_Conga__c, Total_Amount_Paid__c From Invoice__c  where Id =:listInvoice[0].Id Limit 1];               
                                
        List<Commission__c> listCommisssion = TestUtility.getCommissionRecords(3, 
                                listAccounts[0].Id, listOpportunity[0].Id, InvoiceObj1.Id);
        CheckRecursive.runAfter = true;
        insert listCommisssion;

        listInvoice[1].Opportunity__c=  listOpportunity[1].Id;
        //update the projject record
        CheckRecursive.runAfter = true;
        Test.startTest();
            update listInvoice[1];
        Test.stopTest();
        System.assertNotEquals(Null, listInvoice[0].Id);
    }
    
    static testMethod void testonInvoiceDelete() {
        // TO DO: implement unit test
       //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(1, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);
        
         List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(3,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
         CheckRecursive.runAfter = true;                            
        Test.startTest();
        delete listInvoice[2];
        Test.stopTest();
    }
    
    private static List<Line_Item__c> createInvoiceLineItem(Integer pCount, Id projectId, Id opportunityId, Id invoiceId) {
        List<Line_Item__c> listLineItem = new List<Line_Item__c>();
        
        for(Integer count =0; count <= pCount ; count++) {
            Line_Item__c objLineItem = new Line_Item__c();
            objLineItem.Date__c = system.Today();
            objLineItem.HarvestProject__c = projectId;
            objLineItem.Description__c = 'Test Description'+count;
            objLineItem.Credit_Reason__c='Deposit/PrePaid';
            objLineItem.Opportunity__c = opportunityId;
            objLineItem.Invoice__c = invoiceId;
            objLineItem.Hours_Num__c = 2;
            objLineItem.Credit_Hrs__c = 20;
            listLineItem.add(objLineItem);
        }
        return listLineItem;
    }
}