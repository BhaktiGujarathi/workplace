/**************************************************************************************************
* Name               : UserTriggerHandler                                                         *
* Description        : This is a handler for user class. Has below functionality.                 *
*                      - Used to share user with the reporting managers.                          *
*                      - Used to share user's related records with the reporting managers.        *
* Created Date       : NSI - Vineet                                                               *
* Created By         : 17/01/2017                                                                 *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- * 
* Change History    VERSION     AUTHOR                  DATE                                      *
* CH00              1.0         NSI - Vineet            17/01/2017                                *
* CH01              1.1         NSI - Sivasankar        07/02/2017                                *
* CH03				1.2			NSI - Sivasankar		15/03/2017								  *
**************************************************************************************************/
public class UserTriggerHandler implements TriggerFactoryInterface { 
    //CH01.Start
    public Map<ID,ID> portalUserIDs ;
    public Set<ID> inActiveUserIDs;
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
        try{
            /* Calling method to update the salesforce user on contact. */
            portalUserIDs = new Map<ID,ID>();
            inActiveUserIDs = new Set<ID>();
            for(User U : (List<User>)newRecordsMap.values()){
                if(U.IsActive && U.ContactId != null)
                    portalUserIDs.put(U.ContactId,U.id);
                if(!U.IsActive)
                    inActiveUserIDs.add(U.Id);
            }
            if(!portalUserIDs.isEmpty() && portalUserIDs.size() > 0){
                updateContactWithSalesforceUser(portalUserIDs);
                addAgentToCampainAndInventory(portalUserIDs);
                updateNoOfPortalUsers(portalUserIDs.keyset());
                createCollaborationGroup(portalUserIDs.values());
                assigntorespectiveAccountCG(portalUserIDs.values());
            } 
            
            if(!inActiveUserIDs.isEmpty() && inActiveUserIDs.size() > 0){
                removeInventoryAccess(inActiveUserIDs);
            }
            assigntoQueue(newRecordsMap.keySet());
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after update.                        *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        try{
        	//CH03 Add the condition to bypass the when users are updated from reshuffling batch
        	if(!DAMAC_Constants.isExecutingFromReshufflingBatch){
	            /* Calling method to update the salesforce user on contact. */
	            portalUserIDs = new Map<ID,ID>();
	            Map<ID,ID> activeContactsUserID = new Map<ID,ID>();
	            inActiveUserIDs = new Set<ID>();
	            
	            for(User U : (List<User>)newRecordsMap.values()){
	                if(U.IsActive != ((User)oldRecordsMap.get(U.id)).IsActive && U.ContactId != null){
	                    portalUserIDs.put(U.ContactId,U.id);
	                    if(U.IsActive)
	                        activeContactsUserID.put(U.ContactId,U.ID);
	                }
	                if(!U.IsActive)
	                    inActiveUserIDs.add(U.Id);
	            }
	            if(!portalUserIDs.isEmpty() && portalUserIDs.size() > 0){
	                updateNoOfPortalUsers(portalUserIDs.keyset());
	            }
	            
	            if(!activeContactsUserID.isEmpty() && activeContactsUserID.size() > 0){
	                addAgentToCampainAndInventory(activeContactsUserID);
	            }
	            
	            if(!inActiveUserIDs.isEmpty() && inActiveUserIDs.size() > 0){
	                removeInventoryAccess(inActiveUserIDs);
	            }
        	}
            set<Id> stUseridsAssignQueues = new set<id>();
            for(user ul : (List<User>)newRecordsMap.values()){
                user oldrec = (User)oldRecordsMap.get(ul.id);
                if(ul.Assign_to_Queue__c != oldrec.Assign_to_Queue__c && ul.Assign_to_Queue__c){
                    stUseridsAssignQueues.add(ul.id);
                }
            }
            if(stUseridsAssignQueues != null && !stUseridsAssignQueues.isempty()){
                assigntoQueue(stUseridsAssignQueues);
            }
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to update contact with the user.                                     *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @future
    @TestVisible private static void updateContactWithSalesforceUser(Map<ID,ID> updatedContactsUserID) {
        List<Contact> updateContacts = new List<Contact>();
        for(ID conID: updatedContactsUserID.keySet()){
                updateContacts.add(new Contact(Id = conID, Salesforce_User__c = updatedContactsUserID.get(conID)));
        }
        if(!updateContacts.isEmpty()){
            update updateContacts;
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to remove the access on Inventory for inactive users                 *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @future
    @TestVisible private static void removeInventoryAccess(Set<ID> inActiveUsers) {
        try{
            List<Agency_PC__c> inActivePCs = new List<Agency_PC__c>([SELECT ID FROM Agency_PC__c WHERE User__c IN:inActiveUsers ]);
            if(!inActivePCs.isEmpty()){ delete inActivePCs;}
            
            List<Assigned_PC__c> inActiveAssignedPCs = new List<Assigned_PC__c>([SELECT ID FROM Assigned_PC__c WHERE User__c IN:inActiveUsers ]);
            if(!inActiveAssignedPCs.isEmpty()){ delete inActiveAssignedPCs;}
            
            List<Assigned_Agent__c> inActiveAssignedAgents = new List<Assigned_Agent__c>([SELECT ID FROM Assigned_Agent__c WHERE User__c IN:inActiveUsers ]);
            if(!inActiveAssignedAgents.isEmpty()){ delete inActiveAssignedAgents;}
            
            List<Inventory_User__c> inActiveInvUsers = new List<Inventory_User__c>([SELECT ID FROM Inventory_User__c WHERE User__c IN:inActiveUsers ]);
            if(!inActiveInvUsers.isEmpty()){ delete inActiveInvUsers;}
        }
        Catch(Exception ex){
            system.debug('#### removeInventoryAccess = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    /************************************************************************************************
    * @Description : this method takes the parameter as Map and this will call from AgencyPCTrigger *
    * @Params      : Set<ID>                                                                        *
    * @Return      : void                                                                           *
    * @Created By  : Sivasankar                                                                     *
    *************************************************************************************************/
    @future
    @TestVisible private static void updateNoOfPortalUsers(set<ID> updatedAgencyIDs){
        
        List<Account> updateAccounts = new List<Account>();
        try{
            //Aggregate query to get the number of active agency users are assigned to the account
            for(AggregateResult agg : [SELECT AccountID,Count(Id) totPCs 
                                        FROM Contact 
                                        WHERE ID IN: updatedAgencyIDs 
                                            AND Salesforce_User__c != null 
                                            AND Salesforce_User__r.isActive = true 
                                        Group By AccountID ]){
                    updateAccounts.add(new Account(id=(ID)agg.get('AccountID'),Strength_of_Agency__c = (Decimal)agg.get('totPCs')));
            }
            //update the records if the list is not blank
            System.debug('updateAccounts==='+updateAccounts);
            if(!updateAccounts.isEmpty()){
                update updateAccounts;
            }
        }Catch(Exception ex){
            system.debug('#### updateNoOfPortalUsers Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        } 
    }
    
    /************************************************************************************************
    * @Description : Method to add the new portal user to Assigned Agent and Inventory User         *
    * @Params      : List<Contact>                                                                  *
    * @Return      : void                                                                           *
    * @Created By  : Sivasankar                                                                     *
    *************************************************************************************************/
    @future
    @TestVisible private static void addAgentToCampainAndInventory(Map<ID,ID> activeContactsUserID){
        
        List<Assigned_Agent__c> upsertAgents = new List<Assigned_Agent__c>();
        Map<String,Assigned_Agent__c> existingAssignedAgents = new Map<String,Assigned_Agent__c>();
        List<Inventory_User__c> upsertInvUsers = new List<Inventory_User__c>();
        Map<String,List<Inventory_User__c>> existingInvUsers = new Map<String,List<Inventory_User__c>>();
        Map<Id,contact> contactMap = new Map<Id,Contact>([SELECT Id,AccountId,Salesforce_User__c,Salesforce_User__r.IsActive FROM Contact WHERE ID IN:activeContactsUserID.keySet()]);
        
        Set<ID> accountIds = new Set<ID>();
        Assigned_Agent__c assAgent;
        Inventory_User__c invUser;
        
        
        for(Id conID : activeContactsUserID.keySet()){
            if(contactMap.containsKey(conID)){ accountIds.add(contactMap.get(conID).AccountId); }
        }

        try{
            if(!accountIds.isEmpty()){
                //insert the newly added Contact to Assigned Agent
                for(AggregateResult ag : [SELECT Agency__c,Campaign__c,End_Date__c,Start_Date__c 
                                            FROM Assigned_Agent__c 
                                            WHERE Agency__c IN: accountIds 
                                            GROUP BY Agency__c,Campaign__c,End_Date__c,Start_Date__c]){
                                                
                    if(!existingAssignedAgents.containsKey((String)ag.get('Agency__c'))) {
                        assAgent = new Assigned_Agent__c(Agency__c = (ID)ag.get('Agency__c'),
                                                        Campaign__c = (ID)ag.get('Campaign__c'), 
                                                        Start_Date__c = (Date)ag.get('Start_Date__c'),
                                                        End_Date__c = (Date)ag.get('End_Date__c'));
    
                        existingAssignedAgents.put((String)ag.get('Agency__c'),assAgent);
                    }
                }
                
                for(Contact con : contactMap.values()){ 
                    if(existingAssignedAgents.containsKey(con.AccountID)){
                        assAgent = existingAssignedAgents.get(con.AccountID);
                        upsertAgents.add(new Assigned_Agent__c(Agency__c = assAgent.Agency__c, 
                                                              Campaign__c = assAgent.Campaign__c,
                                                              Start_Date__c = assAgent.Start_Date__c,
                                                              End_Date__c = assAgent.End_Date__c,
                                                              Contact__c = con.id,
                                                              User__c = activeContactsUserID.get(con.id),
                                                              Unique_ID__c=assAgent.Campaign__c+'###'+activeContactsUserID.get(con.id)));
                    }
                }
    
                if(!upsertAgents.isEmpty()){
                    Database.upsert(upsertAgents,Assigned_Agent__c.Unique_ID__c.getDescribe().getSObjectField(),false);
                }
                
                //insert the newly added Contact to Inventory User
                for(AggregateResult ag : [SELECT End_Date__c,Inventory__c,Start_Date__c,Team_Building__c,Team_Building__r.Agency_or_Group_Id__c agID 
                                            FROM Inventory_User__c 
                                            WHERE Team_Building__r.Agency_or_Group_Id__c IN: accountIds 
                                                AND Team_Building__c != null 
                                                GROUP BY Inventory__c,Team_Building__c,Start_Date__c,End_Date__c,Team_Building__r.Agency_or_Group_Id__c]){
                    invUser = new Inventory_User__c(Inventory__c = (ID)ag.get('Inventory__c'),
                                                        Team_Building_ID__c = (String)ag.get('Team_Building__c'),
                                                        Team_Building__c = (ID)ag.get('Team_Building__c'), 
                                                        Start_Date__c = (Date)ag.get('Start_Date__c'),
                                                        Unique_Key__c = null,
                                                        End_Date__c = (Date)ag.get('End_Date__c'));
                    
                    System.debug('Adding portal users to Inventory Users');  
                    
                    if(existingInvUsers.containsKey((String)ag.get('agID'))) {
                        upsertInvUsers = existingInvUsers.get((String)ag.get('agID'));
                        upsertInvUsers.add(invUser);
                        existingInvUsers.put((String)ag.get('agID'),upsertInvUsers);
                    }
                    else{
                        upsertInvUsers = new List<Inventory_User__c>();
                        upsertInvUsers.add(invUser);
                        existingInvUsers.put((String)ag.get('agID'),upsertInvUsers);
                    }
                }
                System.debug('existingInvUsers = '+existingInvUsers.size()+', existingInvUsers = '+existingInvUsers.values().size());
                System.debug('upsertInvUsers 1 = '+upsertInvUsers.size());
                upsertInvUsers = new List<Inventory_User__c>();
                System.debug('upsertInvUsers Before= '+upsertInvUsers.size());
                
                for(Contact con : contactMap.values()){ 
                    if(existingInvUsers.containsKey(con.AccountID)){
                        for(Inventory_User__c invUserRec : existingInvUsers.get(con.AccountID)){
                            invUserRec.User__c = activeContactsUserID.get(con.id);
                            invUserRec.Unique_Key__c = invUserRec.Inventory__c+'###'+activeContactsUserID.get(con.id);
                            upsertInvUsers.add(invUserRec);
                            System.debug('#####3');
                        }
                    }
                }
                System.debug('upsertInvUsers = '+upsertInvUsers.size());
                if(!upsertInvUsers.isEmpty()){
                    System.debug('#####2');
                    //insert upsertInvUsers;
                    Database.upsert(upsertInvUsers,Inventory_User__c.unique_key__c.getDescribe().getSObjectField(),false);
                    System.debug('#####1');
                }
            }
        }catch(Exception ex){
            system.debug('#### addAgentToCampainAndInventory Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
            throw ex;
        }
    }
    //CH01.End
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        AgencyFieldsHandler(newRecordsList);
    }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        
        AgencyFieldsHandler(newRecordsMap.values());
        
    }
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, map<Id,sObject> oldRecordsMap){
        
    }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    public static void AgencyFieldsHandler(List<sobject> newRecordsList){
        Set<Id> agencyIds = new Set<Id>();
        for(User u: (List<User>)newRecordsList){
            if(u.accountId != null) { agencyIds.add(u.accountId); }
        }
        
        if(!agencyIds.isEmpty()){
            Map<Id,Account> agencies = new map<Id,account>();
            for(Account acc: [Select id, name, Agency_Tier__c, Eligible_For_Tier_Program__c from Account where Id in: agencyIds]){
                agencies.put(acc.Id,acc);
            }
            
            for(User u:(List<User>) newRecordsList){
                if(u.accountId != null && agencies.containsKey(u.accountId)){
                    u.Account_name__c = agencies.get(u.accountId).Name;
                    u.agency_tier_status__c = agencies.get(u.accountId).Agency_Tier__c;
                    u.Eligible_For_Tier_Program__c = agencies.get(u.accountId).Eligible_For_Tier_Program__c ; 
                }
            }
        }
    }
    
    @future 
    private static void createCollaborationGroup(list<Id> userIds){
        if(!userIds.isEmpty()){
            if(String.isNotBlank(System.label.Default_Community_Chatter_group)){
                CollaborationGroup cgrp;
                for(CollaborationGroup thisGroup : [SELECT Id FROM CollaborationGroup WHERE Name =: System.label.Default_Community_Chatter_group]){
                    cgrp = thisGroup;
                    break;  
                }
                if(cgrp != null){
                    List<CollaborationGroupMember> lstMembers = new List<CollaborationGroupMember>();
                    for(Id userId : userIds){
                        CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cgrp.Id, MemberId = userId, CollaborationRole = 'Standard');
                        lstMembers.add(cgm);
                    }
                    if(!lstMembers.isEmpty()){
                        insert lstMembers;
                    }   
                }
            }
        }   
    }
    
    @future
    Public static void assigntoQueue(set<Id> stUsrIds){
        try{
            Map<string,List<string>> mpProfileNameGroupName = new Map<string,List<string>>();
            set<string> stUniqQueuNames = new set<string>();
            for(ProfileQueueMapping__mdt cmd: [select id,MasterLabel,developername,Profile_Name__c,Queue_Name__c from ProfileQueueMapping__mdt]){
                if(mpProfileNameGroupName.containsKey(cmd.Profile_Name__c)){
                    List<string> lstQueNames = mpProfileNameGroupName.get(cmd.Profile_Name__c);
                    lstQueNames.add(cmd.Queue_Name__c);
                    mpProfileNameGroupName.put(cmd.Profile_Name__c,lstQueNames);
                }else{
                    List<string> lstQueNames = new List<string>();
                    lstQueNames.add(cmd.Queue_Name__c);
                    mpProfileNameGroupName.put(cmd.Profile_Name__c,lstQueNames);
                }
                stUniqQueuNames.add(cmd.Queue_Name__c);
            }
            
            Map<string,id> mpGrpNameGrpId = new Map<string,id>();
            For(Group gp : [select Id,name,developername from Group where type='Queue' and name in : stUniqQueuNames]){
                mpGrpNameGrpId.put(gp.name,gp.id);
            }
            List<User> lstUser = [select id,name,profile.name,Assign_to_Queue__c from user where id in : stUsrIds];
            List<GroupMember> lstGm = new List<GroupMember>();
            List<User> lstUsertoUpdate = new List<User>();
            for(user u : lstUser){
                if(mpProfileNameGroupName.containskey(u.profile.name)){
                    for(string grpname : mpProfileNameGroupName.get(u.profile.name)){
                        lstGm.add(new groupmember(GroupId=mpGrpNameGrpId.get(grpname),UserOrGroupId=u.id));
                    }
                }
            }
            if(lstGm != null && !lstGm.isempty()){
                insert lstGm;         
            }
        }
        catch(exception ex){
            system.debug('--->'+ex.getmessage());
        }
	}
	
    @future
    public static void assigntorespectiveAccountCG(List<Id> userIds){
        Map<id,string> mpuseridCGName = new map<id,string>();
        for(user u : [select id,name,contactid,contact.accountid,contact.account.name,contact.account.Agency_Short_Name__c,contact.account.UniqueNo__c from user where id in: userIds]){
            if(u.contact != null && u.contact.accountid != null){
                string str = (u.contact.account.Agency_Short_Name__c != null ? u.contact.account.Agency_Short_Name__c : '' );
                if(str.length() >27){str = str.substring(0,27);}
                mpuseridCGName.put(u.id,str+u.contact.account.UniqueNo__c+'-Sales');
            }
        }
        system.debug('--mpuseridCGName>'+mpuseridCGName);
        Map<string,id> mpstringCGid = new Map<string,id>();
        for(CollaborationGroup cg : [select id,name from CollaborationGroup where name in : mpuseridCGName.values()]){
            	mpstringCGid.put(cg.name,cg.id);
        }
        system.debug('--mpstringCGid>'+mpstringCGid);
        List<CollaborationGroupMember> lstCgm = new List<CollaborationGroupMember>();
        for(id uid : mpuseridCGName.keyset()){
            CollaborationGroupMember cgm = new CollaborationGroupMember();
            if(!mpstringCGid.containskey(mpuseridCGName.get(uid))){
                continue;
            }
            cgm.CollaborationGroupId =mpstringCGid.get(mpuseridCGName.get(uid));
            cgm.memberId = uid;
            lstCgm.add(cgm);
        }
        system.debug('--lstCgm>'+lstCgm);
        insert lstCgm;
    }
    
    //Version: 2.0 Start
    /*********************************************************************************************
    * @Description : Method to Add the Assigned Agents to Inventory Users on insert              *
    * @Params      : Map<ID,Set<Id>>                                                             *
    * @Return      : none                                                                        *
    *********************************************************************************************/ 
    /*public static void addInventoryUsers(Map<ID,Set<ID>> mapCampaignAgentIDs){
        List<Inventory_User__c> upsertInvetoryUser = new List<Inventory_User__c>();
        Map<ID,List<Inventory_User__c>> mapInventoryUsers = new Map<ID,List<Inventory_User__c>>();
        Set<ID> userIDs = new Set<ID>();
        Set<ID> CampaignAgentIDs = mapCampaignAgentIDs.keySet();
        Set<String> setAddedInventoryUsers = new Set<String>();
        List<Inventory_User__c> inventoryUsersMap;
        Inventory_User__c invUserRec;
        
        
        for(ID campID: mapCampaignAgentIDs.keySet())
            for(ID userID : mapCampaignAgentIDs.get(campID))
                userIDs.add(userID);
                
        for(Assigned_Agent__c thisAgent : (List<Assigned_Agent__c>)Database.query('SELECT User__c,Campaign__c,Start_Date__c,End_Date__c FROM Assigned_Agent__c WHERE Campaign__c IN:CampaignAgentIDs'+(!userIDs.isEmpty() ? ' AND User__c IN:userIDs' : ''))){
            invUserRec = new Inventory_User__c(Campaign__c = thisAgent.Campaign__c,
                                                  Campaign_ID__c = thisAgent.Campaign__c,
                                                  User__c = thisAgent.User__c,
                                                  Inventory__c = null,
                                                  Start_Date__c = thisAgent.Start_Date__c,
                                                  End_Date__c = thisAgent.End_Date__c,
                                                  Unique_Key__c = null);
                                                  
            if(mapInventoryUsers.containsKey(thisAgent.Campaign__c)){
                inventoryUsersMap = mapInventoryUsers.get(thisAgent.Campaign__c);
                inventoryUsersMap.add(invUserRec);
                mapInventoryUsers.put(thisAgent.Campaign__c,inventoryUsersMap);
            }
            else{
                inventoryUsersMap = new List<Inventory_User__c>();
                inventoryUsersMap.add(invUserRec);
                mapInventoryUsers.put(thisAgent.Campaign__c,inventoryUsersMap);
            }
        }
        System.debug('mapInventoryUsers = '+mapInventoryUsers);
        for(Campaign_Inventory__c thisCampInventory : new List<Campaign_Inventory__c>([SELECT Campaign__c,Inventory__c 
                                                                                        FROM Campaign_Inventory__c
                                                                                        WHERE Campaign__c IN:mapCampaignAgentIDs.keySet()])){
            
            for(Inventory_User__c invUser : mapInventoryUsers.containsKey(thisCampInventory.Campaign__c) ? mapInventoryUsers.get(thisCampInventory.Campaign__c) : new List<Inventory_User__c>()){
                invUser.Unique_Key__c = invUser.User__c+'###'+thisCampInventory.Inventory__c;
                invUser.Inventory__c = thisCampInventory.Inventory__c;
                String key = invUser.User__c+'###'+thisCampInventory.Inventory__c+'###'+thisCampInventory.Campaign__c+'###'+invUser.Campaign_ID__c+'###'+invUser.Start_Date__c+'###'+invUser.End_Date__c;
                System.debug('key = '+key);
                if(!setAddedInventoryUsers.contains(key)){
                    upsertInvetoryUser.add(invUser);
                    setAddedInventoryUsers.add(key);
                }
            }
        }
        System.debug('setAddedInventoryUsers = '+setAddedInventoryUsers);
        System.debug('upsertInvetoryUser = '+upsertInvetoryUser);
        if(!upsertInvetoryUser.isEmpty() && upsertInvetoryUser.size() > 0){
            Database.UpsertResult[] upsertResults = Database.upsert(upsertInvetoryUser,Inventory_User__c.unique_key__c.getDescribe().getSObjectField(),false);
        }
    }*/
    //Version: 2.0 End
}// End of class.