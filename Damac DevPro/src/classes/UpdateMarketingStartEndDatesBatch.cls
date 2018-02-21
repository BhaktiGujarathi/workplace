/**************************************************************************************************
* Name               : UpdateMarketingStartEndDatesBatch                                       *
* Description        : This class will update the Marketing Campaign records when Marketing Start *
						and Marketing End date is updated by user.								  *
* Created Date       : 14/05/2017                                                                 *
* Created By         : NSI                                                                        *
* Test class		 : UpdateMarketingStartEndDatesBatch_Test									  *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Siva      14/05/2017      Initial Draft.                                      *
**************************************************************************************************/
global with sharing class UpdateMarketingStartEndDatesBatch implements Database.Batchable <sObject>,Database.Stateful{
	//Define the object defination for creating the SObject
	global final Schema.SObjectType assignedPCsObject = Schema.Assigned_PC__c.getSObjectType();//Schema.getGlobalDescribe().get('Assigned_PC__c');
	global final Schema.SObjectType assignedAgentObject = Schema.Assigned_Agent__c.getSObjectType();//Schema.getGlobalDescribe().get('Assigned_Agent__c');
	global final Schema.SObjectType campInventoryObject = Schema.Campaign_Inventory__c.getSObjectType();//Schema.getGlobalDescribe().get('Campaign_Inventory__c');
	global final Schema.SObjectType inventoryUserObject = Schema.Inventory_User__c.getSObjectType();//Schema.getGlobalDescribe().get('Inventory_User__c');
	
	global Set<ID> medchangdCampaigns;//strore the campaign Id
	global Boolean recursiveFlag;//to specify that batch should call recursive or not
	
	//Constructor
	global UpdateMarketingStartEndDatesBatch(Set<ID> medCampaigns){
		System.debug('Batch is invoked');
		medchangdCampaigns = medCampaigns;
		recursiveFlag = false;
	}
	
	/**
    *    Start Method to return all Campaign records
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Start is invoked');
        return Database.getQueryLocator('SELECT Id,Marketing_Start_Date__c,Marketing_End_Date__c FROM Campaign__c WHERE Is_MED_Changed__c = true AND ID IN: medchangdCampaigns');
    }
    
    /**
    *    Execute Method to process all the Inquiry records
    **/
    global void execute(Database.BatchableContext BC,List <SObject> scope) {
    	System.debug('Execute is invoked');
        try{
        	List<Campaign__c> medCampaigns = (List<sObject>)scope;
        	List<SObject> updatesObjects = new List<sObject>();
        	sObject sObj;
        	
            if(!medCampaigns.isEmpty()){
            	ID thisCampaignID = medCampaigns[0].id;
            	Campaign__c thisCampaign = [SELECT Id,Marketing_Start_Date__c,Marketing_End_Date__c,
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_Agents__r WHERE End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 2000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_PCs__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 1000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Campaign_Inventories__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 2000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Inventory_Users__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 5000) 
        									FROM Campaign__c WHERE ID=: thisCampaignID ];
        		//prepare the Assigned Agent records and assign to sObject list							
        		for(SObject obj : (List<SObject>) thisCampaign.Assigned_Agents__r){
        			sObj = assignedAgentObject.newSObject();
        			sObj.put('End_Date__c',thisCampaign.Marketing_End_Date__c);
        			sObj.put('Id',(ID)obj.get('Id'));
        			updatesObjects.add(sObj);
        		}
        		//prepare the Assigned PCs records and assign to sObject list	
    			for(SObject obj : (List<SObject>) thisCampaign.Assigned_PCs__r){
        			sObj = assignedPCsObject.newSObject();
        			sObj.put('End_Date__c',thisCampaign.Marketing_End_Date__c);
        			sObj.put('Id',(ID)obj.get('Id'));
        			updatesObjects.add(sObj);
        		}
        		//prepare the Campaign Inventory records and assign to sObject list	
    			for(SObject obj : (List<SObject>) thisCampaign.Campaign_Inventories__r){
        			sObj = campInventoryObject.newSObject();
        			sObj.put('End_Date__c',thisCampaign.Marketing_End_Date__c);
        			sObj.put('Id',(ID)obj.get('Id'));
        			updatesObjects.add(sObj);
        		}
        		//prepare the Inventory User records and assign to sObject list	
    			for(SObject obj : (List<SObject>) thisCampaign.Inventory_Users__r){
        			sObj = inventoryUserObject.newSObject();
        			sObj.put('End_Date__c',thisCampaign.Marketing_End_Date__c);
        			sObj.put('Id',(ID)obj.get('Id'));
        			updatesObjects.add(sObj);
        		}
        		System.debug('updatesObjects = '+updatesObjects);
        		if(updatesObjects != null && !updatesObjects.isEmpty()){
        			Database.update(updatesObjects,false);
        		}
        		
        		Campaign__c updatedCampaign = [SELECT Id,Marketing_Start_Date__c,Marketing_End_Date__c,
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_Agents__r WHERE End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 2000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Assigned_PCs__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 1000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Campaign_Inventories__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 2000),
            									(Select Campaign__c,End_Date__c,Id,Start_Date__c FROM Inventory_Users__r WHERE  End_Date__c >: medCampaigns[0].Marketing_End_Date__c LIMIT 5000) 
        									FROM Campaign__c WHERE ID=: thisCampaignID ];
            
            	if(updatedCampaign != null && updatedCampaign.Assigned_Agents__r.isEmpty()
            		&& updatedCampaign.Assigned_PCs__r.isEmpty()
            		&& updatedCampaign.Campaign_Inventories__r.isEmpty()
            		&& updatedCampaign.Inventory_Users__r.isEmpty() ) {
            		
            		//remove the campaign Id if it has all related records are 0.
            		medchangdCampaigns.remove(thisCampaignID);
            		
            	}
            	
            	// recursive is required or not
            	recursiveFlag =( (updatedCampaign != null && (!updatedCampaign.Assigned_Agents__r.isEmpty()
            		|| !updatedCampaign.Assigned_PCs__r.isEmpty()
            		|| !updatedCampaign.Campaign_Inventories__r.isEmpty()
            		|| !updatedCampaign.Inventory_Users__r.isEmpty()) ) ? true : recursiveFlag); 
            		
            }
            System.debug(' executive recursiveFlag = '+recursiveFlag);
        }Catch(Exception ex){
            System.debug('Exception at update update end date batch ' + ex);
        }
    }
    
    /**
    ** Finish Method 
    **/
    global void finish(Database.BatchableContext BC) {
        System.debug('recursiveFlag = '+recursiveFlag);
        System.debug('medchangdCampaigns = '+medchangdCampaigns);
        if(recursiveFlag){
        	Database.executeBatch(new UpdateMarketingStartEndDatesBatch(medchangdCampaigns),1);
        }
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
	      				 FROM AsyncApexJob 
	      				 WHERE Id =: BC.getJobId()];
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   String[] toAddresses = new String[] {'vineet.kumar@nsigulf.com'};
	   mail.setToAddresses(toAddresses);
	   mail.setSubject('Update Marketing Start and End Date batch : ' + a.Status);
	   mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
	   						 ' batches with '+ a.NumberOfErrors + ' failures.');
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}