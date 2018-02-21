@isTest 
private class scorecardsTriggerTest{
    
    public static User createStandardUsers(Integer i){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        
        User u = new User(Alias = 'user', Email = 'exampleUser' + i + '@loremipsum.es', 
        EmailEncodingKey = 'UTF-8', LastName = 'LN', LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'exampleUser' + i + '@loremipsum.es');
        
        insert u;
        return u;
    }

    static TestMethod void UpdateUsersForScorecardsTest(){

        List<Sales_Rep_Report_Card__c> scoreCardsList = new List<Sales_Rep_Report_Card__c>();

        Test.StartTest();

        for (Integer i = 0; i <10; i++){
            Sales_Rep_Report_Card__c scorecard = new Sales_Rep_Report_Card__c();

            User u = createStandardUsers(i);

            scorecard.Sales_Rep__c = u.id;

            scoreCardsList.add(scorecard);
        }

        insert scorecardsList;

        delete scorecardsList[0];

        Test.StopTest();

    }


}