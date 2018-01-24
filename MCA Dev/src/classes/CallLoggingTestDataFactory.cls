@isTest
public class CallLoggingTestDataFactory {
	/**
	*Method to get Account Records
	*/
	public static Account getAccountRecord() {
        Account accountObj = new Account();
        accountObj  = MCAOrgTestDataFactory.getOrgAccountRecord(accountObj, 1);
        return accountObj;
    }
    /**
    *Method to get Opportunity Records
    */
    public static List<Opportunity> getOpportunityRecordsList(Integer pCount, Id pParentId, Id pOwnerId) {
        RecordType recordtypeObj = [Select SobjectType, 
                                           Name, 
                                           Id 
                                    From RecordType 
                                    Where SobjectType = 'Opportunity' 
                                    AND Name = 'Default'];
        
        List<Opportunity> opportunityList = new List<Opportunity>();
                
        for(Integer i = 0; i < pCount; i++) {
            Opportunity opportunityObj = new Opportunity();
            opportunityObj = MCAOrgTestDataFactory.getOrgOpportunityRecord(opportunityObj, i);
            opportunityObj.RecordTypeId = recordtypeObj.Id;
            opportunityObj.AccountId = pParentId;
            opportunityObj.OwnerId = pOwnerId;
            opportunityList.add(opportunityObj);
        }
        return opportunityList;
    }

	/**
	*Method to get Not Started and Completed Task
	*/
    public static List<Task> getTaskRecordsNotCompleted(Integer pCount,List<Opportunity> oppList) {
    	List<Task> taskList = new List<Task>();
    	//Not-Completed Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status='Not Started';
    		taskObj.ActivityDate = system.TODAY();
    		taskObj.Activity_Type__c = 'Call';
        	taskObj.Description= 'Test Task'+i;
        	taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	//Completed Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status='Completed';
    		taskObj.ActivityDate =  system.TODAY() -1;
    		taskObj.Activity_Type__c = 'Offer Rework';
    		taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	
    	return taskList;
    }
    
    /**
	*Method to get In-Progress and Completed Task
	*/
    public static List<Task> getTaskRecordsPending(Integer pCount,List<Opportunity> oppList) {
    	List<Task> taskList = new List<Task>();
    	//InProgress Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status='In Progress';
    		taskObj.ActivityDate = system.TODAY();
    		taskObj.Activity_Type__c = 'Call';
        	taskObj.Description= 'Test Task'+i;
        	taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	//Completed Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status='Completed';
    		taskObj.ActivityDate =  system.TODAY() -3;
    		taskObj.Activity_Type__c = 'Offer Rework';
    		taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	
    	return taskList;
    }
    /**
	*Method to get Deferred and In Progress Task
	*/
    public static List<Task> getTaskRecordsDeferred(Integer pCount,List<Opportunity> oppList) {
    	List<Task> taskList = new List<Task>();
    	//InProgress Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status= 'Deferred';
    		taskObj.ActivityDate = system.TODAY();
    		taskObj.Activity_Type__c = 'Call';
        	taskObj.Description= 'Test Task'+i;
        	taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	//Completed Task
    	for(integer i=0; i<pCount; i++) {
    		Task taskObj = new Task();
    		taskObj.Status= 'In Progress';
    		taskObj.ActivityDate =  system.TODAY() -3;
    		taskObj.Activity_Type__c = 'Offer Rework';
    		taskObj.WhatId = oppList[i].Id;
        	taskObj.OwnerId = oppList[i].OwnerId;
    		taskObj = MCAOrgTestDataFactory.getOrgTaskRecord(taskObj,i);
    		taskList.add(taskObj);
    	}
    	
    	return taskList;
    }
}