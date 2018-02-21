/**************************************************************************************************
* Name                  : AgencyPCTriggerHandler    
* Test Class            : Test Class Name
* Description           : This class will update the number of Agency PCs are assigned to the Agency Account .
* Created By            : NSI - DMCC                                                                        
* Created Date          : 12/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - DMCC               12/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
public with sharing class AgencyPCTriggerHandler implements TriggerFactoryInterface{
    
    /**
    * Description: this method takes the parameter as Map and this will call from AgencyPCTrigger
    * Parameter : Set<ID>
    * Return    : void
    **/
    @TestVisible private void executeOnAfterInsertUpdateDelete(Set<ID> updatedAgencyIDs){
        
        List<Account> updateAccounts = new List<Account>();
        try{
            //Aggregate query to get the number of active agency users are assigned to the account
            for(AggregateResult PC : [SELECT Agency__c,Count(Id) totPCs FROM Agency_PC__c WHERE ID IN: updatedAgencyIDs AND User__c != null AND User__r.isActive = true Group By Agency__c ]){
                    updateAccounts.add(new Account(id=(ID)PC.get('Agency__c'),Number_of_PCs_Assigned__c = (Decimal)PC.get('totPCs')));
            }
            //update the records if the list is not blank
            System.debug('updateAccounts==='+updateAccounts);
            if(!updateAccounts.isEmpty()){
                update updateAccounts;
                System.debug('updateAccounts123==='+updateAccounts);
            }
        }Catch(Exception ex){
            if(!Trigger.isDelete)
                Trigger.new[0].addError(''+ex.getMessage());
            else Trigger.old[0].addError(''+ex.getMessage());
        } 
    }
    //Methods to be implemented
    //Before Trigger Methods
	public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){}
	public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
	public void executeBeforeDeleteTrigger(Map<Id, sObject> mapOldRecords){
         deletePCsharingIndividualAcct(mapOldRecords);
    }
	public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords, Map<Id,sObject> mapOldRecords){}
	
	//After Trigger Methods
	public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
	    executeOnAfterInsertUpdateDelete(mapNewRecords.keySet());
	    addAgencyPCToGroup(mapNewRecords.values());
        doSharingIndividualAcc(mapNewRecords,NULL);
	}
	public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
	    executeOnAfterInsertUpdateDelete(mapNewRecords.keySet());
        doSharingIndividualAcc(mapNewRecords,mapOldRecords);
	}
	public void executeAfterDeleteTrigger(Map<Id, sObject> mapOldRecords){
	    executeOnAfterInsertUpdateDelete(mapOldRecords.keySet());
	}
	public void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
	
    public void addAgencyPCToGroup(List<Agency_PC__c> allAgencyPC){
        set<id> stIds = new set<id>();
        for(Agency_PC__c ag : allAgencyPC){
            if(ag.Agency__c != null)
            	stIds.add(ag.Agency__c);
        }
        system.debug('-->'+stIds);
        Map<Id,account> mpaccount = new Map<id,account>([select id,name,Agency_Short_Name__c,UniqueNo__c from account where id in : stids]);
        system.debug('--mpaccount>'+mpaccount); 
        //prepare a map of collabaration grp name => account id
        Map<string,id> mpcolgrpNameaccid = new Map<string,id>();
        for(account acc : mpaccount.values()){
            string str = (acc.Agency_Short_Name__c != null ? acc.Agency_Short_Name__c : '' );
            if(str.length() >27)
                str = str.substring(0,27);
            mpcolgrpNameaccid.put(str+acc.UniqueNo__c+'-Sales',acc.id);
        }
        system.debug('-->mpcolgrpNameaccid'+mpcolgrpNameaccid);
        //prepare a map if accid to list of agency pc's
        Map<Id,List<Agency_PC__c>> mpaccidlstagencies = new Map<Id,List<Agency_PC__c>>();
        for(Agency_PC__c aPC: allAgencyPC){
            if(mpaccidlstagencies.containsKey(aPC.Agency__c)){
                List<Agency_PC__c> tmp = mpaccidlstagencies.get(aPC.Agency__c);
                tmp.add(apc);
                mpaccidlstagencies.put(aPC.agency__c,tmp);    
            }
            else{
                List<Agency_PC__c> tmp = new List<Agency_PC__c>();
                tmp.add(apc);
                mpaccidlstagencies.put(aPC.agency__c,tmp);      
            }
        }
        //Prepare map of account id => collabarationgroup id
        Map<id,id> mpaccidColgrpid = new map<id,id>();
        if(mpcolgrpNameaccid != null && !mpcolgrpNameaccid.isempty()){
            for(CollaborationGroup cg : [select id,name from CollaborationGroup where name in : mpcolgrpNameaccid.keyset()]){
            	mpaccidColgrpid.put(mpcolgrpNameaccid.get(cg.name),cg.id);
            }
        }
        system.debug('-->mpaccidColgrpid'+mpaccidColgrpid);
        List<CollaborationGroupMember> lstCgm = new List<CollaborationGroupMember>();
        //iterate through all agency pc of an account and add them to their respective collabaration group.
        for(id accid : mpaccidlstagencies.keyset()){
            if(mpaccidlstagencies.get(accid) != null && !mpaccidlstagencies.get(accid).isempty() && mpaccidColgrpid.containskey(accid)){
                for(Agency_PC__c apc : mpaccidlstagencies.get(accid)){
                    CollaborationGroupMember cgm = new CollaborationGroupMember();
                    cgm.CollaborationGroupId =mpaccidColgrpid.get(accid);
                    cgm.memberId = apc.User__c;
                    lstCgm.add(cgm);
                }
            }
        }
        if(lstCgm != null && !lstCgm.isempty()){
            insert lstCgm;
        }
    }
    
    public static void doSharingIndividualAcc(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        List<AccountSharingUtility.JsonWrapper> lstSharingRec = new List<AccountSharingUtility.JsonWrapper>();
        Map<id,set<id>> mpAccIdStUIds = new Map<id,set<id>>();
        List<Agency_PC__c> lsttoConsider = new List<Agency_PC__c>();
        //Prepare map of accid to the set of users.
        if(mapNewRecords != null && !mapNewRecords.isempty()){
            for(sObject objrec : mapNewRecords.values())
            {
                Agency_PC__c newrec = (Agency_PC__c)objrec;
                Agency_PC__c oldrec = null;
                if(mapOldRecords != null && !mapOldRecords.isempty()){
                    oldrec = (Agency_PC__c)mapOldRecords.get(objrec.id);
                }
                if(oldrec != null){
                    if(oldrec.Agency__c == newrec.Agency__c)
                    	continue;
                }
                if(mpAccIdStUIds.containskey(newrec.Agency__c)){
                    set<id> stUsersid = mpAccIdStUIds.get(newrec.Agency__c);
                    stUsersid.add(newrec.User__c);
                    mpAccIdStUIds.put(newrec.Agency__c,stUsersId);
                }else{
                    set<id> stUsersid = new set<id>();
                    stUsersid.add(newrec.User__c);
                    mpAccIdStUIds.put(newrec.Agency__c,stUsersId);
                }
            }
        }
        if(mpAccIdStUIds != null && !mpAccIdStUIds.isempty()){
            //share only the individual accounts to users
            Map<Id,Account> mpAccountIndividual = new Map<Id,Account>([select id,name from account where recordtype.name = 'Individual Agency' and id in : mpAccIdStUIds.keyset()]);
            if(mpAccountIndividual != null && !mpAccountIndividual.isempty()){
                for(id acid : mpAccountIndividual.keyset()){
                    if(mpAccIdStUIds.get(acid) != null && !mpAccIdStUIds.get(acid).isempty()){
                        lstSharingRec.add(new AccountSharingUtility.JsonWrapper(acid,mpAccIdStUIds.get(acid)));  
                    }
                }
            }
        }
        if(lstSharingRec != null && !lstSharingRec.isempty()){
            AccountSharingUtility.shareAccount(json.serialize(lstSharingRec));
        }
    }
    
    public static void deletePCsharingIndividualAcct(Map<Id, sObject> mapOldRecords){
        Map<string,integer> mpAccIdUserId = new Map<string,integer>();
        set<Id> staccid = new set<id>();
        for(sObject objrec : mapOldRecords.values())
        {
            Agency_PC__c newrec = (Agency_PC__c)objrec;
            if(newrec.User__c != null && newrec.Agency__c != null){
                mpAccIdUserId.put(string.valueof(newrec.User__c)+string.valueof(newrec.Agency__c),1);
                staccid.add(newrec.Agency__c);
            }
        }
        if(mpAccIdUserId != null && !mpAccIdUserId.isempty()){
            List<AccountShare> lstAccShare = [select id,UserOrGroupId,AccountId from accountshare where accountid =: staccid];
            if(lstAccShare != null && !lstAccShare.isempty()){
                List<AccountShare> lstAccSharetodelete = new List<AccountShare>();
                for(AccountShare accshare : lstAccShare){
                    if(mpAccIdUserId.containsKey(string.valueof(accshare.UserOrGroupId)+string.valueof(accshare.AccountId))){
                        lstAccSharetodelete.add(accshare);
                    }
                }
                if(lstAccSharetodelete != null && !lstAccSharetodelete.isempty()){
                    delete lstAccSharetodelete;
                    database.emptyRecycleBin(lstAccSharetodelete);
                }        
            }
        }
    }
    
   
}