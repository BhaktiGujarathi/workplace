/**************************************************************************************************
* Name                  : CampaignManageAgencyControl
* Test Class			: CampaignManageAgencyControl_Test
* Visualforce Page      : CampaignManageAgency
* Description           : This class will invoke from CampaignManageAgency page, it will display all Property Consultant profile users in the page with search functinality
*                         and pagination. Once admin selects the user and click on add Campaign users button it will search for Agencies where selected users are assigned.
*                         Will create the Campaign Users with all related Contacts which has the Portal users and one more record for selected users with Campaign and related user. And the selected user is not assigned to any Agency then 
*                         it will create the Campaign User record with Campaign and related user.
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 12/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* ----------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         12/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/

public class CampaignManageAgencyControl {
    
    public CampaignManage_Helper manageHelper {get;set;}
    List<CampaignManage_Helper.searchResultWrapper> lstAgencies {get;set;}
    public searchWrapper searchSection {get;set;}
    public Integer mStartDate {get;set;}
    public Integer mEndDate {get;set;}
    public Boolean isSaved {get;set;}
    
    public List<SelectOption> strengthOfAgency {
        get{
            if(strengthOfAgency == null){
                strengthOfAgency = new List<SelectOption>();
                Set<Decimal> decset = new Set<Decimal>();
                strengthOfAgency.add(new SelectOption('','--Select Strength--'));
                for(Account acc : new List<Account>([SELECT Strength_of_Agency__c FROM Account WHERE Strength_of_Agency__c != null])){
                    if(!decset.contains(acc.Strength_of_Agency__c))
                        strengthOfAgency.add(new SelectOption(''+acc.Strength_of_Agency__c,''+acc.Strength_of_Agency__c));
                    decset.add(acc.Strength_of_Agency__c);
                }
            }
            return strengthOfAgency;
        }
        set;
    }
    
    public String campaignID {
        get{
        	campaignID = ApexPages.currentPage().getParameters().get('id');
            return campaignID;
    	}set;
    } 
	
	private Set<String> agencyRecordTypes {
	    get{
	        if(agencyRecordTypes == null){
	            agencyRecordTypes = new Set<String>();
	            for(String recType : DamacUtility.getRecordTypesOfSObject('Account',false)){
	                if(recType.containsIgnoreCase('Agency'))
	                    agencyRecordTypes.add(recType);
	            }
	        }
	        return agencyRecordTypes;
	    }
	    set;
	}
	
    public static Set<Id> existingAgencies{
        get{
            existingAgencies = CampaignManage_Helper.existingRecordIds('Assigned_Agent__c');
            return existingAgencies;
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
    
    public ApexPages.StandardSetController controller {
        get {
            if(controller == null ) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT IsPersonAccount,Id,Strength_of_Agency__c,BillingCity,BillingCountry,RecordType.Name, Name FROM Account 
                                                                                                            WHERE RecordType.Name IN:agencyRecordTypes AND 
                                                                                                            Id NOT IN:existingAgencies Order By Name limit 10000]));//(RecordType.Name=\'Individual Agency\' OR RecordType.Name=\'Corporate Agency\')
            }
            // sets the number of records in each page set
            controller.setPageSize(20);
            return controller; 
        }
        set;
    }
    
    /**
    *CampaignManageUsersControl(ApexPages.StandardController ctrl): Default constructor
    **/
    public CampaignManageAgencyControl(ApexPages.StandardController ctrl) {
        searchSection = new searchWrapper();
        lstAgencies =  new List<CampaignManage_Helper.searchResultWrapper>();
        mStartDate = null;
        mEndDate = null;
    }
    
     
    @RemoteAction
    public static List<String> getAgencies(String searchTerm,String campID,String autoFor) {
        Set<Id> existingAgencyIDs = new Set<ID>();
        Set<String> recTypeNames  = new Set<String>();
        for(Assigned_Agent__c apc: new List<Assigned_Agent__c>([SELECT Agency__c,User__c From Assigned_Agent__c WHERE Campaign__c =:campID AND Agency__c !=null])){
            existingAgencyIDs.add(apc.Agency__c);
        }
        
        for(String recType : DamacUtility.getRecordTypesOfSObject('Account',false)){
            if(recType.containsIgnoreCase('Agency'))
                recTypeNames.add(recType);
        }
        
        String queryStr = 'Select Name,BillingCity,BillingCountry from Account where '+autoFor+' like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND RecordType.Name IN:recTypeNames AND ID NOT IN:existingAgencyIDs';//(RecordType.Name=\'Individual Agency\' OR RecordType.Name=\'Corporate Agency\')
        
        List<String> agencies = new List<String>();
            
        for(Account acc: Database.query(queryStr)){ 
            if(autoFor == 'Name')
                agencies.add(acc.Name);
            if(autoFor == 'BillingCity')
                agencies.add(acc.BillingCity);
            if(autoFor == 'BillingCountry')
                agencies.add(acc.BillingCountry);
        }
        System.debug(agencies);
        return agencies;
    }
    
    /**
    *getlstofPCProfielUser(): Get all Property Consultant users who are active and returns a list of AgencyWrapper objects for the sObjects in the current page set
    **/ 
    
    public List<CampaignManage_Helper.searchResultWrapper> getlstAgencies() {
        System.debug(' lstAgencies.isEmpty() = '+lstAgencies.isEmpty()+' == '+lstAgencies.size());
        if(lstAgencies.isEmpty()){
            CampaignManage_Helper.searchResultWrapper searchWrapper;
            for (Account accRec : (List<Account>)controller.getRecords()){
                searchWrapper = new CampaignManage_Helper.searchResultWrapper();
                searchWrapper.assignedPC = new Assigned_PC__c();
                searchWrapper.checked = false;
                searchWrapper.obj = accRec;
                lstAgencies.add(searchWrapper);
            }
            //System.debug('Agencies = '+lstAgencies);
            System.debug('Agencies = '+lstAgencies.size());
        }
        
        return lstAgencies;
    }
    
    /**
    *searchAgencys(): search the Users
    **/
    public void searchAgency(){
        System.debug('searchSection = '+searchSection);
        String queryStr = '';
        lstAgencies.clear();
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        if(String.isNotBlank(searchSection.agencyName) || String.isNotBlank(searchSection.strength) || String.isNotBlank(searchSection.city) || String.isNotBlank(searchSection.country) || String.isNotBlank(searchSection.typeofAccount) || String.isNotBlank(searchSection.tier)) {
            queryStr = 'Select Id,Strength_of_Agency__c,BillingCity,BillingCountry,RecordType.Name, Name FROM Account WHERE ';
            queryStr += ((String.isBlank(searchSection.typeofAccount)) ? 'RecordType.Name IN:agencyRecordTypes' : ((String.isNOTBlank(searchSection.typeofAccount)) ? 'RecordType.Name LIKE \'%'+searchSection.typeofAccount+'%\'':''));//(RecordType.Name=\'Individual Agency\' OR RecordType.Name=\'Corporate Agency\')
            queryStr += ((String.isNotBlank(searchSection.agencyName)) ? ' ; Name LIKE \'%'+searchSection.agencyName.trim()+'%\'' : '');
            queryStr += ((String.isNotBlank(searchSection.city)) ? ' ; BillingCity LIKE \'%'+searchSection.city.trim()+'%\'' : '');
            queryStr += ((String.isNotBlank(searchSection.country)) ? ' ; BillingCountry LIKE \'%'+searchSection.country.trim()+'%\'' : '');
            queryStr += ((String.isNotBlank(searchSection.strength) && String.isNotBlank(searchSection.strength.trim())) ? ' ; Strength_of_Agency__c ='+Decimal.valueOf(searchSection.strength.trim()): '');
            queryStr += ((String.isNotBlank(searchSection.tier)) ? ' ; Agency_Tier__c LIKE \'%'+searchSection.tier.trim()+'%\'' : '');
            queryStr += ' AND Id NOT IN:existingAgencies';
            
            queryStr = queryStr.replace(';','AND');
            queryStr +=' Order By Name limit 50000';
            System.debug('==Final String = '+queryStr);
            controller = new ApexPages.StandardSetController(Database.query(queryStr));
        } else {
            controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select IsPersonAccount,Id,Strength_of_Agency__c,BillingCity,BillingCountry,RecordType.Name, Name 
                                                                                                    FROM Account 
                                                                                                    WHERE 
                                                                                                        (RecordType.Name IN: agencyRecordTypes) //='Individual Agency' OR RecordType.Name='Corporate Agency'
                                                                                                         AND Id NOT IN:existingAgencies 
                                                                                                         Order By Name limit 50000]));
        }
        //lstAgencies.clear();
        mStartDate = null;
        mEndDate = null;
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        //getlstAgencies();
        //return null;
    }
    
    /**
    *createCampaignUsers(): Add the Campaign Users with selected users, this method will all so check the existing campaign users.
    **/ 
    public PageReference assignAgents() {
        System.debug('selectedAgencyIDs=1');
        Date marketStartDate = ((campainRecords.Marketing_Start_Date__c != null) ? campainRecords.Marketing_Start_Date__c.addDays(((mStartDate == null) ? 0 : mStartDate)) : null);
        Date marketEndDate = ((campainRecords.Marketing_End_Date__c != null) ?campainRecords.Marketing_End_Date__c.addDays(((mEndDate == null) ? 0 : Integer.valueOf('-'+mEndDate) )) : null);
        set<ID> selectedAgencyIDs = new Set<ID>();
        Set<Id> existingAgencyUsers = new Set<Id>();
        System.debug('campainRecords = '+campainRecords );
        System.debug('marketStartDate = '+marketStartDate +',marketEndDate = '+marketEndDate );
        System.debug('1 = '+(marketStartDate < campainRecords.Marketing_Start_Date__c) );
        System.debug('2 = '+(campainRecords.Marketing_End_Date__c <= marketStartDate) );
        System.debug('3 = '+(campainRecords.Marketing_Start_Date__c >= marketEndDate) );
        System.debug('4 = '+(campainRecords.Marketing_End_Date__c < marketEndDate) );
        if(campainRecords != null && (marketStartDate < campainRecords.Marketing_Start_Date__c || 
                                     marketStartDate >= campainRecords.Marketing_End_Date__c ||
                                    marketEndDate < campainRecords.Marketing_Start_Date__c || 
                                    marketEndDate > campainRecords.Marketing_End_Date__c) 
                                    ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Start and End dates must be between Marketing Start and Marketing End dates.'));
            return null;
        }
        
        //local variables
        List<Assigned_Agent__c> insertAgencies = new List<Assigned_Agent__c>();
        
        
        for (CampaignManage_Helper.searchResultWrapper agencyR : lstAgencies) {
            if (agencyR.checked){
                selectedAgencyIDs.add(agencyR.obj.Id);
            }
        }
        System.debug('selectedAgencyIDs='+selectedAgencyIDs);
        //if Users are selected 
        try{
            if(!selectedAgencyIDs.isEmpty()){
                for(Assigned_Agent__c ag: new List<Assigned_Agent__c>([SELECT ID,User__c From Assigned_Agent__c WHERE Campaign__c =:campaignID AND User__c != null])){
                    existingAgencyUsers.add(ag.User__c);
                }
                System.debug('campaignID = '+campaignID + 'existingAgencyUsers = '+existingAgencyUsers);
                //get all contacts where Account is Agency record type and Contact is Customer portal record is Created irrespective of Active
                List<Contact> lstContacts = new List<Contact>([SELECT Id,AccountID,Account.IsPersonAccount,Name,Salesforce_User__c,Salesforce_User__r.Name FROM Contact WHERE Salesforce_User__c != null AND Salesforce_User__c NOT IN:existingAgencyUsers AND AccountID IN:selectedAgencyIDs]);//AND Salesforce_User__r.isActive = true
                for (CampaignManage_Helper.searchResultWrapper agencyR : lstAgencies) {
                    if (agencyR.checked){
                        for (Contact con : lstContacts){
                            if (agencyR.obj.id == con.AccountID)
                                insertAgencies.add(new Assigned_Agent__c(Campaign__c = campaignID,User__c = con.Salesforce_User__c,Contact__c =con.id,Agency__c = con.AccountId,Start_Date__c = marketStartDate,End_Date__c = marketEndDate));
                        }
                    }
                } 
                System.debug('insertAgencies='+insertAgencies);
                //Insert the campaign Members
                if(!insertAgencies.isEmpty()){
                    insert insertAgencies;
                    isSaved = true;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Agents are added sucessfully'));
                    searchSection = new searchWrapper();
                    mStartDate = null;
                    mEndDate = null;
                    controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Strength_of_Agency__c,BillingCity,BillingCountry,RecordType.Name, Name FROM Account WHERE RecordType.Name IN: agencyRecordTypes AND ID NOT IN:existingAgencies Order By Name limit 100]));//='Individual Agency' OR RecordType.Name='Corporate Agency')
                    //lstAgencies.clear();
                    lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
                    //getlstAgencies(); 
                    System.debug('insertAgencies1='+insertAgencies);
                    
                }else {
                    System.debug('insertAgencies2='+insertAgencies);
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'No members in the chosen agency.'));
                }
            }
        }Catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return null;
    }
    
    public class searchWrapper{
        public String agencyName {get;set;}
        public String city {get;set;}
        public String country {get;set;}
        public String typeofAccount {get;set;}
        public String strength {get;set;}
        public String tier {get;set;}
    }
    
    public PageReference doCancel(){
        return controller.cancel();
    }
    
    // returns the first page of records
    public void first() {
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        controller.first();
    }
    
    // returns the last page of records
    public void last() {
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        controller.last();
    }
    
    // returns the previous page of records
    public void previous() {
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        controller.previous();
    }
    
    // returns the next page of records
    public void next() {
        lstAgencies = new List<CampaignManage_Helper.searchResultWrapper>();
        controller.next();
    }
    
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        controller.cancel();
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return controller.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return controller.getHasPrevious();
        }
        set;
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return controller.getPageNumber();
        }
        set;
    }
}