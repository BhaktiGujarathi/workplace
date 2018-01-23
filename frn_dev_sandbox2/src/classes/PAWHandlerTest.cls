@isTest
public class PAWHandlerTest {

	private static testMethod  void PAWHandler_test(){

			Opportunity opp = new Opportunity();
			opp.StageName = 'Determination Complete';
			opp.Name = 'test';
			opp.CloseDate = System.today();
			insert opp;

			Pay_Agreement_Worksheet__c paw= new Pay_Agreement_Worksheet__c();
			paw.Opportunity__c = opp.id;
			insert paw;

            Map<Id,Opportunity> oppMap =  new Map<Id,Opportunity>();
	        Set<Id> vobProfileId = new Set<Id>();

            Test.startTest();
            PAWHandler PAWHandlerObj = new PAWHandler();
            PAWHandlerObj.bulkBefore();
            Test.stopTest();


	}
}