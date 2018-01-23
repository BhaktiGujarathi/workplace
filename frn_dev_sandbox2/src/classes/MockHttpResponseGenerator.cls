@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    String body ='';
	
	// Implement this interface method
	
	global MockHttpResponseGenerator(){
		body = '<root><Token>54225</Token></root>';
	}
	
    global MockHttpResponseGenerator(String par) {
        body = '   <ItineraryInfoList xmlns="http://www.concursolutions.com/api/travel/trip/2010/06" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">  '  + 
 '       <ItineraryInfo>  '  + 
 '           <BookingSource>Manual</BookingSource>  '  + 
 '           <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '           <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '           <Passengers i:nil="true"/>  '  + 
 '           <RecordLocator>Manual_0</RecordLocator>  '  + 
 '           <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '           <TravelerFirst>Dev</TravelerFirst>  '  + 
 '           <TravelerLast>User</TravelerLast>  '  + 
 '           <TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId>  '  + 
 '           <TripName>Going Home</TripName>  '  + 
 '           <UserLoginId>sgdev@statusgonow.com</UserLoginId>  '  + 
 '           <id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id>  '  + 
 '       </ItineraryInfo>  '  + 
 '  </ItineraryInfoList>  ' ; 
    }
	
	global MockHttpResponseGenerator(Integer i) {
        body = '   <ItineraryInfoList xmlns="http://www.concursolutions.com/api/travel/trip/2010/06" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">  '  + 
 '       <Itinerary>  '  + 
 '           <BookingSource>Manual</BookingSource>  '  + 
 '           <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '           <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '           <Passengers i:nil="true"/>  '  + 
 '           <RecordLocator>Manual_0</RecordLocator>  '  + 
 '           <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '           <TravelerFirst>Dev</TravelerFirst>  '  + 
 '           <TravelerLast>User</TravelerLast>  '  + 
 '           <TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId>  '  + 
 '           <TripName>Going Home</TripName>  '  + 
 '           <UserLoginId>sgdev@statusgonow.com</UserLoginId>  '  + 
 '           <id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id>  '  + 
 '       </Itinerary>  '  + 
 '  </ItineraryInfoList>  ' ; 
    }
	
	
	
	
	
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}