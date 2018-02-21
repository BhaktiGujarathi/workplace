@isTest
private class SettingsModelTest {

	@isTest
	private static void AutoSyncFrequencyChangedIsFalseByDefautl() { 
		Settings__c settings = new Settings__c(Name = 'Test1');
		SettingsModel model = new SettingsModel(settings);
		System.assertEquals(false, model.AutoSyncFrequencyChanged);
	}
	
	@isTest
	private static void cronJobExistsReturnsFalse() {
		Settings__c settings = new Settings__c(Name = 'Test1');
		settings.AutoSyncFrequencyInHours__c = 2;
		SettingsModel model = new SettingsModel(settings);
		System.assertEquals(0, model.AutoSyncFrequencyInHours = 0);
	}

}