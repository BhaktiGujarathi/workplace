/**
 * Class BehavioralSocialHistoryHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class BehavioralSocialHistoryHandler implements TriggerInterface {
    Map<string,string> ClinicIdMap;
    // Constructor
    public BehavioralSocialHistoryHandler(){
        ClinicIdMap = new Map<string,string>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){   
        set<Id> ClinicIdset = new set<Id>();
        for(Behavioral_Social_History__c t: (List<Behavioral_Social_History__c>)trigger.new){
             if(t.Clinical_Assessment__c != null){
                ClinicIdset.add(t.Clinical_Assessment__c);
            }
        }
        List<Clinical_Assessment__c> ClinicalList = new List<Clinical_Assessment__c>();
        if(ClinicIdset.size()>0){
            ClinicalList = [select id, Opportunity__r.Contact__c from Clinical_Assessment__c where Id IN : ClinicIdset];
        }
        for(Clinical_Assessment__c cac : ClinicalList){
            if(cac.Opportunity__r.Contact__c!=null){
                ClinicIdMap.put(cac.Id,cac.Opportunity__r.Contact__c);
            }
        }
        
    }
 
    public void bulkAfter(){
        
       
    }
 
    public void beforeInsert(SObject so){        
       Behavioral_Social_History__c Behavioral =(Behavioral_Social_History__c)so;
       if(ClinicIdMap.containsKey(Behavioral.Clinical_Assessment__c)) 
       Behavioral.Patient__c = ClinicIdMap.get(Behavioral.Clinical_Assessment__c); 
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
      Behavioral_Social_History__c Behavioral =(Behavioral_Social_History__c)so;
       if(ClinicIdMap.containsKey(Behavioral.Clinical_Assessment__c))
       Behavioral.Patient__c = ClinicIdMap.get(Behavioral.Clinical_Assessment__c);          
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