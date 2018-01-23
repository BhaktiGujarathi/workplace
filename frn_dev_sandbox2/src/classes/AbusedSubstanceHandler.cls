/** 
* Class AbusedSubstanceHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class AbusedSubstanceHandler implements TriggerInterface 
{ 
    
    //Constructor 
    public Map<Id,Opportunity> oppMap;
    
    public AbusedSubstanceHandler(){ 
        oppMap = new Map<Id,Opportunity>();
    }
 
    public void bulkBefore(){ 
        Set<Id> oppId = new Set<Id>();
        for(Abused_Substance__c abs:(List<Abused_Substance__c>)trigger.new){
            if(abs.Opportunity__c!=null)
                oppId.add(abs.Opportunity__c);
        }
        
        if(oppId.size()>0){
            oppMap = new Map<Id,Opportunity>([Select Id,Contact__c from Opportunity where Id IN:oppId]);
        }
    } 

    public void bulkAfter(){

    } 
    
    public void beforeInsert(SObject so){ 
        Abused_Substance__c abs = (Abused_Substance__c)so;
        if(oppMap.containsKey(abs.Opportunity__c)){
            abs.Patient__c = oppMap.get(abs.Opportunity__c).Contact__c;
        }
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so){ 
        Abused_Substance__c abs = (Abused_Substance__c)so;
        Abused_Substance__c oldAbs = (Abused_Substance__c)oldSo;
        
        if(abs.Opportunity__c!=oldAbs.Opportunity__c){
            if(oppMap.containsKey(abs.Opportunity__c))
                abs.Patient__c = oppMap.get(abs.Opportunity__c).Contact__c;
            else 
                abs.Patient__c = null;          
        }
    } 
    
    public void beforeDelete(SObject so){ 

    } 
    /** 
    * afterInsert 
    * 
    * This method is called iteratively for each record inserted during an AFTER 
    * trigger. Always put field validation in the 'After' methods in case another trigger 
    * has modified any values. The record is 'read only' by this point. 
    */ 
    public void afterInsert(SObject so) { 
    
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