/*
* Name : Sivasankar
* Date : 06/05/2017
* Purpose : Delete all Assigned PCs which are having past end date
* Company : NSI Gulf
* Change History:
*/
global class DeleteAssignedPCsBatch implements Database.Batchable <sObject>,Database.Stateful{  
    
    /**
    * Constructor to initialise required the values 
    **/
    global DeleteAssignedPCsBatch(){ 
        
    }

    /**
    * Start Method to fetch all the Inquiry for which it has to be reassigned
    **/
    /*global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator('SELECT Campaign__c,End_Date__c,Id,Name,Start_Date__c,User__c FROM Assigned_PC__c WHERE End_Date__c < today AND User__c != null Order By End_Date__c desc');
    }*/
    
    global Iterable<Sobject> start(Database.BatchableContext BC) {
        
        List<SObject> sobjList = new List<SObject>();
        List<Assigned_PC__c> assignedPcList= [SELECT Campaign__c,End_Date__c,Id,Name,Start_Date__c,User__c 
        										FROM Assigned_PC__c WHERE End_Date__c < today AND User__c != null Order By End_Date__c desc];
        sobjList.addAll((List<SObject>)assignedPcList);
        List<Assigned_Agent__c> assignedAgentList = [SELECT Campaign__c,End_Date__c,Id,Name,Start_Date__c,User__c FROM Assigned_Agent__c WHERE End_Date__c < today AND User__c != null Order By End_Date__c desc];
        sobjList.addAll((List<SObject>)assignedAgentList);
        return sobjList;
    }
    
    /**
    *    Execute Method to process all the Inquiry records
    **/
    global void execute(Database.BatchableContext BC,List <SObject> scope) {
        try{
            if(!scope.isEmpty()){
                /*
                AssignedPcTriggerHandler assTrgObj = new AssignedPcTriggerHandler();
                Map<ID,Assigned_PC__c> mapDleteShareRecord = new Map<ID,Assigned_PC__c>();
                for(Assigned_PC__c thisAssPC : scope)
                    mapDleteShareRecord.put(thisAssPC.Id,thisAssPC);
                if(!mapDleteShareRecord.isEmpty())
                    assTrgObj.revokeAccess(mapDleteShareRecord);
                */
                Database.delete(scope,false);
            }
        }Catch(Exception ex){
            System.debug('Exception at Assigned PC deleted batch ' + ex);
        }
    }
    /**
    ** Finish Method 
    **/
    global void finish(Database.BatchableContext BC) {
        
    }
}