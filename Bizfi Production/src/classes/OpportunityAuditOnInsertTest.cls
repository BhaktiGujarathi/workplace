@isTest(seeAllData = false)
private class OpportunityAuditOnInsertTest {
    
    static testMethod void testonOpportunityInsert() {
        // TO DO: implement unit test
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //generateTestUser(String userName,Profile  profile,String alias,String email)
        User userOld = ATTestDataUtility.generateTestUser('testOld@testorg.com',profile,'standt','standarduser@testorg.com');
        insert userOld;
        
        User userNew = ATTestDataUtility.generateTestUser('TestNew@testorg.com',profile,'ceo2','standarduser2@testorg.com');
        insert userNew;
        
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity objOpportunity;
        
        Lead tempLead = ATTestDataUtility.generateTestLead();
        insert tempLead;
        
        // This code runs as the system user
        for(Integer i=0; i<10; ++i)
        {
            objOpportunity = ATTestDataUtility.generateTestOpportunity();
            objOpportunity.OwnerId = userOld.Id;
            objOpportunity.Lead_ID__c = tempLead.id;
            lstOpportunity.add(objOpportunity);
        }
        
        insert lstOpportunity;
        
    }
}