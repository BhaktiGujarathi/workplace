@isTest
public class OpportunityExperianTestData {

	public static User testUser(){
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Agent - Opener'];
	    User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
	    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
	    LocaleSidKey='en_US', ProfileId = p.Id, IsActive=true,
	    TimeZoneSidKey='America/Los_Angeles', UserName='bizfistandarduser@bizfitestorg.com');

	    insert u;
	    return u;
	}	

	public static void scoreCard(User u){
		Sales_Rep_Report_Card__c sc = new Sales_Rep_Report_Card__c(Name = u.LastName, Sales_Rep__c = u.Id); 
    	insert sc;
	}

}