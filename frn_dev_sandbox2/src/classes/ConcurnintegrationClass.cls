public class ConcurnintegrationClass {
  public Map<String,String> eachRecordMap;
  public Map<String,String> eachRecordMap1;
    public List<Map<String,String>> mapTripList;
    public List<Map<String,String>> mapTripList1;
    public List<Trip__c> TripList{get;set;}
    public List<Trip__c> TripList1{get;set;}
    public List<Reservation__c> ResTripList{get;set;}
    public String ErorString{get;set;}
    public string authorizationret;
    public boolean flag;
    public set<string> setTrip;
    public Map<string,string> tripIdMap;
    public Map<string,Trip__c> tripMap;
    public Map<string,string> tripMapCompare;
    public List<Trip__c> TripLisst;
    public Map<String,Integer> reservationCount;
    Private List<string> oppIDList;
    Private  Map<id,Opportunity> oppMap;
    public ConcurnintegrationClass(){
        reservationCount = new Map<String,Integer>();
        setTrip = new set<string>();
        flag= true;
        tripIdMap = new Map<string,string>();
        tripMap = new Map<string,Trip__c>();
        tripMapCompare = new Map<string,string>();
        TripList =  new list<Trip__c>();
        TripList1 =  new list<Trip__c>();
        mapTripList = new List<Map<String,String>>();
        oppIDList = new List<string>();
        oppMap = new  Map<id,Opportunity>();
    }
    
    public String getConcurAuthentication() {
        String username ='';
        String password ='';
        String ConsumerKey ='';
        String EndPointURl ='';
        Concur_Integration__c coni;
        System.debug('flag.... '+flag);
        
            coni = Concur_Integration__c.getInstance('Authorization');
            if( coni!= null){
            username = coni.User_Name__c;
            password = coni.Password__c; 
            ConsumerKey = coni.Consumer_Key__c; 
            EndPointURl  = coni.EndPoint__c;
            }
        if(!flag){
            user u = [select id,Concur_Consumer_Key__c,Concur_Password__c,Concur_Username__c from User where Id=:UserInfo.getUserId() ];
            if( u!= null){
            username = u.Concur_Username__c;
            password = u.Concur_Password__c; 
            ConsumerKey = u.Concur_Consumer_Key__c; 
            flag= true;
            }
        }
        system.debug('username>> '+username+' password>> '+password+' ConsumerKey>>> '+ConsumerKey);
        if(username!= '' && username!= null && password!= '' && password!= null && ConsumerKey!= '' && ConsumerKey!= null){
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +  EncodingUtil.base64Encode(headerValue);
            
            Http http = new Http(); 
            HttpRequest req = new HttpRequest();
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
                String Service = xroot.getChildElement('Token', null).getText();
                system.debug(Service);  
                return Service;
            }else{ 
                return 'Authentication error';
            }
        }
        return null;
    }  
    
    public string getConcurTravalTrip(){
       //authorizationret = '0_nTyZc0KbuxQjLLuZKyLRM9H44=';
       authorizationret = getConcurAuthentication();
        if(authorizationret != null && authorizationret!='Authentication error'){
            Concur_Integration__c coni = Concur_Integration__c.getInstance('ConcurTravelTrip'); 
                HttpRequest req = new HttpRequest();
                req.setEndpoint(coni.EndPoint__c+'?userid_type='+coni.Userid_Type__c +'&userid_value='+coni.Userid_Value__c +'&bookingtype='+coni.Booking_Type__c);
                req.setMethod('GET');  
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
     public void GetUserTrips(){
         flag = false;
        GetTrips();
         
     }
    
    public void GetTrips(){
        TripList =  new list<Trip__c>();
        TripLisst =  new list<Trip__c>();
        TripList1 =  new list<Trip__c>();
        mapTripList = new List<Map<String,String>>();
        tripMapCompare = new Map<string,string>();
        String xmlBody='';
        
        xmlBody = getConcurTravalTrip();
        system.debug('xmlBody>>>> ' +xmlBody);
        if(xmlBody!=null && xmlBody!= ''){ 
        TripLisst = [Select id,Trip_ID__c from Trip__c where Trip_ID__c <> null]; 
            for(Trip__c tr:TripLisst){
                tripMapCompare.put(tr.Trip_ID__c,tr.Id);
            }
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
            createTripRecord(mapTripList);
        }  
    }
      
    public void createTripRecord(List<Map<String,String>> mapTripList){ 
        TripList =  new list<Trip__c>();
        TripList1 =  new list<Trip__c>();
        setTrip = new set<string>();
        tripIdMap = new Map<string,string>();
        tripMap = new Map<string,Trip__c>();
        Map<String,String> ProgramMap = new Map<String,String>();
        Integer index = 1;
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
                string dateTimeInString =  eachMap.get('DateModifiedUtc'); 
                DateTime deletedat = DateTime.Valueof(dateTimeInString.replace('T', ' '));
                trip.Modified_Date_Time__c = getCurrentLoggedInUserDateTime(deletedat); 
                if(!tripMapCompare.containsKey(eachMap.get('TripId'))){
                    TripList1.add(trip);                
                }
                if(index==100){
                    break;
                }else{
                    index+=1;
                }
            }
        } 
        if(TripList1.size()>0){
            insert TripList1;
            for(Trip__c tr:TripList1){
                setTrip.add(tr.Trip_ID__c); 
                tripIdMap.put(tr.Trip_ID__c,tr.id);
                tripMap.put(tr.Trip_ID__c,tr);
            }
             
            ErorString = 'Trip records are created ' ;  
        } else{
            ErorString = 'No new trips found';  
        } 
    }
    
    
    public void ParserTripID(){
        mapTripList1 = new List<Map<String,String>>();
        //system.debug('>>>>'+setTrip.size());
            for(string tp:setTrip){      
                Concur_Integration__c coni = Concur_Integration__c.getInstance('ConcurTravelTrip'); 
                HttpRequest req = new HttpRequest();
                req.setEndpoint(coni.EndPoint__c+'?tripId='+tp);
                req.setMethod('GET');  
                req.setHeader('Authorization', 'OAuth '+authorizationret);  
                req.setTimeout(20000);
                Http http = new Http(); 
                HTTPResponse res = http.send(req);  
                System.debug('BODY: '+res.getBody());  
                System.debug('STATUS:'+res.getStatus()); 
                System.debug('STATUS_CODE:'+res.getStatusCode());
                String xmlBody = res.getBody();
                if(xmlBody!=null){ 
               /* XmlStreamReader reader = new XmlStreamReader(xmlBody); 
                    while(reader.hasNext()){
                        if((reader.getEventType() == XmlTag.START_ELEMENT)&&(reader.getLocalName() == 'Itinerary')){ 
                            reader.next(); 
                            parseNext1(reader);
                        } else {
                            reader.next();
                        }    
                    } 
                    
                    mapTripList1.addAll(parserRes(xmlBody).get('Air'));*/
                    if(parserRes(xmlBody).containsKey('Air')){
                        mapTripList1.addAll(parserRes(xmlBody).get('Air'));
                    }
                } 
            }
            system.debug(mapTripList1.size());
            createTripRecord1(mapTripList1);
    }
    
 

    public void createTripRecord1(List<Map<String,String>> mapTripList){ 
      ResTripList = new List<Reservation__c>(); 
        Map<String,String> ProgramMap = new Map<String,String>();
        Map<Id,Trip__c> updateTriplist= new Map<Id,Trip__c>();
        Trip__c tp;
        if(oppIDList.size()> 0){
            oppmap= new  Map<id,Opportunity>([select Id from Opportunity where ID IN: oppIDList]);
        }
        List<Trip__c> TripToDelete = new List<Trip__c>();
        String descrpOppId = null;
        for(Map<String,String> eachMap : mapTripList){
            if(eachMap.get('Description')!= null && (eachMap.get('Description')).startsWith(Opportunity.sobjecttype.getDescribe().getKeyPrefix()) && String.valueOf(eachMap.get('Description')).length() >= 15){  
            
                descrpOppId = String.valueOf(eachMap.get('Description')).substring(0, 15);
                if(oppmap.containsKey(descrpOppId) && tripIdMap.containsKey(eachMap.get('TripId'))){
                    system.debug('>>>>>'+oppmap.containsKey(eachMap.get('Description')));
                      Reservation__c reser = new Reservation__c();
                      reser.Trip__c = tripIdMap.get(eachMap.get('TripId'));
                    reser.RecordTypeId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId(); 
                    reser.Ticket_Number__c = eachMap.get('PlatingControlNumber');
                    reser.Airline__c = eachMap.get('VendorName'); 
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
                    reser.Total_Amount_Charged__c = (eachMap.containsKey('TotalFare')) ? decimal.valueOf(eachMap.get('TotalFare'))/reservationCount.get(eachMap.get('TripId')) : null;
                    reser.Total_Amount_Charged_Currency__c = eachMap.get('TotalFareCurrency');
                    reser.Rate_Currency__c = eachMap.get('BaseFareCurrency'); 
                    reser.Pickup_Location_Type__c = 'Airport';
                    if(eachMap.get('Description') != null){
                        tp = new Trip__c();
                        tp.Id = tripIdMap.get(eachMap.get('TripId'));
                        if((eachMap.get('Description')).startsWith(Opportunity.sobjecttype.getDescribe().getKeyPrefix()) && oppMap.containsKey(eachMap.get('Description'))){ 
                             tp.Opportunity__c = eachMap.get('Description');
                        } 
                         tp.Description__c = eachMap.get('Description');
                           string dateTimeInStringq =  eachMap.get('DateBookedLocal'); 
                           DateTime deletedat2 = DateTime.Valueof(dateTimeInStringq.replace('T', ' ')); 
                           tp.Created_Date__c = date.valueOf(getCurrentLoggedInUserDateTime(deletedat2)); 
                        updateTriplist.put(tp.Id,tp); 
                        TripList.add(tripMap.get(eachMap.get('TripId')));
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

                insert ResTripList; 
            
            if(updateTriplist.size()>0){
                    Update updateTriplist.values();     
            }
 
            ErorString = 'Reservation records are created ' ;  
        } else{
            ErorString = 'No new trips found';  
        } 
    }
    
        public Map<String, List<Map<string, string>>> parserRes(String res){
        String tripId ='';
        Map<String, List<Map<string, string>>> reservTypeMap = new Map<String, List<Map<string, string>>>();
        Dom.Document docx = new Dom.Document();
        docx.load(res);
        dom.XmlNode xroot = docx.getrootelement() ;

        dom.XmlNode [] xrec = xroot.getchildelements() ; //Get all Record Elements
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
        
        
         if(child.getname() == 'Bookings'){

         //getchildren()
          for (dom.XmlNode bookingNode : child.getchildelements() ) {
              System.debug('bookingNode.getname():::'+ bookingNode.getname());
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
                                    /* for(dom.XmlNode ticketCoupons:quoteChild.getchildren()){
                                        if(ticketCoupons.getname() == 'AirlineTicketCoupons'){
                                            for(dom.XmlNode coupon:ticketCoupons.getchildren()){
                                                if(coupon.getName() == 'AirlineTicketCoupon'){
                                                    //reservationCount.put(tripId,reservationCount.get(tripId)++);
                                                    if(reservationCount.containsKey(tripId)){
                                                        Integer i = reservationCount.get(tripId);
                                                        i +=1;
                                                        reservationCount.put(tripId,i);
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    } */
                                }
                             }
                        }
                    }
                    
                    if(bookChild.getname() == 'Segments'){
                        System.debug('bookChild.getname():::'+ bookChild.getname());
                        for(dom.XmlNode segChild: bookChild.getchildelements()){
                            System.debug('segChild.getname():::'+ segChild.getname());
                            if(segChild.getname() == 'Air'){
                            Map<String, String> airMap = new Map<String, String>();
                            if(reservationCount.containsKey(tripId)){
                                Integer i = reservationCount.get(tripId);
                                i +=1;
                                reservationCount.put(tripId,i);
                            }
                            for(dom.XmlNode airChild: segChild.getchildren()){
                                if(airChild.getname() != null){
                                    airMap.putAll(airFareMap);
                                    airMap.putAll(tripDelMap);
                                    System.debug('airChild.getname():::'+ airChild.getname()+':::::'+ airChild.getname());
                                    airMap.put(airChild.getname(), airChild.getText());
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
        String localtimeinString = dateToConvert.format('MM/dd/yyyy hh:mm a');
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