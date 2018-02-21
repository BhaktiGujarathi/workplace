/* 
*  Apex controller for funding Tabs
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0              Yogesh Mahajan        4-Mar 2016        Test Class of Funding_Application_TabController
*/

@isTest
private class Funding_Application_TabController_Test {
    
    //Create test data for custom setting of show related object into tab
    public static MCAExtension1__Show_Related_Object__c createCustomSettingRecord() {
        MCAExtension1__Show_Related_Object__c objCustomSetting = new MCAExtension1__Show_Related_Object__c();
        objCustomSetting.Name = 'Tab Permission';
        objCustomSetting.MCAExtension1__Bank_Statements__c = true;
        objCustomSetting.MCAExtension1__Loan_Balances__c = true;
        return objCustomSetting ;
    }
    //Valid testing to display tab into funding application
    public static testMethod void tabControllerValidTest() {
        MCAExtension1__Show_Related_Object__c objCustomSetting = createCustomSettingRecord();
        insert objCustomSetting;
        system.assertEquals(true,objCustomSetting.Id!=null);
       
        Test.startTest();
            ApexPages.currentPage().getParameters().put('newApplication', 'false');
            Funding_Application_TabController tabControllerInstance = new Funding_Application_TabController();
        Test.stopTest();
        System.assertEquals(true, tabControllerInstance.isLonVisible);
    }// End tabControllerValidTest()
    
    //Invalid testing to display tab into funding application
     public static testMethod void tabControllerInValidTest() {
        MCAExtension1__Show_Related_Object__c objCustomSetting = createCustomSettingRecord();
        objCustomSetting.MCAExtension1__Loan_Balances__c = false;
        insert objCustomSetting;
        system.assertEquals(true,objCustomSetting.Id!=null);
       
        Test.startTest();
            ApexPages.currentPage().getParameters().put('newApplication', 'true');
            Funding_Application_TabController tabControllerInstance = new Funding_Application_TabController();
        Test.stopTest();
        System.assertEquals(false, tabControllerInstance.isLonVisible);
    }// End tabControllerInValidTest()
}// End Class