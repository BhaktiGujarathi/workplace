/**************************************************************************************************
* Name               : SchUpdateMarketingStartEndDatesBatch                                       *
* Description        : Scheduler class for UpdateMarketingStartEndDatesBatch batch class.         *
					   Schedule the class every day @ 11 PM
* Created Date       : 14/05/2017                                                                 *
* Created By         : NSI                                                                        *
* Test class		 : UpdateMarketingStartEndDatesBatch_Test									  *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Siva      14/05/2017      Initial Draft.                                      *
**************************************************************************************************/
/*
SchUpdateMarketingStartEndDatesBatch p = new SchUpdateMarketingStartEndDatesBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('UpdateMarketingStartEndDateOfCampaign', sch, p);
*/
public with sharing class SchUpdateMarketingStartEndDatesBatch implements Schedulable{
    
    public void execute(SchedulableContext SC) {
    	Set<ID> campaignIds = new Set<ID>();
    	for(Campaign__c thisCampaign : [SELECT Id,Is_MED_Changed__c,Marketing_End_Date__c,
    											Marketing_Start_Date__c,MED_Changed_Date__c,
    											(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_Agents__r),
    											(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_PCs__r),
    											(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Campaign_Inventories__r),
    											(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Inventory_Users__r) 
										FROM Campaign__c 
										WHERE Is_MED_Changed__c = true])
    		if(!thisCampaign.Assigned_Agents__r.isEmpty() || !thisCampaign.Assigned_PCs__r.isEmpty() 
    			|| !thisCampaign.Campaign_Inventories__r.isEmpty() || !thisCampaign.Inventory_Users__r.isEmpty() )
    		campaignIds.add(thisCampaign.id);
    	
    	if(!campaignIds.isEmpty()){	
			UpdateMarketingStartEndDatesBatch updateObjects = new UpdateMarketingStartEndDatesBatch(campaignIds);
			Database.executeBatch(updateObjects,1); 
    	}
	}
}