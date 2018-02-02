@isTest(seeAllData=false)
public class CCPullTripFromConcurAndSFTest
{
    public static String oppID;
    static testMethod void pullTripFromConcurAndSFExecuteTest()
    {

        //Creating Test data.
        Call_in_Code__c callinCodeObj = new Call_in_Code__c(Name = 'testCode', Inactive__c = false);
        insert callinCodeObj;
        
        Opportunity opp = new Opportunity(Name='test1', StageName='Open', CloseDate=system.today().addDays(5), Call_in_Code__c = callinCodeObj.Id);
        insert opp;

        oppID = opp.id;

        Trip__c tempTrip = new Trip__c(Trip_ID__c = 'abc'/*, Opportunity__c = opp.id*/);
        insert tempTrip;

        Concur_Integration__c conIntAuthorization = new Concur_Integration__c(
                                                                             name = 'Authorization',
                                                                             User_Name__c = 'sgdev@statusgonow.com',
                                                                             Password__c = 'Welcome@2',
                                                                             Consumer_Key__c = 'Lp8uH8PwUcmpcQYSjZU4qV',
                                                                             EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx'
                                                                             );
        insert conIntAuthorization;

        Concur_Integration__c conIntConcurTravelTrip = new Concur_Integration__c(
                                                                                 name = 'ConcurTravelTrip',
                                                                                 Booking_Type__c = 'Air',
                                                                                 Userid_Type__c = 'login',
                                                                                 Userid_Value__c = 'ALL',
                                                                                 EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'
                                                                                 );
        insert conIntConcurTravelTrip;

        Test.setMock(HttpCalloutMock.class, new CCMockHttpResponseGenerator());
        Test.startTest();
          CCPullTripFromConcurAndSF.pullTripFromConcurAndSFExecute();
        Test.stopTest();

    }

    static testMethod void cleanNullFrmLstTest()
    {
        List<sObject> nullstrList = new List<sObject>();
        nullstrList.add(null);
        test.startTest();
            CCUtility.cleanNullFrmLst(nullstrList);
        test.stopTest();
    }

    /**
     * Method to test Concur login failure
     */
    static testMethod void testConcurLoginFailure() {
        Concur_Integration__c conIntAuthorization = new Concur_Integration__c(
            Name = 'Authorization',
            User_Name__c = 'sgdev@statusgonow.com',
            Password__c = 'Welcome@2',
            Consumer_Key__c = 'Lp8uH8PwUcmpcQYSjZU4qV',
            EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx'
        );
        insert conIntAuthorization;

        Concur_Integration__c conIntConcurTravelTrip = new Concur_Integration__c(
            Name = 'ConcurTravelTrip',
            Booking_Type__c = 'Air',
            Userid_Type__c = 'login',
            Userid_Value__c = 'ALL',
            EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'
        );
        insert conIntConcurTravelTrip;

        Test.setMock(HttpCalloutMock.class, new CCMockHttpErrorResponseGenerator());
        Test.startTest();
            CCPullTripFromConcurAndSF.pullTripFromConcurAndSFExecute();
        Test.stopTest();

        List<Apex_Debug_log__c> apexDebugLogs =
            [
                SELECT
                    Id,
                    Name,
                    Apex_Class__c,
                    Line__c,
                    Message__c,
                    Method__c,
                    Record_ID__c,
                    Stack_Trace__c,
                    Time_Stamp__c,
                    Type__c
                FROM
                    Apex_Debug_log__c
            ];
        System.assertEquals(1, apexDebugLogs.size());
        System.assertEquals('CCPullTripFromConcurAndSFService', apexDebugLogs[0].Apex_Class__c);
        System.assertEquals('loginToConcurSystem', apexDebugLogs[0].Method__c);
        System.assertEquals(ConcurErrorHandler.CONCUR_ERROR, apexDebugLogs[0].Record_ID__c);
    }

    /**
     * Method to test Concur login failure
     */
    static testMethod void testConcurTravelTripFailure() {
        Concur_Integration__c conIntConcurTravelTrip = new Concur_Integration__c(
            Name = 'ConcurTravelTrip',
            Booking_Type__c = 'Air',
            Userid_Type__c = 'login',
            Userid_Value__c = 'ALL',
            EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'
        );
        insert conIntConcurTravelTrip;

        Test.setMock(HttpCalloutMock.class, new CCMockHttpErrorResponseGenerator());
        Test.startTest();
            CCPullTripFromConcurAndSFService.PullTripResponse pullTripResponseInstance =
                CCPullTripFromConcurAndSFService.fetchTripsAndInsertRecords('fakeAccessToken');
        Test.stopTest();

        System.assert(pullTripResponseInstance != null);
        System.assert(pullTripResponseInstance.isSuccess != null);
        System.assertEquals(false, pullTripResponseInstance.isSuccess);
        System.assert(pullTripResponseInstance.reSchedulePull != null);
        System.assertEquals(true, pullTripResponseInstance.reSchedulePull);
    }

    /**
     * Method to test Concur login failure
     */
    static testMethod void testCCPullReservationConcurBatchFailure() {
        //Creating Test data.
        Call_in_Code__c callinCodeObj = new Call_in_Code__c(Name = 'testCode', Inactive__c = false);
        insert callinCodeObj;
        
        Opportunity opp = new Opportunity(
            Name = 'test1',
            StageName = 'Open',
            CloseDate = system.today().addDays(5),
            Call_in_Code__c = callinCodeObj.Id
        );
        insert opp;
        Trip__c tempTrip = new Trip__c(Trip_ID__c = 'abc');
        insert tempTrip;

        Map<String,Trip__c> mapIdConcurTrip = new Map<String,Trip__c>();
        mapIdConcurTrip.put(tempTrip.Id, tempTrip);
        Test.setMock(HttpCalloutMock.class, new CCMockHttpErrorResponseGenerator());

        Test.startTest();
        Database.executeBatch(
            new CCPullReservationConcurBatch(mapIdConcurTrip, 'fakeAccessToken')
        );
        Test.stopTest();

        List<Apex_Debug_log__c> apexDebugLogs =
            [
                SELECT
                    Id,
                    Name,
                    Apex_Class__c,
                    Line__c,
                    Message__c,
                    Method__c,
                    Record_ID__c,
                    Stack_Trace__c,
                    Time_Stamp__c,
                    Type__c
                FROM
                    Apex_Debug_log__c
            ];
        System.assert(apexDebugLogs.size() != 0);
        for (Apex_Debug_log__c apexDebugLog : apexDebugLogs) {
            if (ConcurErrorHandler.CONCUR_ERROR == apexDebugLog.Record_ID__c) {
                System.assertEquals('CCPullReservationConcurBatchService', apexDebugLog.Apex_Class__c);
                System.assertEquals('getReservationsFromTrip', apexDebugLog.Method__c);
            }
        }
    }
}