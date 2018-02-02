/**
 * Class PsyDiagnosisHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class PsyDiagnosisHandler implements TriggerInterface {
   
    public Map<Id,Opportunity> contactmap ;
    
    // Constructor
    public PsyDiagnosisHandler(){
        contactmap = new Map<Id,Opportunity>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){        
        Set<Id> oppid = new Set<Id>();
        if(!Trigger.isDelete){
        	for(Psychiatric_Diagnosis__c pd : (List<Psychiatric_Diagnosis__c>)Trigger.new){
            	if(pd.Opportunity__c!=null){
            	oppid.add(pd.Opportunity__c);
            	}
        	}
        }
        if(oppId.size()>0){
            contactmap = new Map<Id,Opportunity>([Select Id,Contact__c from Opportunity where Id IN:oppId]);
        }
        System.debug('contactmap>>>>'+contactmap);
    }
 
    public void bulkAfter(){
             
    }
 
    public void beforeInsert(SObject so){        
        Psychiatric_Diagnosis__c psyd= (Psychiatric_Diagnosis__c)so;
        system.debug('contactmap>>>>'+contactmap);
        if(contactmap.containsKey(psyd.Opportunity__c)){
            psyd.Patient__c = contactmap.get(psyd.Opportunity__c).Contact__c;
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        Psychiatric_Diagnosis__c psyd = (Psychiatric_Diagnosis__c)so;
        Psychiatric_Diagnosis__c oldPsyd = (Psychiatric_Diagnosis__c)oldSo;
        System.debug('contactmap>>>>'+contactmap);
        if(psyd.Opportunity__c!=oldPsyd.Opportunity__c){
            if(contactmap.containsKey(psyd.Opportunity__c)){
                psyd.Patient__c = contactmap.get(psyd.Opportunity__c).Contact__c;
            } else {
                psyd.Patient__c = null;
            }
        }             
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