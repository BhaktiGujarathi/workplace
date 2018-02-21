/* The Handler class to update 'Activity Count' Field on Opportunity Object. The activity count will gets increased 
 * by 1 if any Task or Event is created. The trigger will also decrease the Activity Count by 1 if any Task or Event 
 * is deleted.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Ajay Singh Solanki                       03/04/2013                              Initial Draft
 */ 
 
public with sharing class ActivityCountHandlerForOpportunity {
	
	//Constructor
	public ActivityCountHandlerForOpportunity(){
	}//End ActivityCountHandler Constructor.
	
	
	
	/* The method will give the Updated List of Opportunity Records after Incrementing or Decrementing the 
	 * Activity Count of Opportunity.
	 */
	public List<Opportunity> returnUpdatedListOfOppRecords(Map<Id, Integer> pMapOppIdWithCountToIncrease,
													        Map<Id, Integer> pMapOppIdWithCountToDecrease){
		// List will contain the list of Opportunity Records whose 'Activity Count' field gets Updated. 
		List<Opportunity> lstOpportunityRecordsToUpdate = new List<Opportunity>();
		
		if(pMapOppIdWithCountToIncrease == null)
			pMapOppIdWithCountToIncrease = new Map<Id, Integer> ();
			
		if(pMapOppIdWithCountToDecrease == null)
			pMapOppIdWithCountToDecrease = new Map<Id, Integer> ();
		
		for(Opportunity oppRecordToUpdate : [Select Id, 
											  		Activity_Count__c
									         From Opportunity 
									        Where (Id IN : pMapOppIdWithCountToIncrease.keySet())
									        OR (Id IN : pMapOppIdWithCountToDecrease.keySet())]){
			
			if(pMapOppIdWithCountToIncrease.containsKey(oppRecordToUpdate.Id)){												 	
				//Increasing the Activity Count by the count available for that Opportunity in pMapOppIdWithCountToIncrease.												 	
				oppRecordToUpdate.Activity_Count__c = (oppRecordToUpdate.Activity_Count__c <> null) ? 
													   (oppRecordToUpdate.Activity_Count__c + pMapOppIdWithCountToIncrease.get(oppRecordToUpdate.Id)) : 
													    pMapOppIdWithCountToIncrease.get(oppRecordToUpdate.Id);
				//Adding Opportunity Record into the List that gets Updated.
				lstOpportunityRecordsToUpdate.add(oppRecordToUpdate);      
			}//End if.     
			else if(pMapOppIdWithCountToDecrease.containsKey(oppRecordToUpdate.Id)){
				oppRecordToUpdate.Activity_Count__c = (oppRecordToUpdate.Activity_Count__c <> null) ? 
													   oppRecordToUpdate.Activity_Count__c - pMapOppIdWithCountToDecrease.get(oppRecordToUpdate.Id) : 0;
				lstOpportunityRecordsToUpdate.add(oppRecordToUpdate);       //Adding Opportunity record into the List that gets updated.
			}//End else if.
	    }//End for.
		
		return lstOpportunityRecordsToUpdate;
	}//End returnUpdatedListOfOppRecords method.
	
	
	
	//The method will update Opportunity records.
	public void updateOpportunities(list<Opportunity> pLstOppToUpdate, Map<Id, SObject> pMapOpportunityWithTaskEventRecord){
		try{
			if(!pLstOppToUpdate.isEmpty())
				update(pLstOppToUpdate);
		
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		     	IdforError =  objexception.getDmlId(index);
		        SObject objRecord = pMapOpportunityWithTaskEventRecord.get(IdforError);
		        objRecord.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End updateOpportunities method.
	
	
	
	// The Method will increase the Activity Count associated with Opportunity Record by 1.
	public Map<Id, Integer> returnIncrementedOppCount( Id pOppId, Map<Id,Integer> pMapOppIdWithCountToIncrease){
		if(pMapOppIdWithCountToIncrease.containsKey(pOppId))
			pMapOppIdWithCountToIncrease.put(pOppId, pMapOppIdWithCountToIncrease.get(pOppId) + 1);      //Increasing the count by 1.
		else
			pMapOppIdWithCountToIncrease.put(pOppId, 1);
			
		return pMapOppIdWithCountToIncrease;
	}//End returnIncrementedOppCount method.
	
	
	
	/* The Method will reduce the Activity Count associated with Opportunity Record by 1.
	 */
	public Map<Id, Integer> returnDecrementedOppCount( Id pOppId, Map<Id, Integer> pMapOppIdWithCountToDecrease){
		if(pMapOppIdWithCountToDecrease.containsKey(pOppId))
			pMapOppIdWithCountToDecrease.put(pOppId, pMapOppIdWithCountToDecrease.get(pOppId) + 1);      //Increasing the count by 1.
		else
			pMapOppIdWithCountToDecrease.put(pOppId, 1);
			
		return pMapOppIdWithCountToDecrease;
	}//End returnDecrementedOppCount method.
	
	
	
	//The method will increase the activity count related to an Opportunity by 1 if any Task is created.
	public void onTaskInsertIncreaseActivityCount(List<Task> pListNewTasks){
		Map<Id, Task> opportunityWithTaskRecord = new Map<Id, Task>();
			//List will contain the list of Opportunity Records whose 'Activity Count' field gets Updated. 
			List<Opportunity> lstOppRecordsToUpdate = new List<Opportunity>();
			//Map will contain Opportunity Id and Number of Count that gets added to Activity Count field of that Opportunity.
			Map<Id, Integer> mapOppIdWithCountToIncrease = new Map<Id, Integer>();
			
			for(Task taskRecord : pListNewTasks){
				opportunityWithTaskRecord.put(taskRecord.WhatId, taskRecord );
				mapOppIdWithCountToIncrease = this.returnIncrementedOppCount(taskRecord.WhatId, mapOppIdWithCountToIncrease);
			}//End for.
			
			lstOppRecordsToUpdate = this.returnUpdatedListOfOppRecords(mapOppIdWithCountToIncrease, null);
			//Updating Opportunity records.
			this.updateOpportunities(lstOppRecordsToUpdate, opportunityWithTaskRecord);
			
	}//End onTaskInsertIncreaseActivityCount
	
	
	
	//Method will reduce the Activity Count Field of Opportunity if any Task is deleted.
	public void OnTaskDeleteDecreaseActivityCount(List<Task> pListTask){
		Map<Id, Task> opportunityWithTaskRecord = new Map<Id, Task>();
		//List will contain the list of Opportunity Records whose 'Activity Count' field gets Updated. 
		List<Opportunity> lstOppRecordsToUpdate = new List<Opportunity>();
		//Map will contain Opportunity Id and Number of Count that gets subtrated to Activity Count field of that Opportunity.
		Map<Id, Integer> mapOppIdWithCountToDecrease = new Map<Id, Integer>();		    
		for(Task taskRecord : pListTask){
			opportunityWithTaskRecord.put(taskRecord.WhatId, taskRecord );
			mapOppIdWithCountToDecrease = this.returnDecrementedOppCount(taskRecord.WhatId, mapOppIdWithCountToDecrease);
		}//End for.
		lstOppRecordsToUpdate = this.returnUpdatedListOfOppRecords(null, mapOppIdWithCountToDecrease);
		//Updating Opportunity records.
		this.updateOpportunities(lstOppRecordsToUpdate, opportunityWithTaskRecord);
			
	}//End OnTaskDeleteDecreaseActivityCount method.
	
	
	
	//The method will increase the activity count related to an Opportunity by 1 if any Event is created.
	public void onEventInsertIncreaseActivityCount(List<Event> pListEvent){
		Map<Id, Event> OpportunityWithEventRecord = new Map<Id, Event>();
		//List will contain the list of Opportunity Records whose 'Activity Count' field gets Updated. 
		List<Opportunity> lstOppRecordsToUpdate = new List<Opportunity>();
		//Map will contain Opportunity Id and Number of Count that gets added to Activity Count field of that Opportunity.
		Map<Id, Integer> mapOppIdWithCountToIncrease = new Map<Id, Integer>();
		for(Event eventRecord : pListEvent){
			OpportunityWithEventRecord.put(eventRecord.WhatId, eventRecord );
			mapOppIdWithCountToIncrease = this.returnIncrementedOppCount(eventRecord.WhatId, mapOppIdWithCountToIncrease);
		}//End for.
		
		lstOppRecordsToUpdate = this.returnUpdatedListOfOppRecords(mapOppIdWithCountToIncrease, null);
		//Updating Opportunity records.
		this.updateOpportunities(lstOppRecordsToUpdate, OpportunityWithEventRecord);
	   
	}//End onEventInsertIncreaseCount method.
	
	
	
	//Method will reduce the Activity Count Field of Opportunity if an Event is deleted.
	public void OnEventDeleteDecreaseActivityCount(List<Event> pListEvent){
		Map<Id, Event> OpportunityWithEventRecord = new Map<Id, Event>();
		// List will contain the list of Opportunity Records whose 'Activity Count' field gets Updated. 
		List<Opportunity> lstOppRecordsToUpdate = new List<Opportunity>();
		//Map will contain Opportunity Id and Number of Count that gets subtrated to Activity Count field of that Lead.
		Map<Id, Integer> mapOppIdWithCountToDecrease = new Map<Id, Integer>();		    
		for(Event eventRecord : pListEvent){
			OpportunityWithEventRecord.put(eventRecord.WhatId, eventRecord );
			mapOppIdWithCountToDecrease = this.returnDecrementedOppCount(eventRecord.WhatId, mapOppIdWithCountToDecrease);
		}//End for.
		
		lstOppRecordsToUpdate = this.returnUpdatedListOfOppRecords(null, mapOppIdWithCountToDecrease);
		//Updating Opportunity records.
		this.updateOpportunities(lstOppRecordsToUpdate, OpportunityWithEventRecord);
		
	}//End OnTaskDeleteDecreaseActivityCount method.

	//Method will update Opportunity Stage when application sent via conga
	public void onTaskInsertUpdateOpportunityStage(List<Task> pListNewTasks){
		Set<Id> opportunityIds = new Set<Id>();
		for(Task task : pListNewTasks){
         	if(task.Status == 'Completed' && task.Subject == 'Email: Funding Application' 
         	   && task.Description.Contains('PFA the Funding Application.')){
         		opportunityIds.add(task.WhatId);
         	}
		 }
         list<Opportunity> OpportunityToUpdate = [SELECT Id, StageName FROM Opportunity WHERE Id IN : opportunityIds];
		 for(Opportunity opp : OpportunityToUpdate){
		 	if(opp.StageName!='Application Sent')
			 opp.StageName='Application Sent';
		 }
		 try{
		 	//update Opportunity records
		 	if(!OpportunityToUpdate.isEmpty())
		 		update OpportunityToUpdate;
		 }catch(DMLException e){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
    	}
	}// End of onTaskInsertUpdateOpportunityStage
	
}//ActivityCountHandlerForOpportunity class