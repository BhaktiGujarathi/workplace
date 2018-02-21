/****************************************************************************************************************
* Name                  : CampaignInventoryTriggerHandler                                                       *
* Trigger               : CampaignInventoryTrigger                                                              *
* Description           : This trigger will create the Team users or Agency users in Inventory Users            *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 07/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *
* CH00              1.0         NSI - Sivasankar K         07/Feb/2017      Initial developmen                  *
* CH01              2.0                                                                                         *
*****************************************************************************************************************/
public with sharing class CampaignInventoryTriggerHandler implements TriggerFactoryInterface{
    
    // TO BE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){
        Map<ID,List<Campaign_Inventory__c>> mapCampainInventories = new Map<ID,List<Campaign_Inventory__c>>();
        for(Campaign_Inventory__c thisCamp_Inventory : (List<Campaign_Inventory__c>)newRecordsMap.values()){
            if(mapCampainInventories.containsKey(thisCamp_Inventory.Campaign__c))
                mapCampainInventories.get(thisCamp_Inventory.Campaign__c).add(thisCamp_Inventory);
            else
                mapCampainInventories.put(thisCamp_Inventory.Campaign__c,new List<Campaign_Inventory__c>{thisCamp_Inventory});
        }
        
        if(!mapCampainInventories.isEmpty()){
            createInventoryUsers(mapCampainInventories);
        }
    }
    
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){
       deleteInventoryUsers((List<Campaign_Inventory__c>)oldRecordsMap.values());
    }
    
    /*********************************************************************************************
    * @Description : Delete the Inventory User records on deletion of Campaign Inventory         *
    * @Params      : List<Campaign_Inventory__c>                                                 *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void deleteInventoryUsers(List<Campaign_Inventory__c> oldCampaignInventories){
        Set<ID> CampaignIDs = new Set<ID>();
        Set<ID> inventoryIDS = new Set<ID>();
        
        for(Campaign_Inventory__c thisCamp_Inventory :  oldCampaignInventories){
            if(thisCamp_Inventory.Campaign__c != null)
                CampaignIDs.add(thisCamp_Inventory.Campaign__c);
            if(thisCamp_Inventory.Inventory__c != null)
                inventoryIDS.add(thisCamp_Inventory.Inventory__c);
        }
        delete [Select id from Inventory_User__c where Campaign_ID__c IN: CampaignIDs AND Inventory__c IN:inventoryIDS];
    }
    
    /*********************************************************************************************
    * @Description : Delete the Inventory User records on deletion of Campaign Inventory         *
    * @Params      : List<Campaign_Inventory__c>                                                 *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void createInventoryUsers(Map<ID,List<Campaign_Inventory__c>> mapOfCampInventories){
        List<Inventory_User__c> upsertInventoryUser = new List<Inventory_User__c>();
        
        
        for(Assigned_Agent__c assAgent : new List<Assigned_Agent__c>([Select Id,Campaign__c,Start_Date__c,End_Date__c,User__c 
                                                                        FROM Assigned_Agent__c 
                                                                        WHERE Campaign__c IN:mapOfCampInventories.keySet() ]) ){
            for(Campaign_Inventory__c campInve : mapOfCampInventories.get(assAgent.Campaign__c)){
                upsertInventoryUser.add(new Inventory_User__c(Inventory__c = campInve.Inventory__c,
                                                          User__c = assAgent.User__c,
                                                          Campaign__c = campInve.Campaign__c,
                                                          Campaign_ID__c = campInve.Campaign__c,
                                                          Unique_Key__c = assAgent.User__c+'###'+campInve.Inventory__c+'###'+campInve.Campaign__c,
                                                          Start_Date__c = assAgent.Start_Date__c,
                                                          End_Date__c = assAgent.End_Date__c
                                                        ));
            }
        }
        
        if(!upsertInventoryUser.isEmpty() && upsertInventoryUser.size() > 0){
            Database.UpsertResult[] upsertResults = Database.upsert(upsertInventoryUser,Inventory_User__c.unique_key__c.getDescribe().getSObjectField(),false);
        }
    }
}