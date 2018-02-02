/** 
* Class mentalHealthSymptomHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class mentalHealthSymptomHandler implements TriggerInterface { 
    
    Map<Id,Opportunity> opptyContactMap;
   
    //Constructor 
    public mentalHealthSymptomHandler(){ 
        opptyContactMap = new map<Id,Opportunity>();
    }
   /* 
bulkBefore
*/  
    public void bulkBefore(){ 
        Set<Id> healthSympID = new set<Id>();
        for(Mental_Health_Symptom__c meHealth: (List<Mental_Health_Symptom__c>)trigger.new){
            if(meHealth.Opportunity__c !=null){
                healthSympID.add(meHealth.Opportunity__c);
                    system.debug('healthSympID____________________'+healthSympID);                  
            }   
            
        }
            if(healthSympID !=null){
                opptyContactMap = new map<id,Opportunity>([select id, Contact__c from Opportunity where id=:healthSympID]);
                    System.debug('opptyContactMap____________________'+opptyContactMap);
                
            }
    }
    
    public void bulkAfter()
    { } 
   /* 
beforeInsert
*/    
    public void beforeInsert(SObject so){ 
        System.debug('opptyContactMap..........>>>>'+opptyContactMap);
            Mental_Health_Symptom__c mhSymp = (Mental_Health_Symptom__c)so;
            
                if(opptyContactMap.containskey(mhSymp.Opportunity__c))
                    mhSymp.Patient__c = opptyContactMap.get(mhSymp.Opportunity__c).Contact__c; 
                
                
    } 
  
    public void beforeUpdate(SObject oldSo, SObject so){
        System.debug('opptyContactMap..........>>>>'+opptyContactMap);
            Mental_Health_Symptom__c mhSymp = (Mental_Health_Symptom__c)so;
            
                if(opptyContactMap.containskey(mhSymp.Opportunity__c))
                    mhSymp.Patient__c = opptyContactMap.get(mhSymp.Opportunity__c).Contact__c; 
                
               
    } 
    
    public void beforeDelete(SObject so)
    { } 
    /** 
    * afterInsert 
    * 
    * This method is called iteratively for each record inserted during an AFTER 
    * trigger. Always put field validation in the 'After' methods in case another trigger 
    * has modified any values. The record is 'read only' by this point. 
    */  
    public void afterInsert(SObject so)
    { } 
    public void afterUpdate(SObject oldSo, SObject so)
    { } 
    public void afterDelete(SObject so)
    { } 
    public void afterUndelete(SObject so)
    { } 

    /** 
    * andFinally 
    * 
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records. 
    */ 
    public void andFinally()
    { } 

}