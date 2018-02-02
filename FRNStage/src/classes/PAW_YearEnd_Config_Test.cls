@isTest
private class PAW_YearEnd_Config_Test {

	@testSetup static void setupTestData() {
		Year_End_PAW_Settings__c objCustomSetting = new Year_End_PAW_Settings__c();
		objCustomSetting.Year_End_Mode_Enabled__c = true;
		insert objCustomSetting;
    }


	@isTest static void fetch_test_method() {
		Year_End_PAW_Settings__c objCustomSettingTest = [SELECt Id FROM Year_End_PAW_Settings__c];
		Test.startTest();
		PAW_YearEnd_Config.fetch();
		Test.stopTest();

		System.assert(PAW_YearEnd_Config.setting != NULL);

	}


}