/**
 * Class PsyTreatmentHistoryHandler
 *
 * Trigger Handler for the Treatment_History__c SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class PsyTreatmentHistoryHandler
    implements TriggerInterface
{ 
   
    public Map<Id,Opportunity> contactmap ;
    
    // Constructor
    public PsyTreatmentHistoryHandler(){
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
        for(Treatment_History__c  pd : (List<Treatment_History__c >)Trigger.new){
            if(pd.Opportunity__c!=null){
                oppid.add(pd.Opportunity__c);
            }
        }
        
        if(oppId.size()>0){
            contactmap = new Map<Id,Opportunity>([Select Id,Contact__c from Opportunity where Id IN:oppId]);
        }
        system.debug('contactmap>>>>'+contactmap);
        
    }
 
    public void bulkAfter(){
             
    }
 
    public void beforeInsert(SObject so){
        Treatment_History__c psyt= (Treatment_History__c)so;
        System.debug('contactmap>>>>'+contactmap);
        if(contactmap.containsKey(psyt.Opportunity__c)){
            psyt.Patient__c = contactmap.get(psyt.Opportunity__c).Contact__c;
        }        
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        Treatment_History__c psyt = (Treatment_History__c)so;
        Treatment_History__c oldPsyt = (Treatment_History__c)oldSo;
        System.debug('contactmap>>>>'+contactmap);
        if(psyt.Opportunity__c!=oldPsyt.Opportunity__c){
            if(contactmap.containsKey(psyt.Opportunity__c)){
                psyt.Patient__c = contactmap.get(psyt.Opportunity__c).Contact__c;
            } else {
                psyt.Patient__c = null;
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