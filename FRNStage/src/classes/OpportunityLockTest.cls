public with sharing class OpportunityLockTest
{   
    public String returnToId;
    public static Boolean isLockedFlag;
    
    @InvocableMethod
    public static void opportunityLock(List<Id> pOpportunityIdList) { 
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Record_Lock_Setting__mdt> objectsToLockList = new List<Record_Lock_Setting__mdt>();
        String queryStr = '';
        List<sObject> sobjectList = new List<sObject>();
        
        opportunityList = [SELECT Id 
                           FROM Opportunity 
                           WHERE Id IN :pOpportunityIdList];
       Approval.LockResult[] lstLockResult = Approval.lock(opportunityList, false);
       
       objectsToLockList = [SELECT Id,
                                   Opportunity_Relationship_Field_API__c,
                                   MasterLabel
                            FROM Record_Lock_Setting__mdt];
                            
       system.debug('>>> objectsToLockList : '+objectsToLockList);
       if(!objectsToLockList.isEmpty()) {
           for(Record_Lock_Setting__mdt metadataInstance : objectsToLockList) {
               queryStr = '';
               queryStr = 'SELECT id FROM '+metadataInstance.MasterLabel+ ' WHERE '+metadataInstance.Opportunity_Relationship_Field_API__c+ ' IN : pOpportunityIdList';
               system.debug('>>> queryStr : '+queryStr);
               sobjectList = database.query(queryStr);
               if(!sobjectList.isEmpty()) {
                    system.debug('>>> sobjectList : '+sobjectList);
                    Approval.LockResult[] lstSobjectLockResult = Approval.lock(sobjectList, false);
                    system.debug('>>> result : '+lstSobjectLockResult);
               } 
           }
       }
    }
}