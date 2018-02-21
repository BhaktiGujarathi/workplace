/***********************************************************************************
 * Class : ExpertSearchFullProfileController_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in ExpertSearchFullProfileController
                 page and it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    26/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class ExpertSearchFullProfileController_Test {

    /**
     * Test related records are fetched when a contact id is passed
     */
    static testMethod void testRelatedRecordsFetched() {
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> contacts = TestDataFactory.createExperts(1, accountRecord[0]);
        List<Catalog__c> catalogs = CatalogFactory.createLanguageCatalog(1);
        catalogs = CatalogFactory.insertData(catalogs);
        Profile_Record__c profile =
            TestDataFactory.createprofileRecordData(contacts[0], catalogs[0], 'G_Employment');
        insert profile;
        TestDataFactory.createFullProfileCustomSettings();
        Test.startTest();
        PageReference pageRef = Page.ExpertSearchFullProfile;
        pageRef.getParameters().put('id', contacts[0].Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController
            = new ApexPages.StandardController(contacts[0]);
        ExpertSearchFullProfileController pageCtrl
            = new ExpertSearchFullProfileController(stdController);
        Test.stopTest();

        System.assertEquals(1, pageCtrl.profileRecords.size());
        System.assertEquals(0, pageCtrl.deployments.size());
    }
}