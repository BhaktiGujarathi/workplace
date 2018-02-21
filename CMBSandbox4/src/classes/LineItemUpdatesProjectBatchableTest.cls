@isTest
private class LineItemUpdatesProjectBatchableTest {
    
    static testMethod void testBatchExecute() {
        
        // get Account Records
        List<Account> accountList = TestUtility.getAccountRecords(1);
        insert accountList;
        system.assertNotEquals(accountList[0].Id, null);
        
        // get Opportunity records 
        List<Opportunity> opportunityList = TestUtility.getOpportunityRecords(1, 
                                                                              accountList[0].Id);
        insert opportunityList;
        
        //get Contact Records
        List<Contact> contactList = TestUtility.getContactRecords(1, 
                                                                  accountList[0].Id);
        insert contactList;
        
        //get Invoice Records
        List<Invoice__c> invoiceList = TestUtility.getInvoiceRecords(1, 
                                                                     accountList[0].Id, 
                                                                     contactList[0].Id, 
                                                                     opportunityList[0].Id);
        insert invoiceList;
        
        // get Project Records
        List<HarvestProject__c> projectList = TestUtility.getHarvestProjectRecords(1, 
                                                                                   accountList[0].Id, 
                                                                                   contactList[0].Id, 
                                                                                   opportunityList[0].Id);
        for(HarvestProject__c projectObj : projectList) {
            projectObj.Total_Invoice_Hours__c = 8;
            projectObj.Total_Invoiced_Amount__c = 500;
        }
        insert projectList;
        
        // get Line Item Records
        List<Line_Item__c> lineItemList = TestUtility.getInvoiceLineItemRecords(10, 
                                                                                opportunityList[0].Id,
                                                                                invoiceList[0].Id, 
                                                                                projectList[0].Id);
        
        insert lineItemList;
        
        // update the invoice record to sent status
        invoiceList[0].Status__c = 'Sent';
        invoiceList[0].Date_Sent__c = System.Today()-20;
        update invoiceList;   
                                                                                
        //LineItemUpdatesProjectBatchable batchObj = new LineItemUpdatesProjectBatchable();
        
        Test.startTest();
        SchedulableContext sc = null;
        LineItemUpdatesProjectScheduler schduleClass = new LineItemUpdatesProjectScheduler();
        schduleClass.execute(sc);
        //Database.executeBatch(batchObj);
        Test.stopTest();
    }
}