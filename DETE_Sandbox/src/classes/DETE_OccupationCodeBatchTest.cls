@isTest
private class DETE_OccupationCodeBatchTest {

    private static final BOOLEAN BOOLEANFALSE = false;
    private static final BOOLEAN BOOLEANTRUE  = true;
    public static final String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testMethod void unitTestOne() {

        Set<Id> idSet = new Set<Id>();
        Set<String> titleSet = new Set<String>();

        List<Occupation__c> occupationList = DETE_DataFactory.getOccupList(BOOLEANTRUE);


        System.assertEquals(4, occupationList.size());
        for(Occupation__c occupationObj : occupationList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertNotEquals(null, occupationObj.Name);
            System.assertNotEquals(null, occupationObj.Title__c);
            idSet.add(occupationObj.Id);
            titleSet.add(occupationObj.Title__c);
        }

        DETE_ONET_Integration_Details__c integrationDetailsObj = DETE_DataFactory.getOnetIntegrationSetting(BOOLEANTRUE);

        System.assertNotEquals(null, integrationDetailsObj.Id);


        // Call the mock response generator class
        Test.setMock(HttpCalloutMock.class, new DETE_MockResponseClass());

        // Start the test
        Test.startTest();
            Database.executeBatch(new DETE_OccupationCode(), 200);
        Test.stopTest();
        // Stop the test

        List<Occupation__c> occupationQueryList = [
                                                      SELECT Id,
                                                             Name,
                                                             Title__c
                                                        FROM Occupation__c
                                                  ];

        System.assertEquals(4, occupationQueryList.size());
        for(Occupation__c occupationObj : occupationQueryList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertnotEquals(null, occupationObj.Name);
            System.assertnotEquals(null, occupationObj.Title__c);
            System.assertEquals(BOOLEANTRUE, idSet.contains(occupationObj.Id));
            System.assertEquals(BOOLEANTRUE, titleSet.contains(occupationObj.Title__c));
        }
    }

    static testMethod void unitTestTwo() {

        Set<Id> idSet = new Set<Id>();
        Set<String> titleSet = new Set<String>();

        List<Occupation__c> occupationList = DETE_DataFactory.getOccupList(BOOLEANTRUE);


        System.assertEquals(4, occupationList.size());
        for(Occupation__c occupationObj : occupationList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertNotEquals(null, occupationObj.Name);
            System.assertNotEquals(null, occupationObj.Title__c);
            idSet.add(occupationObj.Id);
            titleSet.add(occupationObj.Title__c);
        }

        DETE_ONET_Integration_Details__c integrationDetailsObj = DETE_DataFactory.getOnetIntegrationSetting(BOOLEANTRUE);

        System.assertNotEquals(null, integrationDetailsObj.Id);


        // Call the mock response generator class
        Test.setMock(HttpCalloutMock.class, new DETE_MockResponseBadResponseClass());

        // Start the test
        Test.startTest();
            Database.executeBatch(new DETE_OccupationCode(), 200);
        Test.stopTest();
        // Stop the test

        List<Occupation__c> occupationQueryList = [
                                                      SELECT Id,
                                                             Name,
                                                             Title__c
                                                        FROM Occupation__c
                                                  ];

        System.assertEquals(4, occupationQueryList.size());
        for(Occupation__c occupationObj : occupationQueryList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertnotEquals(null, occupationObj.Name);
            System.assertnotEquals(null, occupationObj.Title__c);
            System.assertEquals(BOOLEANTRUE, idSet.contains(occupationObj.Id));
            System.assertEquals(BOOLEANTRUE, titleSet.contains(occupationObj.Title__c));
        }
    }

    static testmethod void unitTestThree() {


        Set<Id> idSet = new Set<Id>();
        Set<String> titleSet = new Set<String>();

        List<Occupation__c> occupationList = DETE_DataFactory.getOccupList(BOOLEANTRUE);


        System.assertEquals(4, occupationList.size());
        for(Occupation__c occupationObj : occupationList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertNotEquals(null, occupationObj.Name);
            System.assertNotEquals(null, occupationObj.Title__c);
            idSet.add(occupationObj.Id);
            titleSet.add(occupationObj.Title__c);
        }

        DETE_ONET_Integration_Details__c integrationDetailsObj = DETE_DataFactory.getOnetIntegrationSetting(BOOLEANTRUE);

        System.assertNotEquals(null, integrationDetailsObj.Id);

      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new DETE_OccupationCodeSchedular());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP,
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00',
         String.valueOf(ct.NextFireTime));

      // Call the mock response generator class
      Test.setMock(HttpCalloutMock.class, new DETE_MockResponseBadResponseClass());

      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new merchandise that got added.
      List<Occupation__c> occupationQueryList = [
                                                      SELECT Id,
                                                             Name,
                                                             Title__c
                                                        FROM Occupation__c
                                                  ];

        System.assertEquals(4, occupationQueryList.size());
        for(Occupation__c occupationObj : occupationQueryList) {
            System.assertNotEquals(null, occupationObj.Id);
            System.assertnotEquals(null, occupationObj.Name);
            System.assertnotEquals(null, occupationObj.Title__c);
        }

   }
}