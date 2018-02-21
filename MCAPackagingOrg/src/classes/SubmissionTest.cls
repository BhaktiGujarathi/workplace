@isTest
private class SubmissionTest {

    static testMethod void CalculateRollUpOnTest() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(2);
        insert listAccount;        
        
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(5);
        insert listOpportunity;        
        
        List<Submission__c> listSubmission = TestDataUtility.getSubmissionRecords(4, listOpportunity[0].Id);
        insert listSubmission ;
    }
}