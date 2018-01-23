public Class CCPullTripFromConcurAndSFClone implements Schedulable
{
   //Constant
    public static Date tripSFStartDate = system.today().addDays(Integer.valueOf(system.label.CCtripSFStartDate));
    public static Date tripSFEndDate = system.today().addDays(Integer.valueOf(system.label.CCtripSFEndDate));
    public static Date tripConcurStartDate = system.today().addDays(Integer.valueOf(system.label.CCtripConcurStartDate));
    public static Date tripConncurEndDate = system.today().addDays(Integer.valueOf(system.label.CCtripConncurEndDate));
    public static String pullTripEndpoint = '';
    public static String accessToken; 
   //Declaration of Variables
    
   //Declaration of collections
   public static List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>(); 
    
   //Declaration of methods  
   @future(callout=true)
   public static void pullTripFromConcurAndSFExecute()
   {
     lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullTripFromConcurAndSF','pullTripFromConcurAndSFExecute','---Entered in pullTripFromConcurAndSFExecute---',18, system.now(), '---Entered in pullTripFromConcurAndSFExecute---')));
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
     
      if(String.isBlank(accessToken))
        accessToken = loginToConcurSystem();
     
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
        HttpResponse httpResponseTrip = RestUtility.getResponse(httpRequestGetTrip);   
        if(httpResponseTrip.getStatusCode() == 200)
        {  
            for(Trip__c tripTemp : parseTrip(httpResponseTrip))
            {
                mapIdConcurTrip.put(tripTemp.Trip_ID__c,tripTemp);
            }
            // 2.3 For finding newly created trip B(Concur) - A(sys) = newly created trip.
            system.debug('$$$$$$ mapIdConcurTrip'+mapIdConcurTrip);
            mapIdConcurTrip.keyset().removeAll(mapIdSFTrip.keyset());
            
            //3. Pass this map of trip to reseration Batch. 
            ID jobID = System.enqueueJob(new CCPullReservationConcurQueuebleJob (mapIdConcurTrip,
                                                                                accessToken));
        
        }
        else
        {



            try{
                throw new ApplicationException('Please review the Status Code: '
                                            +httpResponseTrip.getStatusCode()
                                            +' and Status:'+httpResponseTrip.getStatus());
            }catch(Exception exp){ 

                lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information(   'CCPullTripFromConcurAndSF'
                                                                                ,'pullTripFromConcurAndSFExecute'
                                                                                ,'Failed:Not200:Request'
                                                                                , 94 
                                                                                , Datetime.now()
                                                                                , ApexDebugLog.logHTTPRequest(httpRequestGetTrip)
                                                                                )
                                                    )
                );


                lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information(   'CCPullTripFromConcurAndSF'
                                                                                    ,'pullTripFromConcurAndSFExecute'
                                                                                    ,'Failed:Not200:Response'
                                                                                    , 94 
                                                                                    , Datetime.now()
                                                                                    , ApexDebugLog.logHTTPResponse(httpResponseTrip)
                                                                                 )
                                                     )
                );
                //@TODO Send email to admin
            }
            
        }

        insert CCUtility.cleanNullFrmLst(lstApxlog);
   
   }
   
   
   public static String loginToConcurSystem()
   {
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
        HttpResponse httpResponse = RestUtility.getResponse(httpRequestAccessToken);
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullTripFromConcurAndSF','loginToConcurSystem','---httpResponse.getStatusCode()----', 117 , system.now(),httpResponse.getStatusCode()+'')));
        if(httpResponse.getStatusCode() == 200)
        {
            Dom.Document doc = httpResponse.getBodyDocument();
            //Retrieve the root element for this document.
            Dom.XMLNode root = doc.getRootElement();
            return root.getChildElement('Token', null).getText();
        
        }
      
      
        return null;  
   }
   
   public static List<Trip__c> parseTrip(HttpResponse httpResponseTrip)
   {
         List<Trip__c> lstTrip = new List<Trip__c>();
         Dom.Document doc = new Dom.Document();
         lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullTripFromConcurAndSF','parseTrip','---httpResponseTrip.getBody()----', 134 , system.now(),httpResponseTrip.getBody())));
         doc.load(httpResponseTrip.getBody());
         Dom.XmlNode itineraryInfoListNode = doc.getRootElement();
         
         for(Dom.XmlNode itineraryInfoNode : itineraryInfoListNode.getChildElements()) 
         {
            Trip__c trip = new Trip__c();
            for(Dom.XmlNode childNode : itineraryInfoNode.getChildElements()) 
            {
                
                String childNodeName = childNode.getName();
                if(childNodeName == 'BookingSource'){ trip.Booking_Source__c = childNode.getText(); }
                if(childNodeName == 'EndDateLocal'){ trip.End_Date__c = childNode.getText(); }
                if(childNodeName == 'StartDateLocal'){trip.Start_Date__c = childNode.getText();}
                if(childNodeName == 'TripId'){trip.Trip_ID__c = childNode.getText();}
                if(childNodeName == 'TripName'){trip.Trip_Name__c = childNode.getText();}
                if(childNodeName == 'id'){trip.ID__c = childNode.getText();}
                //Convert the time to time to local user time.
                DateTime deletedat =  ( childNodeName == 'DateModifiedUtc' ? DateTime.Valueof(childNode.getText().replace('T', ' ')) : null);
                if(deletedat != null){ trip.Modified_Date_Time__c = getCurrentLoggedInUserDateTime(deletedat);  }
                trip.Trip_Ref__c = trip.Trip_Name__c+system.now().getTime();
                lstTrip.add(trip);
                
            }
           
         }
         lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('CCPullTripFromConcurAndSF','parseTrip','---lstTrip----', 165 , system.now(),lstTrip+'')));
         return lstTrip;
   }
   
   
   public static  Datetime getCurrentLoggedInUserDateTime(Datetime dateToConvert){
        String localtimeinString = dateToConvert.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
        String[] dtTime = localtimeinString.split(' ');  
        Date crntdate = Date.parse(dtTime[0]);
        System.debug('parse ::>'+crntdate);  
      
        String timeInString = dtTime[1]+' '+dtTime[2];
        return getDateTimeFromIntervals(crntdate,timeInString);
    }
      
    public static DateTime getDateTimeFromIntervals(date dateFromDayOption, string timeInternal){
        system.debug('==Date==: ' + dateFromDayOption + '==Time Interval==: ' + timeInternal);
        integer hours,minutes;
        
        List<string> intervals = timeInternal.split(' ');
        if(intervals[1] == 'AM'){
            List<string> lstTimings = intervals[0].split(':');
            if(lstTimings[0] == '12')
                hours = 0;
            else
                hours = integer.valueOf(lstTimings[0]);
            
            minutes = integer.valueOf(lstTimings[1]);
        }else if(intervals[1] == 'PM'){
            List<string> lstTimings = intervals[0].split(':');
            if(lstTimings[0] == '12')
                hours = integer.valueOf(lstTimings[0]);
            else
                hours = integer.valueOf(lstTimings[0]) + 12;
                
            minutes = integer.valueOf(lstTimings[1]);
        }
        
        Time tm = Time.newInstance(hours, minutes, 0, 0);
        system.debug('==Hours==: ' + hours + ' ==Minutes==: ' + minutes + ' ==Time==: ' + tm);
        
        DateTime dateTimeToReturn = dateFromDayOption;
        dateTimeToReturn = dateTimeToReturn.addHours(hours);
        dateTimeToReturn = dateTimeToReturn.addMinutes(minutes);
        dateTimeToReturn = dateTimeToReturn.addSeconds(0);
        return dateTimeToReturn;
    }
    
     /*
        Schedulable_Batch_Context
     */ 
     public void execute(SchedulableContext ctx) 
     {
       // CCPullTripFromConcurAndSF a = new CCPullTripFromConcurAndSF();
        CCPullTripFromConcurAndSF.pullTripFromConcurAndSFExecute();
        
     }
    
   
   // Declaration of wrapper class

}