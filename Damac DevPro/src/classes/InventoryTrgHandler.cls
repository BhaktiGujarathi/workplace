/**************************************************************************************************
* Name               : InventoryTrgHandler                                                        *
* Description        : This is a handler class for inventory trigger.                             *
* Created Date       : 26/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      	DATE			COMMENTS                                              *
* 1.0         Vineet        26/02/2017      Initial Draft                                         *
* V1.2  	  18/Apr/2017	Sivasankar K		Taking the floor numbers only from floor number.  *
**************************************************************************************************/
public class InventoryTrgHandler implements TriggerFactoryInterface{ 
    
    /************ Start of Interface methodes ***************/
    public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){ 
    	//V1.2.Start
        for(Inventory__c thisInventory : (List<Inventory__c>)lstNewRecords){
        	if(String.isNotBlank(thisInventory.Floor_Number__c)){
        		String floorNoOnly = thisInventory.Floor_Number__c.replaceAll('[^0-9]','');
        		if(String.isNotBlank(floorNoOnly) && floorNoOnly.isNumeric())
        			thisInventory.Floor_No__c = Decimal.valueOf(floorNoOnly);
        	}
        }
        //V1.2.End
    }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ 
    	//V1.2.Start
        for(Inventory__c thisInventory : (List<Inventory__c>)mapNewRecords.values()){
        	Inventory__c oldInventory = (Inventory__c)mapOldRecords.get(thisInventory.id);
        	if(String.isNotBlank(thisInventory.Floor_Number__c) && thisInventory.Floor_Number__c != oldInventory.Floor_Number__c){
        		String floorNoOnly = thisInventory.Floor_Number__c.replaceAll('[^0-9]','');
        		if(String.isNotBlank(floorNoOnly) && floorNoOnly.isNumeric())
        			thisInventory.Floor_No__c = Decimal.valueOf(floorNoOnly);
        	}
        }
        //V1.2.End
    }
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords,map<Id,sObject> mapOldRecords){ }
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){//InventoryHelper.createRec((List<Inventory__c>)mapNewRecords.values());
    }
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){//InventoryHelper.createRec((List<Inventory__c>)mapNewRecords.values());
                                                                                                         }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    /************ End of Interface methodes ***************/
    
    /*********************************************************************************************
    * @Description : Method to add users to inventory users junction object,                     *
    *                if user are added to team or an agency.                                     *
    * @Params      : Map<String, List<User>>                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    public static void addUserAccess(Map<String, List<User>> teamOrAgencyUserListMap){ 
        Set<Id> locationIdsSet = new Set<Id>();
        try{
            /* Calling method to get map ot team or agency id with associated team building records. */
            Map<String, List<Team_Building__c>> teamOrAgencyIdTeamBuildingListMap = getAssociatedTeamBuildingRecords(teamOrAgencyUserListMap.keySet());
            for(String thisKey : teamOrAgencyIdTeamBuildingListMap.keySet()){
                for(Team_Building__c thisTeamBuildingRecord : teamOrAgencyIdTeamBuildingListMap.get(thisKey)){
                    locationIdsSet.add(thisTeamBuildingRecord.Location__c);    
                }
            }
            if(!locationIdsSet.isEmpty()){
                List<Inventory_User__c> inventoryUserList = new List<Inventory_User__c>();
                /* Calling method to get the list of associated inventories to a location. */
                Map<Id, List<Inventory__c>> locationInventoryListMap = getLocationInventoryDetails(locationIdsSet);
                /* Reason for 4 level of nested for : 
                   We need to insert record in inventory user table for each user, each team or a agency can have multiple users added, 
                   and each agency or a team can belong to multiple location which eventually can have multiple inventories. */
                for(Id thisTeamAgencyKey : teamOrAgencyUserListMap.keySet()){
                    for(User thisUser : teamOrAgencyUserListMap.get(thisTeamAgencyKey)){
                        for(Team_Building__c thisTeamBuildingRecord : teamOrAgencyIdTeamBuildingListMap.get(thisTeamAgencyKey)){
                            for(Inventory__c thisInventory : locationInventoryListMap.get(thisTeamBuildingRecord.Location__c)){
                                Inventory_User__c inventoryRecord = new Inventory_User__c();
                                inventoryRecord.unique_key__c = thisUser.Id+'###'+thisInventory;
                                inventoryRecord.User__c = thisUser.Id;
                                inventoryRecord.Inventory__c = thisInventory.Id;
                                inventoryRecord.Team_Building__c = thisTeamBuildingRecord.Id;
                                inventoryUserList.add(inventoryRecord);       
                            }    
                        }
                    }
                }   
                if(!inventoryUserList.isEmpty()){
                    database.upsert(inventoryUserList, Inventory_User__c.unique_key__c.getDescribe().getSObjectField(),false);    
                }    
            }
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to remove users from inventory users junction object,                *
    *                if user are removed from team or an agency.                                 *
    * @Params      : Map<String, List<User>>                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    public static void removeUserAccess(Map<String, List<User>> teamOrAgencyUserListMap){
        Set<Id> teamBuildingIdSet = new Set<Id>();
        try{
            /* Calling method to get map ot team or agency id with associated team building records. */
            Map<String, List<Team_Building__c>> teamOrAgencyIdTeamBuildingListMap = getAssociatedTeamBuildingRecords(teamOrAgencyUserListMap.keySet());
            for(String thisKey : teamOrAgencyIdTeamBuildingListMap.keySet()){
                for(Team_Building__c thisTeamBuildingRecord : teamOrAgencyIdTeamBuildingListMap.get(thisKey)){
                    teamBuildingIdSet.add(thisTeamBuildingRecord.Id);    
                }
            }   
            if(!teamBuildingIdSet.isEmpty()){
                delete getAssociatedInventoryUsers(teamBuildingIdSet);      
            }
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get the associated team building records to a team or an agency.  *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, List<Team_Building__c>>                                         *
    *********************************************************************************************/ 
    private static Map<String, List<Team_Building__c>> getAssociatedTeamBuildingRecords(Set<String> teamOrAgencyIdsSet){
        Map<String, List<Team_Building__c>> teamOrAgencyIdTeamBuildingListMap = new Map<String, List<Team_Building__c>>();
        for(Team_Building__c thisTeamBuilding : [SELECT Id, Start_Date__c, End_Date__c, Project__c, 
                                                        Unique_Key__c, Agency_or_Group_Id__c, 
                                                        Location__c 
                                                 FROM Team_Building__c 
                                                 WHERE Agency_or_Group_Id__c IN: teamOrAgencyIdsSet]){
            if(teamOrAgencyIdTeamBuildingListMap.containsKey(thisTeamBuilding.Agency_or_Group_Id__c)){
                teamOrAgencyIdTeamBuildingListMap.get(thisTeamBuilding.Agency_or_Group_Id__c).add(thisTeamBuilding);        
            }else{
                teamOrAgencyIdTeamBuildingListMap.put(thisTeamBuilding.Agency_or_Group_Id__c, new List<Team_Building__c>{thisTeamBuilding});
            }    
        }    
        return teamOrAgencyIdTeamBuildingListMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get the associated inventory records to a location.               *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, List<Inventory__c>>                                             *
    *********************************************************************************************/ 
    private static Map<Id, List<Inventory__c>> getLocationInventoryDetails(Set<Id> locationIdsSet){ 
        Map<Id, List<Inventory__c>> locationInventoryListMap = new Map<Id, List<Inventory__c>>();
        for(Inventory__c thisInventory : [SELECT Id, Building_Location__c 
                                          FROM Inventory__c 
                                          WHERE Status__c = 'Available' AND 
                                                Building_Location__c IN: locationIdsSet]){
            if(locationInventoryListMap.containsKey(thisInventory.Building_Location__c)){
               locationInventoryListMap.get(thisInventory.Building_Location__c).add(thisInventory);      
            }else{  
                locationInventoryListMap.put(thisInventory.Building_Location__c, new List<Inventory__c>{thisInventory});
            }         
        }
        return locationInventoryListMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get the associated inventory users records related to a team.     *
    * @Params      : Set<Id>                                                                     *
    * @Return      : List<Inventory__c>                                                          *
    *********************************************************************************************/ 
    private static List<Inventory_User__c> getAssociatedInventoryUsers(Set<Id> teamBuildingIdSet){
        return ([SELECT Id FROM Inventory_User__c WHERE Team_Building_ID__c IN: teamBuildingIdSet]);    
    }
}// End of class.