/**
 * Test Class for DETE_ProfilePageController.
 */
@isTest
private class DETE_ProfilePageControllerTest {

    static testMethod void createProfile() {

        DETE_DataFactory.getAccountRecord(true);
        List<Occupation__c> occupObjList = DETE_DataFactory.getOccupList(true);
        List<Technology__c> technologyList = DETE_DataFactory.getHotTechnologyRecords(true);
        DETE_DataFactory.getGeneralTechnologyRecords(true);
        DETE_DataFactory.getKnowledges(true);

        List<OccupationTechLineItem__c> occupationTechList =
            DETE_DataFactory.getOccupationTechList(true, occupObjList, technologyList);

        DETE_ProfilePageController testProfile = new DETE_ProfilePageController();

        testProfile.stdContact.FirstName = 'Test First Name';
        testProfile.stdContact.LastName = 'Test Last Name';
        testProfile.stdContact.Birthdate = system.today();
        testProfile.stdContact.Position_Title__c = 'Web Developers';
        testProfile.emailStr = 'abc@abc.com';
        testProfile.confirmEmailStr = 'abc@abc.com';
        testProfile.passwordStr = 'espl@1234!';
        testProfile.confirmPswrdStr = 'espl@1234!';
        testProfile.stdContact.Address2__c = 'test address';
        testProfile.stdContact.Education__c = 'High School Education/ High School Equivalency';
        testProfile.hotTechnologies[0].isSelected = true;
        testProfile.generalTechnologies[0].isSelected = true;
        testProfile.knowledgeList[0].isSelected = true;

        Test.startTest();
        PageReference pg = testProfile.submitprofile();
        DETE_ProfilePageController.getOccupations('Construction');
        Test.stopTest();
    }

    static testMethod void updateProfile() {
        User objCommunityUser = DETE_DataFactory.getUSerRecord(true);
        List<Occupation__c> occupObjList = DETE_DataFactory.getOccupList(true);
        List<Technology__c> technologyList = DETE_DataFactory.getHotTechnologyRecords(true);
        DETE_DataFactory.getGeneralTechnologyRecords(true);
        DETE_DataFactory.getKnowledges(true);

        List<OccupationTechLineItem__c> occupationTechList =
            DETE_DataFactory.getOccupationTechList(true, occupObjList, technologyList);

        Test.startTest();

        System.runAs(objCommunityUser) {

            Test.setCurrentPageReference(new PageReference('Page.DETE_ProfilePage'));
            //System.currentPageReference().getParameters().put(Label.DETE_UserNameParameter, objCommunityUser.Username);
            DETE_ProfilePageController testProfile = new DETE_ProfilePageController();

            System.assertEquals(testProfile.strUserName, objCommunityUser.Username);
            System.assertEquals(testProfile.isLoggedIn, true);

            PageReference pg = testProfile.submitprofile();
        }
        Test.stopTest();
    }
}