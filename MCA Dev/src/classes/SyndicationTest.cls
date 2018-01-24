@isTest
private class SyndicationTest {

    static testMethod void CalculateRollUpOnTest() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(2);
        insert listAccount;        
        
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(5);
        insert listOpportunity;        
        
        List<Syndication__c> listSyndication = TestDataUtility.getSyndicationRecords(4, listOpportunity[0].Id);
        insert listSyndication;
        
        if(listSyndication!=null && listSyndication.size() >0)
            delete listSyndication;
    }
}