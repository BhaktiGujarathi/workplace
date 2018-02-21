/*
* Version       Date             Author         Description
*   1.0         05/10/2015       Ashwini S      Test class for Roll up on Account (Total_30_Days_Past_Due__c) from Invoice on daily basis   
*
*/
@isTest
private class InvoiceRollupAmountBatchTest {

    static testMethod void invoiceRollupAmountBatchTest() {
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
        
         List<Invoice__c> listInvoice = TestUtility.getInvoiceRecords(6,
                                listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        CheckRecursive.runAfter = true;                            
        insert listInvoice;
        System.assertNotEquals(Null, listInvoice[0].Id);
        
        
        list<HarvestProject__c> harvestProjectList = TestUtility.insertHarvestProjects(5,listOpportunity[0].Id,
        listAccounts[0].Id, listContacts[0].Id);
        insert harvestProjectList;
        
        for(Integer invoiceCount = 1; invoiceCount <= listInvoice.size(); invoiceCount++){
        List<Line_Item__c> listInvoiceLineItem = TestUtility.getInvoiceLineItemRecords(2,
                                 listOpportunity[0].Id,listInvoice[invoiceCount-1].Id, harvestProjectList[0].Id);
        CheckRecursive.runAfter = true;
        insert listInvoiceLineItem;
        }
         Test.startTest();
           string batch1= SchedulerQueryGenenrator.queryFetch(0);
           Database.executeBatch(new InvoiceRollupAmountonAccountBatch(0,batch1));
           string batch2= SchedulerQueryGenenrator.queryFetch(30);
           Database.executeBatch(new InvoiceRollupAmountonAccountBatch(30,batch2));
           string batch3= SchedulerQueryGenenrator.queryFetch(90);
           Database.executeBatch(new InvoiceRollupAmountonAccountBatch(90,batch3));
           string batch4= SchedulerQueryGenenrator.queryFetch(60);
           Database.executeBatch(new InvoiceRollupAmountonAccountBatch(60,batch4));
         Test.stopTest();
    }
}