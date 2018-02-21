global with sharing class ExperianContactCallout {

	// Get all the contact ids where the opp id info is filled in
	public static void idList(Map<Id, Contact> newCons, Map<Id, Contact> oldCons) {

		List<Id> ids = new List<Id>();

		for(Contact c : newCons.values()) {
			if(oldCons.get(c.Id).Opportunity_Id__c != newCons.get(c.Id).Opportunity_Id__c){
				if(String.isNotBlank(c.Opportunity_Id__c) && c.Opportunity_Id__c.length() > 14 && c.Authorize_Run_Credit__c == true) {
					ids.add(c.Id);
				}   
			}
		}
		System.debug('List size is '+ids.size());
		if(!ids.isEmpty()) { restCall(ids); }
	
	}
	
	// Send contact information to experian
	@future(callout=true)
	global static void restCall(List<Id> subList) {
		if(subList.size() > 0) {
			String url = 'https://GetCreditReport1.nextlevelfunding.com/SalesForce.aspx';

			List<Contact> consOut = [SELECT Id, Opportunity_Id__c, FirstName, LastName, Birthdate, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, McaApp__Social_Security_Number1__c 
									 FROM Contact 
									 WHERE Id IN :subList];

			String body = JSON.serialize(consOut);
			String bodyPretty = JSON.serializePretty(consOut);
			 
			HttpResponse response = APICallout.PostCall(url, body);
			System.debug('Code '+response.getStatusCode());

			if(response.getStatusCode() < 400){
				System.debug('returned message is: '+response.getBody());
			} else {
				System.debug('Unexpected status code:  '+response.getStatusCode()+'.  Message is '+response.getBody());
				Callout_Error__c ce = new Callout_Error__c(Outbound_Message__c = bodyPretty, Class__c = 'ExperianContactCallout', Status__c = response.getStatus(), Status_Code__c = response.getStatusCode(), Response_Body__c = response.getBody());
				insert ce;
			}
		} else {
			System.debug('Contact list is empty');
		}
	}

}