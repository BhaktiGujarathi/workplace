/* Test Class to check the Code Coverage of the functionalty implemented in ActivityCountHandlerForOpportunity Class.
 * 
 *
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Ajay Singh Solanki                       03/04/2014                              Initial Draft
 */ 
 
@isTest
private class ActivityCountHandlerForOpportunityTest {

    /* The method will check the Code coverage of functionality implemented in ActivityCountHandler class
	 *  when there are records in ExcludedSubject Custom setting.  
	 */
	 
    static testMethod void testActivityCountHandler(){
    	
    	ActivityCountHandlerForOpportunity controller = new ActivityCountHandlerForOpportunity();
    	//Calling createOpportunityRecords for getting Opportunity records.
    	list<Opportunity> lstOppRecords = ActivityCountHandlerForOpportunityTest.createOpportunityRecords(4);
    	insert lstOppRecords;
    	
    	//Calling createTaskRecords for getting a Task record.
    	list<Task> lstTaskRecords = ActivityCountHandlerForOpportunityTest.createTaskRecords(lstOppRecords, 25);
    	
    	//Calling createEventRecord for getting a Event record.
	    list<Event> eventRecords = ActivityCountHandlerForOpportunityTest.createEventRecords(lstOppRecords, 25);
    	
    	test.startTest();
    		//Inserting Task records.
	    	insert(lstTaskRecords) ;
	    	for(Opportunity oppRecord : [Select Id, StageName, Activity_Count__c From Opportunity Where Id IN : lstOppRecords])
	    		//system.assertEquals(oppRecord.Activity_Count__c, 25);
	    		system.assertEquals(oppRecord.Activity_Count__c, 50);  
	    	
	    	Opportunity oppRec = [Select Id, Activity_Count__c, StageName From Opportunity Where Id =: lstOppRecords[3].id];
	    		system.assertEquals('Application Sent', oppRec.StageName);
	    		
	    	//Inserting Event records.
	    	insert(eventRecords);
	    	
	    	for(Opportunity oppRecord : [Select Id, Activity_Count__c From Opportunity Where Id IN : lstOppRecords])
	    		//system.assertEquals(oppRecord.Activity_Count__c, 50);
	    		system.assertEquals(oppRecord.Activity_Count__c, 75); 
	    	//Deleting Task Record to decrease the activity Count.
	    	delete(lstTaskRecords);
	    	
	    	for(Opportunity oppRecord : [Select Id, Activity_Count__c From Opportunity Where Id IN : lstOppRecords])
	    		//system.assertEquals(oppRecord.Activity_Count__c, 25);
	    		system.assertEquals(oppRecord.Activity_Count__c, 50);
	    	
	       //Deleting Event Record to decrease the activity Count.
	    	delete(eventRecords);
	    	
	    	for(Opportunity oppRecord : [Select Id, Activity_Count__c From Opportunity Where Id IN : lstOppRecords])
	    		//system.assertEquals(oppRecord.Activity_Count__c, 0);
	    		system.assertEquals(oppRecord.Activity_Count__c, 25);
	    		
	    test.stopTest();
    	
    }//End Method.
    
    //The method will return dummy Records of Opportunity.
    public  static list<Opportunity> createOpportunityRecords(Integer pIndex){
    	list<Opportunity> lstTempOppRecords = new list<Opportunity>();
		for(Integer index = 1; index <= pIndex; index ++){
			lstTempOppRecords.add(new Opportunity(Name = 'Rocky' + index,  CloseDate = system.today(), 
												     StageName = 'Underwriting', ForecastCategoryName = 'Pipeline',
												     Amount = 1000 + index)); 
		}  
    		return lstTempOppRecords;
    }//End createOpportunityRecords method.
    
 
    
    //The method will return temporary Record of Task Object.
    private static List<Task> createTaskRecords(list<Opportunity> pLstOpp, Integer pIndex){
    	List<Task> lstTaskRecords = new List<Task>();
    	for(Integer index = 1; index <= pIndex; index ++){
    		lstTaskRecords.add(new Task(Subject = 'Test Task1' + index, Status = 'Completed', OwnerId = UserInfo.getUserId(), 
    		                            Priority = 'Normal', WhatId =  pLstOpp[0].Id));
    	}
    	for(Integer index = 1; index <= pIndex; index ++){
    		lstTaskRecords.add(new Task(Subject = 'Test Task2' + index, Status = 'Not Started', OwnerId = UserInfo.getUserId(), 
    		                            Priority = 'Normal', WhatId =  pLstOpp[1].Id));
    	}
    	for(Integer index = 1; index <= pIndex; index ++){
    		lstTaskRecords.add(new Task(Subject = 'Test Task3' + index, Status = 'In Progress', OwnerId = UserInfo.getUserId(), 
    		                            Priority = 'Normal', WhatId =  pLstOpp[2].Id));
    	}
    	for(Integer index = 1; index <= pIndex; index ++){
    		lstTaskRecords.add(new Task(Subject = 'Email: Funding Application', Status = 'Completed', OwnerId = UserInfo.getUserId(), 
    		                            Priority = 'Normal', WhatId =  pLstOpp[3].Id, Description='PFA the Funding Application.'));
    	}
    	return lstTaskRecords;
    }//End createTaskRecords method.
    
    
    
    //The method will return dummy Records of Event Object.
    private static list<Event> createEventRecords(list<Opportunity> pLstOpp, Integer pIndex){
    	List<Event> lstEventRecords = new List<Event>();
    	for(Integer index = 1; index <= pIndex; index ++){
	    	lstEventRecords.add(new Event(Subject = 'Test Event1' + index, WhatId = pLstOpp[0].Id, 
	    	                              OwnerId = UserInfo.getUserId(), StartDateTime = system.now() - 1 , 
	    	                              EndDateTime = system.now()));
    	}
    	for(Integer index = 1; index <= pIndex; index ++){
	    	lstEventRecords.add(new Event(Subject = 'Test Event2' + index, WhatId = pLstOpp[1].Id, 
	    	                              OwnerId = UserInfo.getUserId(), StartDateTime = system.now() - 1 , 
	    	                              EndDateTime = system.now()));
    	}
    	for(Integer index = 1; index <= pIndex; index ++){
	    	lstEventRecords.add(new Event(Subject = 'Test Event3' + index, WhatId = pLstOpp[2].Id, 
	    	                              OwnerId = UserInfo.getUserId(), StartDateTime = system.now() - 1 , 
	    	                              EndDateTime = system.now()));
    	}
    	
    	for(Integer index = 1; index <= pIndex; index ++){
	    	lstEventRecords.add(new Event(Subject = 'Test Event4' + index, WhatId = pLstOpp[3].Id, 
	    	                              OwnerId = UserInfo.getUserId(), StartDateTime = system.now() - 1 , 
	    	                              EndDateTime = system.now()));
    	}
    	return lstEventRecords;
    }//End createEventRecords method.
    
}//End ActivityCountHandlerForOpportunityTest class.