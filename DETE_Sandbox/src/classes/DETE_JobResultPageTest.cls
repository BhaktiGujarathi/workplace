@isTest
private class DETE_JobResultPageTest {

    static testMethod void testLoadPage() {

        PageReference pageRef = Page.DETE_JobResultPage;

        Test.startTest();
            User user = DETE_DataFactory.getUSerRecord(true);
        System.runAs(user) {
            Test.setCurrentPage(pageRef);
            //pageRef.getParameters().put(System.Label.DETE_UserNameParameter,user.Username);

            DETE_JobResultController controller = new DETE_JobResultController();
            System.assertEquals(user.Username, controller.strUserName);
        }

        Test.stopTest();


    }

    //Method to test Occupation not avillable in org data
    static testMethod void testNonAutoCompleteOccupation() {

        PageReference pageRef = Page.DETE_JobResultPage;

        List<DETE_OccupationWiseJobResult> resultMain;
        List<DETE_OccupationWiseJobResult> resultRelated;
        List<DETE_OccupationWiseJobResult> resultOther;

        Test.setMock(HttpCalloutMock.class, new DETE_MockResponseClass());

        User user = DETE_DataFactory.getUSerRecord(true);

        Test.startTest();
        System.runAs(user) {
            Test.setCurrentPage(pageRef);
            // pageRef.getParameters().put(System.Label.DETE_UserNameParameter,user.Username);

            DETE_JobResultController controller = new DETE_JobResultController();

            resultMain =
                DETE_JobResultController.getmainOccupationJobResultList(controller.userPosition);

            resultRelated =
                DETE_JobResultController.getrelatedOccupationJobResultList(controller.userPosition);

            resultOther =
                DETE_JobResultController.getOtherOccupationJobResultList(controller.specificTechnologies);
            }

            Test.stopTest();
            System.assert(resultMain.size() > 0);
            System.assert(resultRelated.size() == 0);
            System.assert(resultOther.size() == 0);
    }

    //Method to test Occupation not avillable in org data
    static testMethod void testAutoCompleteOccupation() {

        PageReference pageRef = Page.DETE_JobResultPage;

        List<DETE_OccupationWiseJobResult> resultMain;
        List<DETE_OccupationWiseJobResult> resultRelated;
        List<DETE_OccupationWiseJobResult> resultOther;

        Test.setMock(HttpCalloutMock.class, new DETE_MockResponseClass());

        User user = DETE_DataFactory.getUSerRecord(true);
        List<Occupation__c> occupObjList = DETE_DataFactory.getOccupList(true);
        List<Technology__c> technologyList = DETE_DataFactory.getHotTechnologyRecords(true);
        List<OccupationTechLineItem__c> occupationTechList =
            DETE_DataFactory.getOccupationTechList(true, occupObjList, technologyList);

        DETE_DataFactory.getOnetIntegrationSetting(true);

        Test.startTest();
        System.runAs(user) {
            Test.setCurrentPage(pageRef);
            // pageRef.getParameters().put(System.Label.DETE_UserNameParameter,user.Username);

            DETE_JobResultController controller = new DETE_JobResultController();

            resultMain =
                DETE_JobResultController.getmainOccupationJobResultList(controller.userPosition);

            resultRelated =
                DETE_JobResultController.getrelatedOccupationJobResultList(controller.userPosition);

            resultOther =
                DETE_JobResultController.getOtherOccupationJobResultList(controller.specificTechnologies);
        }
        Test.stopTest();

        System.assert(resultMain.size() > 0);
        System.assert(resultRelated.size() > 0);
        System.assert(resultOther.size() > 0);
    }

    //Method to test Occupation not avillable in org data
    static testMethod void testLocationAndRadiusInput() {
        DETE_JobLinkService.JobDetails jobDetail = new DETE_JobLinkService.JobDetails();
        Test.setMock(HttpCalloutMock.class, new DETE_MockResponseClass());

        Test.startTest();
            List<DETE_JobLinkService.JobDetails> jobDetails
                = DETE_JobLinkService.searchAvillableJobs('Construction', 'Wilmington, DE', 10);

            System.assert(jobDetails.size() > 0);
        Test.stopTest();
    }

}