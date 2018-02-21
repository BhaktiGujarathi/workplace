/*
* Version       Date             Author         Description
*   1.0         01/02/2016       Ashwini S      Test class for InvoiceCreationFromProjectsBatch
*/


@isTest
private class InvoiceCreationFromProjectsBatchTest {

    static testMethod void validBatchTest() {
        
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;
        
        List<Contact> listContacts = TestUtility.getContactRecords(1, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());
        
        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        listOpportunity[0].Billing_Contact__c = listContacts[0].Id;
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);
                
        list<HarvestProject__c> harvestProjectList = TestUtility.insertHarvestProjects(5, listOpportunity[0].Id,
        listAccounts[0].Id, listContacts[0].Id);
        insert harvestProjectList;
        
        List<Estimates__c> estimateList = new List<Estimates__c>();
        List<Estimates__c> listEstimateTemp = new List<Estimates__c>();
        for(Integer i = 0; i < 5; i++) {
            listEstimateTemp.clear();
            listEstimateTemp = TestUtility.insertEstimates(2, 
                                                           listOpportunity[0].Id,
                                                           harvestProjectList[i].Id);
            estimateList.addAll(listEstimateTemp);
        }
        
        insert estimateList;
        System.assertNotEquals(null, estimateList[0].id);
               
        Test.startTest();
           SchedulableContext sc = null;
           InvoiceCreationFromProjectsScheduler schduleClass = new InvoiceCreationFromProjectsScheduler();
           schduleClass.execute(sc);
           //InvoiceCreationFromProjectsBatch batchCls = new InvoiceCreationFromProjectsBatch();
           //Database.executeBatch(batchCls);
        Test.stopTest();
    }
}