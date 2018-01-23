/**
 * Class TripHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class TripHandler implements TriggerInterface {
	Map<string,string> oppconIdMap;
    // Constructor
    public TripHandler(){
		oppconIdMap = new Map<string,string>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){   
		set<Id> oppIdset = new set<Id>();
		for(Trip__c t: (List<Trip__c>)trigger.new){
            if(t.Opportunity__c != null){
				oppIdset.add(t.Opportunity__c);
			}
        }
		List<Opportunity> oppList = new List<Opportunity>();
		for(Opportunity opp:[select id, Contact__c from Opportunity where Id IN: oppIdset]){
			oppconIdMap.put(opp.Id,opp.Contact__c);
		}
        
    }
 
    public void bulkAfter(){
        
       
    }
 
    public void beforeInsert(SObject so){        
       Trip__c tso =(Trip__c)so;
	   if(oppconIdMap.containskey(tso.Opportunity__c))
	   tso.Patient__c = oppconIdMap.get(tso.Opportunity__c);
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
		Trip__c tso =(Trip__c)so;
	   if(oppconIdMap.containskey(tso.Opportunity__c))
	   tso.Patient__c = oppconIdMap.get(tso.Opportunity__c);
    }
	 
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){ 
       
    }
    public void afterUpdate(SObject oldSo, SObject so){
                   
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
                
    }
}