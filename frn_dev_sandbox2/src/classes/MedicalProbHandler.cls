public without sharing class MedicalProbHandler implements TriggerInterface {
        
    public Map<Id,Opportunity> mapGetPatient;
    
    // Constructor
    public medicalprobHandler() {
        mapGetPatient = new map<id,opportunity>();
    }
    
    public void bulkBefore(){
        Set<Id> oppId = new Set<Id>();
        if(!Trigger.isDelete){
            for(Medical_Problem_Symptom__c med : (List<Medical_Problem_Symptom__c>)Trigger.new){
                oppId.add(med.Opportunity__c);
                System.debug('OppId---'+oppId);
            }
        }
        mapGetPatient = new map<Id,Opportunity>([Select Id, Contact__c from Opportunity where Id=:oppId]);
        System.debug('mapGetPatient----'+mapGetPatient);
    }
    
    public void bulkAfter(){
        
    }
    
    public void beforeInsert(SObject so) {
        Medical_Problem_Symptom__c medpro = (Medical_Problem_Symptom__c)so;
        if(mapGetPatient.containsKey(medpro.Opportunity__c)){
            medpro.Patient__c = mapGetPatient.get(medpro.Opportunity__c).Contact__c;
            system.debug('medpro----'+medpro);
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        Medical_Problem_Symptom__c medpro = (Medical_Problem_Symptom__c)so;
        Medical_Problem_Symptom__c oldMedpro = (Medical_Problem_Symptom__c)oldSo;
        if(medpro.Opportunity__c!=oldMedpro.Opportunity__c){
            if(mapGetPatient.containsKey(medpro.Opportunity__c)){
                medpro.Patient__c = mapGetPatient.get(medpro.Opportunity__c).Contact__c;
            } else {
                medpro.Patient__c = null;
            }
        }
    } 
    
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
   
    public void andFinally(){

    }
}