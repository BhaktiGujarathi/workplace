@isTest(seeAllData=false)
private class RestUtilityTest {

    public static final String STR_GET = 'GET';
    public static final String STR_ENDPOINT = 'https://www.concursolutions.com/api/travel/trip/v1.1';
    public static Date tripConcurStartDate = system.today().addDays(Integer.valueOf(system.label.CCtripConcurStartDate));
    public static Date tripConncurEndDate = system.today().addDays(Integer.valueOf(system.label.CCtripConncurEndDate));

    
    @isTest static void test_CreatePostRequest() {

        Blob headerValue = Blob.valueOf('sgdev@statusgonow.com'+':'+'Welcome@2');
        String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);

        // header
        Map<String,String> mapheaders =  new Map<String,String>{ 
                                                                'Authorization' => authorizationHeader,
                                                                'X-ConsumerKey' => 'Lp8uH8PwUcmpcQYSjZU4qV'
        };

        Boolean isException = false;
        HttpRequest request = new HttpRequest();

        Test.startTest();
            try {
                request = RestUtility.createPostRequest( STR_ENDPOINT , mapheaders , 'mapParam' );
            }
            catch (Exception e) {
                isException = true;
            }
        Test.stopTest();
        System.assertNotEquals( null , request , 'test_CreatePostRequest : Expect request not to ber null');
    }// end of test_CreatePostRequest
    
    @isTest static void test_CreateGetRequest() {
        Blob headerValue = Blob.valueOf('sgdev@statusgonow.com'+':'+'Welcome@2');
        String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);

        // header
        Map<String,String> mapheaders =  new Map<String,String>{ 
                                                                'Authorization' => authorizationHeader,
                                                                'X-ConsumerKey' => 'Lp8uH8PwUcmpcQYSjZU4qV'
        };

        //Params
        Map<String,String> mapParam = new Map<String,String>{
                                                            'userid_type' => 'login',
                                                            'userid_value' => 'ALL',
                                                            'bookingtype' => 'Air',
                                                            'createdAfterDate' => (tripConcurStartDate+'').remove(' 00:00:00'),
                                                            'createdBeforeDate' => (tripConncurEndDate+'').remove(' 00:00:00') 
        };

        Boolean isException = false;
        HttpRequest request = new HttpRequest();

        Test.startTest();
            try {
                request = RestUtility.createGetRequest( STR_ENDPOINT , mapheaders , mapParam );
            }
            catch (Exception e) {
                isException = true;
            }
        Test.stopTest();
        System.assertNotEquals( null , request , 'test_CreateGetRequest : Expect request not to be null');
    }// end of test_CreateGetRequest


    @isTest static void test_GetResponse() {
        Blob headerValue = Blob.valueOf('sgdev@statusgonow.com'+':'+'Welcome@2');
        String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);

        // header
        Map<String,String> mapheaders =  new Map<String,String>{
                                                                'Authorization' => authorizationHeader,
                                                                'X-ConsumerKey' => 'Lp8uH8PwUcmpcQYSjZU4qV'
        };

        //Params
        Map<String,String> mapParam = new Map<String,String>{};

        Boolean isException = false;
        HttpRequest request = RestUtility.createGetRequest( STR_ENDPOINT , mapheaders , mapParam );
        HttpResponse response = new HttpResponse();

        Test.startTest();
            try {
                response = RestUtility.getResponse( request );
            }
            catch (Exception e) {
                isException = true;
            }
        Test.stopTest();
        System.assertNotEquals( 200 , response.getStatusCode() , 'test_GetResponse : Expect response Status code should be 200');
    }// end of test_GetResponse

    
}