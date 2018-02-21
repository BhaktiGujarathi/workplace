/**************************************************************************************************
* Name               : DamacHomeController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 22/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          22/Jan/2017                                                               
**************************************************************************************************/

public with sharing class DamacNotificationController {
/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/
public Notification__c notification{set;get;}
public List<Notification__c> notificationList{set;get;}
public Integer unreadNotificationCount{set;get;}
public boolean showNotificationDetail{set;get;}
/**************************************************************************************************
    Method:         DamacNotificationController
    Description:    Constructor executing model of the class - get all notifications
**************************************************************************************************/
	public DamacNotificationController() {
		
		showNotificationDetail = false;

		Contact contactInfo = UtilityQueryManager.getContactInformation();
		notificationList = new List<Notification__c>();
		if(null != contactInfo && (contactInfo.Portal_Administrator__c ||
		contactInfo.Authorised_Signatory__c)){
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
		
		
		system.debug('***Notification List'+notificationList);
		unreadNotificationCount = UtilityQueryManager.unreadNotificationCount;
	}


/**************************************************************************************************
    Method:			viewNotificationDetail
    Description:    page action to get the notification id from url and get the description 
**************************************************************************************************/
	public void viewNotificationDetail(){
		
		system.debug(ApexPages.currentPage().getParameters().containsKey('nid'));
		if(ApexPages.currentPage().getParameters().containsKey('nid') &&
			null != ApexPages.currentPage().getParameters().get('nid')){
			showNotificationDetail = true;
			readNotification(ApexPages.currentPage().getParameters().get('nid'));
		}
	}

/**************************************************************************************************
    Method:			viewCurrentNotificationDetail
    Description:    page action to get the notification id from url and get the description 
**************************************************************************************************/
	public void viewCurrentNotificationDetail(){
		
		system.debug(ApexPages.currentPage().getParameters().containsKey('notificationId'));
		if(ApexPages.currentPage().getParameters().containsKey('notificationId') &&
			null != ApexPages.currentPage().getParameters().get('notificationId')){
			readNotification(ApexPages.currentPage().getParameters().get('notificationId'));
		}
	}

/**************************************************************************************************
    Method:			readNotification
    Description:    get the notification title and description and mark it as read
**************************************************************************************************/

	private void readNotification(String notificationId){
		notification = new Notification__c();
		if(null != notificationId)
			notification = UtilityQueryManager.getNotificationDescription(notificationId);

		if(null != notification && notification.Read__c == false){
			UtilityQueryManager.markNotificationAsRead(notificationId);
		}
	}
}