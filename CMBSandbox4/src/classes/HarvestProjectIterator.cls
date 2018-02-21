global class HarvestProjectIterator implements Iterator<HarvestProject__c> { 

	List<HarvestProject__c> projects { get; set; }
	Integer i { get; set; }
	 
	public HarvestProjectIterator() { 
		Date yesterday = Date.today().addDays(-1);
		projects = new List<HarvestProject__c>();
		projects.add(new HarvestProject__c(Name=HarvestSyncProjectsBatchable.TASK_PEOPLE));
		projects.add(new HarvestProject__c(Name=HarvestSyncProjectsBatchable.TASK_TASKS));
		projects.add(new HarvestProject__c(Name=HarvestSyncProjectsBatchable.TASK_PROJECTS));
		projects.addAll([SELECT Id, Name, ProjectCodeExternalId__c FROM HarvestProject__c
			WHERE DateCompleted__c >= :yesterday OR DateCompleted__c = null]);
		i = 0;
	}
	
	global boolean hasNext() { 
		return (i < projects.size());
	}
	
	global HarvestProject__c next() {
		return projects[i++];
	}
}