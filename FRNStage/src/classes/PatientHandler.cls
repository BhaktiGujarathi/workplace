/**
 * Class PatientHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class PatientHandler implements TriggerInterface {
    
    public Map<Id, Opportunity> oppMap;
    public list<opportunity> opplist;
    // Constructor
    public PatientHandler(){
      
      oppMap = new Map<Id, Opportunity>();
      opplist = new list<opportunity>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){  
       Set<Id> oppId = new Set<Id>();
        //if(!trigger.isDelete){
            for(Medical_Equipment__c medequ : (list<Medical_Equipment__c>)trigger.new){
                oppId.add(medequ.Opportunity__c);
            }
        //}
		system.debug('oppId'+oppId);
        if(oppId.size()>0){
            opplist = [select Id, Contact__c from opportunity where Id=:oppId];
			system.debug('opplist'+opplist);
                for(opportunity opp1 : opplist){
                   oppMap.put(opp1.Id, opp1);
				   system.debug('oppMap'+oppMap);
                }       
        }

        }
 
    public void bulkAfter(){
        
    }
 
    public void beforeInsert(SObject so){  
	   Medical_Equipment__c med = (Medical_Equipment__c)so;
	   system.debug('med.Opportunity__c'+med.Opportunity__c);
       if(med.Opportunity__c!=null){
	   system.debug('oppMap'+oppMap);
       med.Patient__c = oppMap.get(med.Opportunity__c).Contact__c;
	   system.debug('med.Patient__c'+med.Patient__c);
       }
       
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
	   Medical_Equipment__c med = (Medical_Equipment__c)so;
	   system.debug('med.Opportunity__c'+med.Opportunity__c);
       if(med.Opportunity__c!=null){
	   system.debug('oppMap'+oppMap);
       med.Patient__c = oppMap.get(med.Opportunity__c).Contact__c;
	   system.debug('med.Patient__c'+med.Patient__c);
       }
                   
    }
    
    public void AfterUpdate(SObject oldSo, SObject so){
        
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