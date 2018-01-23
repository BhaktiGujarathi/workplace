/** 
* Class InfectiousDiseaseHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class InfectiousDiseaseHandler implements TriggerInterface 
{ 
    
    //Constructor 
    public Map<Id,String> conIdMap;
    public Set<Id> opIds = new Set<Id>();
    public InfectiousDiseaseHandler(){ 
        conIdMap = new Map<Id,String>();
    }
 
    public void bulkBefore(){ 
       for(Infectious_Disease__c ids : (List<Infectious_Disease__c>)Trigger.new){
            opIds.add(ids.Opportunity__c);
       }
       if(opIds.size() >0){
           for(Opportunity op : [Select id,contact__c from Opportunity where Id IN: opIds]){
               conIdMap.put(op.Id,op.contact__c);
           }
       }
    } 

    public void bulkAfter(){
        
    } 
    
    public void beforeInsert(SObject so){ 
        Infectious_Disease__c  infDis = (Infectious_Disease__c )so;
        if(infDis.Opportunity__c != null && conIdMap.containsKey(infDis.Opportunity__c)){
            infDis.Patient__c = conIdMap.get(infDis.Opportunity__c);
        }
         
        
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so){ 
        Infectious_Disease__c  infDis = (Infectious_Disease__c )so;
        if(infDis.Opportunity__c != null && conIdMap.containsKey(infDis.Opportunity__c)){
            infDis.Patient__c = conIdMap.get(infDis.Opportunity__c);
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