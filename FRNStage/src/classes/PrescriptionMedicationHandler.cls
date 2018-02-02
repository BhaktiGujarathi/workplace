/**
 * Class PrescriptionMedicationHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class PrescriptionMedicationHandler implements TriggerInterface {
    public list<Medication__c> Medicationlist;
    public list<Abused_Substance__c> Abusedlist;
    public Map<Id, Medication__c> preMap2;
    public Map<Id,Opportunity> oppMap;
    
    // Constructor
    public PrescriptionMedicationHandler(){
        Medicationlist = new list<Medication__c>();
        Abusedlist = new list<Abused_Substance__c>();
        preMap2 = new Map<Id, Medication__c>();
        oppMap = new Map<Id,Opportunity>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){  
        Set<String> oppIds = new Set<String>();
        if(!Trigger.isDelete){
            for(Prescription_Medication__c preM:(List<Prescription_Medication__c>)trigger.new){
                if(preM.Opportunity__c!=null) oppIds.add(preM.Opportunity__c);
            }
        }
        if(oppIds.size()>0){
            oppMap = new Map<Id,Opportunity>([Select Id,Contact__c from Opportunity where Id IN:oppIds]);
        }
    }
 
    public void bulkAfter(){        
        Set<Id> preId = new Set<Id>();
        if(!trigger.isDelete){
            for(Prescription_Medication__c pre:(List<Prescription_Medication__c>)trigger.new){
                preId.add(pre.Medication__c);
            }
        }
        if(preId.size()>0){
            preMap2 = new Map<Id,Medication__c>([Select Id, Name from Medication__c where Id IN:preId]);            
        }       
    }
 
    public void beforeInsert(SObject so){        
        Prescription_Medication__c pm = (Prescription_Medication__c)so;
        if(pm.Currently_Abusing_Substance__c == 'Yes' && (pm.Patient__c == null || pm.Opportunity__c == null)){
           pm.addError('Patient and Opportunity can not be left blank when Currently Abusing Substance is set to Yes.');
        }
        if(pm.Opportunity__c!=null && oppMap.containskey(pm.Opportunity__c)){
            pm.Patient__c = oppMap.get(pm.Opportunity__c).Contact__c;
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        Prescription_Medication__c pm = (Prescription_Medication__c)so;          
        Prescription_Medication__c oldPm = (Prescription_Medication__c)oldSo;
        if(pm.Opportunity__c!=null){
            if(pm.Opportunity__c!=oldPm.Opportunity__c || pm.Patient__c!=oppMap.get(pm.Opportunity__c).Contact__c){
                pm.Patient__c = oppMap.get(pm.Opportunity__c).Contact__c;
            }
        } else {
            pm.Patient__c = null;
        }
    }
    
    public void afterInsert(SObject so){ 
        Prescription_Medication__c prescription = (Prescription_Medication__c)so;       
        if(prescription.Currently_Abusing_Substance__c == 'Yes' && prescription.Opportunity__c != null && prescription.Patient__c != null){
            Abused_Substance__c abuse = new Abused_Substance__c();
            abuse.Opportunity__c = prescription.Opportunity__c;
            abuse.Patient__c = prescription.Patient__c;
            if(preMap2.containskey(prescription.Medication__c)){
                abuse.Substance__c = preMap2.get(prescription.Medication__c).Name;
            }
            abuse.Average_Amount_of_Use__c = prescription.Amount_Abused__c;
            Abusedlist.add(abuse);
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
        if(Abusedlist.size()>0){
            insert Abusedlist;
        }
    }
}