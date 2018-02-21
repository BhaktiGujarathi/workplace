/**************************************************************************************************
* Name                  : CampaignManageUsersControl    
* Visualforce Page      : CampaignManageUsers
* Description           : This class will invoke from CampaignManageUsers page, it will display all Property Consultant profile users in the page with search functinality
*                         and pagination. Once admin selects the user and click on add Campaign users button it will search for Agencies where selected users are assigned.
*                         Will create the Campaign Users with all related Contacts which has the Portal users and one more record for selected users with Campaign and related user. And the selected user is not assigned to any Agency then 
*                         it will create the Campaign User record with Campaign and related user.
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 12/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         12/Jan/2017      Initial development
* CH01              2.0			NSI - Sivasankar K 		   19/Apr/2017		#406 - Add all pc users to campaign
* CH02              3.0
**************************************************************************************************/

public with sharing class CampaignManageUsersControl {
    
    public CampaignManage_Helper manageHelper {get;set;}
    List<CampaignManage_Helper.searchResultWrapper> lstofPCProfielUser {get;set;}
    public List<CampaignManage_Helper.searchResultWrapper> lstSelectedAgencies {get;set;}
    public Search_User__c searchSection {get;set;}
    public static Date mStartDate {get;set;} 
    public static Date mEndDate {get;set;}
    public static Integer dMStartDate {get;set;} 
    public static Integer dMEndDate {get;set;}
    public Boolean showPopup {get; set;}
    /**
    * existingInventories: Get the existing Inventories
    **/
    public static Set<Id> existingusers{
        get{
            existingusers = CampaignManage_Helper.existingRecordIds('Assigned_PC__c');
            return existingusers;
        }
        set;
    } 
    
    public static String campaignID {
        get{
            campaignID = ApexPages.currentPage().getParameters().get('id');
            return campaignID;
        }
        set;
    }
    
    public Campaign__c campainRecords {
        get{
            if(campainRecords == null && String.isNotBlank(campaignID)){
                campainRecords = [SELECT ID,Name,Marketing_Start_Date__c,Marketing_End_Date__c FROM Campaign__c WHERE ID=:campaignID];
            }
            return campainRecords;
        }
        set;
    }
    
    public List<SelectOption> teamNames {
        get{
            if(teamNames == null){
                teamNames = new List<SelectOption>();
                teamNames.add(new SelectOption('','--Select Team--'));
                for(Group gr : new List<Group>([SELECT ID,DeveloperName FROM Group WHERE DeveloperName LIKE '%DAMAC_TEAM%'])){
                    teamNames.add(new SelectOption(gr.id,gr.DeveloperName.subStringBefore('_DAMAC_TEAM')));
                }
            }
            return teamNames;
        }
        set;
        
    }
    //public Campaign_User__c defaultDates{get;set;}
    
    /**
    *CampaignManageUsersControl(ApexPages.StandardController ctrl): Default constructor
    **/
    public CampaignManageUsersControl(ApexPages.StandardController ctrl) {
        
        showPopup = false;
        lstSelectedAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        searchSection = new Search_User__c();
        manageHelper = new CampaignManage_Helper('Select Id,Title, Name,Email,Languages_Known__c,HOS_Name__c,HOD_Name__c,DOS_Name__c,UserName,Profile.Name FROM User WHERE Profile.Name =\'Property Consultant\' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000');
        mStartDate =campainRecords.Marketing_Start_Date__c;
        mEndDate = campainRecords.Marketing_End_Date__c;
        dMStartDate = null;
        dMEndDate = null;
        System.debug('mStartDate = '+mStartDate+'mEndDate = '+mEndDate);
        
    }
    
    @RemoteAction
    public static List<String> searchUser(String searchTerm,String campID,String autoFor) {
        System.debug('Search String is: '+searchTerm +'MS = '+mStartDate+',MD'+mEndDate+'=>'+campID);
        String queryStr = 'Select Id, Name from User where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Profile.Name='+((autoFor == 'Property') ? '\'Property Consultant\'':((autoFor == 'HOS') ? '\'Head of Sales\'' : ((autoFor == 'DOS') ? '\'Director of Sales\'':'')))+' AND IsActive = true';
        if(String.isNotBlank(campID)){
            Campaign__c camRec = [SELECT ID,Name,Marketing_Start_Date__c,Marketing_End_Date__c FROM CAmpaign__c WHERE ID=:campID];
            if(camRec.Marketing_Start_Date__c != null && camRec.Marketing_End_Date__c != null){
                mStartDate = camRec.Marketing_Start_Date__c;
                mEndDate = camRec.Marketing_End_Date__c;
                System.debug('MS = '+mStartDate+',MD'+mEndDate+'=>'+camRec);
                
                if (autoFor != 'DOS' && autoFor != 'HOS')
                    queryStr +=' AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) )';
            }
        }
        
        List<String> users = new List<String>();
        for(User U: Database.query(queryStr)){
            users.add(U.Name);
        }
        return users;
    }
    
   
    /**
    *getlstofPCProfielUser(): Get all Property Consultant users who are active and returns a list of PCUsersWrapper objects for the sObjects in the current page set
    **/ 
    
    public List<CampaignManage_Helper.searchResultWrapper> getlstofPCProfielUser() {
        lstofPCProfielUser = new List<CampaignManage_Helper.searchResultWrapper>();
        CampaignManage_Helper.searchResultWrapper searchWrapper;
        for (User userRec : (List<USer>)manageHelper.controller.getRecords()) {
            searchWrapper = new CampaignManage_Helper.searchResultWrapper();
            searchWrapper.assignedPC = new Assigned_PC__c();
            searchWrapper.checked = (Test.isRunningTest() ? true:false);
            searchWrapper.obj = userRec;
            lstofPCProfielUser.add(searchWrapper);
        }
        //if( lstofPCProfielUser.size() == 0 )
        //    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Property Consultants are already added / not available to add users'));
        System.debug('lstofPCProfielUser = '+lstofPCProfielUser);
        return lstofPCProfielUser;
    }
    
    /**
    *searchUsers(): search the Users
    **/
    public PageReference searchUsers(){
        //System.debug('searchUSer1 = '+manageHelper.searchText);
        String conditionString ='', lang = (String.isNotBlank(searchSection.PC_Languages__c) ? '\''+searchSection.PC_Languages__c+'\'':''), nantion = searchSection.PC_Nationality__c, team = searchSection.Team__c,salesOff = searchSection.Sales_Office__c,queryString='';        
        List<String> lstLan = new List<String>{lang};
        Set<ID> teamMemberIDs = new Set<ID>();
        String managerQuery = 'SELECT ID FROM USER WHERE ';
        managerQuery += ((String.isNotBlank(searchSection.DOS__c) && String.isNotBlank(searchSection.HOS__c)) ? '(Name LIKE \'%'+searchSection.DOS__c+'%\' OR Name LIKE \'%'+searchSection.DOS__c+'%\')':(String.isNotBlank(searchSection.DOS__c) ? '(Name LIKE \'%'+searchSection.DOS__c+'%\')': String.isNotBlank(searchSection.HOS__c) ? '(Name LIKE \'%'+searchSection.HOS__c+'%\')':''));
        Set<ID> managerIds = new Set<ID>();
        if(String.isNotBlank(searchSection.DOS__c) || String.isNotBlank(searchSection.HOS__c)){
            for(USer U : Database.query(managerQuery))
                managerIds.add(u.id);
        }  
        System.debug('managerIds = '+managerIds); 
        system.debug(conditionString+'conditionString>>>>>>>>>');
        queryString = 'Select Id, Name,Email,UserName,Languages_Known__c,HOS_Name__c,HOD_Name__c,DOS_Name__c,Profile.Name FROM User WHERE ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) AND Profile.Name =\'Property Consultant\'';
        
        conditionString += (!managerIds.isEmpty() ? ' ; (ManagerId IN: managerIds OR Manager.ManagerId IN: managerIds OR Manager.Manager.ManagerId IN: managerIds OR Manager.Manager.Manager.ManagerId IN: managerIds)' : '');
        conditionString +=((String.isNotBlank(manageHelper.selectedText)) ? ' ; (Name LIKE \'%'+manageHelper.selectedText+'%\' OR UserName LIKE \'%'+manageHelper.selectedText+'%\')':'');
        conditionString +=((String.isNotBlank(lang)) ? ' ; Languages_Known__c includes '+lstLan:''); 
        //conditionString +=((String.isNotBlank(nantion)) ? ' ; TimeZoneSidKey LIKE \'%'+nantion+'%\'':''); // Commented as per Riddhis request on May 22 2017
        conditionString +=((String.isNotBlank(salesOff)) ? ' ; Sales_Office__c LIKE \'%'+salesOff+'%\'':'');
        
        if(String.isNotBlank(searchSection.Team__c)){
            teamMemberIDs = UtilityQueryManager.getUserIdsFromGroups(new Set<Id>{searchSection.Team__c});
            system.debug(teamMemberIDs+'teamMemberIDsteamMemberIDs');
            //if(teamMemberIDs.size() > 0){
            	conditionString += ' ; ID IN:teamMemberIDs';    
            //}        
        }        
        conditionString = conditionString.replace(';','AND');
        queryString += (String.isNotBlank(conditionString) ? conditionString : '');        
        queryString += ' Order By Name ';
        
        
        if(String.isNotBlank(conditionString)) {
            System.debug('Final queryString= '+queryString);
            manageHelper.controller = new ApexPages.StandardSetController(Database.query(queryString));
        } else {
            manageHelper.controller = new ApexPages.StandardSetController(Database.query('Select Id,Title,Name,Email,Languages_Known__c,HOS_Name__c,HOD_Name__c,DOS_Name__c,UserName,Profile.Name FROM User WHERE Profile.Name =\'Property Consultant\' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000'));//[Select Id,Title, Name,Email,UserName,Profile.Name FROM User WHERE Profile.Name ='Property Consultant' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 100]));
        }
        return null;
    }
    
    public void cancel(){
        showPopup = false;    
    }
    
    public void getAllAgencies(){
        lstSelectedAgencies = getSelectedAgency();
        //local variables
        showPopup = true;
    }
    
    /**
    *createCampaignUsers(): Add the Campaign Users with selected users, this method will all so check the existing campaign users.
    **/ 
    public PageReference createCampaignUsersNew() {
        Date startDate;
        Date endDate;
        Date marketStartDate = (campainRecords.Marketing_Start_Date__c != null ? campainRecords.Marketing_Start_Date__c.addDays(((dMStartDate == null) ? 0 : dMStartDate)) : null);
        Date marketEndDate = (campainRecords.Marketing_End_Date__c != null ? campainRecords.Marketing_End_Date__c.addDays(((dMEndDate == null) ? 0 : Integer.valueOf('-'+dMEndDate))) : null);
        List<Assigned_Agent__c> InsertAgents = new List<Assigned_Agent__c>();
        List<Assigned_PC__c> assignedPCs = new List<Assigned_PC__c>();
        Set<String> existingCampagnUsers = new Set<String>(); 
        Set<ID> selectedUserIDs = new Set<ID>();
        Set<ID> addedPCs = new Set<ID>();
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'====>'+mStartDate+'=====>'+mEndDate));
        try{
            
            if(campainRecords != null && (campainRecords.Marketing_Start_Date__c > marketStartDate || 
                                        campainRecords.Marketing_End_Date__c < marketStartDate ||
                                        campainRecords.Marketing_Start_Date__c > marketEndDate || 
                                        campainRecords.Marketing_End_Date__c < marketEndDate) 
                                        ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Start and End dates must be between Marketing Start and Marketing End dates.'));
                return null;
            }
            else{
            
                for(Assigned_Agent__c AA : new List<Assigned_Agent__c>([SELECT User__c FROM Assigned_Agent__c WHERE Campaign__c =:campaignID])){
                    existingCampagnUsers.add(AA.User__c);//Adding the existing unique IDs
                }
                for (CampaignManage_Helper.searchResultWrapper userR : lstofPCProfielUser) {
                    if (userR.checked && !addedPCs.contains(userR.obj.id)){
                        startDate = userR.assignedPC.Start_Date__c;
                        endDate = userR.assignedPC.End_Date__c;
                        System.debug('userR = '+userR);
                        assignedPCs.add(new Assigned_PC__c(Campaign__c = campaignID, 
                                                           User__c = userR.obj.id, 
                                                           Start_Date__c = marketStartDate, 
                                                           End_Date__c = marketEndDate));
                        addedPCs.add(userR.obj.id);
                    }
                }  
                for (CampaignManage_Helper.searchResultWrapper agency : lstSelectedAgencies) {
                    if (agency.checked){
                        selectedUserIDs.add(((Agency_PC__c)agency.obj).Agency__c);
                    }
                }
                if(!selectedUserIDs.isEmpty()){        
                    Map<Id, List<Contact>> accountIdContactMap = new Map<Id, List<Contact>>();//AND Salesforce_User__r.isActive = true
                    for(Contact thisContact : [SELECT Id,AccountID,Name,Salesforce_User__c,Salesforce_User__r.Name 
                                               FROM Contact 
                                               WHERE Salesforce_User__c NOT IN:existingCampagnUsers 
                                               AND  AccountID IN: selectedUserIDs]){
                        if(accountIdContactMap.containsKey(thisContact.AccountID)){
                            accountIdContactMap.get(thisContact.AccountID).add(thisContact);   
                        }else{
                            accountIdContactMap.put(thisContact.AccountID, new List<Contact>{thisContact});    
                        }
                    }
                    for(CampaignManage_Helper.searchResultWrapper agency : lstSelectedAgencies){
                        if(agency.checked){
                            if(accountIdContactMap.containsKey(((Agency_PC__c)agency.obj).Agency__c)){
                                for (Contact con : accountIdContactMap.get(((Agency_PC__c)agency.obj).Agency__c)){
                                        InsertAgents.add(new Assigned_Agent__c(Campaign__c = campaignID, 
                                                                               User__c = con.Salesforce_User__c, 
                                                                               Contact__c =con.id, 
                                                                               Agency__c = con.AccountId,
                                                                               Start_Date__c = marketStartDate,
                                                                               End_Date__c = marketEndDate));
                                }
                            }
                        }
                    }
                }
                System.debug('assignedPCs = '+assignedPCs);
                System.debug('InsertAgents = '+InsertAgents);
                if(!assignedPCs.isEmpty()){
                    
                    insert assignedPCs;
                    if (!InsertAgents.isEmpty()){
                        insert InsertAgents;
                    }
                    manageHelper.isSaved = true;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Campain Users are added sucessfully'));
                    manageHelper.controller = new ApexPages.StandardSetController(Database.query('Select Id,Title, Name,Email,UserName,Profile.Name,Languages_known__c,DOS_Name__c,HOS_Name__c,HOD_Name__c  FROM User WHERE Profile.Name =\'Property Consultant\' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000'));//getQueryLocator([Select Id,Title, Name,Email,UserName,Profile.Name FROM User WHERE Profile.Name ='Property Consultant' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000]));
                    showPopup = false;
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Error at line number : '+ex.getLineNumber()+', is :'+ex.getMessage()));   
        }
        return null;
    }
    //CH01.Start
    /**
    *assignAllPCsToCampaign(): Add all PC users to Campaign.
    **/
    public void assignAllPCsToCampaign(){
    	
    	List<Assigned_PC__c> assignedPCs = new List<Assigned_PC__c>();
    	Date marketStartDate = (campainRecords.Marketing_Start_Date__c != null ? campainRecords.Marketing_Start_Date__c.addDays(((dMStartDate == null) ? 0 : dMStartDate)) : null);
        Date marketEndDate = (campainRecords.Marketing_End_Date__c != null ? campainRecords.Marketing_End_Date__c.addDays(((dMEndDate == null) ? 0 : Integer.valueOf('-'+dMEndDate))) : null);
        try{
	        for (User userRec : [Select Id,Title, Name,Email,UserName,Profile.Name,Languages_known__c,DOS_Name__c,HOS_Name__c,HOD_Name__c  FROM User WHERE Profile.Name ='Property Consultant' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000]){
	        	assignedPCs.add(new Assigned_PC__c(Campaign__c = campaignID, 
	                                                           User__c = userRec.id, 
	                                                           Start_Date__c = marketStartDate, 
	                                                           End_Date__c = marketEndDate));
	        }
	        
	        if(assignedPCs != null && assignedPCs.size() > 0){
	        	insert assignedPCs;
	        	manageHelper.isSaved = true;
	            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Campain Users are added sucessfully'));
	            manageHelper.controller = new ApexPages.StandardSetController(Database.query('Select Id,Title, Name,Email,UserName,Profile.Name,Languages_known__c,DOS_Name__c,HOS_Name__c,HOD_Name__c  FROM User WHERE Profile.Name =\'Property Consultant\' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000'));//getQueryLocator([Select Id,Title, Name,Email,UserName,Profile.Name FROM User WHERE Profile.Name ='Property Consultant' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:mStartDate AND Leave_Start_Date__c <=:mStartDate) OR (Leave_Start_Date__c >=:mEndDate)) ) Order By Name limit 50000]));
	        }
        }Catch(Exception ex){
        	System.debug('Error at '+ex);
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    //CH01.End
    public List<CampaignManage_Helper.searchResultWrapper> getSelectedAgency() {
        List<String> idsArray = new List<String>();
        Set<ID> selAgencyIDs = new Set<Id>();
        System.debug('lstofPCProfielUserg at  = '+lstofPCProfielUser);
        for(CampaignManage_Helper.searchResultWrapper thisRecord : lstofPCProfielUser){
            if(thisRecord.checked){
                idsArray.add(thisRecord.obj.Id);    
            }    
        }
        System.Debug('idsArray = '+idsArray);
        List<CampaignManage_Helper.searchResultWrapper> lstSelAgency = new List<CampaignManage_Helper.searchResultWrapper>();
        CampaignManage_Helper.searchResultWrapper searchUser ;
        for(Agency_PC__c ac: [SELECT ID,Name,Agency__r.Name,Agency__c FROM Agency_PC__c WHERE User__c IN:idsArray]){
            if(!selAgencyIDs.contains(ac.Agency__c)){
                searchUser = new CampaignManage_Helper.searchResultWrapper();
                searchUser.assignedPC = new Assigned_PC__c();
                searchUser.checked = true;
                searchUser.obj = ac;
                lstSelAgency.add(searchUser);
                selAgencyIDs.add(ac.Agency__c);
            }
        }
        System.debug('lstSelectedAgencies= '+lstSelAgency);
        return lstSelAgency;
    }
    
    
    public PageReference doCancel(){
        return manageHelper.controller.cancel();
    }
    
    public class AgentWraper {
        public Account agency {get;set;}
        public Boolean checked {get;set;}
    }
    
    // returns the first page of records
    public void first() {
        manageHelper.controller.first();
    }
    
    // returns the last page of records
    public void last() {
        manageHelper.controller.last();
    }
    
    // returns the previous page of records
    public void previous() {
        manageHelper.controller.previous();
    }
    
    // returns the next page of records
    public void next() {
        manageHelper.controller.next();
    }
    
}