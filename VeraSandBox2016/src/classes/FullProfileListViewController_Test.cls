/***********************************************************************************
 * Class : FullProfileListViewController_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in FullProfileListView
                 components and it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    26/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class FullProfileListViewController_Test {

    /**
     * Test setter method of sobject list
     */
    static testMethod void testSetSobjectsParameter() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        List<Catalog__c> catalogs = CatalogFactory.createLanguageCatalog(1);
        catalogs = CatalogFactory.insertData(catalogs);
        TestDataFactory.createFullProfileCustomSettings();
        Test.startTest();
        Profile_Record__c profile =
            TestDataFactory.createprofileRecordData(contacts[0], catalogs[0], 'G_Employment');
        insert profile;
        List<Profile_Record__c> profileList = TestDataFactory.fetchProfileRecords(contacts[0].id);
        FullProfileListViewController controller = new FullProfileListViewController();
        controller.setsobjects(profileList);
        Test.stopTest();

        System.assertEquals(0, controller.fieldNames.size());
    }

    /**
     * Test setter method of page
     */
    static testMethod void testSetPageParameter() {
        Test.startTest();
        FullProfileListViewController controller = new FullProfileListViewController();
        controller.setPage('ExpertSearchFullProfile');
        Test.stopTest();

        System.assertEquals(0, controller.fieldNames.size());
    }

    /**
     * Test all the field names are fetched when all attributes are set
     */
    static testMethod void testSetAllParameter() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        List<Catalog__c> catalogs = CatalogFactory.createLanguageCatalog(1);
        catalogs = CatalogFactory.insertData(catalogs);
        TestDataFactory.createFullProfileCustomSettings();
        Test.startTest();
        Profile_Record__c profile =
            TestDataFactory.createprofileRecordData(contacts[0], catalogs[0], 'G_Employment');
        insert profile;
        List<Profile_Record__c> profileList = TestDataFactory.fetchProfileRecords(contacts[0].id);

        FullProfileListViewController controller = new FullProfileListViewController();
        controller.setsobjects(profileList);
        controller.setPage('ExpertSearchFullProfile');
        controller.setSection('Employment');
        controller.getsobjects();
        controller.getPage();
        controller.getSection();
        Test.stopTest();

        System.assertNotEquals(0, controller.fieldNames.size());
    }

    /**
     * Test all the field names are fetched when all attributes are set but no filters are applied
     */
    static testMethod void testSetAllParameterNoFilter() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        List<Catalog__c> catalogs = CatalogFactory.createLanguageCatalog(1);
        catalogs = CatalogFactory.insertData(catalogs);
        TestDataFactory.createFullProfileCustomSettings();
        Test.startTest();
        Profile_Record__c profile =
            TestDataFactory.createprofileRecordData(contacts[0], catalogs[0], 'G_Employment');
        insert profile;
        List<Profile_Record__c> profileList = TestDataFactory.fetchProfileRecords(contacts[0].id);

        FullProfileListViewController controller = new FullProfileListViewController();
        controller.setsobjects(profileList);
        controller.setPage('ExpertSearchFullProfile');
        controller.setSection('Education');
        controller.getsobjects();
        controller.getPage();
        controller.getSection();
        Test.stopTest();

        System.assertNotEquals(0, controller.fieldNames.size());
    }
}