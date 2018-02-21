@isTest(seeAllData=false)
private class OpportunityAuditOnUpdateTest {

    static testMethod void testonOpportunityUpdate() {
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity objOpportunity;
        // TO DO: implement unit test
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User originalUser = new User(Alias = 'standt', 
                                     Email='standarduser@testorg.com', 
                                     EmailEncodingKey='UTF-8', 
                                     LastName='Testing',
                                     LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', 
                                     ProfileId = p.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', 
                                     UserName='shraddha1@testorg.com');
        insert originalUser;
        
        User changedUser = new User(alias = 'ceo2', 
                                    email='standarduser2@testorg.com',
                                    emailencodingkey='UTF-8',
                                    lastname='Testing', 
                                    languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    timezonesidkey='America/Los_Angeles', 
                                    username='shraddha2@testorg.com', 
                                    profileid = p.Id);
        insert changedUser;
        
        
        // This code runs as the system user
        for(Integer i=0; i<10; ++i){
                objOpportunity = new Opportunity(
                                                 Name = 'Test Opportunity',
                                                 StageName = 'Prospecting',
                                                 CloseDate = system.today(),
                                                 OwnerId = originalUser.Id,
                                                 Organic_Sub__c = false);
                
                lstOpportunity.add(objOpportunity);
        }
       insert lstOpportunity;
        
        
       for(Integer i=0; i<lstOpportunity.size(); ++i){
              lstOpportunity[i].StageName = 'Approved';
              lstOpportunity[i].OwnerId = changedUser.Id;
              lstOpportunity[i].Organic_Sub__c = true;
        }
        checkRecursiveOppToAudTrail.runAfterOppToAudTrail = true;
        system.test.startTest();
        update lstOpportunity;
        system.test.stopTest();
        
        
    }
}