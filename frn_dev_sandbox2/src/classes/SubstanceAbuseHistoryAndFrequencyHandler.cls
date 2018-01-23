/**
 * Class SubstanceAbuseHistoryAndFrequencyHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class SubstanceAbuseHistoryAndFrequencyHandler implements TriggerInterface {
	Map<string,string> oppconIdMap;
    // Constructor
    public SubstanceAbuseHistoryAndFrequencyHandler(){
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
		for(Substance_Abuse_History_and_Frequency__c t: (List<Substance_Abuse_History_and_Frequency__c>)trigger.new){
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
       Substance_Abuse_History_and_Frequency__c Substan =(Substance_Abuse_History_and_Frequency__c)so;
	   if(oppconIdMap.containskey(Substan.Opportunity__c))
	   Substan.Patient__c = oppconIdMap.get(Substan.Opportunity__c);
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
	   Substance_Abuse_History_and_Frequency__c Substan =(Substance_Abuse_History_and_Frequency__c)so;
	    
	   if (oppconIdMap.containskey(Substan.Opportunity__c))
	   Substan.Patient__c = oppconIdMap.get(Substan.Opportunity__c);        
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