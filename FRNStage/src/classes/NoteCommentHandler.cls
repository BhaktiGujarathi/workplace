/**
 * Class NoteComment Handler
 *
 * Trigger Handler for the Note/Comment SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class NoteCommentHandler implements TriggerInterface {
    
    
    public Map<Id,RecordType> recordTypeMap;
    public Map<string,string> idMap;
    public List<Task> taskList;
    
    public Map<String, String> whatIdMap = new  Map<String, String>();
    public Map<String, String> whoIdMap = new  Map<String, String>();
    public Map<String, String> recordTypeNameMap = new  Map<String, String>();
    public Set<Id> recId = new Set<Id>();
    // Constructor
    public NoteCommentHandler(){
       
       recordTypeMap = new Map<Id,RecordType>();
       idMap = new Map<string,string>();
       taskList = new List<Task>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){   
        
        
    }
 
    public void bulkAfter(){
        for(Note_Comment__c nc : (List<Note_Comment__c>)Trigger.New){
            
            if(nc.Opportunity__c!= null){
                whatIdMap.put(nc.id,nc.Opportunity__c);               
            } else if(nc.Pay_Agreement_Worksheet__c!= null){
                whatIdMap.put(nc.id,nc.Pay_Agreement_Worksheet__c);
            } else if(nc.Insurance_Benefit__c!= null){
                whatIdMap.put(nc.id,nc.Insurance_Benefit__c);
            } else if(nc.Estimates_of_Treatment_Costs__c!= null){
                whatIdMap.put(nc.id,nc.Estimates_of_Treatment_Costs__c);              
            } else if(nc.Case__c!= null){
                whatIdMap.put(nc.id,nc.Case__c);   
            } else if(nc.Estimates_of_Treatment_Costs__c!= null){
                whatIdMap.put(nc.id,nc.Estimates_of_Treatment_Costs__c);   
            } 

			if(nc.Patient__c!= null){
                whoIdMap.put(nc.id,nc.Patient__c);
            }else if(nc.Lead__c!= null){
                whoIdMap.put(nc.id,nc.Lead__c);
            }
           
			if(nc.RecordTypeId != null){
                recId.add(nc.RecordTypeId);                
            }           
        }
		recordTypeMap = new Map<Id,RecordType>([Select Id,Name from RecordType where Id IN:recId]);
    }

    public void beforeInsert(SObject so){    
    
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        
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
        Note_Comment__c ncc = (Note_Comment__c)so;
		Task tk = new Task();
		tk.Description = (ncc.Note_Comment__c!=null) ? ncc.Note_Comment__c.replaceAll('<[^>]+>',' '):'';
		if(recordTypeMap.containsKey(ncc.RecordTypeId)){
			tk.Subject = 'Note/Comment - ' + recordTypeMap.get(ncc.RecordTypeId).Name;
		}if(whatIdMap.containsKey(ncc.Id)){
			tk.WhatId = whatIdMap.get(ncc.Id);
		}
		if(whoIdMap.containsKey(ncc.Id)){
			tk.WhoId = whoIdMap.get(ncc.Id);
		}
		tk.Status = 'Completed';		
        taskList.add(tk);
       
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
        if(taskList.size()>0){
            insert taskList;
        }    
    }
}