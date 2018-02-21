public class HarvestSyncProjectEntriesController { 

    private final HarvestProject__c project;
    private final ApexPages.StandardController controller;
    public String ErrorMessage { get; set; }
    
    public HarvestSyncProjectEntriesController(ApexPages.StandardController cont) {
        project = (HarvestProject__c) cont.getRecord();
        controller = cont;
    }
    
    public PageReference sync() {
        PageReference pr = null;
        if (project.ProjectCode__c != null) {
            HarvestIntegration integration = DependencyManager.getHarvestIntegration(false);
            try {
            	integration.syncTimeEntriesForProjectId(project.Id);
            	pr = controller.view();
            }
            catch (Exception e) {
            	ErrorMessage = e.getMessage();
            }
        }
        return pr;
    }
    
    public PageReference toProject() {
    	return controller.view();
    }
    
}