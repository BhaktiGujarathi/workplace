/***********************************************************************************
 * Class : NominationEvaluationController_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in NominationEvaluation page
                 and it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    20/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class NominationEvaluationController_Test {

    /**
     * Test for checking nomination records are fetched if training id is passed from url
     */
    static testMethod Void testFetchNominationOnLoad() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        Test.stopTest();

        System.assertEquals(nominations.size(), pageCtrl.nominatedExperts.size());
    }

    /**
     * Test for checking nomination records are NOT fetched if training id is not passed in URL
     */
    static testMethod Void testFetchNominationOnLoadNoTrainingId() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        Test.stopTest();

        System.assertNotEquals(nominations.size(), pageCtrl.nominatedExperts.size());
        System.assertNotEquals(null, pageCtrl.nominationForLookup);
    }

    /**
     * Test for selecting nomination record
     */
    static testMethod Void testNominationSelection() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.selectedNominationId = nominations[0].Id;
        pageCtrl.showSelectedNominationData();
        pageCtrl.getIsUserEvaluated();
        Test.stopTest();

        System.assertEquals(nominations.size(), pageCtrl.nominatedExperts.size());
    }

    /**
     * Test add new evaluation function
     */
    static testMethod Void testAddEvaluation() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.selectedNominationId = nominations[0].Id;
        pageCtrl.showSelectedNominationData();
        pageCtrl.addEvaluation();
        Test.stopTest();

        System.assertEquals(nominations.size(), pageCtrl.nominatedExperts.size());
        System.assertEquals(true, pageCtrl.isEditMode);
    }

    /**
     * Test saving a new evaluation when required fields are not entered
     */
    static testMethod Void testSaveEvaluationValidation() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.selectedNominationId = nominations[0].Id;
        pageCtrl.showSelectedNominationData();
        pageCtrl.addEvaluation();
        pageCtrl.saveEvaluation();
        Test.stopTest();

        System.assertEquals(true, pageCtrl.isEditMode);
        System.assertEquals(false, pageCtrl.isSaveSuccess);
    }

    /**
     * Test saving a new evaluation
     */
    static testMethod Void testSaveEvaluation() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.selectedNominationId = nominations[0].Id;
        pageCtrl.showSelectedNominationData();
        pageCtrl.addEvaluation();
        pageCtrl.newEvaluation.Overall_Evaluation__c = '1';
        pageCtrl.newEvaluation.Overall_Comments__c = 'Comment';
        pageCtrl.saveEvaluation();
        Test.stopTest();

        System.assertEquals(false, pageCtrl.isEditMode);
        System.assertEquals(true, pageCtrl.isSaveSuccess);
    }

    /**
     * Test cancel new evaluation creation
     */
    static testMethod Void testCancelEvaluation() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        pageRef.getParameters().put('id', trainings[0].Id);
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.selectedNominationId = nominations[0].Id;
        pageCtrl.showSelectedNominationData();
        pageCtrl.addEvaluation();
        pageCtrl.cancelEvaluation();
        Test.stopTest();

        System.assertEquals(false, pageCtrl.isEditMode);
    }

    /**
     * Test training selection and then adding a new evaluation
     */
    static testMethod Void testTrainingSelection() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.nominationForLookup.Training__c = trainings[0].Id;
        pageCtrl.loadNominations();
        Test.stopTest();

        System.assertEquals(nominations.size(), pageCtrl.nominatedExperts.size());
    }

    /**
     * Test pagination functionality
     */
    static testMethod Void testPaginationFunctions() {

        List<Account> accounts = TestDataFactory.createAccountData(1);
        List<Contact> experts = TestDataFactory.createExperts(1, accounts[0]);
        List<Country__c> countries = TestDataFactory.createCountryData(1);
        List<Training__c> trainings = TestDataFactory.createTrainingData(1, countries[0]);
        List<Campaign> campaigns = TestDataFactory.createCampaignData(1);
        List<Nomination__c> nominations = TestDataFactory.createNominations(1,
                                            campaigns[0],
                                            trainings[0],
                                            experts[0]);

        Test.startTest();
        PageReference pageRef = Page.NominationEvaluation;
        Test.setCurrentPage(pageRef);
        NominationEvaluationController pageCtrl = new NominationEvaluationController();
        pageCtrl.nominationForLookup.Training__c = trainings[0].Id;
        pageCtrl.loadNominations();
        pageCtrl.nextPage();
        pageCtrl.firstPage();
        pageCtrl.lastPage();
        pageCtrl.previousPage();
        Test.stopTest();

        System.assertNotEquals(0, pageCtrl.nominatedExperts.size());
    }
}