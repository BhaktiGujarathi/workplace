/** 
* Class LegalOffenseHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class LegalOffenseHandler implements TriggerInterface { 
    
    Map<Id,Opportunity> conMap;
   
    //Constructor 
    public LegalOffenseHandler(){ 
        conMap = new map<Id,Opportunity>();
    }
 
    public void bulkBefore(){ 
        Set<Id> oppId = new set<Id>();
        for(Legal_Offense__c lo: (List<Legal_Offense__c>)trigger.new){
            if(lo.Opportunity__c !=null){
                oppId.add(lo.Opportunity__c);               
            }
        }
        if(oppId !=null){
            conMap = new map<id,Opportunity>([select id,Contact__c from Opportunity where id=:oppId]);
            System.debug('conMap..........>>>>'+conMap);
        }
    } 

    public void bulkAfter(){
        

    } 
    
    public void beforeInsert(SObject so){ 
        System.debug('conMap..........>>>>'+conMap);
        Legal_Offense__c loc = (Legal_Offense__c)so;
        if(conMap.containskey(loc.Opportunity__c))
            loc.Patient__c = conMap.get(loc.Opportunity__c).Contact__c;     
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so){    
        Legal_Offense__c loc = (Legal_Offense__c)so;
        Legal_Offense__c oldLoc = (Legal_Offense__c)oldSo;
        if(loc.Opportunity__c!=oldLoc.Opportunity__c){
            if(conMap.containskey(loc.Opportunity__c))
                loc.Patient__c = conMap.get(loc.Opportunity__c).Contact__c; 
            else    
                loc.Patient__c = null;
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
    public void andFinally() { 
        
    } 

}