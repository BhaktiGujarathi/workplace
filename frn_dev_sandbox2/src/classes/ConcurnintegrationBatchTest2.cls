@isTest
public class ConcurnintegrationBatchTest2 {

    static testMethod void Test1(){  
    Concur_Integration__c cInteg = new Concur_Integration__c();
        cInteg.name = 'Authorization';
        cInteg.EndPoint__c = 'http://test.com/';
        cInteg.User_Name__c = 'test';
        cInteg.Password__c = 'test';
        cInteg.Consumer_Key__c = 'test';
        
        Concur_Integration__c cInteg1 = new Concur_Integration__c();
        cInteg1.name = 'ConcurTravelTrip';
        cInteg1.EndPoint__c = 'http://test.com/'; 
        
        Concur_Batch_Frequency__c ct = new Concur_Batch_Frequency__c();
        ct.name='FrequncyInMin';
        ct.Time_interval_In_Minutes__c =12;
        insert cInteg1;
        insert cInteg;
        insert ct;
        
        Trip__c trp = new Trip__c();
        trp.Trip_ID__c = 'gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144';
        insert trp;
         Opportunity opp = new Opportunity(); 
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won'; 
        insert opp;
        set<string> listrip = new set<string>();
        listrip.add(trp.Trip_ID__c);
        Test.startTest();
        Map<String, String> mapTrip= new Map<String, String>(); 
        mapTrip.put(trp.id,trp.id);
        ConcurnintegrationForReservBatch c = new ConcurnintegrationForReservBatch(mapTrip,'0_DnssiIF62lJaArxo3LO8IuuG5CY=');    
         //ConcurnintegrationForReservBatch.getCurrentLoggedInUserDateTime(system.now());
         ConcurnintegrationForReservBatch.getCurrentLoggedInUserDateTime(system.now());
        ConcurnintegrationForReservBatch.getCurrentLoggedInUserDateTime(system.now().addHours(-13));
        Map<string,string> tempma= new Map<string,string>();
        tempma.put('gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144',trp.id);
         c.tripIdMap = tempma;
        
        String bdyString =  '<Itinerary xmlns="http://www.concursolutions.com/api/travel/trip/2010/06"><id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id><ItinLocator>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</ItinLocator><TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId><UserLoginId>sgdev@statusgonow.com</UserLoginId><DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal><DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc><DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc><Description>'+opp.id+'</Description><EndDateLocal>2016-08-25T12:00:00</EndDateLocal> <EndDateUtc>2016-08-25T16:00:00</EndDateUtc><StartDateLocal>2016-08-11T12:00:00</StartDateLocal> <StartDateUtc>2016-08-11T18:00:00</StartDateUtc><TripName>Going Home</TripName><TripStatus>0</TripStatus><Bookings><Booking><BookingOwner>OpenBookingEmail</BookingOwner><Source>OpenBookingEmail</Source><BookingSource>Manual</BookingSource><DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal><DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc><DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc><RecordLocator>Manual_0</RecordLocator><AirlineTickets><AirlineTicket><BaseFare>753.3300</BaseFare><BaseFareCurrency>USD</BaseFareCurrency><DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc><DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc><IssueDateTime>2016-08-15T20:48:30</IssueDateTime><PlatingCarrierNumericCode>312</PlatingCarrierNumericCode><PlatingControlNumber>3123123123</PlatingControlNumber><TotalFare>753.3300</TotalFare><TotalFareCurrency>USD</TotalFareCurrency><AirlineTicketCoupons>    <AirlineTicketCoupon>        <ClassOfService>Y</ClassOfService>        <CouponNumber>0</CouponNumber>        <CouponStatus>OPEN</CouponStatus>        <EndCityCode>PHL</EndCityCode>        <FlightNumber>111</FlightNumber>        <StartCityCode>DEN</StartCityCode>        <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>        <Vendor>AC</Vendor>    </AirlineTicketCoupon></AirlineTicketCoupons></AirlineTicket> </AirlineTickets><Segments><Air><Cabin>Y</Cabin><ClassOfService>Y</ClassOfService><ConfirmationNumber>123123123123123</ConfirmationNumber><DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc><DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc><EndCityCode>PHL</EndCityCode><EndDateLocal>2016-08-25T12:00:00</EndDateLocal><EndDateUtc>2016-08-25T16:00:00</EndDateUtc><FlightNumber>111</FlightNumber><StartCityCode>DEN</StartCityCode><StartDateLocal>2016-08-11T12:00:00</StartDateLocal><StartDateUtc>2016-08-11T18:00:00</StartDateUtc><Status>HK</Status><Vendor>AC</Vendor><VendorName>Air Canada</VendorName><Seats>    <AirSeat>        <PassengerRph>1</PassengerRph>        <SeatNumber>1A</SeatNumber>    </AirSeat></Seats></Air></Segments></Booking> </Bookings></Itinerary>';  
        
        Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration(bdyString));
         c.ParserTripID(listrip);
        ConcurnintegrationForReservBatch.getCurrentLoggedInUserDateTime(system.now().addHours(13));
         Database.executeBatch(c);
        
        Test.stopTest();

    }
}