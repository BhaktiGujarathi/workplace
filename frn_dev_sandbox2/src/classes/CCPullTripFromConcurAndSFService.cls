public class CCPullTripFromConcurAndSFService {

    public class PullTripResponse {
        public Boolean reSchedulePull;
        public Boolean isSuccess;

        {
            this.isSuccess = true;
            this.reSchedulePull = false;
        }
    }

    public static Date tripSFStartDate = system.today().addDays(Integer.valueOf(system.label.CCtripSFStartDate));
    public static Date tripSFEndDate = system.today().addDays(Integer.valueOf(system.label.CCtripSFEndDate));
    public static Date tripConcurStartDate = system.today().addDays(Integer.valueOf(system.label.CCtripConcurStartDate));
    public static Date tripConncurEndDate = system.today().addDays(Integer.valueOf(system.label.CCtripConncurEndDate));
    public static String pullTripEndpoint = '';

    public static PullTripResponse  fetchTripsAndInsertRecords(String accessToken){
        PullTripResponse pullTripResponse = new PullTripResponse();
        //sudo code
     /*
        1. Hit the trip (Concur System) which were created in past one day and find the newly created Trip.
        2. Logic for newly created trip.
            2.1 Find the existing trip in SF system for last 24 hr where tripID != null---> lets say it as A(sys).
            2.2 Make a callout to concur system and bring the trip of last 24 hous ----> lets say it is B(Concur).
                2.2.1 Get Access Token.And Login to Concur system.
                2.2.2 Callout for trip to get past 24 hrs trip.
            2.3 For finding newly created trip B(Concur) - A(sys) = newly created trip.
            // Do not perform DML on trip but catch it into Map<Trip__ID__c,Trip>. where Trip__ID__c is the trip ID of concur.
        3. Pass this map of trip to reseration Batch.

     */

        // Declaration
        Map<String,Trip__c> mapIdSFTrip = new Map<String,Trip__c>();
        Map<String,Trip__c> mapIdConcurTrip = new Map<String,Trip__c>();
        //2.  Logic for newly created trip.
        //2.1 Find the existing trip in SF system for last 24 hr where tripID != null---> lets say it as A(sys).
        for(Trip__c tripTemp : [SELECT  id,
                                Trip_ID__c,
                                CreatedDate
                            FROM Trip__c
                        WHERE Trip_ID__c != null
                            AND CreatedDate <: tripSFEndDate
                            AND CreatedDate >: tripSFStartDate]
            )
        {
                mapIdSFTrip.put(tripTemp.Trip_ID__c,tripTemp);
        }
        //2.2 Make a callout to concur system and bring the trip of last 24 hous ----> lets say it is B(Concur).
        //2.2.1 Get Access Token. And Login to Concur system.

        //2.2.2 Callout for trip to get past 24 hrs trip.
        //system.debug('https://www.concursolutions.com/api/travel/trip/v1.1?userid_type=login&userid_value=ALL&bookingtype=Air&createdAfterDate='+system.today()+'&createdBeforeDate='+system.today().addDays(1));
        Concur_Integration__c coniTrip = Concur_Integration__c.getInstance('ConcurTravelTrip');
        HttpRequest httpRequestGetTrip = RestUtility.createGetRequest( coniTrip.EndPoint__c,
                                                                        //header
                                                                        new Map<String,String>{
                                                                                            'Authorization' => 'OAuth '+accessToken
                                                                                            },
                                                                        //Params
                                                                        new Map<String,String>{
                                                                                                'userid_type' => 'login',
                                                                                                'userid_value' => 'ALL',
                                                                                                'bookingtype' => 'Air',
                                                                                                'createdAfterDate' => (tripConcurStartDate+'').remove(' 00:00:00'),
                                                                                                'createdBeforeDate' => (tripConncurEndDate+'').remove(' 00:00:00')
                                                                                            }
                                                                    );



        HttpResponse httpResponseTrip;
        try {

            httpResponseTrip = RestUtility.getResponse(httpRequestGetTrip);
            ConcurErrorHandler.ConcurStatusDetails concurStatusDetails = ConcurErrorHandler.getStatusDetails(httpResponseTrip);

            if ( true == concurStatusDetails.isSuccess ) {

                for (Trip__c tripTemp : parseTrip(httpResponseTrip)) {
                    mapIdConcurTrip.put(tripTemp.Trip_ID__c,tripTemp);
                }
                // 2.3 For finding newly created trip B(Concur) - A(sys) = newly created trip.
                system.debug('$$$$$$ mapIdConcurTrip'+mapIdConcurTrip);
                mapIdConcurTrip.keyset().removeAll(mapIdSFTrip.keyset());

                //3. Pass this map of trip to reseration Batch.
                ID jobID = System.enqueueJob(new CCPullReservationConcurQueuebleJob ( mapIdConcurTrip,
                                                                                      accessToken)
                );

            } else {

                throw new ApplicationException('Please review the Status Code: '
                                            +httpResponseTrip.getStatusCode()
                                            +' and Status:'+httpResponseTrip.getStatus());
            }

        } catch (Exception exp){

            pullTripResponse.isSuccess = false;
            pullTripResponse.reSchedulePull = true;

            CCPullTripFromConcurAndSF.lstApxlog.add(
                ApexDebugLog.createLog(
                    new ApexDebugLog.Information(
                         'CCPullTripFromConcurAndSFService'
                        ,'fetchTripsAndInsertRecords'
                        , ConcurErrorHandler.CONCUR_ERROR
                        , exp.getLineNumber()
                        , Datetime.now()
                        , ApexDebugLog.getHttpTransactionLog(httpRequestGetTrip, httpResponseTrip)
                    ).setStackTrace(exp)
                )
            );
        }

        return pullTripResponse;
    }

    public static String loginToConcurSystem() {

        Concur_Integration__c coni = Concur_Integration__c.getInstance('Authorization');
        String username = coni.User_Name__c;
        String password = coni.Password__c;
        String ConsumerKey = coni.Consumer_Key__c;
        String EndPointURl  = coni.EndPoint__c;
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequestAccessToken =  RestUtility.createGetRequest(  EndPointURl,
                                                                             //header
                                                                             new Map<String,String>{
                                                                                                     'Authorization' => authorizationHeader,
                                                                                                     'X-ConsumerKey' => ConsumerKey
                                                                                                   },
                                                                             //Params
                                                                             new Map<String,String>{}
                                                                           );
        HttpResponse httpResponse;

        try{

            httpResponse = RestUtility.getResponse(httpRequestAccessToken);
            ConcurErrorHandler.ConcurStatusDetails concurStatusDetails = ConcurErrorHandler.getStatusDetails(httpResponse);

            if( true == concurStatusDetails.isSuccess ) {
                Dom.Document doc = httpResponse.getBodyDocument();
                //Retrieve the root element for this document.
                Dom.XMLNode root = doc.getRootElement();
                return root.getChildElement('Token', null).getText();

            } else {
                throw new ApplicationException('Retrieving Access Token Failed.');
            }

        } catch(Exception exp){

            CCPullTripFromConcurAndSF.lstApxlog.add(
                ApexDebugLog.createLog(
                    new ApexDebugLog.Information(
                         'CCPullTripFromConcurAndSFService'
                        ,'loginToConcurSystem'
                        , ConcurErrorHandler.CONCUR_ERROR
                        , exp.getLineNumber()
                        , Datetime.now()
                        , ApexDebugLog.getHttpTransactionLog(httpRequestAccessToken, httpResponse)
                    ).setStackTrace(exp)
                )
            );

        }

        return null;
    }


    public static List<Trip__c> parseTrip(HttpResponse httpResponseTrip) {
         List<Trip__c> lstTrip = new List<Trip__c>();
         Dom.Document doc = new Dom.Document();

         CCPullTripFromConcurAndSF.lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullTripFromConcurAndSF','parseTrip','---httpResponseTrip.getBody()----', 134 , system.now(),httpResponseTrip.getBody())));

         doc.load(httpResponseTrip.getBody());
         Dom.XmlNode itineraryInfoListNode = doc.getRootElement();

         for(Dom.XmlNode itineraryInfoNode : itineraryInfoListNode.getChildElements())
         {
            Trip__c trip = new Trip__c();

            for(Dom.XmlNode childNode : itineraryInfoNode.getChildElements())
            {

                String childNodeName = childNode.getName();

                if(childNodeName == 'BookingSource') {
                    trip.Booking_Source__c = childNode.getText();
                }

                if(childNodeName == 'EndDateLocal') {
                    trip.End_Date__c = childNode.getText();
                }

                if(childNodeName == 'StartDateLocal'){
                    trip.Start_Date__c = childNode.getText();
                }

                if(childNodeName == 'TripId'){
                    trip.Trip_ID__c = childNode.getText();
                }

                if(childNodeName == 'TripName'){
                    trip.Trip_Name__c = childNode.getText();
                }

                if(childNodeName == 'id') {
                    trip.ID__c = childNode.getText();
                }

                //Convert the time to time to local user time.
                DateTime deletedat =  ( childNodeName == 'DateModifiedUtc' ?
                                            DateTime.Valueof(childNode.getText().replace('T', ' '))
                                        :
                                            null
                );

                if(deletedat != null) {
                    trip.Modified_Date_Time__c = CCUtility.getCurrentLoggedInUserDateTime(deletedat);
                }

                trip.Trip_Ref__c = trip.Trip_Name__c+system.now().getTime();
                lstTrip.add(trip);

            }

         }


        CCPullTripFromConcurAndSF.lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information(   'CCPullTripFromConcurAndSF'
                                                                            , 'parseTrip'
                                                                            , '---lstTrip----'
                                                                            ,  165
                                                                            , system.now(),lstTrip+'')
                                             )
        );

        return lstTrip;
   }


}