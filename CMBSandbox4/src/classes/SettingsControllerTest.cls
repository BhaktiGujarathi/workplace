@isTest
private class SettingsControllerTest {

	@isTest
	private static void editReturnsSettings() {
		SettingsController cont = new SettingsController();
		PageReference expectedPr = Page.Settings;
		PageReference pr = cont.edit();
		System.assertEquals(expectedPr.getUrl(), pr.getUrl());
	} 

	@isTest
	private static void cancelReturnsSettingsDetail() {
		SettingsController cont = new SettingsController();
		PageReference expectedPr = Page.SettingsDetail;
		PageReference pr = cont.cancel();
		System.assertEquals(expectedPr.getUrl(), pr.getUrl());
	} 

	@isTest
	private static void saveReturnsSettingsDetail() {
		SettingsController cont = new SettingsController();
		PageReference expectedPr = Page.SettingsDetail;
		PageReference pr = cont.save();
		System.assertEquals(expectedPr.getUrl(), pr.getUrl());
	} 
}