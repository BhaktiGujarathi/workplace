/**************************************************************************************************
* Name               : DamacSidebarController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 19/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          19/Jan/2017                                                               
**************************************************************************************************/
public without sharing class DamacSidebarController {
    /**************************************************************************************************
            Variables used in the class
    **************************************************************************************************/
    public List<Notification__c> notificationList{set;get;}
    public Integer unreadNotificationCount{set;get;}
    public Integer notificationListSize{set;get;}

    public Announcement__c latestAnnouncement{set;get;}
    public boolean noAnnounements{set;get;}
    public Integer announcementNo{set;get;}

    public Assigned_Agent__c latestCampaign{set;get;}

    public boolean isAuthorisedToUpload{set;get;} // isLoggedin user authorised to upload attahcments in announcements
    public AssignedAgentWrapper assignedAgents{set;get;}
    public String campaignstartDate{set;get;}
    public String campaignStartOrEndString{set;get;}
    /**************************************************************************************************
    Method:         DamacSidebarController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    public DamacSidebarController() {

        //get all notification based on role.
        //if user is admin then show account level notifications as well
        Contact contactInfo = UtilityQueryManager.getContactInformation();
        notificationListSize = 0;
        notificationList = new List<Notification__c>();
        
        if(null != contactInfo && (contactInfo.Portal_Administrator__c ||
        contactInfo.Authorised_Signatory__c || contactInfo.Owner__c)){
            String condition1 = '(Contact__r.id =\''+contactInfo.Id+'\' OR Account__r.id =\''+contactInfo.accountID+
                                '\') AND Active__c  =true '+
                                ' ORDER BY Read__c,CreatedDate DESC';
            system.debug(condition1);
            notificationList = UtilityQueryManager.getNotifications(condition1);
        }
        else if(null != contactInfo){
            String condition = 'Contact__r.id =\''+contactInfo.Id+'\' AND Active__c  =true'+ 
                                ' ORDER BY Read__c,CreatedDate DESC';
            system.debug(condition);
            notificationList = UtilityQueryManager.getNotifications(condition);
        }
        notificationListSize = notificationList.size();
        system.debug('***Notification List'+notificationList);
        unreadNotificationCount = UtilityQueryManager.unreadNotificationCount;
        
        if(null != contactInfo){
            Account account = UtilityQueryManager.getAccountInformation(contactInfo.accountID);
           
            //Announcement to be shown based on the tier, ongoing/future and agency type is corporate
            if(null != account){
                //latestAnnouncement = UtilityQueryManager.getLatestAnnouncement(account);
                //noAnnounements = UtilityQueryManager.noAnnounements;
                List<Announcement__c> announcementList = UtilityQueryManager.getAllAnnouncements(account);
                announcementNo = announcementList.size();
                if(announcementList.size()>0){
                    latestAnnouncement = new Announcement__c();
                    latestAnnouncement = announcementList[0];
                }
            }
        }

        latestCampaign = new Assigned_Agent__c();
        latestCampaign = UtilityQueryManager.getLatestCampaign();
        system.debug('**sidebar latestCampaign'+latestCampaign);

        assignedAgents = new AssignedAgentWrapper(latestCampaign.Campaign_Name__c,latestCampaign.Start_Date__c,latestCampaign.End_Date__c);

        if(null != latestCampaign.Start_Date__c && latestCampaign.Start_Date__c>=System.now().Date()){
            DateTime dt = Datetime.newInstance( latestCampaign.Start_Date__c.year(),  latestCampaign.Start_Date__c.month(), latestCampaign.Start_Date__c.day()); 
            campaignstartDate = dt.format('MM/dd/yyyy kk:mm ');
            campaignStartOrEndString = 'Starts at :';
        }
        else if(null != latestCampaign.End_Date__c){
            DateTime dt = Datetime.newInstance( latestCampaign.End_Date__c.year(),  latestCampaign.End_Date__c.month(), latestCampaign.End_Date__c.day()); 
            campaignstartDate = dt.format('MM/dd/yyyy kk:mm ');
            campaignStartOrEndString = 'Ends at :';
        }

        system.debug('***'+campaignstartDate);
    }

    public class AssignedAgentWrapper{
        public String campaignName{set;get;}
        public Date campaignStartDate{set;get;}
        public Date campaignEndDate{set;get;}

        public AssignedAgentWrapper(String campaignName, Date campaignStartDate, Date campaignEndDate){
            this.campaignName = campaignName;
            this.campaignStartDate = campaignStartDate;
            this.campaignEndDate = campaignEndDate;
        }
    }
}