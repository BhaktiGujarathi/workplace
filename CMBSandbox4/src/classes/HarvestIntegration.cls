public interface HarvestIntegration {
	
	void populateTasks();
	
	void populatePeople();
	
	void populateProjectIdMap();
	
	void syncTimeEntriesForProjectId(String projectId);
	
	void archiveProject(Id projectId);
	
	void unarchiveProject(Id projectId);
}