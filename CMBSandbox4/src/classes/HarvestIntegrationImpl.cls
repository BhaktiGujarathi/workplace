public class HarvestIntegrationImpl implements HarvestIntegration {
	
	public static final String SYNC_STATUS_PROJECT_NOT_FOUND = 'Harvest Project Not Found'; 
	private HarvestService service;
	private Settings__c settings;
	private Logger log = DependencyManager.getLogger();
	
	public HarvestIntegrationImpl() {
		settings = [SELECT HarvestURL__c, Username__c, Password__c, 
			LastSync__c FROM Settings__c LIMIT 1];
		service = DependencyManager.getHarvestService(settings.Username__c, settings.Password__c,
		settings.HarvestURL__c);
		service.populateTasks();			
		service.populatePeople();		
		service.populateProjectIdMap();		
	}
	
	public HarvestIntegrationImpl(Boolean deferPrefetch) {
		if (deferPrefetch) {
			settings = [SELECT HarvestURL__c, Username__c, Password__c, 
				LastSync__c FROM Settings__c LIMIT 1];			
			service = DependencyManager.getHarvestService(settings.Username__c, settings.Password__c,
				settings.HarvestURL__c);
		} 
		else {
			this();
		}
	}
	
	public void populateTasks() {
		service.populateTasks();			
	}
	
	public void populatePeople() {
		service.populatePeople();		
	}
	
	public void populateProjectIdMap() {
		service.populateProjectIdMap();		
	}
	
	public void syncTimeEntriesForProjectId(String projectId) {
		DateTime startTime = Datetime.now();
		HarvestProject__c project = [SELECT Id, ProjectCodeExternalId__c 
			FROM HarvestProject__c WHERE Id = :projectId LIMIT 1];
		List<HarvestTimeEntry__c> sfEntries = new List<HarvestTimeEntry__c>();
		List<HarvestEntry> entries = null;
		try {
			entries = service.getEntriesForProject(project.ProjectCodeExternalId__c);
			project.SyncStatus__c = 'Harvest Project Linked';
			project.LastHarvestSync__c = startTime;
			for (HarvestEntry entry : entries) {
				HarvestTimeEntry__c sfEntry = sfEntryFromHarvestEntry(entry);
				sfEntry.HarvestProject__r = new HarvestProject__c(
					ProjectCodeExternalId__c = project.ProjectCodeExternalId__c);
				System.debug(sfEntry);
				sfEntries.add(sfEntry);
			}
		}
		catch (HarvestException e) {
			if (e.getMessage().startsWith(
				HarvestException.EXCEPTION_HARVEST_PROJECT_NOT_FOUND)) {
				project.SyncStatus__c = SYNC_STATUS_PROJECT_NOT_FOUND;					
			}
		}
		if (sfEntries.size() > 0) {
			upsertTimeEntries(sfEntries, true);
		}
		project.LastHarvestSync__c = startTime;
		update project;
	}
	
	public void archiveProject(Id projectId) {
		String harvestId = harvestIdFromSalesforceId(projectId);
		service.deactivateProject(harvestId); 
	}
	
	public void unarchiveProject(Id projectId) {
		String harvestId = harvestIdFromSalesforceId(projectId);
		service.activateProject(harvestId);
	}
	
	private String harvestIdFromSalesforceId(Id projectId) {
		String projectCode = [
			SELECT ProjectCodeExternalId__c FROM HarvestProject__c WHERE Id = :projectId
		].ProjectCodeExternalId__c;
		String harvestId = service.getHarvestProjectId(projectCode);
		return harvestId;		
	}
	
	private void upsertTimeEntries(List<HarvestTimeEntry__c> entries, 
			Boolean deprecateMovedEntries) {
		List<Database.Upsertresult> results = Database.upsert(entries, 
			HarvestTimeEntry__c.fields.HarvestEntryId__c, false);
		List<HarvestTimeEntry__c> entriesToRetry = new List<HarvestTimeEntry__c>();
		List<Decimal> harvestEntryIdsToDeprecate = new List<Decimal>();
		for (Integer i = 0; i < results.size(); i++) {
			Database.Upsertresult result = results[i];
			HarvestTimeEntry__c entry = entries[i];
			if (!result.isSuccess()) { 
				if (result.getErrors()[0].getStatusCode() == 
					StatusCode.INVALID_FIELD_FOR_INSERT_UPDATE && deprecateMovedEntries) {
					entriesToRetry.add(entry);
					harvestEntryIdsToDeprecate.add(entry.HarvestEntryId__c);
				} 
				else {
					log.error('failed to upsert time entry: ' + result.getErrors()[0]);
				}
			} 
		}
		if (entriesToRetry.size() > 0) {
			deprecateTimeEntries(harvestEntryIdsToDeprecate);
			upsertTimeEntries(entriesToRetry, false);
		}
	}
	
	private void deprecateTimeEntries(List<Decimal> harvestEntryIds) {
		List<HarvestTimeEntry__c> entries = [SELECT Id FROM HarvestTimeEntry__c WHERE 
			HarvestEntryId__c IN :harvestEntryIds];
		for (HarvestTimeEntry__c entry : entries) {
			entry.Duration__c = 0;
			entry.Notes__c = 'time moved';
			entry.harvestEntryId__c = null;
		}
		List<Database.Saveresult> results = Database.update(entries, false);
		for (Integer i = 0; i < results.size(); i++) {
			Database.Saveresult result = results[i];
			HarvestTimeEntry__c entry = entries[i];
			if (!result.isSuccess()) {
				log.error('failued to update time entries. ' + result.getErrors()[0]);
			}
		}
	}
	
	private HarvestTimeEntry__c sfEntryFromHarvestEntry(HarvestEntry entry) {
		HarvestTimeEntry__c sfEntry = new HarvestTimeEntry__c();
		sfEntry.HarvestEntryId__c = entry.Id;
		sfEntry.HarvestProject__r = new HarvestProject__c(ProjectCodeExternalId__c = entry.ProjectCode);
		sfEntry.Date__c = entry.SpentAt;
		sfEntry.Duration__c = entry.Hours;
		sfEntry.Person__c = entry.Person;
		sfEntry.Task_Type__c = entry.Task;
		sfEntry.Notes__c = entry.Notes;
		sfEntry.Invoiced__c = entry.IsBilled;
		return sfEntry;
	}
}