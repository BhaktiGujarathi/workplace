public with sharing class ProjectToggleArchivedController {

	ApexPages.StandardController standardController;
	HarvestProject__c project;

	public ProjectToggleArchivedController(ApexPages.StandardController stdCont) {
		standardController = stdCont;
		project = (HarvestProject__c) stdCont.getRecord();
	}
	
	public PageReference toggleArchived() {
		HarvestProjectManager mgr = new HarvestProjectManager();
		mgr.toggleArchived(project.Id);
		PageReference pr = standardController.view();
		return pr;
	}
}