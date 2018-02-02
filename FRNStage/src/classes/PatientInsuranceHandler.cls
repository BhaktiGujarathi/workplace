/** 
* Class PatientInsuranceHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class PatientInsuranceHandler implements TriggerInterface 
{ 
    Map<String,Contact> conMap;
    Map<String,Account> accMap;
    //Constructor
    public PatientInsuranceHandler(){ 
        conMap = new Map<String,Contact>();
        accMap = new Map<String,Account>();
    }
 
    public void bulkBefore(){ 
        Set<String> patientIds = new Set<String>();
        Set<String> iCompanyIds = new Set<String>();
        for(Patient_Insurance__c pi:(List<Patient_Insurance__c>)trigger.new){
            if(pi.Patient__c!=null)
                patientIds.add(pi.Patient__c);
            if(pi.Insurance_Company__c!=null)
                iCompanyIds.add(pi.Insurance_Company__c);
            
        }
        
        if(iCompanyIds.size()>0){
            accMap = new Map<String,Account>([Select Id, Name from Account WHERE Id IN:iCompanyIds]);
        }
        
        if(patientIds.size()>0){
            conMap = new Map<String,Contact>([Select Id,FirstName,LastName from Contact WHERE Id IN:patientIds]);
        }
    } 

    public void bulkAfter()
    { } 
    
    public void beforeInsert(SObject so){ 
        Patient_Insurance__c pi = (Patient_Insurance__c)so;
        String name = getUpdatedPI(pi);
        if(name != null && name!= '')
             pi.Name =name;
        if(pi.Member_ID__c!=null){
            if(name != null && name!= '')
                pi.Name = name+' ('+pi.Member_ID__c+')';  
            else
                pi.Name =' ('+pi.Member_ID__c+')';
        }       
            
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so){    
        Patient_Insurance__c pi = (Patient_Insurance__c)so;
        Patient_Insurance__c oldPi = (Patient_Insurance__c)oldSo;
        String name = getUpdatedPI(pi);
        if(name != null && name!= '')
             pi.Name =name;
        if(pi.Member_ID__c!=null){
           if(name != null && name!= '')
                pi.Name = name+' ('+pi.Member_ID__c+')';  
            else
                pi.Name =' ('+pi.Member_ID__c+')';                  
        }
        
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
    
    public String getUpdatedPI(Patient_Insurance__c pi){
        String name = '';   
        if(conMap.containsKey(pi.Patient__c)){
            if(conMap.get(pi.Patient__c).FirstName!=null && conMap.get(pi.Patient__c).FirstName!='')
                name = conMap.get(pi.Patient__c).FirstName;
            if(conMap.get(pi.Patient__c).LastName!=null && conMap.get(pi.Patient__c).LastName!=''){
                if(name==null)
                    name = conMap.get(pi.Patient__c).LastName;
                else 
                    name = name+' '+conMap.get(pi.Patient__c).LastName ;
            }           

        }
    /*** adding Patient_Insurance.(Account.Name)*/      
        if(accMap.containsKey(pi.Insurance_Company__c)){
            if(accMap.get(pi.Insurance_Company__c).Name!=null && accMap.get(pi.Insurance_Company__c).Name!=''){ 
                    if(name!= null && name!='')
                        name+= ' - ';
                    
                        name += accMap.get(pi.Insurance_Company__c).Name;             
            }

        }           
        
        
            
        return name;
        
    }
}