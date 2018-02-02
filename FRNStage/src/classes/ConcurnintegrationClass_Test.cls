@isTest
private class ConcurnintegrationClass_Test 
{
 
    Static testMethod void Unit_Test(){ 

        
        		
		 Opportunity opp= new Opportunity();
        opp.Name='test';
		opp.Description='etstesrstsetest';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
        		
		Trip__c tr = new Trip__c(Trip_ID__c = 'Test', Description__c = 'etstesrstsetest',Opportunity__c = opp.id);
		insert tr;
		
		Trip__c trip = new Trip__c(Trip_ID__c ='123456678',Description__c = 'etstesrstsetest', Opportunity__c=opp.id);
		insert trip;
		Concur_Integration__c cInteg = new Concur_Integration__c();
		cInteg.name = 'Authorization';
		cInteg.EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx';
		cInteg.User_Name__c = 'test';
		cInteg.Password__c = 'test';
		cInteg.Consumer_Key__c = 'test';
		insert cInteg;
		
		Concur_Integration__c cInteg1 = new Concur_Integration__c();
		cInteg1.name = 'ConcurTravelTrip';
		cInteg1.EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'; 
		insert cInteg1;

		Test.startTest();
        ConcurnintegrationClass coni = new ConcurnintegrationClass();
		Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration());
		coni.getConcurAuthentication();
		coni.getConcurAuthentication();
		coni.getConcurTravalTrip();
		coni.GetUserTrips();
		coni.GetTrips();
		//coni.createTripRecord();
		coni.ParserTripID();
		//coni.createTripRecord1();
		//coni.parseNext();
		ConcurnintegrationClass.getCurrentLoggedInUserDateTime(system.now());
		
		String bdyString = '   <ItineraryInfoList xmlns="http://www.concursolutions.com/api/travel/trip/2010/06" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">  '  + 
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
		XmlStreamReader reader = new XmlStreamReader(bdyString); 
		coni.parseNext(reader);
		
		Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration(bdyString));
		//coni.parseResponse();
		Test.stopTest();
	 }   

	  Static testMethod void Unit_Test1(){ 

        Opportunity opp= new Opportunity();
        opp.Name='test';
		opp.Description='teststestetstesrstsetest';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
        		
		Trip__c tr = new Trip__c(Trip_ID__c = 'Test', Description__c = 'teststestetstesrstsetest',Opportunity__c = opp.id);
		insert tr;
		
		Trip__c trip = new Trip__c(Trip_ID__c ='123456678',Description__c = 'teststestetstesrstsetest', Opportunity__c=opp.id);
		insert trip;
		Concur_Integration__c cInteg = new Concur_Integration__c();
		cInteg.name = 'Authorization';
		cInteg.EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx';
		cInteg.User_Name__c = 'test';
		cInteg.Password__c = 'test';
		cInteg.Consumer_Key__c = 'test';
		insert cInteg;
		
		Concur_Integration__c cInteg1 = new Concur_Integration__c();
		cInteg1.name = 'ConcurTravelTrip';
		cInteg1.EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'; 
		insert cInteg1;
		
		
		Map<String, String> mapTrip= new Map<String, String>();
		mapTrip.put('TripId',string.valueof(trip.id));
		mapTrip.put('BookingSource','test');
		mapTrip.put('TripName','testTrip');
		mapTrip.put('id',string.valueof(trip.id));
		mapTrip.put('RecordLocator','testLoc');
		mapTrip.put('StartDateLocal',string.valueof(System.today()));
		mapTrip.put('EndDateLocal',string.valueof(System.today()));
		mapTrip.put('DateModifiedUtc',string.valueof(System.now()));
		
		List<Map<String,String>> TripList = new List<Map<String,String>>();
		TripList.add(mapTrip);
		
		
		Test.startTest();
        ConcurnintegrationClass coni = new ConcurnintegrationClass();
		Set<String> tripSet = new Set<String>();
		tripSet.add('gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144');
		coni.setTrip = tripSet; 
		Map<String,string> tripMap = new Map<String, string>();
		tripMap.put('gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144', tr.id);
		coni.tripIdMap = tripMap;
		Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration());
		coni.getConcurAuthentication();
		coni.getConcurTravalTrip();
		coni.GetUserTrips();
		coni.GetTrips();
		coni.createTripRecord(TripList);
		//coni.ParserTripID();
		//coni.createTripRecord1();
		//coni.parseNext();
		ConcurnintegrationClass.getCurrentLoggedInUserDateTime(system.now());
		//ConcurnintegrationClass.getDateTimeFromIntervals();
		
		
		String bdyString =  '<Itinerary xmlns="http://www.concursolutions.com/api/travel/trip/2010/06">  '  + 
 '       <id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id>  '  + 
 '       <ItinLocator>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</ItinLocator>  '  + 
 '       <TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId>  '  + 
 '       <UserLoginId>sgdev@statusgonow.com</UserLoginId>  '  + 
 '       <DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal>  '  + 
 '       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '       <Description>This is a test</Description>  '  + 
 '       <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '       <EndDateUtc>2016-08-25T16:00:00</EndDateUtc>  '  + 
 '       <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '       <StartDateUtc>2016-08-11T18:00:00</StartDateUtc>  '  + 
 '       <TripName>Going Home</TripName>  '  + 
 '       <TripStatus>0</TripStatus>  '  + 
 '       <Bookings>  '  + 
 '           <Booking>  '  + 
 '               <BookingOwner>OpenBookingEmail</BookingOwner>  '  + 
 '               <Source>OpenBookingEmail</Source>  '  + 
 '               <BookingSource>Manual</BookingSource>  '  + 
 '               <DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal>  '  + 
 '               <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '               <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '               <RecordLocator>Manual_0</RecordLocator>  '  + 
 '               <AirlineTickets>  '  + 
 '                   <AirlineTicket>  '  + 
 '                       <BaseFare>753.3300</BaseFare>  '  + 
 '                       <BaseFareCurrency>USD</BaseFareCurrency>  '  + 
 '                       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '                       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '                       <IssueDateTime>2016-08-15T20:48:30</IssueDateTime>  '  + 
 '                       <PlatingCarrierNumericCode>312</PlatingCarrierNumericCode>  '  + 
 '                       <PlatingControlNumber>3123123123</PlatingControlNumber>  '  + 
 '                       <TotalFare>753.3300</TotalFare>  '  + 
 '                       <TotalFareCurrency>USD</TotalFareCurrency>  '  + 
 '                       <AirlineTicketCoupons>  '  + 
 '                           <AirlineTicketCoupon>  '  + 
 '                               <ClassOfService>Y</ClassOfService>  '  + 
 '                               <CouponNumber>0</CouponNumber>  '  + 
 '                               <CouponStatus>OPEN</CouponStatus>  '  + 
 '                               <EndCityCode>PHL</EndCityCode>  '  + 
 '                               <FlightNumber>111</FlightNumber>  '  + 
 '                               <StartCityCode>DEN</StartCityCode>  '  + 
 '                               <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '                               <Vendor>AC</Vendor>  '  + 
 '                           </AirlineTicketCoupon>  '  + 
 '                       </AirlineTicketCoupons>  '  + 
 '                   </AirlineTicket>  '  + 
 '               </AirlineTickets>  '  + 
 '               <Segments>  '  + 
 '                   <Air>  '  + 
 '                       <Cabin>Y</Cabin>  '  + 
 '                       <ClassOfService>Y</ClassOfService>  '  + 
 '                       <ConfirmationNumber>123123123123123</ConfirmationNumber>  '  + 
 '                       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '                       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '                       <EndCityCode>PHL</EndCityCode>  '  + 
 '                       <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '                       <EndDateUtc>2016-08-25T16:00:00</EndDateUtc>  '  + 
 '                       <FlightNumber>111</FlightNumber>  '  + 
 '                       <StartCityCode>DEN</StartCityCode>  '  + 
 '                       <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '                       <StartDateUtc>2016-08-11T18:00:00</StartDateUtc>  '  + 
 '                       <Status>HK</Status>  '  + 
 '                       <Vendor>AC</Vendor>  '  + 
 '                       <VendorName>Air Canada</VendorName>  '  + 
 '                       <Seats>  '  + 
 '                           <AirSeat>  '  + 
 '                               <PassengerRph>1</PassengerRph>  '  + 
 '                               <SeatNumber>1A</SeatNumber>  '  + 
 '                           </AirSeat>  '  + 
 '                       </Seats>  '  + 
 '                   </Air>  '  + 
 '               </Segments>  '  + 
 '           </Booking>  '  + 
 '       </Bookings>  '  + 
 '  </Itinerary>  ' ; 
 XmlStreamReader reader = new XmlStreamReader(bdyString); 
 coni.parseNext(reader);
 
		Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration(bdyString));
		//coni.ParserTripID();
	Test.stopTest();
    }   
	
	  Static testMethod void Unit_Test2(){ 

        Opportunity opp= new Opportunity();
        opp.Name='test';
		opp.Description='teststestetstesrstsetest';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
        		
		Trip__c tr = new Trip__c(Trip_ID__c = '123333', Description__c = 'teststestetstesrstsetest',Opportunity__c = opp.id);
		insert tr;
		
		Trip__c trip = new Trip__c(Trip_ID__c ='123456678',Description__c = 'teststestetstesrstsetest', Opportunity__c=opp.id);
		insert trip;
		Concur_Integration__c cInteg = new Concur_Integration__c();
		cInteg.name = 'Authorization';
		cInteg.EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx';
		cInteg.User_Name__c = 'test';
		cInteg.Password__c = 'test';
		cInteg.Consumer_Key__c = 'test';
		insert cInteg;
		
		Concur_Integration__c cInteg1 = new Concur_Integration__c();
		cInteg1.name = 'ConcurTravelTrip';
		cInteg1.EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'; 
		insert cInteg1;
		
		
		Map<String, String> mapTrip= new Map<String, String>();
		mapTrip.put('TripId',string.valueof(trip.id));
		mapTrip.put('BookingSource','test');
		mapTrip.put('TripName','testTrip');
		mapTrip.put('id',string.valueof(trip.id));
		mapTrip.put('RecordLocator','testLoc');
		mapTrip.put('StartDateLocal',string.valueof(System.today()));
		mapTrip.put('EndDateLocal',string.valueof(System.today()));
		mapTrip.put('DateModifiedUtc',string.valueof(System.now()));
		
		List<Map<String,String>> TripList = new List<Map<String,String>>();
		TripList.add(mapTrip);
		
		
		Test.startTest();

		
		
		String bdyString =  '<Itinerary xmlns="http://www.concursolutions.com/api/travel/trip/2010/06">  '  + 
 '       <id>https://www.concursolutions.com/api/travel/trip/v1.1/gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</id>  '  + 
 '       <ItinLocator>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</ItinLocator>  '  + 
 '       <TripId>gWutRRSrLgxphZNl72RkdUf45Cp0CBRF5TOnN144</TripId>  '  + 
 '       <UserLoginId>sgdev@statusgonow.com</UserLoginId>  '  + 
 '       <DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal>  '  + 
 '       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '       <Description>This is a test</Description>  '  + 
 '       <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '       <EndDateUtc>2016-08-25T16:00:00</EndDateUtc>  '  + 
 '       <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '       <StartDateUtc>2016-08-11T18:00:00</StartDateUtc>  '  + 
 '       <TripName>Going Home</TripName>  '  + 
 '       <TripStatus>0</TripStatus>  '  + 
 '       <Bookings>  '  + 
 '           <Booking>  '  + 
 '               <BookingOwner>OpenBookingEmail</BookingOwner>  '  + 
 '               <Source>OpenBookingEmail</Source>  '  + 
 '               <BookingSource>Manual</BookingSource>  '  + 
 '               <DateBookedLocal>2016-08-15T00:00:00</DateBookedLocal>  '  + 
 '               <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '               <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '               <RecordLocator>Manual_0</RecordLocator>  '  + 
 '               <AirlineTickets>  '  + 
 '                   <AirlineTicket>  '  + 
 '                       <BaseFare>753.3300</BaseFare>  '  + 
 '                       <BaseFareCurrency>USD</BaseFareCurrency>  '  + 
 '                       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '                       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '                       <IssueDateTime>2016-08-15T20:48:30</IssueDateTime>  '  + 
 '                       <PlatingCarrierNumericCode>312</PlatingCarrierNumericCode>  '  + 
 '                       <PlatingControlNumber>3123123123</PlatingControlNumber>  '  + 
 '                       <TotalFare>753.3300</TotalFare>  '  + 
 '                       <TotalFareCurrency>USD</TotalFareCurrency>  '  + 
 '                       <AirlineTicketCoupons>  '  + 
 '                           <AirlineTicketCoupon>  '  + 
 '                               <ClassOfService>Y</ClassOfService>  '  + 
 '                               <CouponNumber>0</CouponNumber>  '  + 
 '                               <CouponStatus>OPEN</CouponStatus>  '  + 
 '                               <EndCityCode>PHL</EndCityCode>  '  + 
 '                               <FlightNumber>111</FlightNumber>  '  + 
 '                               <StartCityCode>DEN</StartCityCode>  '  + 
 '                               <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '                               <Vendor>AC</Vendor>  '  + 
 '                           </AirlineTicketCoupon>  '  + 
 '                       </AirlineTicketCoupons>  '  + 
 '                   </AirlineTicket>  '  + 
 '               </AirlineTickets>  '  + 
 '               <Segments>  '  + 
 '                   <Air>  '  + 
 '                       <Cabin>Y</Cabin>  '  + 
 '                       <ClassOfService>Y</ClassOfService>  '  + 
 '                       <ConfirmationNumber>123123123123123</ConfirmationNumber>  '  + 
 '                       <DateCreatedUtc>2016-08-16T03:48:30</DateCreatedUtc>  '  + 
 '                       <DateModifiedUtc>2016-08-16T03:48:30</DateModifiedUtc>  '  + 
 '                       <EndCityCode>PHL</EndCityCode>  '  + 
 '                       <EndDateLocal>2016-08-25T12:00:00</EndDateLocal>  '  + 
 '                       <EndDateUtc>2016-08-25T16:00:00</EndDateUtc>  '  + 
 '                       <FlightNumber>111</FlightNumber>  '  + 
 '                       <StartCityCode>DEN</StartCityCode>  '  + 
 '                       <StartDateLocal>2016-08-11T12:00:00</StartDateLocal>  '  + 
 '                       <StartDateUtc>2016-08-11T18:00:00</StartDateUtc>  '  + 
 '                       <Status>HK</Status>  '  + 
 '                       <Vendor>AC</Vendor>  '  + 
 '                       <VendorName>Air Canada</VendorName>  '  + 
 '                       <Seats>  '  + 
 '                           <AirSeat>  '  + 
 '                               <PassengerRph>1</PassengerRph>  '  + 
 '                               <SeatNumber>1A</SeatNumber>  '  + 
 '                           </AirSeat>  '  + 
 '                       </Seats>  '  + 
 '                   </Air>  '  + 
 '               </Segments>  '  + 
 '           </Booking>  '  + 
 '       </Bookings>  '  + 
 '  </Itinerary>  ' ; 
 XmlStreamReader reader = new XmlStreamReader(bdyString); 
 //coni.parseNext(reader);
 
		Test.setMock(HttpCalloutMock.class, new MockClassForConcurIntegration(bdyString));
		
		ConcurnintegrationClass coni = new ConcurnintegrationClass();
		Set<String> tripSet = new Set<String>();
		tripSet.add('123333');
		tripSet.add('123456678');
		coni.setTrip = tripSet; 
		Map<String,string> tripMap = new Map<String, string>();
		tripMap.put('123333', tr.id);
		tripMap.put('123456678', trip.id);
		//tripIdMap.put(tr.Trip_ID__c,tr.id);
        coni.tripMap.put(tr.Trip_ID__c,tr);
        coni.tripMap.put(trip.Trip_ID__c,trip);
		coni.tripIdMap = tripMap;
		coni.authorizationret = '23456789';
		//coni.getConcurTravalTrip();
		//coni.GetUserTrips();
		//coni.GetTrips();
		//coni.createTripRecord(TripList);
		//coni.ParserTripID();
		//coni.createTripRecord1();
		//coni.parseNext();
		//ConcurnintegrationClass.getCurrentLoggedInUserDateTime(system.now());
		//ConcurnintegrationClass.getDateTimeFromIntervals();
		coni.ParserTripID();
	Test.stopTest();
    }   


	
	}