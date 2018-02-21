/**************************************************************************************************
* Name               : DamacAnnouncementsController                                               
* Description        : An apex page controller for showing all active announcements                                             
* Created Date       : NSI - Diana                                                                        
* Created By         : 22/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          22/Jan/2017                                                               
**************************************************************************************************/
public without sharing class DamacAnnouncementsController {
	/**************************************************************************************************
            Variables used in the class
	**************************************************************************************************/
	public List<Announcement__c> announcementList{set;get;}
	public Contact contactInfo{set;get;}

	/**************************************************************************************************
    Method:         DamacAnnouncementsController
    Description:    Constructor executing model of the class 
	**************************************************************************************************/
	public DamacAnnouncementsController() {
		
		contactInfo = UtilityQueryManager.getContactInformation();
		announcementList = new List<Announcement__c>();
		 if(null != contactInfo){
            Account account = UtilityQueryManager.getAccountInformation(contactInfo.accountID);
           
            //Announcement to be shown based on the tier, ongoing/future and agency type is corporate
            if(null != account)
		       announcementList = UtilityQueryManager.getAllAnnouncements(account);
		 }
	
	}

}