@isTest
public class ConcurnintegrationBatchTest {

    static testMethod void Test1(){   
        Concur_Integration__c cInteg = new Concur_Integration__c();
        cInteg.name = 'Authorization';
        cInteg.EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx';
        cInteg.User_Name__c = 'test';
        cInteg.Password__c = 'test';
        cInteg.Consumer_Key__c = 'test';
     
        
        Concur_Integration__c cInteg1 = new Concur_Integration__c();
        cInteg1.name = 'ConcurTravelTrip';
        cInteg1.EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'; 
        cInteg1.Userid_Type__c = 'login'; 
        cInteg1.Userid_Value__c = 'ALL'; 
        cInteg1.Booking_Type__c = 'Air';  
         
        insert cInteg;
        insert cInteg1;
    
        Test.startTest();
            ConcurnintegrationBatch c = new ConcurnintegrationBatch();
        //c.getConcurAuthentication();
        //c.getConcurTravalTrip();
        ConcurnintegrationBatch.getCurrentLoggedInUserDateTime(system.now());
        ConcurnintegrationBatch.getCurrentLoggedInUserDateTime(system.now().addHours(-13));
        
        //Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration());
        
        String bdyString =  '<ItineraryInfoList xmlns="http://www.concursolutions.com/api/travel/trip/2010/06" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><ItineraryInfo><BookingSource>Manual</BookingSource> <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc><EndDateLocal>2016-08-25T12:00:00</EndDateLocal><Passengers i:nil="true"/><RecordLocator>Manual_0</RecordLocator><StartDateLocal>2016-08-11T12:00:00</StartDateLocal> <TravelerFirst>Dev</TravelerFirst><TravelerLast>User</TravelerLast>  <TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId><TripName>Going Home</TripName> <UserLoginId>sgdev@statusgonow.com</UserLoginId><id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id> </ItineraryInfo></ItineraryInfoList>';   
        Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration(bdyString));
        c.getConcurAuthentication();
        c.getConcurTravalTrip();
        c.mapTripList = new List<Map<String,String>>();
         XmlStreamReader reader = new XmlStreamReader(bdyString); 
         c.parseNext(reader);
         
         ConcurnintegrationBatch.getCurrentLoggedInUserDateTime(system.now().addHours(13));
         Database.executeBatch(c);
        Test.stopTest();  
    }
     
}