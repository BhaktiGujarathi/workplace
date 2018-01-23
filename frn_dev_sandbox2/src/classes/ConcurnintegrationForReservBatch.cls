global class ConcurnintegrationForReservBatch implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts 
{

    global Map<String,String> eachRecordMap1;
    global List<Map<String,String>> mapTripList1;
    global List<Reservation__c> ResTripList;
    global Map<string,string> tripIdMap;
    global List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>();
    //global set<string> setTrip;
    global string authorizationret; 
    public Map<String,Integer> reservationCount = new Map<String,Integer>();
    private Map<string,string> tripDetailsMap;
    Private List<string> oppIDList;
    Private  Map<id,Opportunity> oppMap;
    
    global ConcurnintegrationForReservBatch( Map<string,string> tripIdMap,String oAuthToken)
    {
        system.debug('tripIdMap>>>>'+tripIdMap);
        system.debug('>>>'+oAuthToken);
        this.tripIdMap = tripIdMap;
        authorizationret = oAuthToken;
        oppIDList = new List<string>();
        oppMap = new  Map<id,Opportunity>();
        //lstApxlog = new List<Apex_Debug_Log__c>();
    }
    
    global Database.querylocator start(Database.BatchableContext BC)
    {   lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Start' ,'---Start--', 28 , system.now(), '---Start--')));
        System.debug('tripIdMap.keyset()'+tripIdMap.keyset());
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Start' ,tripIdMap+'', 30 , system.now(), '>>>tripIdMap in constructor'+tripIdMap+'')));
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Start' ,tripIdMap+'', 31 , system.now(), '>>>List of Trip__c in 2nd batch'+[Select id,Trip_ID__c from Trip__c where Trip_ID__c IN: tripIdMap.keyset()]+'')));
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Start' ,tripIdMap+'', 32 , system.now(), '>>>Size of Trip__c in 2nd batch'+[Select id,Trip_ID__c from Trip__c where Trip_ID__c IN: tripIdMap.keyset()].size()+'')));    
        return Database.getQueryLocator([Select id,Trip_ID__c from Trip__c where Trip_ID__c IN: tripIdMap.keyset()]);
        
    }

    global void execute(Database.BatchableContext BC, List<Trip__c> TripLisst)
    {
         try{
        
            set<string> setTrip = new set<string>();
        
            mapTripList1 = new List<Map<String,String>>();
            System.debug('tripIdMap>>>>'+tripIdMap);
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Exceute' ,tripIdMap+'', 45 , system.now(), '>>>tripIdMap in Execute'+tripIdMap+'')));
                 
             if(tripIdMap.size()>0){
                System.debug('TripList.....>>>>>'+tripIdMap);
                for(Trip__c t: TripLisst){
                    if(t.Trip_ID__c != null)
                    setTrip.add(t.Trip_ID__c);
                }
               // setTrip.addall(tripIdMap.keyset());
                  ParserTripID(setTrip);         
            }
        }catch(Exception e){
               System.debug('Exception>>>>'+e.getmessage());
               lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Error('ConcurnintegrationForReservBatch','Exectute' , 'in Exception', 58 , system.now(), e)));
        } 
               
    }

    global void finish(Database.BatchableContext BC)
    {
        Integer timeInterval;
        try{
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','Finish' ,tripIdMap+'', 67 , system.now(), '>>>tripIdMap in Execute'+tripIdMap+'')));
             
            
         Concur_Batch_Frequency__c intervalInMin = Concur_Batch_Frequency__c.getValues('FrequncyInMin');
         timeInterval = integer.valueOf(intervalInMin.Time_interval_In_Minutes__c);
         }
         catch(Exception e)
         {
            timeInterval = 5;
            System.debug('Exception>>>>'+e.getmessage());
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Error('ConcurnintegrationForReservBatch','Finish' , 'RecordId', 77 , system.now(), e)));
            
        
         }
            DateTime now  = System.now();
            DateTime nextRunTime = now.addMinutes(timeInterval);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year();     
            insert lstApxlog; 
               
            System.schedule(ConcurnintegrationBatch.class.getName() + '-' + now.format(), cronString, new ConcurnintegrationBatch()); 
    }
    
    
    
        /*
Schedulable_Batch_Context
     */ 
    public void execute(SchedulableContext ctx) {
        //Database.executeBatch(new ConcurnintegrationBatch());
        
    }
    

    public void ParserTripID(set<string> setTrip1){
        mapTripList1 = new List<Map<String,String>>();
        system.debug('>>>>'+setTrip1.size());
            Integer i =0;
            for(string tp:setTrip1){      
                Concur_Integration__c coni = Concur_Integration__c.getInstance('ConcurTravelTrip'); 
                HttpRequest req = new HttpRequest();
                req.setEndpoint(coni.EndPoint__c+'?tripId='+tp);
                req.setMethod('GET');  
                req.setHeader('Authorization', 'OAuth '+authorizationret); 
                req.setTimeout(120000);   
                Http http = new Http(); 
                
                HTTPResponse res = http.send(req);  
                lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','ParserTripID',tp+'', 115 , system.now(), '>>>reservation response body in Execute'+res.getBody()+'')));
                System.debug('BODY: '+res.getBody());  
                System.debug('STATUS:'+res.getStatus()); 
                System.debug('STATUS_CODE:'+res.getStatusCode());
                String xmlBody = res.getBody();
                if(xmlBody!=null){ 
           
                  lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','ParserTripID',tp+'', 123 , system.now(), '>>>checking Air Node'+parserRes(xmlBody).containsKey('Air')+'')));      
                    if(parserRes(xmlBody).containsKey('Air')){
                        mapTripList1.addAll(parserRes(xmlBody).get('Air'));
                    }
                    
            } 
        i++;
        if(i>98){
            break;
        }           
        }
        system.debug(mapTripList1);     
        system.debug(mapTripList1.size());
        createTripRecord1(mapTripList1);
    }
    
 

    public void createTripRecord1(List<Map<String,String>> mapTripList){ 
      ResTripList = new List<Reservation__c>(); 
        Map<String,String> ProgramMap = new Map<String,String>();
        Map<Id,Trip__c> updateTriplist= new Map<Id,Trip__c>();
        Trip__c tp;
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','createTripRecord1',tp+'', 146 , system.now(), '>>>oppIDList'+oppIDList+'')));      
        if(oppIDList.size()> 0)
        {
           oppmap = new  Map<id,Opportunity>([select Id from Opportunity where ID IN: oppIDList]);
           lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','createTripRecord1',tp+'', 150 , system.now(), '>>>oppIDList'+oppIDList+'')));
        }
        
        List<Trip__c> TripToDelete = new List<Trip__c>();
        String descrpOppId = null;
        for(Map<String,String> eachMap : mapTripList){
            if(eachMap.get('Description')!= null && (eachMap.get('Description')).startsWith(Opportunity.sobjecttype.getDescribe().getKeyPrefix())&& String.valueOf(eachMap.get('Description')).length() >= 15){  
   
                descrpOppId = String.valueOf(eachMap.get('Description')).substring(0, 15);
                if(oppmap.containsKey(descrpOppId) && tripIdMap.containsKey(eachMap.get('TripId'))){
                    System.debug('eachMap ::>'+eachMap);
                    Reservation__c reser = new Reservation__c();
                    reser.Trip__c = tripIdMap.get(eachMap.get('TripId'));
                    reser.RecordTypeId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId(); 
                    reser.Ticket_Number__c = eachMap.get('PlatingControlNumber');
                    reser.Airline__c = eachMap.get('VendorName');
                    system.debug('>>>>>>'+eachMap.get('ClassOfService'));
                    reser.Cabin__c = eachMap.get('ClassOfService');
                    reser.Confirmation_Number__c = eachMap.get('ConfirmationNumber');
                    if(eachMap.get('FlightNumber').length()<= 8){
                        reser.Flight_Number__c = eachMap.get('FlightNumber'); 
                    }
                   // reser.Flight_Number__c = eachMap.get('FlightNumber'); 
                    reser.Status__c = eachMap.get('Status');
                    reser.Seat_Assignment__c = eachMap.get('SeatNumber');
                    string dateTimeInString =  eachMap.get('StartDateLocal'); 
                    DateTime deletedat = DateTime.Valueof(dateTimeInString.replace('T', ' '));
                    reser.Departure_Date_Time__c = deletedat.format('MM/dd/yyyy hh:mm a'); 
                    string dateTimeInString1 =  eachMap.get('EndDateLocal'); 
                    DateTime deletedat1 = DateTime.Valueof(dateTimeInString1.replace('T', ' '));
                    reser.Departure_Airport__c = eachMap.get('StartCityCode');
                    reser.Arrival_Date_Time__c = deletedat1.format('MM/dd/yyyy hh:mm a');
                    reser.Arrival_Airport__c = eachMap.get('EndCityCode');
                    reser.Total_Amount_Charged__c = (eachMap.containsKey('TotalFare')) ? decimal.valueOf(eachMap.get('TotalFare'))/reservationCount.get(eachMap.get('TripId'))  : null;
                    reser.Total_Amount_Charged_Currency__c = eachMap.get('TotalFareCurrency');
                    reser.Rate_Currency__c = eachMap.get('BaseFareCurrency'); 
                    reser.Pickup_Location_Type__c = 'Airport';
                    if(eachMap.get('Description') != null){
                        tp = new Trip__c();
                        system.debug('>>>>>>'+tripIdMap);
                        system.debug('>>>>>>'+eachMap);
                        tp.Id = tripIdMap.get(eachMap.get('TripId'));
                        if((eachMap.get('Description')).startsWith(Opportunity.sobjecttype.getDescribe().getKeyPrefix())){ 
                            tp.Opportunity__c = eachMap.get('Description');
                        } else {
                            tp.Description__c = eachMap.get('Description');
                        } 
                        string dateTimeInStringq =  eachMap.get('DateBookedLocal'); 
                        DateTime deletedat2 = DateTime.Valueof(dateTimeInStringq.replace('T', ' ')); 
                        tp.Created_Date__c = date.valueOf(getCurrentLoggedInUserDateTime(deletedat2)); 
                        system.debug('>>>>>'+tp);
                        updateTriplist.put(tp.Id,tp); 
                        system.debug(updateTriplist.size());
                    } 
                    ResTripList.add(reser); 
                }else{
                    tp = new Trip__c();
                    tp.Id = tripIdMap.get(eachMap.get('TripId'));
                    TripToDelete.add(tp);
                }
            }else{
                    tp = new Trip__c();
                    tp.Id = tripIdMap.get(eachMap.get('TripId'));
                    TripToDelete.add(tp);
            }
        } 
        if(ResTripList.size()>0){
              
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','createTripRecord1','', 218 , system.now(), '>>>ResTripList'+ResTripList+'')));
            insert ResTripList; 
            if(updateTriplist.size()>0)
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationForReservBatch','createTripRecord1','', 221 , system.now(), '>>>TRIP to updateTriplist'+updateTriplist.values()+'')));
            Update updateTriplist.values(); 
            
        } if(TripToDelete.size()>0){}
            
        
    }
    public Map<String, List<Map<string, string>>> parserRes(String res){
        String tripId ='';
        Map<String, List<Map<string, string>>> reservTypeMap = new Map<String, List<Map<string, string>>>();
        Dom.Document docx = new Dom.Document();
        docx.load(res);
        dom.XmlNode xroot = docx.getrootelement() ;

        dom.XmlNode [] xrec = xroot.getchildelements() ; //Get all Record Elements
        tripDetailsMap = new Map<string,string>();
        Map<String, String> tripDelMap = new Map<String, String>();
        for(Dom.XMLNode child : xrec) //Loop Through Records
        {
        
         
        if(child.getname() == 'TripId'){
            tripDelMap.put(child.getname(), child.getText());
            reservationCount.put(child.getText(),0);
            tripId = child.getText();
        }
        if(child.getname() == 'DateBookedLocal'){
            tripDelMap.put(child.getname(), child.getText());
        }
        if(child.getname() == 'Description'){
            tripDelMap.put(child.getname(), child.getText());
              if(child.getText() != null && child.getText() != ''){
                oppIDList.add(child.getText());
               }
        }
         //tripDetailsMap.put(child.getname(), child.getText());
         if(child.getname() == 'Bookings'){

         //getchildren()
          for (dom.XmlNode bookingNode : child.getchildelements() ) {             
              Map<String, String> airFareMap = new Map<String, String>();
              for(dom.XmlNode bookChild: bookingNode.getchildelements()){
                                    
                    if(bookChild.getname() == 'AirfareQuotes'){
                        for(dom.XmlNode airFareChild: bookChild.getchildelements()){
                             if(airFareChild.getname() == 'Quote'){
                                for(dom.XmlNode quoteChild: airFareChild.getchildren()){
                                    airFareMap.put(quoteChild.getName(), quoteChild.getText());
                                }
                             }
                        }
                    }                   
                    
                    if(bookChild.getname() == 'AirlineTickets'){                        
                        for(dom.XmlNode airFareChild: bookChild.getchildelements()){                            
                            if(airFareChild.getname() == 'AirlineTicket'){
                                for(dom.XmlNode quoteChild: airFareChild.getchildren()){
                                    airFareMap.put(quoteChild.getName(), quoteChild.getText());
                                }
                             }
                        }
                    }
                    
                    if(bookChild.getname() == 'Segments'){
                        System.debug('bookChild.getname():::'+ bookChild.getname());
                        for(dom.XmlNode segChild: bookChild.getchildelements()){
                            System.debug('segChild.getname():::'+ segChild.getname());
                            if(segChild.getname() == 'Air'){
                            if(reservationCount.containsKey(tripId)){
                                Integer i = reservationCount.get(tripId);
                                i +=1;
                                reservationCount.put(tripId,i);
                            }
                            Map<String, String> airMap = new Map<String, String>();
                            
                            for(dom.XmlNode airChild: segChild.getchildren()){
                                if(airChild.getname() != null){
                                    System.debug('airFareMap:::'+ airFareMap);
                                    System.debug('tripDelMap:::'+ tripDelMap);
                                    airMap.putAll(airFareMap);
                                    airMap.putAll(tripDelMap);
                                    System.debug('airMap:::'+ airMap);
                                    System.debug('airChild.getname():::'+ airChild.getname()+':::::'+ airChild.getText());
                                    airMap.put(airChild.getname(), airChild.getText());
                                    System.debug('airMap:::'+ airMap);
                                    System.debug('airChild.getname():::'+ airMap.get(airChild.getname()));
                                    System.debug('airChild.getname():::'+ airChild.getname()+':::::'+ airChild.getText());
                                    if(airChild.getname() == 'Seats'){
                                        for(dom.XmlNode seatsChild: airChild.getchildren()){
                                        //airChild.getChildElement('AirSeat', null).getChildElement('SeatNumber', null).gettext();
                                            for(dom.XmlNode airSeatChild: seatsChild.getchildren()){
                                                airMap.put(airSeatChild.getname(), airSeatChild.getText());
                                            }
                                        }
                                    }
                                }
                                
                            }
                                // insert map with air and values
                                if(reservTypeMap.containsKey('Air')){
                                    reservTypeMap.get('Air').add(airMap);
                                }else{
                                    List<Map<string, string>> aListMap = new List<Map<string, string>>();
                                    aListMap.add(airMap);
                                    reservTypeMap.put('Air',aListMap);
                                }
                            }
                        }
                        //dom.XmlNode[] segNode11=  bookChild.getChildElement('Segments', null).getChildElement('Air', null).getchildren();
                   }
              }
             
         }

        }
        
      }
      System.debug('reservTypeMap::'+reservTypeMap);
      return reservTypeMap;
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
   
}