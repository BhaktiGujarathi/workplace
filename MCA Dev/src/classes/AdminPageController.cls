/* 
 *  Description - Controller for Admin Page
 *	 
 *  Date - 27-02-2014
 *  
 *  Created by - Sneha P.
 */
public with sharing class AdminPageController {
	
	public list<String> lstReportNames {get; set;}
	public list<String> lstPipelineNames {get; set;}
	public list<String> lstAccountingNames {get; set;}
	public list<String> lstSetupNames {get; set;}
	
	public map<String,AdminReportSetting__c> mapReportSetting {get;set;}
	public map<String,AdminPipelineSetting__c> mapPipelineSetting {get;set;}
	public map<String,AdminAccountingSetting__c> mapAccountingSetting {get;set;}
	public map<String,AdminSetupSetting__c> mapSetupSetting {get;set;}
	
	//Constructor
	public AdminPageController(){
		mapReportSetting = new map<String,AdminReportSetting__c>();
		mapPipelineSetting = new map<String,AdminPipelineSetting__c>();
		mapAccountingSetting = new map<String,AdminAccountingSetting__c>();
		mapSetupSetting = new map<String,AdminSetupSetting__c>();
		
		//Get the data from the Custom Setting
		mapReportSetting = AdminReportSetting__c.getAll();
		mapPipelineSetting = AdminPipelineSetting__c.getAll();
		mapAccountingSetting = AdminAccountingSetting__c.getAll();
		mapSetupSetting = AdminSetupSetting__c.getAll();
		
		//lstString = new list<String>();
		lstReportNames = new list<String>();
	    lstPipelineNames = new list<String>();
	    lstAccountingNames = new list<String>();
	    lstSetupNames = new list<String>();
		
		//Sort all the list by Name and display it on Page
		lstReportNames.addAll(mapReportSetting.keySet());
		lstReportNames.sort();
		
		lstPipelineNames.addAll(mapPipelineSetting.keySet());
		lstPipelineNames.sort();
		
		lstAccountingNames.addAll(mapAccountingSetting.keySet());
		lstAccountingNames.sort();
		
		lstSetupNames.addAll(mapSetupSetting.keySet());
		lstSetupNames.sort();
	}
}