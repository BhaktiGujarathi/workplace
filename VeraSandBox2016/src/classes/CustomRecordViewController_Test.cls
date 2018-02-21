/***********************************************************************************
 * Class : NominationEvaluationController_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in CustomRecordView
                 components and it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    20/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class CustomRecordViewController_Test {

    /**
     * Test setter method of sobjectInstanceId
     */
    static testMethod void testSetSobjectInstanceId() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);

        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setSobjectInstanceId(contacts[0].Id);
        Test.stopTest();

        System.assertEquals(null, controller.sobjectInstance);
    }

    /**
     * Test setter method of page
     */
    static testMethod void testSetPage() {
        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setPage('ExpertSearchFullProfile');
        Test.stopTest();

        System.assertEquals(null, controller.sobjectInstance);
    }

    /**
     * Test setter method of Section
     */
    static testMethod void testSetSection() {
        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setSection('Expert Detail');
        Test.stopTest();

        System.assertEquals(null, controller.sobjectInstance);
    }

    /**
     * Test whether records is fetched correctly when all the setters are called
     */
    static testMethod void testSetAllComponent() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        TestDataFactory.createFullProfileCustomSettings();
        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setSobjectInstanceId(contacts[0].Id);
        controller.setPage('ExpertSearchFullProfile');
        controller.setSection('Expert Detail');
        controller.getSobjectInstanceId();
        controller.getPage();
        controller.getSection();
        controller.sectionColumns = 2;
        Test.stopTest();

        System.assertNotEquals(null, controller.sobjectInstance);
    }

    /**
     * Test whether records NOT fetched when custom setting record is not present
     */
    static testMethod void testSetAllComponentNoConfigData() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setSobjectInstanceId(contacts[0].Id);
        controller.setPage('ExpertSearchFullProfile');
        controller.setSection('Expert Detail');
        controller.getSobjectInstanceId();
        controller.getPage();
        controller.getSection();
        controller.sectionColumns = 2;
        Test.stopTest();

        System.assertEquals(null, controller.sobjectInstance);
    }

    /**
     * Test SOQL query exception by setting wrong field set name
     */
    static testMethod void testExceptionWrongFieldSet() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        TestDataFactory.createFullProfileCustomSettings();
        String pageName = 'ExpertSearchFullProfile';
        String sectionName = 'Expert Detail';
        Full_Profile_Setting__c settingToUpdate = [
                                                    SELECT
                                                        Id,
                                                        Fields__c
                                                    FROM
                                                        Full_Profile_Setting__c
                                                    WHERE
                                                        Page_Name__c = :pageName
                                                        AND Section_Name__c = :sectionName
                                                    ];
        settingToUpdate.Fields__c = 'Foo';
        update settingToUpdate;
        Test.startTest();
        CustomRecordViewController controller = new CustomRecordViewController();
        controller.setSobjectInstanceId(contacts[0].Id);
        controller.setPage(pageName);
        controller.setSection(sectionName);
        controller.getSobjectInstanceId();
        controller.getPage();
        controller.getSection();
        controller.sectionColumns = 2;
        Test.stopTest();

        System.assertEquals(null, controller.sobjectInstance);
    }
}