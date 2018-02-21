@isTest
private class ContactCalloutExperianTest {

    @testSetup
    static void testData() {
        ExperianContactTestSetup.dmlData();
    }


    @isTest
    static void test_pos_invocable() {

        Integer code = 200;
        String status = 'OK';
        String body = '{"successful" : "true"}';

        Map<Id, Contact> oldMap = ExperianContactTestSetup.mapSetup(false);
        Map<Id, Contact> newMap = ExperianContactTestSetup.mapSetup(true);

        Test.startTest();    
        Test.setMock( HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, body) );   
        ExperianContactCallout.idList( oldMap, newMap ); 
        Test.stopTest();
        
        Callout_Error__c[] ceList = [SELECT Name, Status__c, Status_Code__c, Response_Body__c FROM Callout_Error__c];
        System.assert(ceList.isEmpty());

    }

    @isTest
    static void test_neg_invocable() {

        Integer code = 401;
        String status = 'ERROR';
        String body = '{"successful" : "false"}';

        Map<Id, Contact> oldMap = ExperianContactTestSetup.mapSetup(false);
        Map<Id, Contact> newMap = ExperianContactTestSetup.mapSetup(true);
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, body) );
        ExperianContactCallout.idList( oldMap, newMap );
        Test.stopTest();

        Callout_Error__c[] ceList = [SELECT Status__c, Status_Code__c, Response_Body__c FROM Callout_Error__c];
        System.assert(!ceList.isEmpty());
        for(Callout_Error__c ce : ceList){
            System.assertEquals(ce.Status_Code__c, code);
            System.assertEquals(ce.Status__c, status);
            System.assertEquals(ce.Response_Body__c, body);
        } 

    }

    @isTest
    static void test_Pos_Submission() {

        String body = ExperianContactTestSetup.jsonSetup();

        Integer code = 200;
        String status = 'OK';
        String resBody = '{"successful" : true}';
        String url = 'https://GetCreditReport1.nextlevelfunding.com/SalesForce.aspx';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, resBody));
        HttpResponse res = APICallout.PostCall(url, body);
        Test.stopTest();

        System.assertEquals(code, res.getStatusCode());
        System.assertEquals(status, res.getStatus());
        System.assertEquals(resBody, res.getBody());

    }

    @isTest
    static void test_Neg_Submission() {

        String body = ExperianContactTestSetup.jsonSetup();

        Integer code = 401;
        String status = 'ERROR';
        String resBody = '{"successful" : false}';
        String url = 'https://GetCreditReport1.nextlevelfunding.com/SalesForce.aspx';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, resBody));
        HttpResponse res = APICallout.PostCall(url, body);
        Test.stopTest();

        System.assertEquals(code, res.getStatusCode());
        System.assertEquals(status, res.getStatus());
        System.assertEquals(resBody, res.getBody());

    }
    
}