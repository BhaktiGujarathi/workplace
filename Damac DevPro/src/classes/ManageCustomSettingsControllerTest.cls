@isTest(seeAllData=true)
public class ManageCustomSettingsControllerTest {

    public static testmethod void ManageCustomSettingsControllerTest_testMethod1() {
        ManageCustomSettingsController mcsc = new ManageCustomSettingsController();
        mcsc.getselectedConfigures();
        mcsc.selectedObject = 'Inquiry_Settings__c';
        mcsc.showCustomSettingValues();
        mcsc.saveCustomSettings();
        
        mcsc.selectConfigureType = 'CustomLabels';
        mcsc.getselectedConfigures();
        mcsc.showCustomSettingValues();
        mcsc.saveCustomSettings();
        
        ManageCustomSettingsController.CustomSettingWarpper obj = new ManageCustomSettingsController.CustomSettingWarpper();
        ManageCustomSettingsController.FieldWrapper obj1 = new ManageCustomSettingsController.FieldWrapper();
        ManageCustomSettingsController.CustomSettingFieldValues obj2 = new ManageCustomSettingsController.CustomSettingFieldValues();
        ManageCustomSettingsController.CustomLabelsWrapper obj3 = new ManageCustomSettingsController.CustomLabelsWrapper();
    }
}