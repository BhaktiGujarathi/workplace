@isTest
public with sharing class MaxOfferedAmountTest {
	

/*	@isTest
	public static void testMaxOfferedAmountTest() {
		
		Opportunity o = creaetOpportunity();

		o = createOffer(o, 500);
		System.assertEquals(o.Max_Offer_Amount__c, 500);

		o = createOffer(o, 200);
		System.assertEquals(o.Max_Offer_Amount__c, 500);

		o = createOffer(o, 600);
		System.assertEquals(o.Max_Offer_Amount__c, 600);
	}
*/

	private static Opportunity creaetOpportunity() {

       Opportunity opp = new opportunity(); 
       opp.name = 'Test Opportunity';
       opp.StageName = 'Underwriting';
       opp.CloseDate = Date.today();
       insert opp; 		

       return opp;
	}


	private static Opportunity createOffer(Opportunity o, Integer amount) {
		McaApp__Submission__c sub = new McaApp__Submission__c();
		sub.McaApp__Opportunity__c = o.Id;
		insert sub;

		McaApp__Offer__c offer = new McaApp__Offer__c();
		offer.McaApp__Opportunity__c = o.Id;
		offer.McaApp__Amount__c = amount;
		offer.McaApp__Submission__c = sub.Id;
		insert offer;

		return [select Max_Offer_Amount__c from Opportunity where Id = :o.Id];
	}
}