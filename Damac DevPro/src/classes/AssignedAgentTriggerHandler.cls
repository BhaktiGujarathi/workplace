/**************************************************************************************************
* Name               : AssignedAgentTriggerHandler                                                *
* Description        : This is a handler class to manage Assigned Agent object.                   *
*                      - Used to share records with PC and PC's Manager.                          *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE                                                              *
* 1.0         NSI - Vineet      17/01/2017                                                        *
* 2.0         NSI - Sivasankar  13/02/2017                                                        *
**************************************************************************************************/
public class AssignedAgentTriggerHandler extends UtilitySharingManager implements TriggerFactoryInterface{ 
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
        try{
            /*Calling method to update inquiry status when a activity is created. */
            provideAccess((Map<Id, Assigned_Agent__c>) newRecordsMap);   
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after delete.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterDeleteTrigger(Map<Id, sObject> oldRecordsMap){ 
        try{
            /*Calling method to update inquiry status when a activity is created. */
            revokeAccess((Map<Id, Assigned_Agent__c>) oldRecordsMap);    
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }  
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, map<Id,sObject> oldRecordsMap){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    
    /*********************************************************************************************
    * @Description : Method to provide access to the PC and PC's Manager.                        *
    * @Params      : Map<Id, Assigned_Agent__c>                                                  *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    @TestVisible  private void provideAccess(Map<Id, Assigned_Agent__c> newRecordsMap){
        List<SObject> shareRecordsList = new List<SObject>();
        Map<Id, List<Assigned_Agent__c>> userAssignedUserMap = new Map<Id, List<Assigned_Agent__c>>();  
        for(Assigned_Agent__c thisAssignedAgent : newRecordsMap.values()){

            if(thisAssignedAgent.User__c != null){
                if(userAssignedUserMap.containsKey(thisAssignedAgent.User__c)){
                    userAssignedUserMap.get(thisAssignedAgent.User__c).add(thisAssignedAgent);      
                }else{
                    userAssignedUserMap.put(thisAssignedAgent.User__c, new List<Assigned_Agent__c>{thisAssignedAgent});     
                }
            }
        }   
        if(!userAssignedUserMap.isEmpty()){
            /* Calling query utility class for getting the manager details. */
            Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(userAssignedUserMap.keySet());
            for(Assigned_Agent__c thisAssignedAgent : newRecordsMap.values()){
                User userAgentRecord = userManagerMap.get(thisAssignedAgent.User__c);
                if(userAgentRecord.Id != null){ 
                    /* Calling sharing utility class to grant access to user hierarchy. */
                    shareRecordsList.addAll(invokeAccess(userAgentRecord, thisAssignedAgent.Campaign__c.getSobjectType().getDescribe().getName(), thisAssignedAgent.Campaign__c, ''));
                }
            }
            if(!shareRecordsList.isEmpty()){
                /* Calling queable method to insert sharing records in the sharing table. */
                system.enqueueJob(new UtilitySharingManager(shareRecordsList, new List<sObject>()));
            }   
        }

        //Version: 2.0 Start
        if(!userAssignedUserMap.isEmpty() && userAssignedUserMap.size() > 0){
            createInventoryUsersforAgents(userAssignedUserMap);
        }
        //Version: 2.0 End
    }    
    
    /*********************************************************************************************
    * @Description : Method to revoke access after the PC is removed from the campaign.          *
    * @Params      : Map<Id, Assigned_Agent__c>                                                  *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    @TestVisible private void revokeAccess(Map<Id, Assigned_Agent__c> deletedRecordsMap){
        Set<Id> campaignIdsSet = new Set<Id>();
        Set<Id> AssignedAgentIdsSet = new Set<Id>();
        List<Campaign__Share> deleteSharingRecordList = new List<Campaign__Share>();
        List<Inventory_User__c> deleteInventoryUsers;//Version: 2.0
        for(Assigned_Agent__c thisDeletedPc : deletedRecordsMap.values()){
            campaignIdsSet.add(thisDeletedPc.Campaign__c);  
            AssignedAgentIdsSet.add(thisDeletedPc.User__c);
        }

        if(!campaignIdsSet.isEmpty()){
            /* Calling method to get records from campaign sharing table. */
            Map<Id, List<Campaign__Share>> campaignShareRecordsMap = getSharingRecords(campaignIdsSet); 
            /* Calling query utility class for getting the manager details. */
            Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(AssignedAgentIdsSet);  
            if(!campaignShareRecordsMap.isEmpty() && !userManagerMap.isEmpty()){
                for(Assigned_Agent__c thisDeletedPc : deletedRecordsMap.values()){
                    if(campaignShareRecordsMap.containsKey(thisDeletedPc.Campaign__c)){
                        User userAgentRecord = userManagerMap.get(thisDeletedPc.User__c);
                        if(userAgentRecord != null){
                            for(Campaign__Share thisShareRecord : campaignShareRecordsMap.get(thisDeletedPc.Campaign__c)){
                                if((userAgentRecord.Id == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.ManagerId != null && userAgentRecord.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.ManagerId != null && userAgentRecord.Manager.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.Manager.ManagerId != null && userAgentRecord.Manager.Manager.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.Manager.Manager.ManagerId != null && userAgentRecord.Manager.Manager.Manager.ManagerId == thisShareRecord.UserOrGroupId)){
                                    deleteSharingRecordList.add(thisShareRecord);   
                                }
                            }
                        }
                    }
                }
                if(!deleteSharingRecordList.isEmpty()){
                    database.deleteResult[] result = database.delete(deleteSharingRecordList, false);
                }
            }
        }

        //Version: 2.0 Start
        if(!campaignIdsSet.isEmpty() && !AssignedAgentIdsSet.isEmpty()){
            deleteInventoryUsers = new List<Inventory_User__c>([SELECT Id FROM Inventory_User__c 
                                                                    WHERE User__c IN: AssignedAgentIdsSet
                                                                    AND Campaign_ID__c IN:campaignIdsSet]);
            if(!deleteInventoryUsers.isEmpty() && deleteInventoryUsers.size() > 0 )
                database.deleteResult[] result = database.delete(deleteInventoryUsers, false);
        }
        //Version: 2.0 End  
    }
    
    /*********************************************************************************************
    * @Description : Method to get sharing records from the campaign sharing table.              *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<Campaign__Share>>                                              *
    *********************************************************************************************/  
    @TestVisible private Map<Id, List<Campaign__Share>> getSharingRecords(Set<Id> campaignIds){
        Map<Id, List<Campaign__Share>> campaignShareRecordsMap = new Map<Id, List<Campaign__Share>>();
        for(Campaign__Share thisShareRecord : [SELECT Id, ParentId, AccessLevel, UserOrGroupId, RowCause 
                                               FROM Campaign__Share 
                                               WHERE ParentId IN: campaignIds]){
            if(campaignShareRecordsMap.containsKey(thisShareRecord.ParentId)){
                campaignShareRecordsMap.get(thisShareRecord.ParentId).add(thisShareRecord);     
            }else{
                campaignShareRecordsMap.put(thisShareRecord.ParentId, new List<Campaign__Share>{thisShareRecord});
            }   
        }   
        return campaignShareRecordsMap; 
    }
    //Version 2.0 Start
    /*********************************************************************************************
    * @Description : Method to create the Inventory User reocrds for assigned agents             *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<Campaign__Share>>                                              *
    *********************************************************************************************/  
    @TestVisible private void createInventoryUsersforAgents(Map<ID,List<Assigned_Agent__c>> mapCampaingUsers){
        List<Inventory_User__c> upsertInventory = new List<Inventory_User__c>();
        for(Campaign_Inventory__c campInve : new List<Campaign_Inventory__c>([SELECT Campaign__c,Inventory__c 
                                                                                FROM Campaign_Inventory__c 
                                                                                WHERE Campaign__c IN:mapCampaingUsers.keySet()])){
                                                                                
            for(Assigned_Agent__c assAgent: mapCampaingUsers.get(campInve.Campaign__c)){
                upsertInventory.add(new Inventory_User__c(Inventory__c = campInve.Inventory__c,
                                                          User__c = assAgent.User__c,
                                                          Campaign__c = campInve.Campaign__c,
                                                          Campaign_ID__c = campInve.Campaign__c,
                                                          Unique_Key__c = assAgent.User__c+'###'+campInve.Inventory__c+'###'+campInve.Campaign__c,
                                                          Start_Date__c = assAgent.Start_Date__c,
                                                          End_Date__c = assAgent.End_Date__c
                                                        ));
            }
        }
        if(!upsertInventory.isEmpty() && upsertInventory.size() > 0)
            Database.UpsertResult[] upsertResults = Database.upsert(upsertInventory,Inventory_User__c.unique_key__c.getDescribe().getSObjectField(),false);
    }
    //Version 2.0 End
}// End of class