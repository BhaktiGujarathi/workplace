/**************************************************************************************************
* Name                  : CampaignManageInventoriesControl    
* Visualforce Page      : CampaignManageInventories
* Description           : This class will invoke from CampaignManageInventories page, it will display all Inventories available.
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 12/Jan/2017 
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         12/Jan/2017      Initial development
* CH01              2.0			NSI - Vineet			   16/April/2017	Added logic to check the assigned flag on the inventory on allocation.
* CH02              3.0
**************************************************************************************************/
public class CampaignManageInventoriesControl {
    
    //List<InventoryWrapper> lstInventories {get;set;}
    public searchWrapper searchvalues {get;set;}
    public CampaignManage_Helper manageHelper {get;set;}
    List<CampaignManage_Helper.searchResultWrapper> lstInventories {get;set;}
    public static Date mStartDate {get;set;} 
    public static Date mEndDate {get;set;}
    public static Integer dMStartDate {get;set;} 
    public static Integer dMEndDate {get;set;}
    //private Set<String> existingCampaignInventories = new Set<String>();
    public String campaignID {
        get{
            campaignID = ApexPages.currentPage().getParameters().get('id');
            return campaignID;
        }set;
    } 
    
    public static Set<Id> existingInventories{
        get{
            existingInventories = CampaignManage_Helper.existingRecordIds('Campaign_Inventory__c');
            return existingInventories;
        }
        set;
    }
    
    /*public List<SelectOption> lstLocations {
        get{
            lstLocations = new List<SelectOption>();
            if( lstLocations == null ){
                for(Location__c loc : [Select Name FROM Location__c]){
                    lstLocations.add(new SelectOption(loc.Name,loc.Name));
                }
            }
            return lstLocations;
        }
        set;
    }*/
    public List<SelectOption> lstProperties {get;set;}
    
    //public static Campaign__c campainRecords {get;set;}
    
    public Campaign__c campainRecords {
        get{
            if(campainRecords == null && String.isNotBlank(campaignID)){
                campainRecords = [SELECT ID,Name,Marketing_Start_Date__c,Marketing_End_Date__c FROM Campaign__c WHERE ID=:campaignID];
            }
            return campainRecords;
        }
        set;
    }
    
    
    public CampaignManageInventoriesControl(ApexPages.StandardController ctrl) {
        searchvalues = new searchWrapper();
        mStartDate =campainRecords.Marketing_Start_Date__c;
        mEndDate = campainRecords.Marketing_End_Date__c;
        dMStartDate = 0;
        dMEndDate = 0;
        manageHelper = new CampaignManage_Helper('SELECT Marketing_Name__c,Unit__c, IPMS_Bedrooms__c, Property_Name__c, Release_Date__c, Bedroom_Type__c, Area__c,Selling_Price__c,Special_Price_2__c,CurrencyIsoCode,Id,Start_Date__c,Address__r.City__c,Unit_Type__c,Building_Location__r.Master_developer__c,End_Date__c, Name,Building_Location__c,Status__c,Building_Location__r.Building_Name__c FROM Inventory__c WHERE Status__c=\'RELEASED\' AND Id NOT IN:existingInventories Order By Name limit 50000');
        System.debug('mStartDate = '+mStartDate+'mEndDate = '+mEndDate);
        
    }
    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController controller {
        get {
            System.debug('existingInventories = '+existingInventories);
            if(controller == null) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select Marketing_Name__c, Unit__c, IPMS_Bedrooms__c, Property_Name__c, Release_Date__c, Bedroom_Type__c, Area__c,Selling_Price__c,Special_Price_2__c,CurrencyIsoCode,Id,Start_Date__c,Address__r.City__c,Unit_Type__c,Building_Location__r.Master_developer__c,End_Date__c, Name,Building_Location__c,Status__c,Building_Location__r.Building_Name__c FROM Inventory__c WHERE Status__c='RELEASED' AND Id NOT IN:existingInventories Order By Name limit 100]));
            }
            // sets the number of records in each page set
            controller.setPageSize(20);
            return controller;
        }
        set;
    }

    @RemoteAction
    public static List<String> searchInventory(String searchTerm,String campID,String autoFor) {
        System.debug('Search String is: '+searchTerm +'MS = '+mStartDate+',MD'+mEndDate+'=>'+campID);
        String queryStr = 'Select Id, Name from User where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Profile.Name='+((autoFor == 'Property') ? '\'Property Consultant\'':((autoFor == 'HOS') ? '\'Head of Sales\'' : ((autoFor == 'DOS') ? '\'Director of Sales\'':'')))+' AND IsActive = true';
        if(String.isNotBlank(campID)){
            Campaign__c camRec = [SELECT ID,Name,Marketing_Start_Date__c,Marketing_End_Date__c FROM Campaign__c WHERE ID=:campID];
            if(camRec.Marketing_Start_Date__c != null && camRec.Marketing_End_Date__c != null){
                mStartDate = camRec.Marketing_Start_Date__c;
                mEndDate = camRec.Marketing_End_Date__c;
                System.debug('MS = '+mStartDate+',MD'+mEndDate+'=>'+camRec);
                
                if (autoFor != 'DOS' && autoFor != 'HOS')
                    queryStr +=' AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR (Leave_Start_Date__c <:mStartDate AND Leave_End_Date__c <:mStartDate AND Leave_Start_Date__c >:mEndDate AND Leave_End_Date__c >:mEndDate) )';
            }
        }
        
        List<String> users = new List<String>();
            
        for(User U: Database.query(queryStr)){
            users.add(U.Name);
        }
        return users;
    }
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<CampaignManage_Helper.searchResultWrapper> getlstInventories() {
        lstInventories = new List<CampaignManage_Helper.searchResultWrapper>();
        CampaignManage_Helper.searchResultWrapper searchWrapper;
        system.debug(manageHelper.controller.getRecords());
        for (Inventory__c category : (List<Inventory__c>)manageHelper.controller.getRecords()){
            searchWrapper = new CampaignManage_Helper.searchResultWrapper();
            //searchWrapper.assignedPC = new Assigned_PC__c();
            searchWrapper.checked = false;
            searchWrapper.obj = category;
            lstInventories.add(searchWrapper);
        }
        //if(lstInventories.size() == 0 ){
        //    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Inventories are already added / not available to add Inventories'));
        //}
        System.debug('lstInventories.size() '+lstInventories.size());
        return lstInventories;
    }
    
    public PageReference searchInventory(){
        try{
            string queryString = 'Select Marketing_Name__c, Unit__c, IPMS_Bedrooms__c, Property_Name__c, Release_Date__c, Bedroom_Type__c, Area__c,Selling_Price__c,Special_Price_2__c,CurrencyIsoCode,Id,Start_Date__c,Address__r.City__c,Unit_Type__c,Building_Location__r.Master_developer__c,End_Date__c, Name,Building_Location__c,Status__c,Building_Location__r.Building_Name__c FROM Inventory__c WHERE Status__c=\'RELEASED\' AND ID NOT IN:existingInventories';
            System.debug('searchWrapper = '+searchvalues);
            String conditionString = '';
            conditionString += ((String.isNotBlank(searchvalues.searchText)) ? '; Id = \''+searchvalues.searchText+'\'':'');
            conditionString += ((String.isNotBlank(searchvalues.location)) ? ' ; Building_Location__c = \''+searchvalues.location+'\'':'');
            conditionString += ((String.isNotBlank(searchvalues.noOfBedRooms)) ? ' ; IPMS_Bedrooms__c = \''+searchvalues.noOfBedRooms+'\'':'');
            conditionString += ((String.isNotBlank(searchvalues.property)) ?' ; Property__c = \''+searchvalues.property+'\'':'');
            //queryString += ((String.isNotBlank(searchvalues.searchText)) ? ' AND ( Name LIKE \'%'+searchvalues.searchText+'%\' OR Building_Location__r.Building_Name__c LIKE \'%'+searchvalues.searchText+'%\' OR Building_Location__r.Name LIKE \'%'+searchvalues.searchText+'%\')' : '');
            //queryString += ((String.isNotBlank(searchvalues.searchText)) ? ' AND ( Name LIKE \'%'+searchvalues.searchText+'%\' OR Building_Location__r.Building_Name__c LIKE \'%'+searchvalues.searchText+'%\' OR Building_Location__r.Name LIKE \'%'+searchvalues.searchText+'%\')' : '');
            
            conditionString = conditionString.substringAfter(';');
            conditionString = conditionString.replace(';','AND');
            queryString += (String.isNotBlank(conditionString) ? ' AND'+conditionString : '');
            queryString += ' Order By Name limit 50000';
            System.debug('queryString = '+queryString);
            if(String.isNotBlank(conditionString)) {
                manageHelper.controller = new ApexPages.StandardSetController(Database.query(queryString));
            } else if(String.isBlank(searchvalues.searchText)){
                manageHelper.controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select Marketing_Name__c, Unit__c, IPMS_Bedrooms__c, Property_Name__c, Release_Date__c, Bedroom_Type__c, Area__c,Selling_Price__c,Special_Price_2__c,CurrencyIsoCode,Id,Start_Date__c,Address__r.City__c,Unit_Type__c,Building_Location__r.Master_developer__c,End_Date__c, Name,Building_Location__c,Building_Location__r.Name,Balcony_Area__c,Status__c,Building_Location__r.Building_Name__c FROM Inventory__c WHERE Status__c='RELEASED' AND ID NOT IN:existingInventories Order By Name limit 50000]));
            }
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        return null;
    }
    
    // displays the selected items
     public PageReference SaveInventories() {
        Set<ID> selectedRec = new Set<ID>();
        System.debug('campainRecords = '+campainRecords);
        System.debug('campainRecords = '+dMStartDate);
        System.debug('campainRecords = '+dMEndDate);
        System.debug('campainRecords = '+campainRecords.Marketing_Start_Date__c);
        Date marketStartDate = ((campainRecords.Marketing_Start_Date__c != null) ? campainRecords.Marketing_Start_Date__c.addDays(((dMStartDate == null) ? 0 : dMStartDate)) : null);
        Date marketEndDate = ((campainRecords.Marketing_Start_Date__c != null) ? campainRecords.Marketing_End_Date__c.addDays(((dMEndDate == null) ? 0 : Integer.valueOf('-'+dMEndDate))) : null);
        
        if(campainRecords != null && (campainRecords.Marketing_Start_Date__c > marketStartDate || 
                                        campainRecords.Marketing_End_Date__c < marketStartDate ||
                                        campainRecords.Marketing_Start_Date__c > marketEndDate || 
                                        campainRecords.Marketing_End_Date__c < marketEndDate) 
          ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Start and End dates must be between Marketing Start and Marketing End dates.'));
        }else {
        	//CH01
			List<Inventory__c> inventoryList = new List<Inventory__c>();
			List<Campaign_Inventory__c> campaignInventories = new List<Campaign_Inventory__c>();
			for (CampaignManage_Helper.searchResultWrapper inv : lstInventories) {
				if (inv.checked){//&& !existingCampaignInventories.contains(key)
					campaignInventories.add(new Campaign_Inventory__c(Campaign__c = campaignID, 
																	  Inventory__c = inv.obj.id, 
																	  Start_Date__c = marketStartDate, 
																	  End_Date__c = marketEndDate));
						  //inv.assignedPC.Start_Date__c,End_Date__c = inv.assignedPC.End_Date__c));
                 	//CH01
                 	inventoryList.add(new Inventory__c(Id = inv.obj.id, Is_Assigned__c = true));
				}
			}
			try{
             	//CH01
				if(!inventoryList.isEmpty()){
					update inventoryList;	
				}
                 if(!campaignInventories.isEmpty()){
                    insert campaignInventories;
                    manageHelper.isSaved = true;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Inventories are added sucessfully'));
                    manageHelper.controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select Marketing_Name__c, Unit__c, IPMS_Bedrooms__c, Property_Name__c, Release_Date__c, Bedroom_Type__c, Area__c,Selling_Price__c,Special_Price_2__c,CurrencyIsoCode,Id,Start_Date__c,Address__r.City__c,Unit_Type__c,Building_Location__r.Master_developer__c,End_Date__c, Name,Building_Location__c,Status__c,Building_Location__r.Building_Name__c FROM Inventory__c WHERE Status__c='RELEASED' AND ID NOT IN:existingInventories Order By Name limit 50000]));
                    manageHelper.searchText = '';
                 } if(campaignInventories.isEmpty()){
                     ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info, 'Inventories are already added'));
                 }
                 //getlstInventories();
             }Catch(Exception ex){
                 if(ex.getMessage().containsIgnoreCase('Duplicate')){
                     ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info, ex.getMessage()));
                 }
             }
        }
        return null;
     }
    
    public PageReference doCancel(){
        return manageHelper.controller.cancel();
    }
    
    public class searchWrapper{
        public String searchText {get;set;}
        public String noOfBedRooms {get;set;}
        public String location {get;set;}
        public String property {get;set;}
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