public Class CCPullReservationConcurBatchService
{

   //Declaration
   public Map<String,Integer> reservationCount = new Map<String,Integer>();
   public Map<String,Boolean> mapIDIsTripCreate =  new Map<String,Boolean>();
   public Map<String,Trip__c> mapConIDTripToInsert = new Map<String,Trip__c>();
   public List<SObject> lstTripResToInsert = new List<SObject>();
   public void CCPullReservationConcurBatchService()
   {
   }


   public void CCPullReservationConcurBatchExecute (
            List<trip__c> newtripList,
            String accessToken,
            Map<String,Trip__c>  mapCncIDTrip,
            Map<String,List<Reservation__c>> mapCncIDReservation,
            Map<String,String> mapCncIDopportunityID,
            List<Apex_Debug_Log__c> lstApxlog
    ){
        /*
        // Sudo code
        1. Make a callout for reservation.
            1.1 Iterate over trip and make the cache DB -> map<concurtripID,Trip__c>
            1.2 Make the callout for Resrevation
            1.3 Make the cache DB of reservation Map<String,List<Reservation__c>> mapCncIDReservation,
                cache DB of Trip Map<String,Trip__c>  mapCncIDTrip
                and cache DB of Opportunity Map<String,String> mapCncIDopportunityID.
        2. Check wether opportunity -> trip sibling's is not having Open or Closed.
           Also Trip should only be create if there is no existing trip to oppotunity or if trip exist then  it should be in cancled state
            2.1 Query Opportunity wit all its related trip.
            2.2 iterate over the trip and find the siblings of the trip satisfies above mentioned(in point 2) condition.
        3. Finally prepare to insert.
            3.1  Iterate over mapCncIDReservation.
            3.2  Pull relate record of mapCncIDopportunityID and check wether Trip can be inserted to particular opportunity.
            3.3  If 3.2 passes, then pull the Trip from mapCncIDTrip and add to .
            Continue... (http://theblogreaders.com/how-to-insert-parent-and-child-records-in-a-single-dml-statement/)

        */
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullReservationConcurBatchService','CCPullReservationConcurBatchExecute','---newTrip ----',41, system.now(),newtripList+'')));
        Boolean isSuccess;
        for(Trip__c newTrip : newtripList) {
            //1.1 Iterate over trip and make the cache DB -> map<concurtripID,Trip__c>
            mapCncIDTrip.put(newTrip.Trip_ID__c,newTrip);

            //1.2 Make the callout for Reservation
            isSuccess = getReservationsFromTrip(
                newTrip,
                accessToken,
                mapCncIDTrip,
                mapCncIDReservation,
                mapCncIDopportunityID,
                lstApxlog
            );
            if (isSuccess == false) {
                break;
            }
        }
        /*As pull for fetching individual trip record details from Concur system failed due to one of the following reasons.
        1. Server down : Action : We reschedule and keep trying as below
        2. Authentication Token Expired : We reschedule and request for new token
        3. Other errors we create debug log record and keep retrying untill success as batch job should not terminate in any case.
           Assumption : Finish method successfully reschedules the pull
        */
        if (isSuccess == false) {
            return;
        }

         /*
         2. Check wether opportunity -> trip sibling's is not having Open or Closed.
            Also Trip should only be create if there is no existing trip to oppotunity
            or if trip exist then  it should be in cancled state
              2.1 Query Opportunity wit all its related trip.

         */
         for(Opportunity opp : [SELECT id,
                                       (
                                       SELECT id,
                                              Status__c
                                         FROM Trips__r
                                       )
                                  FROM Opportunity
                                 WHERE id = :mapCncIDopportunityID.values() ])
        {
              //2.2 iterate over the trip and find the siblings of the trip satisfies above mentioned(in point 2) condition.
              mapIDIsTripCreate.put(opp.id,isTripInserted(opp));

        }

        // lstTripResToInsert
        for (String conID : mapCncIDTrip.keySet()) {

            if (    mapIDIsTripCreate.containskey(mapCncIDopportunityID.get(conID))
                && mapIDIsTripCreate.get(mapCncIDopportunityID.get(conID))
            ) {
                    lstTripResToInsert.add(mapCncIDTrip.get(conID));
                    for(Reservation__c res : mapCncIDReservation.get(conID))
                    {
                    lstTripResToInsert.add(res);
                    }

            }
        }

        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullReservationConcurBatchService','CCPullReservationConcurBatchExecute','---lstTripResToInsert----',93, system.now(),lstTripResToInsert+'')));
        Database.SaveResult[] results = Database.insert(lstTripResToInsert);

        // Check results.
        for (Integer i = 0; i < results.size(); i++)
        {
            if (results[i].isSuccess())
            {
                System.debug('Successfully created ID: '+ results[i].getId());
                lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullReservationConcurBatchService','CCPullReservationConcurBatchExecute','---results[i].isSuccess()----',102, system.now(), results[i].getId()+'')));

            }
            else
            {
                System.debug('Error: could not create sobject '+ 'for array element ' + i + '.');
                System.debug('The error reported was: '+ results[i].getErrors()[0].getMessage() + '\n');
                lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullReservationConcurBatchService','CCPullReservationConcurBatchExecute','Error: could not create sobject '+ 'for array element ' + i + '.',109, system.now(),results[i].getErrors()[0].getMessage()+'')));
            }
        }



    }


    public Boolean getReservationsFromTrip(
        Trip__c newTrip,
        String accessToken,
        Map<String,Trip__c>  mapCncIDTrip,
        Map<String,List<Reservation__c>> mapCncIDReservation,
        Map<String,String> mapCncIDopportunityID,
        List<Apex_Debug_Log__c> lstApxlog
    ) {
        Boolean isSuccess = true;
        reservationCount.put(newTrip.Trip_ID__c,0);
        HttpRequest httpRequestGetTrip = RestUtility.createGetRequest('https://www.concursolutions.com/api/travel/trip/v1.1'+'/'+newTrip.Trip_ID__c,
                                                                    //header
                                                                    new Map<String,String>{
                                                                                           'Authorization' => 'OAuth '+accessToken
                                                                                          },
                                                                    null
                                                                      );
        HttpResponse httpResponseTrip;
        try {

            httpResponseTrip = RestUtility.getResponse(httpRequestGetTrip);
            ConcurErrorHandler.ConcurStatusDetails concurStatusDetails = ConcurErrorHandler.getStatusDetails(httpResponseTrip);

            if ( true == concurStatusDetails.isSuccess ) {

                parseTripDetailsResponse(
                    newTrip,
                    accessToken,
                    mapCncIDTrip,
                    mapCncIDReservation,
                    mapCncIDopportunityID,
                    lstApxlog,
                    httpResponseTrip
                );
                isSuccess = true;
            } else {
                throw new ApplicationException('Fetching Trip Information Failed.');
            }

        } catch( Exception exp ){
            isSuccess = false;
            lstApxlog.add(
                ApexDebugLog.createLog(
                    new ApexDebugLog.Information(
                        'CCPullReservationConcurBatchService'
                        ,'getReservationsFromTrip'
                        , ConcurErrorHandler.CONCUR_ERROR
                        , exp.getLineNumber()
                        , Datetime.now()
                        , ApexDebugLog.getHttpTransactionLog(httpRequestGetTrip, httpResponseTrip)
                    ).setStackTrace(exp)
                )
            );
        }
        return isSuccess;
    }

     public boolean isTripInserted(Opportunity opp)
     {
        Boolean create = false;
        if(opp.Trips__r.size() > 0)
        {

                  for(Trip__c trip : opp.Trips__r)
                  {
                      if(trip.Status__c == 'Open' || trip.Status__c == 'Closed'){ create = create && false;}
                      if(trip.Status__c == 'Cancelled'){ create = create || true;}

                  }
         }
         else
         {
                 create = true;
         }

         return create;

     }

    private void parseTripDetailsResponse(
        Trip__c newTrip,
        String accessToken,
        Map<String,Trip__c>  mapCncIDTrip,
        Map<String,List<Reservation__c>> mapCncIDReservation,
        Map<String,String> mapCncIDopportunityID,
        List<Apex_Debug_Log__c> lstApxlog,
        HttpResponse httpResponseTrip
    ) {
        List<Reservation__c> listOfReservations = new List<Reservation__c>();
        Dom.Document doc = new Dom.Document();
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullReservationConcurBatchService','getReservationsFromTrip','httpResponseReservations',139, system.now(),httpResponseTrip.getBody()+'')));
        doc.load(httpResponseTrip.getBody());
        Dom.XmlNode itineraryNode = doc.getRootElement();
        for(Dom.XmlNode itineraryChildNode : itineraryNode.getChildElements())
        {
            //Extracting and assigning Description XML to Trip Opportunity
            if(itineraryChildNode.getName() == 'Description'
            && !String.isBlank(itineraryChildNode.getText())
            && (itineraryChildNode.getText()).startsWith(Opportunity.sobjecttype.getDescribe().getKeyPrefix())
            && String.valueOf(itineraryChildNode.getText()).length() >= 15)
            {
                newTrip.Opportunity__c = itineraryChildNode.getText();
            }
            //Continue only when the Opportunity is populated.
            if(newTrip.Opportunity__c != null)
            {

                mapCncIDTrip.put(newTrip.Trip_ID__c,newTrip);
                mapCncIDopportunityID.put(newTrip.Trip_ID__c,newTrip.Opportunity__c);

                //Extract reservations
                if(itineraryChildNode.getName() == 'Bookings')
                {
                    for(Dom.XmlNode bookingsChildNode : itineraryChildNode.getChildElements())
                    {
                            if(bookingsChildNode.getName() == 'Booking')
                            {
                                String BaseFare;
                                String BaseFareCurrency;
                                String TotalFare;
                                String TotalFareCurrency;
                                for(Dom.XmlNode bookingChildNode : bookingsChildNode.getChildElements())
                                {
                                if(bookingChildNode.getName() == 'AirlineTickets')
                                    {
                                        for(Dom.XmlNode airlineTicketsChildNode : bookingChildNode.getChildElements())
                                        {
                                            if(airlineTicketsChildNode.getName() == 'AirlineTicket')
                                            {
                                                for(Dom.XmlNode airlineTicketChildNode : airlineTicketsChildNode.getChildElements())
                                                {
                                                    if(airlineTicketChildNode.getName() == 'BaseFare'){BaseFare = airlineTicketChildNode.getText();}
                                                    if(airlineTicketChildNode.getName() == 'BaseFareCurrency'){BaseFareCurrency = airlineTicketChildNode.getText();}
                                                    if(airlineTicketChildNode.getName() == 'TotalFare'){TotalFare = airlineTicketChildNode.getText();}
                                                    if(airlineTicketChildNode.getName() == 'TotalFareCurrency'){TotalFareCurrency = airlineTicketChildNode.getText();}
                                                }
                                            }
                                        }
                                    }

                                    if(bookingChildNode.getName() == 'AirfareQuotes')
                                    {
                                        for(Dom.XmlNode airfareQuotesChildNode : bookingChildNode.getChildElements())
                                        {
                                            if(airfareQuotesChildNode.getName() == 'Quote')
                                            {
                                                for(Dom.XmlNode QuoteNode : airfareQuotesChildNode.getChildElements())
                                                {
                                                    if(QuoteNode.getName() == 'BaseFare'){BaseFare = QuoteNode.getText();}
                                                    if(QuoteNode.getName() == 'BaseFareCurrency'){BaseFareCurrency = QuoteNode.getText();}
                                                    if(QuoteNode.getName() == 'TotalFare'){TotalFare = QuoteNode.getText();}
                                                    if(QuoteNode.getName() == 'TotalFareCurrency'){TotalFareCurrency = QuoteNode.getText();}
                                                }
                                            }

                                        }

                                    }

                                    if(bookingChildNode.getName() == 'Segments')
                                    {
                                        for(Dom.XmlNode segmentsChildNode : bookingChildNode.getChildElements())
                                        {
                                            if(segmentsChildNode.getName() == 'Air')
                                            {
                                            Reservation__c newRes = new Reservation__c();
                                            if(reservationCount.containsKey(newTrip.Trip_ID__c))
                                            {
                                                    Integer i = reservationCount.get(newTrip.Trip_ID__c);
                                                    i +=1;
                                                    reservationCount.put(newTrip.Trip_ID__c,i);
                                            }
                                            }
                                        }
                                        //Drill to Air.
                                        for(Dom.XmlNode segmentsChildNode : bookingChildNode.getChildElements())
                                        {
                                        if(segmentsChildNode.getName() == 'Air')
                                        {
                                            Reservation__c newRes = new Reservation__c();
                                            /* if(reservationCount.containsKey(newTrip.Trip_ID__c))
                                            {
                                                    Integer i = reservationCount.get(newTrip.Trip_ID__c);
                                                    i +=1;
                                                    reservationCount.put(newTrip.Trip_ID__c,i);
                                            }*/

                                            for(Dom.XmlNode AirChildNode : segmentsChildNode.getChildElements())
                                            {

                                                newRes.RecordTypeId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
                                                if(newTrip.Trip_Ref__c != null)
                                                {
                                                Trip__c tripRef = new Trip__c(Trip_Ref__c = newTrip.Trip_Ref__c);
                                                newRes.Trip__r = tripRef;
                                                }
                                                if(AirChildNode.getName() == 'PlatingControlNumber'){ newRes.Ticket_Number__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'VendorName'){ newRes.Airline__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'ClassOfService'){ newRes.Cabin__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'ConfirmationNumber'){ newRes.Confirmation_Number__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'FlightNumber' && AirChildNode.getText().length()<= 8)
                                                {
                                                    newRes.Flight_Number__c = AirChildNode.getText();
                                                }
                                                if(AirChildNode.getName() == 'Status'){ newRes.Status__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'SeatNumber'){ newRes.Seat_Assignment__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'StartDateLocal')
                                                {
                                                    string dateTimeInString =  AirChildNode.getText();
                                                    DateTime deletedat = DateTime.Valueof(dateTimeInString.replace('T', ' '));
                                                    newRes.Departure_Date_Time__c = deletedat.format('MM/dd/yyyy hh:mm a');
                                                }
                                                if(AirChildNode.getName() == 'EndDateLocal')
                                                {
                                                    string dateTimeInString =  AirChildNode.getText();
                                                    DateTime deletedat = DateTime.Valueof(dateTimeInString.replace('T', ' '));
                                                    newRes.Arrival_Date_Time__c = deletedat.format('MM/dd/yyyy hh:mm a');
                                                }
                                                if(AirChildNode.getName() == 'StartCityCode'){ newRes.Departure_Airport__c = AirChildNode.getText();}
                                                if(AirChildNode.getName() == 'EndCityCode'){ newRes.Arrival_Airport__c = AirChildNode.getText();}
                                                if(!String.isBlank(TotalFare)){ newRes.Total_Amount_Charged__c = decimal.valueOf(TotalFare)/reservationCount.get(newTrip.Trip_ID__c); }
                                                if(!String.isBlank(TotalFareCurrency)){ newRes.Total_Amount_Charged_Currency__c = TotalFareCurrency;}
                                                if(!String.isBlank(BaseFareCurrency)){ newRes.Rate_Currency__c = BaseFareCurrency;}
                                                newRes.Pickup_Location_Type__c = 'Airport';

                                            }
                                                listOfReservations.add(newRes);
                                            }
                                        }
                                    } //End of Segment
                                }
                            } // End of Booking
                    } // End of Iterator of Bookings
                } // End of Bookings
            } //End of Opportuntity != null
        } // End on Iterator over itinerary

        mapCncIDReservation.put(newTrip.Trip_ID__c,listOfReservations);
    }

}