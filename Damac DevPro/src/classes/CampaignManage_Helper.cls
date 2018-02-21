/**************************************************************************************************
* Name                  : CampaignManage_Helper    
* Description           : This class will have all variables that can be declared only conce and will be used entair transaction.
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 12/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         12/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
public class CampaignManage_Helper {
    
    public String searchText {get;set;}
    public String selectedText {get;set;}
    public Boolean isSaved {get;set;}
    public String queryString {get;set;}
    public List<searchResultWrapper> lstSearchResult {get;set;}
    public Date mStartDate,mEndDate;
    @testVisible private Set<id> existingusers {
        get{
            existingusers = CampaignManageUsersControl.existingusers;
            return existingusers;
        }
        set;
    }
    
    @testVisible private Set<id> existingInventories {
        get{
            existingInventories = CampaignManageInventoriesControl.existingInventories;
            return existingInventories;
        }
        set;
    }
    
    @testVisible private Set<id> existingAgencies {
        get{
            existingAgencies = CampaignManageAgencyControl.existingAgencies;
            return existingAgencies;
        }
        set;
    }
    
   
    public ApexPages.StandardSetController controller {
        get {
            if(controller == null) {
                System.debug('queryString==> '+queryString);
                controller = new ApexPages.StandardSetController(Database.query(queryString));
            }
            // sets the number of records in each page set
            controller.setPageSize(20);
            return controller; 
        }
        set;
    }
    
    public Campaign__c campainRecord {
        get{
            if(campainRecord == null && CampaignManageUsersControl.campaignID != ''){
                System.debug('==> '+CampaignManageUsersControl.campaignID);
                campainRecord = [SELECT ID,Name,Marketing_Start_Date__c,Marketing_End_Date__c FROM CAmpaign__c WHERE ID=:CampaignManageUsersControl.campaignID];
            }     
            return campainRecord;
        }
        set;
    }
    
    public CampaignManage_Helper(String queryStr){
        mStartDate = campainRecord.Marketing_Start_Date__c;
        mEndDate = campainRecord.Marketing_End_Date__c;
        System.debug('==>'+mStartDate+'queryString ='+queryStr);
        queryString = queryStr;
        
        //campaignID = camID;
    }
    
    public static Set<Id> existingRecordIds(String objectAPIName) {
        Set<Id> ids = new Set<ID>();
        String strID = '';
        
        System.debug('campaignID='+CampaignManageUsersControl.campaignID);
        if(objectAPIName == 'Assigned_PC__c')
            for(Assigned_PC__c apc: new List<Assigned_PC__c>([SELECT User__c From Assigned_PC__c WHERE Campaign__c =:CampaignManageUsersControl.campaignID AND User__c != null])){
                strID = apc.User__c;
                strID = ((strID.length() == 18) ? strID.subString(0,15):strID );
                ids.add(strID);
            } 
        if(objectAPIName == 'Assigned_Agent__c')
            for(Assigned_Agent__c apc: new List<Assigned_Agent__c>([SELECT Agency__c,User__c From Assigned_Agent__c WHERE Campaign__c =:CampaignManageUsersControl.campaignID AND Agency__c !=null])){
                strID = apc.Agency__c;
                strID = ((strID.length() == 18) ? strID.subString(0,15):strID );
                
                ids.add(apc.Agency__c);
            }
        if(objectAPIName == 'Campaign_Inventory__c')
            for(Campaign_Inventory__c apc: new List<Campaign_Inventory__c>([SELECT Inventory__c From Campaign_Inventory__c WHERE Campaign__c =:CampaignManageUsersControl.campaignID AND Inventory__c != null])){
                strID = apc.Inventory__c;
                strID = ((strID.length() == 18) ? strID.subString(0,15):strID );
                ids.add(strID);
            }
        
        System.debug('ids = '+ids);
        return ids;
    }
    
    public class searchResultWrapper {
        
        public Boolean checked{ get; set; }
        public SObject obj { get; set;}
        public Assigned_PC__c assignedPC {get;set;}
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