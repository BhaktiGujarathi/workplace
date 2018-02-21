global class HarvestSyncProjectsBatchable implements Database.Batchable<HarvestProject__c>,
	Database.AllowsCallouts, Database.Stateful {
	
	HarvestIntegration integration;
	public static final String TASK_TASKS = 'Harvest!Tasks';
	public static final String TASK_PEOPLE = 'Harvest!People';
	public static final String TASK_PROJECTS = 'Harvest!Projects';
	
	global Iterable<HarvestProject__c> start(Database.BatchableContext context) {
		integration = DependencyManager.getHarvestIntegration(true);
		return new HarvestProjectIterable();
	}
	
	global void execute(Database.BatchableContext context, List<HarvestProject__c> projects) {
		for (HarvestProject__c project : projects) {
			if (project.Name == TASK_PEOPLE) {
				integration.populatePeople();
			}
			else if (project.Name == TASK_TASKS) {
				integration.populateTasks();
			}
			else if (project.Name == TASK_PROJECTS) {
				integration.populateProjectIdMap();
			}
			else {
				integration.syncTimeEntriesForProjectId(project.Id);
			}	
		}
	}
	
	global void finish(Database.BatchableContext context) {

	}
	
	public static void start() {
		HarvestSyncProjectsBatchable b = new HarvestSyncProjectsBatchable();
		Database.executeBatch(b, 1); 
	}
	
}