public with sharing class OppIdContactUpdate {

	public static void updateExpContact(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		Set<Id> expOppIds = new Set<Id>();
		Set<Id> conRolIds = new Set<Id>();
		List<Id> conIds = new List<Id>();

		// Get ids for opportunities where send to experian was false but is now true
		for(Opportunity opp : newOpps.values()) {
			if(newOpps.get(opp.Id).Send_to_Experian__c != oldOpps.get(opp.Id).Send_to_Experian__c
			   && opp.Send_to_Experian__c == true) {
				expOppIds.add(opp.Id);
			}
		}
		
		// Get all of the contact roles related to the triggered opportunities
		List<OpportunityContactRole> ocrList = [SELECT ContactId, OpportunityId, Contact.Authorize_Run_Credit__c 
												FROM OpportunityContactRole
												WHERE OpportunityId IN :expOppIds AND Contact.Authorize_Run_Credit__c = true];

		// Get the contact ids for those contact roles
		for(OpportunityContactRole ocr : ocrList) {
			conRolIds.add(ocr.ContactId);
		}
		 
		// Get contacts whose ids are in the id list		 											   
		Map<Id, Contact> expConMap = new Map<Id, Contact>([SELECT Id, Opportunity_Id__c
														   FROM Contact 
														   WHERE Id IN :conRolIds]);

		// put the opportunity id values into the opportunity id field on the contacts
		for(OpportunityContactRole ocr : ocrList) {
			expConMap.get(ocr.ContactId).Opportunity_Id__c = ocr.OpportunityId;
			conIds.add(ocr.ContactId);
		}
		
		// Update contacts
		if(expConMap.values().size() > 0){
			try{
				update expConMap.values();
			} catch (DmlException d) {
				System.debug('There was a problem updating the contacts: ' + d.getMessage()); 
			} catch (Exception e) {
				System.debug('The following error has occured: ' + e.getMessage());
			}
		}
	}
	
}