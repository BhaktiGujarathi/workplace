@isTest
private class HarvestSyncProjectsBatchableTest {

	@isTest
	static void test() {
		DependencyManager.TestMode = true;
		HarvestProject__c project = new  HarvestProject__c(
			Name = 'test',
			ProjectCodeExternalId__c = 'test'
		);
		insert project;
		Test.startTest();
		Database.executeBatch(new HarvestsyncProjectsBatchable());
		Test.stopTest();
	}
}