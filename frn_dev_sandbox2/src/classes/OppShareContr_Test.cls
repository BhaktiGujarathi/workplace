@isTest
public class OppShareContr_Test {
    public static testMethod void unitTest() {	
	Contact con = new Contact();
	con.LastName = 'test';
	con.Social_Security_Number__c = 'test#';
	insert con;
	 String accRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
	Opportunity opp = new Opportunity ();
	opp.Name = 'TestOpp';
	opp.Probability = 10;
	opp.Contact__c = con.Id ;
	opp.CloseDate = System.today();
	opp.StageName = 'Prospecting';
	opp.RecordTypeId = accRT;
	insert opp;
	String oppid = opp.id;
	String uid = UserInfo.getUserId();
	User u1 = [Select id from User where id =: uid];
	System.runAs(u1) {
	UserRole r = new UserRole(Name = 'CEO');
	insert r;

	 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
     User u = new User(Alias = 'standt', UserRoleId = r.Id, Email='test1234@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testorg.com');

        System.runAs(u) {
            OppShareContr.shareOpportunity(oppid);
        }	
	
	}
	}
}