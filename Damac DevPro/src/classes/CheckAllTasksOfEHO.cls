public with sharing class CheckAllTasksOfEHO {
	
	@InvocableMethod (label='' description='')
	public static void updateTask (List<Id> listTaskId) {
		list<task> lstTasks = new list<Task>();
		set<Id> setCaseId = new set<id>();
		map<Id, set<String>> mapCaseIdTasks = new map<Id, set<String>>();
		for (Task objtask : [Select Id, WhatId, Subject, Status From Task where Id IN: listTaskId]) {			
			lstTasks.add(objtask);
			setCaseId.add(objtask.WhatId);
		}
		
		for (Task objtask : [Select Id, WhatId, Subject, Status From Task where WhatId IN: setCaseId and Status = 'Completed']){
			if (mapCaseIdTasks.containsKey(objtask.WhatId)){
				set<String> lstTask = mapCaseIdTasks.get(objtask.WhatId);
				lstTask.add(objtask.Subject);
				mapCaseIdTasks.put(objtask.WhatId, lstTask);
			} else {
				mapCaseIdTasks.put(objtask.WhatId, new set<String> {objtask.Subject});
			}
		}
		list<Task> lstTask = new list<Task>();
		for (Task objTask : lstTasks) {
			set<String> lstRelatedTasks = mapCaseIdTasks.get(objTask.WhatId);
			if (lstRelatedTasks.contains('Update Payment Terms') && 
			lstRelatedTasks.contains('Auto reverse call and raise new invoices for lease period') &&
			lstRelatedTasks.contains('Create Partial PCC') &&
			lstRelatedTasks.contains('Create PCC') &&
			lstRelatedTasks.contains('Verify Documents')) {
				Task objTask1 = new Task();
				objTask1.Subject = 'Generate PCC documents and Release it to customer';
				objTask1.Status = 'Not Started';
				objTask1.Priority = 'Medium';
				objTask1.ownerId = '0050Y000001SC4L';
				objTask1.WhatId = objTask.WhatId;
				objTask1.Process_Name__c = 'Early Handover';
				objTask1.Assigned_User__c = 'CRE';
				//objTask1.ActivityDate = System.Now();
				lstTask.add(objTask1);
				
				Task objTask2 = new Task();
				objTask2.Subject = 'Execute agreement and dispatch to Customer';
				objTask2.Status = 'Not Started';
				objTask2.Priority = 'Medium';
				objTask2.ownerId = '0050Y000001SC4L';
				objTask2.WhatId = objTask.WhatId;
				objTask2.Process_Name__c = 'Early Handover';
				objTask2.Assigned_User__c = 'CDC';
				lstTask.add(objTask2);					
			}
		}
		
		if (lstTask.size() > 0) {
			insert lstTask;
		}
		
		
	}
    
}