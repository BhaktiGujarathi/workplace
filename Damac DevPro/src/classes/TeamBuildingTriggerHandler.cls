/****************************************************************************************************************
* Name                  : TeamBuildingTriggerHandler                                                            *
* Test Class            : ManageTeamsAgenciesInventoriesCtrl_Test                                               *
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
public with sharing class TeamBuildingTriggerHandler implements TriggerFactoryInterface {
    
    // TO BE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){
        try{
            Map<Id,List<Id>> mpInventories = new Map<Id, List<Id>>();
            Map<Id,List<Id>> mpAgencyGroups = new Map<Id, List<Id>>();
            set<string> buildingIds = new set<string>();
            set<string> agencyGroupIds = new set<string>();
            Boolean areGroupRecords = false;
            
            String groupKeyPrefix =  Schema.getGlobalDescribe().get('Group').getDescribe().getkeyprefix();
            
            for(Team_Building__c tb: (List<Team_Building__c>)newRecordsMap.values()){
                agencyGroupIds.add(tb.Agency_or_Group_Id__c);
                areGroupRecords = (tb.Agency_or_Group_Id__c.startsWith(groupKeyPrefix) ? true : false);
                buildingIds.add(tb.Location__c);
            }
            
            if(!agencyGroupIds.isEMpty()){
                if(areGroupRecords){ 
                    for(GroupMember gm: [Select id, UserOrGroupId, groupid from GroupMember where groupid in: agencyGroupIds]){
                       if(!mpAgencyGroups.containsKey(gm.groupid)){
                           mpAgencyGroups.put(gm.groupid, new List<id>{gm.UserOrGroupId});
                       }
                       else{    
                           List<Id> existing = mpAgencyGroups.get(gm.groupid);
                           existing.add(gm.UserOrGroupId);
                           mpAgencyGroups.put(gm.groupid,existing);
                       }         
                    } 
                } 
                else{
                    //Adding Property Consultants
                    for(Agency_PC__c agency: [Select id, User__c,Agency__c from Agency_PC__c where Agency__c in: agencyGroupIds]){
                       if(!mpAgencyGroups.containsKey(agency.Agency__c)){
                           mpAgencyGroups.put(agency.Agency__c, new List<id>{agency.User__c});
                       }
                       else{    
                           List<Id> existing = mpAgencyGroups.get(agency.Agency__c);
                           existing.add(agency.User__c);
                           mpAgencyGroups.put(agency.Agency__c,existing);
                       }         
                    }
                    
                    //Adding Portal Users
                    for(Contact agent: [Select id, Salesforce_User__c,AccountID from Contact where AccountID IN: agencyGroupIds AND Salesforce_User__c != null AND Salesforce_User__r.IsActive = True]){
                       if(!mpAgencyGroups.containsKey(agent.AccountID)){
                           mpAgencyGroups.put(agent.AccountID, new List<id>{agent.Salesforce_User__c});
                       } 
                       else{    
                           List<Id> existing = mpAgencyGroups.get(agent.AccountID);
                           existing.add(agent.Salesforce_User__c);
                           mpAgencyGroups.put(agent.AccountID,existing);
                       }         
                    }
                }
            }
            //add the users in Inventory User object
            //InventoryTrgHandler.addUserAccess(mpAgencyGroups);
            
            if(!buildingIds.isEMpty()){
                for(inventory__c inv: [Select id,Building_Location__c from Inventory__c where Status__c = 'RELEASED' AND Building_Location__c in: buildingIds]){
                   if(!mpInventories.containsKey(inv.Building_Location__c)){
                       mpInventories.put(inv.Building_Location__c, new List<id>{inv.Id});
                   }
                   else{    
                       List<Id> existing = mpInventories.get(inv.Building_Location__c);
                       existing.add(inv.id);
                       mpInventories.put(inv.Building_Location__c,existing);
                   }         
                }
            }
        
        
            List<Inventory_User__c> lstUsers2Upsert = new List<Inventory_User__c>();
            for(Team_Building__c tb: (List<Team_Building__c>)newRecordsMap.values()){
                if(mpAgencyGroups.containsKey(tb.Agency_or_Group_Id__c)){
                    for(Id userId: mpAgencyGroups.get(tb.Agency_or_Group_Id__c)){
                        if(mpInventories.containsKey(tb.Location__c)){
                            for(Id inventoryId: mpInventories.get(tb.Location__c)){
                                Inventory_User__c iu = new Inventory_User__c();
                                iu.Inventory__c = inventoryId;
                                iu.User__c = userId;
                                iu.Start_Date__c = tb.Start_Date__c;
                                iu.End_Date__c = tb.End_Date__c;
                                iu.unique_key__c = userId+'###'+inventoryId;
                                iu.Team_Building__c = tb.Id;
                                iu.Team_Building_ID__c = tb.Id;
                                lstUsers2Upsert.add(iu);
                            }
                        }                           
                    }   
                }
            } 
    
            if(!lstUsers2Upsert.isEmpty())
                database.Upsert(lstUsers2Upsert,Inventory_User__c.unique_key__c.getDescribe().getSObjectField() ,false);
        
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){
        delete [Select id from Inventory_User__c where Team_Building_ID__c in: oldRecordsMap.keySet()];
    }
}