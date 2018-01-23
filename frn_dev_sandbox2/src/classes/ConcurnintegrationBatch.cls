global class ConcurnintegrationBatch implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts 
{
    global List<Map<String,String>> mapTripList;  
    global Map<String,String> eachRecordMap;
    global List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>(); 
    Private Map<String,String> tripIdMap;
    global string authorizationret; 
    global ConcurnintegrationClass concu = new ConcurnintegrationClass(); 

    global ConcurnintegrationBatch(){
        tripIdMap = new Map<String,String>();
        
    }
    
    global Database.querylocator start(Database.BatchableContext BC){ 
       lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Start','---Start----', 16 , system.now(),'---Start----')));
       string query = 'Select id from User limit 1'; 
       return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<user> u){ 
    try{
      System.debug('Entered 1st batch.....>>>>>');
      Map<string,string> tripMapCompare = new Map<string,string>();
      List<Trip__c> TripLisst = new List<Trip__c>();
      TripLisst = [Select id,Trip_ID__c from Trip__c where Trip_ID__c <> null]; 
      for(Trip__c tr:TripLisst){
          tripMapCompare.put(tr.Trip_ID__c,tr.Id);
        }
     
      mapTripList = new List<Map<String,String>>();
      List<Trip__c> TripList =new list<Trip__c>();
      String xmlBody =  getConcurTravalTrip();
         
      if(xmlBody!=null){     
        XmlStreamReader reader = new XmlStreamReader(xmlBody); 
        while(reader.hasNext()){
          if((reader.getEventType() == XmlTag.START_ELEMENT)&&(reader.getLocalName() == 'ItineraryInfo')){ 
            reader.next(); 
            parseNext(reader);
          } else {
            reader.next();
          }    
        }
        system.debug(mapTripList.size());
        system.debug(mapTripList);
        Integer count =1;
        for(Map<String,String> eachMap : mapTripList){
          if(!tripMapCompare.containsKey(eachMap.get('TripId'))){
            Trip__c trip = new Trip__c();
            trip.Booking_Source__c = eachMap.get('BookingSource');
            trip.Trip_ID__c = eachMap.get('TripId');
            trip.Trip_Name__c = eachMap.get('TripName');
            trip.ID__c = eachMap.get('id'); 
            trip.Record_Locator__c =  eachMap.get('RecordLocator');
            trip.Start_Date__c =  eachMap.get('StartDateLocal');
            trip.End_Date__c =  eachMap.get('EndDateLocal'); 
            //trip.Opportunity__c = eachMap.get('Description');
            string dateTimeInString =  eachMap.get('DateModifiedUtc'); 
            DateTime deletedat = DateTime.Valueof(dateTimeInString.replace('T', ' '));
            trip.Modified_Date_Time__c = getCurrentLoggedInUserDateTime(deletedat); 
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Excut' ,trip.name, 63 , system.now(), 'trip.name'+trip.name)));
            TripList.add(trip);                
            System.debug('TripList.....>>>>>'+TripList.size());
            System.debug('TripList.....>>>>>'+TripList);
            if(count==100){
            break;
            }
            count++;
          }
        } 
      }  
      if(TripList.size()>0){
        System.debug('TripList.....>>>>>'+TripList);
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Excut' ,TripList+'', 76 , system.now(), '>>>TripList in Excute '+TripList.size()+'')));
        insert TripList;
        System.debug('TripList.....>>>>>'+TripList);
        for(Trip__c tr:TripList){ 
          tripIdMap.put(tr.Trip_ID__c,tr.id);
        }
      }
    }
    catch(Exception e)
    {
         System.debug('Exception>>>>'+e.getmessage());
         lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Error('ConcurnintegrationBatch','Excut' ,' In Exception', 87 , system.now(), e)));
    }
           
    }

    global void finish(Database.BatchableContext BC)
    {
       System.debug('tripIdMap111>>>>'+tripIdMap);
       String authKey = '';
       try
       {
        authKey = getConcurAuthentication();
       }
       catch(Exception e)
       {
         authKey = '';
         System.debug('Exception>>>>'+e.getmessage());
         lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Error('ConcurnintegrationBatch','Finish' , 'In Exception', 104 , system.now(), e)));
         
       }
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Finish' ,tripIdMap+'', 107 , system.now(), '>>>tripIdMap in finish'+tripIdMap+'')));
            ConcurnintegrationForReservBatch conInt1 = new ConcurnintegrationForReservBatch(tripIdMap,authKey);
            if(!Test.isRunningTest())
            {
                Database.executeBatch(conInt1,10);
            }
            
            
             Insert lstApxlog;
           
    }

    
    public String getConcurAuthentication() 
    {
        String username ='';
        String password ='';
        String ConsumerKey =''; 
        Concur_Integration__c coni = Concur_Integration__c.getInstance('Authorization');
        username = coni.User_Name__c;
        password = coni.Password__c; 
        ConsumerKey = coni.Consumer_Key__c; 
        String EndPointURl  = coni.EndPoint__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +  EncodingUtil.base64Encode(headerValue);
            
        Http http = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(EndPointURl);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('X-ConsumerKey', ConsumerKey);
        HttpResponse res = http.send(req);
        
        System.debug('BODY: '+res.getBody());  
        System.debug('STATUS:'+res.getStatus()); 
        System.debug('STATUS_CODE:'+res.getStatusCode());
        if(res.getStatusCode() == 200){
            Dom.Document docx = new Dom.Document();
            docx.load(res.getBody()); 
            dom.XmlNode xroot = docx.getrootelement() ;
            System.debug('xroot.getChildElement ::>'+xroot.getChildElement('Token', null));
            String Service = xroot.getChildElement('Token', null).getText();
            system.debug(Service);  
            return Service;
        } else { 
            return 'Authentication error';
        }
        return null;
    }  
    
    public string getConcurTravalTrip(){
       //authorizationret = '0_nTyZc0KbuxQjLLuZKyLRM9H44=';
       authorizationret = getConcurAuthentication();
        if(authorizationret != null && authorizationret!='Authentication error'){
            Concur_Integration__c coni = Concur_Integration__c.getInstance('ConcurTravelTrip'); 
                HttpRequest req = new HttpRequest();
                //req.setEndpoint(coni.EndPoint__c+'?userid_type='+coni.Userid_Type__c +'&userid_value='+coni.Userid_Value__c +'&bookingtype='+coni.Booking_Type__c);
                req.setEndpoint(coni.EndPoint__c+'?userid_type='+coni.Userid_Type__c +'&userid_value='+coni.Userid_Value__c +'&bookingtype='+coni.Booking_Type__c+'&createdAfterDate='+(system.today().addDays(-7)+'').remove(' 00:00:00')+'&createdBeforeDate='+(system.today().addDays(1)+'').remove(' 00:00:00'));
                req.setMethod('GET');  
        req.setTimeout(120000);
                req.setHeader('Authorization', 'OAuth '+authorizationret);    
        Http http = new Http(); 
                HTTPResponse res = http.send(req);  
                System.debug('BODY: '+res.getBody());  
                System.debug('STATUS:'+res.getStatus()); 
                System.debug('STATUS_CODE:'+res.getStatusCode());
            return res.getBody();
        } else{
            return null;
        }
            return null;
    }
    
    public void parseNext(XmlStreamReader Par){
    eachRecordMap = new Map<String,String>();
    String mapKey;
    String mapVal;
    while(Par.hasNext()){
    if((Par.getEventType() == XmlTag.END_ELEMENT)&&(Par.getLocalName() == 'ItineraryInfo')){
        break;
    } else {
    if(Par.getEventType() == XmlTag.START_ELEMENT){ 
        mapKey = Par.getLocalName();
        while(Par.getEventType() != XmlTag.END_ELEMENT){
            
            if(Par.getEventType() == XmlTag.CHARACTERS){ 
                if(Par.hasText()){
                   
                    mapVal = Par.getText();
                    Par.next();
                }
                } else {
                    Par.next();
                }
            }

        } else {
                Par.next();   
            } 
        }
        if(mapKey != null && mapKey != '' && mapKey != 'null'){
            eachRecordMap.put(mapKey,mapVal);
        }
            mapKey = '';
            mapVal = '';
        }
        System.debug(eachRecordMap.size());
        mapTripList.add(eachRecordMap);
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
        
        system.debug('==Date time from Hours and minutes==: ' + dateTimeToReturn);
        
        return dateTimeToReturn;
    }
    
        /*
Schedulable_Batch_Context
     */ 

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ConcurnintegrationBatch());
       
    }
   
}