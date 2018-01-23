@isTest
global class CCMockHttpResponseGenerator implements HttpCalloutMock {

    

    //Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       
       String endPointURL = req.getEndpoint();
       if(endPointURL == 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx?')
       {
        //Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('<Access_Token>'+
                     '<Instance_Url>https://www.concursolutions.com/'+
                     '</Instance_Url><Token>0_6X//0jzJlf4FsYA8VQ9DwDcK8=</Token>'+
                     '<Expiration_date>7/25/2018 10:06:12 AM</Expiration_date>'+
                     '<Refresh_Token>0_M0Z20VWXn6gphcJmeem4uhYK7WyfN</Refresh_Token>'+
                     '</Access_Token>');
        res.setStatusCode(200);
        return res;
       }
       else if(endPointURL == 'https://www.concursolutions.com/api/travel/trip/v1.1?userid_type=login&userid_value=ALL&bookingtype=Air&createdAfterDate='+(system.today().addDays(Integer.valueOf(system.label.CCtripConcurStartDate))+'').remove(' 00:00:00')+'&createdBeforeDate='+(system.today().addDays(Integer.valueOf(system.label.CCtripConncurEndDate))+'').remove(' 00:00:00'))
       {
        //Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('<ItineraryInfoList xmlns="http://www.concursolutions.com/api/travel/trip/2010/06" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
                       '<ItineraryInfo>'+
                          '<BookingSource>Sabre</BookingSource>'+
                          '<DateModifiedUtc>2017-07-25T01:24:49</DateModifiedUtc>'+
                          '<EndDateLocal>2017-07-25T11:37:00</EndDateLocal>'+
                          '<Passengers>MARK ANDREW ROBERTS</Passengers>'+
                          '<RecordLocator>OOYQAH</RecordLocator>'+
                          '<StartDateLocal>2017-07-25T09:00:00</StartDateLocal>'+
                          '<TravelerFirst>Raymond</TravelerFirst>'+
                          '<TravelerLast>Teamer</TravelerLast>'+
                          '<TripId>gWupaQiXPhh5mZrZuYJC2CPJpal$siIDLNDqo</TripId>'+
                          '<TripName>Trip from Washington to Los Angeles (For  Mark Andrew Roberts )</TripName>'+
                          '<UserLoginId>Raymond.Teamer@frnmail.com</UserLoginId>'+
                          '<id>https://www.concursolutions.com/api/travel/trip/v1.1/gWupaQiXPhh5mZrZuYJC2CPJpal$siIDLNDqo</id>'+
                       '</ItineraryInfo>'+
                    '</ItineraryInfoList>');
        res.setStatusCode(200);
        return res;
       }
       else if(endPointURL == 'https://www.concursolutions.com/api/travel/trip/v1.1/gWupaQiXPhh5mZrZuYJC2CPJpal$siIDLNDqo')
       {
        HttpResponse res = new HttpResponse();
        res.setBody('<Itinerary xmlns="http://www.concursolutions.com/api/travel/trip/2010/06">'+
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
        res.setStatusCode(200);
        return res;
       }
       return null;
    }
}