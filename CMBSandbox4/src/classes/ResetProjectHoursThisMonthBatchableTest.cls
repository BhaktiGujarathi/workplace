@isTest
private class ResetProjectHoursThisMonthBatchableTest {

    static testMethod void testBatchClass() {
        ResetProjectHoursThisMonthBatchable batchClassObj = new ResetProjectHoursThisMonthBatchable();
        
        List<HarvestTimeEntry__c> timeEntryList2 = ResetProjectHoursThisMonthBatchableTest.testDataCreation();
        
        Test.startTest();
            Database.executeBatch(batchClassObj);
        Test.stopTest();
    }
    
    static testMethod void testTriggerOnAfterInsert() {
        List<HarvestTimeEntry__c> timeEntryList2 = ResetProjectHoursThisMonthBatchableTest.testDataCreation();
       
        CheckRecursive.runAfter = true;
        Test.startTest();
            insert timeEntryList2;
        Test.stopTest();
    }
    
    static testMethod void testTriggerOnAfterUpdate() {
        List<HarvestTimeEntry__c> timeEntryList2 = ResetProjectHoursThisMonthBatchableTest.testDataCreation();
        insert timeEntryList2;
        
        timeEntryList2[0].Duration__c = 10;
        timeEntryList2[1].Duration__c = 11;
        
        CheckRecursive.runAfter = true;
        Test.startTest();
            update timeEntryList2;
        Test.stopTest();
    }
    
    static testMethod void testTriggerOnAfterDelete() {
        List<HarvestTimeEntry__c> timeEntryList2 = ResetProjectHoursThisMonthBatchableTest.testDataCreation();
        insert timeEntryList2;
        
        CheckRecursive.runAfter = true;
        Test.startTest();
            delete timeEntryList2;
        Test.stopTest();
    }
    
    static testMethod List<HarvestTimeEntry__c> testDataCreation() {

        List<Account> accountList = TestUtility.getAccountRecords(1);
        insert accountList;
        
        List<Contact> contactList = TestUtility.getContactRecords(1, accountList[0].Id);
        insert contactList;
        
        List<Opportunity> opportunityList = TestUtility.getOpportunityRecords(2, accountList[0].Id);
        insert opportunityList;
        
        List<HarvestProject__c> projectList = TestUtility.getHarvestProjectRecords(1, 
                                                                                  accountList[0].Id, 
                                                                                  contactList[0].Id, 
                                                                                  opportunityList[0].Id);
        insert projectList;
        
        List<HarvestTimeEntry__c> timeEntryList = TestUtility.getHarvestTimeEntryRecords(2,
                                                                                    projectList[0].Id,
                                                                                    contactList[0].Id,
                                                                                    accountList[0].Id);
        insert timeEntryList;
        
        List<HarvestTimeEntry__c> timeEntryList2 = TestUtility.getHarvestTimeEntryRecords(2,
                                                                                    projectList[0].Id,
                                                                                    contactList[0].Id,
                                                                                    accountList[0].Id);
        return timeEntryList2;
    }
}