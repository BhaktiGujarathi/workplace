@isTest 
public class TestOppotunityExtension{
    private static TestMethod  void TestoppotunityExtension_UnitTest(){
        
    Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
    
    Contact con = new Contact();
    con.LastName = 'test';
    con.Phone = '2236558754';
    con.MobilePhone = '2106558754';
    insert con;
    
    opportunity opp = new opportunity();
    opp.StageName = 'Prospecting';
    opp.Name = 'test';
    opp.Probability = 100;
    opp.CloseDate = system.today();
    opp.CloseDate = system.today();
    opp.Contact__c = con.Id;
    insert opp;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    oppotunityExtension opp1 = new oppotunityExtension(sc);
    }
}