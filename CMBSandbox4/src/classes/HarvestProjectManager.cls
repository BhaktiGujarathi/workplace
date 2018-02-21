public class HarvestProjectManager {
	
	public void toggleArchived(Id projectId) { 
		HarvestIntegration integration = DependencyManager.getHarvestIntegration(false);
		HarvestProject__c project = [
			SELECT Archived__c FROM HarvestProject__c WHERE Id = :projectId
		];
		if (project.Archived__c) {
			integration.unarchiveProject(projectId); 
		}
		else {
			integration.archiveProject(projectId);
		}
		project.Archived__c = !project.Archived__c;
		update project;
	}
}