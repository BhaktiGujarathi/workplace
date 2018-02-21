public without sharing class CreAllocationHandler { 
	
    public static final list<CRE_Allocation_Customer_Type_Setting__mdt> lstCustomerTypesSetting = CreAllocationUtility.getCustomerTypesSetting();
    
    public static void updateTaskWhoid(List<Task> lstnewtask){
    	
    	Map<Id,Id>taskid_accountid = new Map<Id,Id>();
    	Set<Id> accountids = new Set<Id>();
    	Map<Id,Account> accountmap = new Map<Id,Account>();
    	Set<String> Queuename = new Set<String>();
    	Map<String,List<Id>> queuename_userIds = new Map<String,List<Id>>();
    	List<Id> userIds = new List<Id>();
    	Set<Id> userIdsset= new Set<Id>();
    	Map<Id,Integer> userid_workload = new Map<Id,Integer>();
    	String strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix() ;
    	List<AccountShare> lstaccshare = new List<AccountShare>();
    	
    	for(Task taskobj: lstnewtask){
    		if(String.valueOf(taskobj.whatid).startsWith('001')){
    			accountids.add(taskobj.whatid);
    			taskid_accountid.put(taskobj.id,taskobj.whatid);
    		}
    	}
    	accountmap = new Map<Id,Account>([Select Queue__c from Account where id in :accountids and Queue__c != null]);
    	for(Account accobj: accountmap.values()){
    		Queuename.add(accobj.Queue__c);
    	}
    	
    	List<GroupMember> lstGroupMember = CreAllocationUtility.getGroupMembers(Queuename);
    	
    	for(GroupMember gm : lstGroupMember){
    		if(String.valueOf( gm.UserOrGroupId ).subString(0,3).equalsIgnoreCase( strUserKeyPrefix )){
    			if(queuename_userIds.containskey(gm.Group.DeveloperName)){
    				queuename_userIds.get(gm.Group.DeveloperName).add(gm.UserOrGroupId);
    			} else{
    				queuename_userIds.put(gm.Group.DeveloperName, new List<Id>{gm.UserOrGroupId});
    			}
    		}
    	}
    	
    	for(String queuenamestr : queuename_userIds.keySet()){
    			userIds.addAll(queuename_userIds.get(queuenamestr));
    	}
    	for(Id idobj : userids){
    		userIdsset.add(idobj);
    	}
    	userid_workload= CreAllocationHelper.calculateCreWorkLoad(userIdsset);
    	
    	Integer minworkload ;
    	Id minworkloadid;
    	
    	for(Task taskobj : lstnewtask){
    		minworkload = 0;
    		minworkloadid = null;
    		Id accountid =taskid_accountid.get(taskobj.id);
    		if(accountid != null)
    			{	
    				Account accountobj =accountmap.get(accountid);
    				if(accountobj != null){
    					List<Id>userid = queuename_userIds.get(accountobj.queue__c);
    					if(userid != null){
    						for(Integer i=0;i<userid.size();i++){
    							if(i==0){
    								minworkload=userid_workload.get(userid[i]);
    								minworkloadid =userids[i]; 
    							}
    							else {
    								if(userid_workload.get(userid[i]) < minworkload){
    									minworkload = userid_workload.get(userid[i]);
    									minworkloadid =userid[i];
    								}
    							}
    						}//end of for of userids
    						if(minworkloadid != null){
	    						taskobj.OwnerId = minworkloadid;
	    						AccountShare accshr = new AccountShare();
	    						accshr.AccountId= accountobj.id;
	    						accshr.AccountAccessLevel='Edit';
	    						accshr.OpportunityAccessLevel='Read';
	    						accshr.UserOrGroupId=minworkloadid;
	    						lstaccshare.add(accshr);
    						}
    					}
    				}
    				
    			}//end of if accountid null
    	}
    	if(lstaccshare.size()>0 && lstaccshare != null)
    		insert lstaccshare;
    }//end of function
    
    public static void deletetaskAccountSharing(Map<Id,Task> taskNewMap, Map<Id,Task> taskOldMap){
    	Set<Id> accountIds = new Set<Id>();
    	List<AccountShare> lstAccountshare = new List<AccountShare>();
    	try{
    	for(Task taskobj : taskNewMap.values()){
    		if(taskOldMap.get(taskobj.id).status != taskobj.status && taskobj.status== 'Closed' && String.valueOf(taskobj.whatid).startsWith('001')){
    			accountIds.add(taskobj.accountid);
    		}
    	}
    	if( !accountIds.isEmpty() ){
    		lstAccountshare = [Select id from AccountShare where Accountid in :accountIds and RowCause = 'Manual'];
    		if(!lstAccountshare.isEmpty()){
    			delete lstAccountshare;
    		}
    	}
    	}catch(Exception ex)
    	{
    		System.debug('Exception :' + ex.getMessage());
    	}
    } 
    
    public static void allocateCreToCustomer( list<Account> lstNewAccounts , map<Id, Account> mapOldAccounts ) {
    	if( lstNewAccounts != null && !lstNewAccounts.isEmpty() ) {
    		if( mapOldAccounts != null && !mapOldAccounts.isEmpty() ) {
    			creReAllocation( lstNewAccounts, mapOldAccounts );
    		}
    		system.debug('== lstAccounts after creReAllocation =='+lstNewAccounts);
    		typeAndNationalityBasedAllocation( lstNewAccounts );
    	}
    }
	
	private static void creReAllocation( list<Account> lstNewAccounts ,map<Id, Account> mapOldAccounts ) {
		system.debug('== creReAllocation Method Called ==');
		for( Account objAcc : lstNewAccounts ) {
			if( objAcc.AnnualRevenue != null && objAcc.AnnualRevenue != mapOldAccounts.get( objAcc.Id ).AnnualRevenue && 
				!CreAllocationUtility.getCustomerType( objAcc.AnnualRevenue, lstCustomerTypesSetting ).equalsIgnoreCase( CreAllocationUtility.getCustomerType( mapOldAccounts.get( objAcc.Id ).AnnualRevenue, lstCustomerTypesSetting ) ) ) {
				objAcc.Primary_CRE__c = null;
				objAcc.Secondary_CRE__c = null;
				objAcc.Tertiary_CRE__c = null;
			}
			else if( objAcc.Nationality__pc != null && objAcc.Nationality__pc != mapOldAccounts.get( objAcc.Id ).Nationality__pc ) {
				objAcc.Primary_CRE__c = null;
				objAcc.Secondary_CRE__c = null;
				objAcc.Tertiary_CRE__c = null;
			}
		}
	}
	
	private static void typeAndNationalityBasedAllocation( list<Account> lstNewAccounts ) { 
		CreAllocationUtility.CreAllocationDetailObject objCreDetails = CreAllocationHelper.getCreAllocationDetailObject( lstNewAccounts );
		List<CRE_Allocation_Group_Setting__mdt> CreAllocationGroupSetting = CreAllocationUtility.getGroupSettings();
		Map<String,String> mapcountrygroup_queue = new Map<String,String>();
		for(Integer i=0; i<CreAllocationGroupSetting.size();i++){
			if(CreAllocationGroupSetting[i].MasterLabel == 'Others')
			mapcountrygroup_queue.put(CreAllocationGroupSetting[i].Parent_Queue__c,CreAllocationGroupSetting[i].Queue__c);
		}
		system.debug('== objCreDetails =='+objCreDetails);
		if( objCreDetails != null ) {
			for( Account objAcc : lstNewAccounts ) {
				if( objAcc.AnnualRevenue != null && objAcc.Nationality__pc != null ) {
					String strCountryGroup = '';
					if( objCreDetails.mapCreGroupInfo.containsKey( objAcc.Nationality__pc )  ) {
						strCountryGroup = objAcc.Nationality__pc ;
					}
					else if( objCreDetails.mapCreGroupInfo.containsKey( CreAllocationUtility.getCountryGroupOfCustomer( objAcc.Nationality__pc ) ) ) {
						strCountryGroup =  CreAllocationUtility.getCountryGroupOfCustomer( objAcc.Nationality__pc ) ;
					}
					
					String strCustomerType = CreAllocationUtility.getCustomerType( objAcc.AnnualRevenue, lstCustomerTypesSetting );
					system.debug('== strCountryGroup =='+strCountryGroup);
					if( objCreDetails.mapCreGroupInfo.containsKey( strCountryGroup ) &&
						objCreDetails.mapCreGroupInfo.get( strCountryGroup ).containsKey( strCustomerType ) ) {
						list<String> lstCreGroupName = objCreDetails.mapCreGroupInfo.get( strCountryGroup ).get( strCustomerType );
						system.debug('== lstCreGroupName =='+lstCreGroupName);
						if(strCustomerType != 'Others'){
							if( lstCreGroupName != null ) {
								objAcc.Queue__c=null;
								Integer index = 0;
								if( lstCreGroupName.size() > 0 && objCreDetails.mapGroupNameCreId.containsKey( lstCreGroupName[0] ) ) {
									//Assign Primary CRE to the user here
									objAcc.Primary_CRE__c = objCreDetails.mapGroupNameCreId.get( lstCreGroupName[0] )[ index ];
									
								}
								
								if( lstCreGroupName.size() > 1 && objCreDetails.mapGroupNameCreId.containsKey( lstCreGroupName[1] ) ) {
									//Assign secondry CRE to user here
									if( lstCreGroupName[0].equalsIgnoreCase( lstCreGroupName[1] ) ) {
										index++;
									}
									if( objCreDetails.mapGroupNameCreId.get( lstCreGroupName[1] ).size() > index ) {
										objAcc.Secondary_CRE__c = objCreDetails.mapGroupNameCreId.get( lstCreGroupName[1] )[ index ];
										
									}
								}
								
								if( lstCreGroupName.size() > 2 && objCreDetails.mapGroupNameCreId.containsKey( lstCreGroupName[2] )  ) {
									//Assign tertiary CRE to user here
									if( lstCreGroupName[1].equalsIgnoreCase( lstCreGroupName[2] ) ) {
										index++;
									}
									if( objCreDetails.mapGroupNameCreId.get( lstCreGroupName[2] ).size() > index ) {
										objAcc.Tertiary_CRE__c = objCreDetails.mapGroupNameCreId.get( lstCreGroupName[2] )[ index ];
										
									}
								}
								
								
							}
						}else{
							objAcc.Queue__c = mapcountrygroup_queue.get(strCountryGroup);
						}
					}
				}
			}
		}
	}
}