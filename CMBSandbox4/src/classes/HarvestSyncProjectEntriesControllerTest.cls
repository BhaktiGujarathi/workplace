@isTest
private class HarvestSyncProjectEntriesControllerTest {

    static testMethod void test() {
	    Account account = new Account(Name='bla');
	    insert account;
	    HarvestProject__c project = new HarvestProject__c(Name='bla', Account__c=account.Id);
	    insert project;
        DependencyManager.TestMode = true;
	    project = [SELECT Id, Name, ProjectCode__c from HarvestProject__c WHERE Id = :project.Id];
    	HarvestSyncProjectEntriesController cont = new HarvestSyncProjectEntriesController(new ApexPages.Standardcontroller(project));
    	cont.sync(); 
    	cont.toProject();
    }
}