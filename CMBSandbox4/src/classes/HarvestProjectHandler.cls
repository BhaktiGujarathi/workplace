/*
* Version 		Date             Author         Description
*   1.0 		24/09/2015       Ashwini S      For Roll up on Account from HarvestProject object  
*/
public with sharing class HarvestProjectHandler {

	public HarvestProjectHandler(){}
	
	public void onAfterInsert(){
		new HarvestProjectAccountRollup().accountRollup((map<Id, HarvestProject__c>)trigger.newMap,
															(map<Id, HarvestProject__c>)trigger.oldMap);
	}
	
	public void onAfterUpdate(){
		new HarvestProjectAccountRollup().accountRollup((map<Id, HarvestProject__c>)trigger.newMap,
															(map<Id, HarvestProject__c>)trigger.oldMap);
	}
	
	public void onAfterDelete(){
		new HarvestProjectAccountRollup().accountRollup((map<Id, HarvestProject__c>)trigger.oldMap,
															(map<Id, HarvestProject__c>)trigger.NewMap);
	}
}