/***********************************************************************************
 * Class : NominationFullProfileController_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in NominationFullProfileController
                 page and it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    26/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class NominationFullProfileController_Test {

    /**
     * Test related records are fetched when a contact id is passed
     */
    static testMethod void testRelatedRecordsFetched() {
        TestDataFactory.createFullProfileCustomSettings();
        List<Account> accountRecord = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accountRecord[0]);
        List<Catalog__c> catalogs = CatalogFactory.createLanguageCatalog(1);
        catalogs = CatalogFactory.insertData(catalogs);
        Profile_Record__c profile =
            TestDataFactory.createprofileRecordData(experts[0], catalogs[0], 'G_Employment');
        insert profile;
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationFullProfile;
        pageRef.getParameters().put('id', nominations[0].Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController
            = new ApexPages.StandardController(nominations[0]);
        NominationFullProfileController pageCtrl
            = new NominationFullProfileController(stdController);
        Test.stopTest();

        System.assertEquals(0, pageCtrl.profileRecords.size());
    }
}