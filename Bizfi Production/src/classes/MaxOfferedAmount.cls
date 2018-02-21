public with sharing class MaxOfferedAmount {
	
	private static Set<String> OFFER_STATUSES = new Set<String>{ 'Removed', 'Backup', 'Not Sellable' };

	private McaApp__Offer__c[] offers;


	public MaxOfferedAmount(McaApp__Offer__c[] newOffers) {
		
		offers = newOffers;
	}


	public void updateOpportunities() {

		Set<Id> opportunityIds = new Set<Id>();


		for (McaApp__Offer__c offer : offers) {

			if (offer.McaApp__Opportunity__c != null) {
				
				opportunityIds.add(offer.McaApp__Opportunity__c);
			}
		}


		Opportunity[] opportunities = new Opportunity[]{};

		for (Opportunity o : [select Max_Offer_Amount__c, 
									(select McaApp__Amount__c  from McaApp__Offers__r where McaApp__Status__c not in :OFFER_STATUSES) 
								from Opportunity
							   where Id in :opportunityIds]) {

			o.Max_Offer_Amount__c = 0;

			if (o.McaApp__Offers__r != null) {
				
				for (McaApp__Offer__c offer : o.McaApp__Offers__r) {
					
					if ((o.Max_Offer_Amount__c == null) || (o.Max_Offer_Amount__c < offer.McaApp__Amount__c)) {
						
						o.Max_Offer_Amount__c = offer.McaApp__Amount__c;
					}
				}
			}

			opportunities.add(o);
		}


		if (!opportunities.isEmpty()) {

			update opportunities;
		}
	}
}