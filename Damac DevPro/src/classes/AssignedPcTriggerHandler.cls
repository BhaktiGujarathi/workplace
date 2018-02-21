/**************************************************************************************************
* Name               : AssignedPcTriggerHandler                                                   *
* Description        : This is a handler class to manage Assigned PC object.                      *
* 					   - Used to share records with PC and PC's Manager.                          *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE                                                              *
* 1.0         NSI - Vineet      17/01/2017                                                        *
**************************************************************************************************/
public class AssignedPcTriggerHandler extends UtilitySharingManager implements TriggerFactoryInterface{ 
	
	/*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
    	try{
    		/*Calling method to update inquiry status when a activity is created. */
	    	provideAccess((Map<Id, Assigned_PC__c>) newRecordsMap);	 
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
	    	revokeAccess((Map<Id, Assigned_PC__c>) oldRecordsMap);	 
    	}catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }  
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
    	Set<ID> userIDs = new Set<ID>();
    	for(Assigned_PC__c aPC : (List<Assigned_PC__c>)newRecordsList){
    		aPC.Unique_ID__c = aPC.User__c+'###'+aPC.Campaign__c;
    		if(aPC.User__c != null)
    			userIDs.add(aPC.User__c);
    	}
    	Map<ID,User> mapUsers = new Map<ID,User>([Select Id,Email FROM User WHERE ID IN:userIDs]);
    	for(Assigned_PC__c aPC : (List<Assigned_PC__c>)newRecordsList){
    		if(aPC.User__c != null && mapUsers.containsKey(aPC.User__c))
    		aPC.PC_Email__c = mapUsers.get(aPC.User__c).Email;
    	}
    }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    	Set<ID> userIDs = new Set<ID>();
    	for(Assigned_PC__c aPC : (List<Assigned_PC__c>)newRecordsMap.values()){
    		aPC.Unique_ID__c = aPC.User__c+'###'+aPC.Campaign__c;
    		if(aPC.User__c != null)
    			userIDs.add(aPC.User__c);
    	}
    	Map<ID,User> mapUsers = new Map<ID,User>([Select Id,Email FROM User WHERE ID IN:userIDs]);
    	for(Assigned_PC__c aPC : (List<Assigned_PC__c>)newRecordsMap.values()){
    		if(aPC.User__c != null && mapUsers.containsKey(aPC.User__c))
    		aPC.PC_Email__c = mapUsers.get(aPC.User__c).Email;
    	}
    }
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, map<Id,sObject> oldRecordsMap){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    
	/*********************************************************************************************
    * @Description : Method to provide access to the PC and PC's Manager.                        *
    * @Params      : Map<Id, Assigned_PC__c>                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
	@TestVisible  private void provideAccess(Map<Id, Assigned_PC__c> newRecordsMap){
		List<SObject> shareRecordsList = new List<SObject>();
		Map<Id, List<Assigned_PC__c>> ownerCampaignMap = new Map<Id, List<Assigned_PC__c>>();  
		for(Assigned_PC__c thisAssignedPc : newRecordsMap.values()){
			if(thisAssignedPc.User__c != null){
				if(ownerCampaignMap.containsKey(thisAssignedPc.User__c)){
					ownerCampaignMap.get(thisAssignedPc.User__c).add(thisAssignedPc);		
				}else{
					ownerCampaignMap.put(thisAssignedPc.User__c, new List<Assigned_PC__c>{thisAssignedPc});		
				}
			}
		}	
		if(!ownerCampaignMap.isEmpty()){
			/* Calling query utility class for getting the manager details. */
			Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(ownerCampaignMap.keySet());
			for(Assigned_PC__c thisAssignedPc : newRecordsMap.values()){
				User userAgentRecord = userManagerMap.get(thisAssignedPc.User__c);
				if(userAgentRecord.Id != null){ 
					/* Calling sharing utility class to grant access to user hierarchy. */
					shareRecordsList.addAll(invokeAccess(userAgentRecord, thisAssignedPc.Campaign__c.getSobjectType().getDescribe().getName(), thisAssignedPc.Campaign__c, ''));
				}
			}
			if(!shareRecordsList.isEmpty()){
				/* Calling queable method to insert sharing records in the sharing table. */
				system.enqueueJob(new UtilitySharingManager(shareRecordsList, new List<sObject>()));
			}	
		}
	}    
	
	/*********************************************************************************************
    * @Description : Method to revoke access after the PC is removed from the campaign.          *
    * @Params      : Map<Id, Assigned_PC__c>                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
	public void revokeAccess(Map<Id, Assigned_PC__c> deletedRecordsMap){
		Set<Id> campaignIdsSet = new Set<Id>();
		Set<Id> assignedPcIdsSet = new Set<Id>();
		List<Campaign__Share> deleteSharingRecordList = new List<Campaign__Share>();
		for(Assigned_PC__c thisDeletedPc : deletedRecordsMap.values()){
			campaignIdsSet.add(thisDeletedPc.Campaign__c);	
			assignedPcIdsSet.add(thisDeletedPc.User__c);
		}
		if(!campaignIdsSet.isEmpty()){
			/* Calling method to get records from campaign sharing table. */
			Map<Id, List<Campaign__Share>> campaignShareRecordsMap = getSharingRecords(campaignIdsSet);	
			/* Calling query utility class for getting the manager details. */
			Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(assignedPcIdsSet);	
			if(!campaignShareRecordsMap.isEmpty() && !userManagerMap.isEmpty()){
				for(Assigned_PC__c thisDeletedPc : deletedRecordsMap.values()){
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
}// End of class