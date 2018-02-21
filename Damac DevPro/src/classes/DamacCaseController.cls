/**************************************************************************************************
* Name               : DamacHomeController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 07/02/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          07/02/2017                                                               
**************************************************************************************************/
public without sharing class DamacCaseController {
	
	/**************************************************************************************************
            Variables used in the class
	**************************************************************************************************/
	public List<Case__c> caseList{set;get;}
	public string CasePrefix{set;get;}
	public String tabName{set;get;}
	/**************************************************************************************************
	    Method:         DamacCaseController
	    Description:    Constructor executing model of the class 
	**************************************************************************************************/
	public DamacCaseController() {
		caseList = new List<Case__c>();
		 if(ApexPages.currentPage().getParameters().containsKey('sfdc.tabName')){
			tabName = ApexPages.currentPage().getParameters().get('sfdc.tabName');
		}
	}

	public void loadCasesList(){

		Contact loginContact = UtilityQueryManager.getContactInformation();

		if(null != loginContact && (loginContact.Portal_Administrator__c ||
		loginContact.Authorised_Signatory__c || loginContact.Owner__c)){
			Set<Id> userIds = UtilityQueryManager.getAllUsers(loginContact.AccountID);
			string condition = 'CreatedById IN :userIds';
			caseList = UtilityQueryManager.getCases(condition, userIds);
		}
		else{

			string condition = 'CreatedById =\''+UserInfo.getUserId()+'\'';
			caseList = UtilityQueryManager.getCases(condition, null);
		}

		CasePrefix = DamacUtility.getObjectPrefix('Case__c');

	}
}