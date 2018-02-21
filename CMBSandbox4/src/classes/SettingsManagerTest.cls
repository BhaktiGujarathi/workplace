@isTest
private class SettingsManagerTest {

	@isTest
	static void test() {
		SettingsManager manager = new SettingsManager();
		SettingsModel model = manager.getModel();
		System.assert(model != null); 
	}
	
	@isTest
	static void save() {
		SettingsManager manager = new SettingsManager();
		SettingsModel model = manager.getModel();
		model.AutoSyncFrequencyInHours = 2;
		manager.save();
		model.AutoSyncFrequencyInHours = 0;
		manager.save();
	}	
}