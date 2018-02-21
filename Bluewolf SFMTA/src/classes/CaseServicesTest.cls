@isTest
private class CaseServicesTest {
    static final string CUSTOM_SETTING_NAME = 'GeocodingDetails';
    static final string CUSTOM_SETTING_KEY = 'AIzaSyA44Uce87uzz4Ngqxx1Fxgy0g6r2irnSYw';
    static final string CUSTOM_SETTING_URL = 'https://maps.googleapis.com/maps/api/geocode/json?';
    static final Decimal EXPECTED_LATITUDE = 38.2726578;
    static final Decimal EXPECTED_LONGITUDE = -122.2750592;

    static testmethod void testRetrieveGeoCodes(){
       List<Id> caseIdList = new List<Id> { 
            new SObjectBuilder(Case.SObjectType)
                .create()
                .getRecord().Id 
        };
        insert new GeoCodingApi__c(
            Name = CUSTOM_SETTING_NAME,
            Key__c = CUSTOM_SETTING_KEY,
            URL__c = CUSTOM_SETTING_URL
        );

        String body = '{"results" : [{"formatted_address" : "La Jota Hall, 2277 Napa Vallejo Hwy, Napa, CA 94558, USA","geometry" : {"bounds" : {"northeast" : {"lat" : 38.27278159999999,"lng" : -122.2748462},"southwest" : {"lat" : 38.272534,"lng" : -122.2752722}},"location" : {"lat" : 38.2726578,"lng" : -122.2750592},"location_type" : "ROOFTOP","viewport" : {"northeast" : {"lat" : 38.27400678029149,"lng" : -122.2737102197085},"southwest" : {"lat" : 38.2713088197085,"lng" : -122.2764081802915}}},"place_id" : "ChIJyQVpngIGhYAR-eIDUYnI6EI","types" : [ "premise" ]}],"status" : "OK"}';          
        Test.setMock(HttpCalloutMock.class, new GeocodeMockResponseGenerator(body));

        Test.startTest();
            CaseServices.RetrieveGeoCodes(caseIdList);
        Test.stopTest();

        List<Case> updatedCaseList = [
            SELECT Id, Case_Location__Latitude__s, Case_Location__Longitude__s  
            FROM Case 
        ];
        System.assertEquals(1, updatedCaseList.size(), 'A single case should be returned');
        System.assertEquals(EXPECTED_LATITUDE, updatedCaseList[0].Case_Location__Latitude__s);
        System.assertEquals(EXPECTED_LONGITUDE,updatedCaseList[0].Case_Location__Longitude__s);
    }
}