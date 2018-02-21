/**************************************************************************************************
* Name               : DamacInquiryController                                                 
* Description        : An apex page controller for Announcements                                             
* Created Date       : NSI - Diana                                                                        
* Created By         : 17/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          17/Jan/2017                                                               
**************************************************************************************************/
public without sharing class DamacInquiryController {
/**************************************************************************************************
    Variables used in the class
**************************************************************************************************/
	public string customListViewId{set;get;}

	public string CILPrefix{set;get;}

	public List<Inquiry__c> CILLists{set;get;}
	public Id inquiryRecordTypeId {set;get;}
	public String tabName{set;get;}


/**************************************************************************************************
    Method:         DamacInquiryController
    Description:    Constructor executing model of the class 
    				Show the CILs	
**************************************************************************************************/
	public DamacInquiryController() {
		/*customListViewId = DamacUtility.getListViewId('Inquiry__c', LABEL.AgentPortal_Inquiry_CustomView_Name);
		if(customListViewId.length()>15){
			customListViewId = customListViewId.substring(0,15);
		}*/

		/*If the logged in user : OWNER OR AUTHORISED USER then show all the CILs submitted by Agents
								: AGENT then show only the CILs submitted by them
		*/
		CILLists = new List<Inquiry__c>();
		inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.CIL_RT).getRecordTypeId();
        
        if(ApexPages.currentPage().getParameters().containsKey('sfdc.tabName')){
			tabName = ApexPages.currentPage().getParameters().get('sfdc.tabName');
		}

	}

/**************************************************************************************************
    Method:         loadCILData
    Description:    - show the custom view for inquiries
**************************************************************************************************/

	public void loadCILData(){
		Contact loginContact = UtilityQueryManager.getContactInformation();

		system.debug('***loadCILData entered');
		system.debug(loginContact.Authorised_Signatory__c);
		system.debug(loginContact.Owner__c);
	   
		if(null != loginContact && ( loginContact.Authorised_Signatory__c || loginContact.Owner__c || loginContact.Portal_Administrator__c)){
			system.debug('***loadCILData entered - Auth /Owner');
			Set<Id> userIds = UtilityQueryManager.getAllUsers(loginContact.AccountID);
			system.debug('***loadCILData entered - userIds'+userIds);
			string condition = 'AND CreatedById IN :userIds';
			CILLists = UtilityQueryManager.getCILs(condition,inquiryRecordTypeId,userIds);
		}
		else if(null != loginContact){
			string condition = 'AND CreatedById =\''+UserInfo.getUserId()+'\'';
			CILLists = UtilityQueryManager.getCILs(condition,inquiryRecordTypeId,null);
		}

		CILPrefix = DamacUtility.getObjectPrefix('Inquiry__c');

		
		 
	}
}