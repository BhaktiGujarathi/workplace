@isTest
global class CCMockHttpErrorResponseGenerator implements HttpCalloutMock {

    //Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint() == 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx?') {
            res.setBody('');
            res.setStatusCode(401);
        } else if (
            req.getEndpoint() ==
                'https://www.concursolutions.com/api/travel/trip/v1.1/gWupaQiXPhh5mZrZuYJC2CPJpal$siIDLNDqo'
        ) {
            res.setBody(
                '<Itinerary xmlns="http://www.concursolutions.com/api/travel/trip/2010/06">'+
                    '<Description>'+CCPullTripFromConcurAndSFTest.oppID+'</Description>'+
                    '<Bookings>'+
                        '<Booking>'+
                            '<BookingOwner>ConcurTravel</BookingOwner>'+
                            '<Source>ConcurTravel</Source>'+
                            '<BookingSource>Sabre</BookingSource>'+
                            '<DateBookedLocal>2017-07-26T19:18:00</DateBookedLocal>'+
                            '<DateCreatedUtc>2017-07-27T00:18:20</DateCreatedUtc>'+
                            '<DateModifiedUtc>2017-07-27T00:18:24</DateModifiedUtc>'+
                            '<AgencyName>Direct Travel</AgencyName>'+
                            '<AgencyPCC>C7F0</AgencyPCC>'+
                            '<IsGhostCard>true</IsGhostCard>'+
                            '<LastTicketDateUtc>2017-07-28T02:00:00</LastTicketDateUtc>'+
                            '<RecordLocator>ZJLWYK</RecordLocator>'+
                            '<AirfareQuotes>'+
                            '<Quote>'+
                                '<BaseFare>304.1900</BaseFare>'+
                                '<BaseFareCurrency>USD</BaseFareCurrency>'+
                                '<DateCreatedUtc>2017-07-27T00:18:24</DateCreatedUtc>'+
                                '<DateModifiedUtc>2017-07-27T00:18:24</DateModifiedUtc>'+
                                '<Endorsements>NONREF/SVCCHGPLUSFAREDIF/CXL BY FLT TIME OR NOVALUE</Endorsements>'+
                                '<IssueByDate>2017-07-27T23:59:00</IssueByDate>'+
                                '<TotalFare>349.8000</TotalFare>'+
                                '<TotalFareCurrency>USD</TotalFareCurrency>'+
                            '</Quote>'+
                            '</AirfareQuotes>'+
                            '<Segments>'+
                                '<Air>'+
                                    '<AircraftCode>321</AircraftCode>'+
                                    '<Cabin>Y</Cabin>'+
                                    '<CarbonEmissionLbs>560.039978</CarbonEmissionLbs>'+
                                    '<CarbonModel>2</CarbonModel>'+
                                    '<ClassOfService>V</ClassOfService>'+
                                    '<ConfirmationNumber>ZJLWYK</ConfirmationNumber>'+
                                    '<DateCreatedUtc>2017-07-27T00:18:20</DateCreatedUtc>'+
                                    '<DateModifiedUtc>2017-07-27T00:19:52</DateModifiedUtc>'+
                                    '<Duration>211</Duration>'+
                                    '<EndCityCode>PHX</EndCityCode>'+
                                    '<EndDateLocal>2017-07-28T12:26:00</EndDateLocal>'+
                                    '<EndDateUtc>2017-07-28T19:26:00</EndDateUtc>'+
                                    '<EndTerminal>4</EndTerminal>'+
                                    '<ETicket>E</ETicket>'+
                                    '<FlightNumber>603</FlightNumber>'+
                                    '<IsPreferredVendor>1</IsPreferredVendor>'+
                                    '<LegId>1</LegId>'+
                                    '<Meals>F</Meals>'+
                                    '<Miles>1436</Miles>'+
                                    '<NumStops>0</NumStops>'+
                                    '<StartCityCode>ORD</StartCityCode>'+
                                    '<StartDateLocal>2017-07-28T10:55:00</StartDateLocal>'+
                                    '<StartDateUtc>2017-07-28T15:55:00</StartDateUtc>'+
                                    '<StartTerminal>3</StartTerminal>'+
                                    '<Status>HK</Status>'+
                                    '<Vendor>AA</Vendor>'+
                                    '<VendorName>American Airlines</VendorName>'+
                                '</Air>'+
                            '</Segments>'+
                        '</Booking>'+
                    '</Bookings>'+
                '</Itinerary>');
            res.setStatusCode(403);
        } else {
            res.setBody('');
            res.setStatusCode(500);
        }
        return res;

    }
}