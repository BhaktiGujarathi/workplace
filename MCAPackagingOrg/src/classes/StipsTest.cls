@isTest
private class StipsTest {

    static testMethod void CalculateRollUpOnTest() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(2);
        insert listAccount;        
        
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(5);
        insert listOpportunity;        
        
        List<Stips__c> listStips = TestDataUtility.getStipsRecords(4, listOpportunity[0].Id);
        insert listStips;
        
        if(listStips.size()>0)
            delete listStips;
    }
}