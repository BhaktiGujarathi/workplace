public class Task2Lead {


	public static void lazarusLead(List<Task> inboundTasks){
		
		// set up lists you will need
		Set<String> statuses = new Set<String>{'Closed - Lost', 'Closed - Future Client', 'Closed - Unqualified'};
	    List<Lead> LeadsToUpdate = new List<Lead>();
	    Map<Id, Id> taskMap = new Map<Id, Id>();

	    // go through the list of tasks that were inserted
	    for (Task t : inboundTasks) {
	      // if they are related to a Lead, add the Lead id (whoID) and their values to a map
	        if (t.WhoId  != null && t.Subject.contains('Inbound Call') && String.isNotBlank(t.isdc_inbound_number_dialed__c)) {
	            taskMap.put(t.WhoId, t.Id);
	        }
	    }

	    // if the map isnt empty
	    if (taskMap.size() > 0) {
	        // get all of the Leads related to the tasks
	        List<Id> taskIDs = taskMap.values();
	        LeadsToUpdate = [SELECT Id, Status, Lazarus_ID__c,
	        			 	 (SELECT Id, ActivityDate, isdc_inbound_number_dialed__c, Call_Path_Name__c FROM Tasks WHERE Id IN :taskIDs ORDER BY ActivityDate DESC)
	        			 	 FROM Lead WHERE Id IN :taskMap.keySet() AND Status IN :statuses];
	        // go through the list for each Lead
	        for (Lead l : LeadsToUpdate) { 
	        	if (l.Tasks.size() > 0) { l.Lazarus_ID__c = l.Tasks[0].Call_Path_Name__c; }
	        }

	        // if the list of Leads isnt empty, update them
	        if (LeadsToUpdate.size() > 0){
	            try{ update LeadsToUpdate; } catch(DmlException de) { System.debug('Leads not updated: ' + de.getMessage()); }
	        }
	    }
		
	}


}