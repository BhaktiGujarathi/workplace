/* 
 *  Description - Handler for LeadMCATrigger. 
 *	 
 *  Date - 08-05-2014
 *  
 *  Created by - Sneha P.
 */
public with sharing class LeadHandler {
	
	/* Function called on After Update of lead, whenever a lead is converted and Opportunity and Contact Role is created, 
	 *	the Contact role should be the Owner 1 of the Opportunity
	 */ 
	public void onAfterUpdate(map<Id,Lead> oldLeadMap ,list<Lead> newLeadList){
    	map<Id,Id> mapOppFirstOwner = new map<Id,Id>();
    	list<Opportunity> opportunityList = new list<Opportunity>();
    	
    	for(Lead objLead : newLeadList){
    		if(oldLeadMap.get(objLead.Id).isConverted == false && objLead.isConverted == true &&
    			objLead.ConvertedOpportunityId != null && objLead.ConvertedContactId != null) {
    			mapOppFirstOwner.put(objLead.ConvertedOpportunityId, objLead.ConvertedContactId);
    		}
    	}
    	
    	for(Id OppId : mapOppFirstOwner.keySet()){
    		opportunityList.add(new Opportunity(Id = OppId, Owner_1__c = mapOppFirstOwner.get(OppId)));
    	}
    	
    	try{
    		//if(opportunityList.size() > 0)
    			update opportunityList;
    	}catch(Exception e){
    		system.debug('-----Error: '+e.getMessage());
    	}
    }
}