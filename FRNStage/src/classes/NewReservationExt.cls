public class NewReservationExt{
    
    public Reservation__c reservObj{get;set;}
    public String reservationId;
    public String recTypeName{get;set;}
    public RecordType recType;
    public String rsvRecType;
    public String getRetURL;
    public String parentID;
    public String tripPrefix;
    public String reservationPrefix;
    public boolean showAirport{get;set;}
    public boolean showStreet{get;set;}
    public boolean showFRN{get;set;}
    public boolean isTripNull {get;set;}
    public boolean isNewRecord {get;set;} 

    public NewReservationExt(ApexPages.StandardController controller) {
        showAirport = false;
        showStreet = false;
        showFRN = false;    
        isNewRecord = true;    
        recTypeName = '';
        reservObj = new Reservation__c();
            
        reservationId = ApexPages.CurrentPage().getparameters().get('id'); 
        rsvRecType = ApexPages.currentPage().getParameters().get('RecordType'); 
        getRetURL = apexpages.currentPage().getParameters().get('retURL');       
        System.debug('rsvRecType________________ '+rsvRecType);
        System.debug('reservationId________________ '+reservationId);
        System.debug('retURL________________ '+getRetURL);

        /***autoPopulate_Trip */        
        String[] s;         
        if(getretURL != null && getretURL.length()>14){
                    s = getretURL.split('/');
                    getretURL=s[1];
        }
        System.debug('ssssssssssss___________________________'+s);
        tripPrefix = Trip__c.sObjectType.getDescribe().getKeyPrefix();
        reservationPrefix = Reservation__c.sObjectType.getDescribe().getKeyPrefix();
        
        if(getretURL!= null && getretURL.length()>14 && getretURL.startsWith(tripPrefix)){
            reservObj.Trip__c = getretURL;
            System.debug('reservObj.Trip___________________________'+reservObj.Trip__c);
        
        } 

        if(rsvRecType != null){
            recType = [SELECT Id,IsActive,Name,SobjectType FROM RecordType WHERE Id =: rsvRecType AND SobjectType = 'Reservation__c' AND IsActive = true];          
            recTypeName = recType.Name;
            System.debug('recTypeName________________ '+recTypeName);               
        }   
    
        if(reservationId !=null && reservationId != ''){
            reservObj = [SELECT Id, RecordTypeId, RecordType.Name, Trip__c,Trip__r.Name, Ticket_Number__c, Airline__c, Confirmation_Number__c, Flight_Number__c, Cabin__c, Status__c, Seat_Assignment__c, Additional_Details__c, Info_Warnings__c, Departure_Date_Time__c, Departure_Airport__c, Arrival_Date_Time__c, Arrival_Airport__c, Total_Amount_Charged__c, Car_Service_Company_Name__c, Car_Service_Company_Phone__c, Pickup_Date_Time__c, Pickup_Address__c, Pickup_City__c, Pickup_Location_Type__c, Pickup_State_Province_Region__c, Pickup_Airport__c, Pickup_Zip_Postal_Code__c, Pickup_FRN_Facility__c, Pickup_Country__c, Drop_Off_Date_Time__c, Drop_off_Address__c, Drop_off_at_same_location_as_Pickup__c, Drop_off_City__c, Drop_off_Location_Type__c, Drop_off_Zip_Postal_Code__c, Drop_off_Airport__c, Drop_off_State_Province_Region__c, Drop_off_FRN_Facility__c, Drop_off_Country__c, Rate__c  FROM Reservation__c WHERE Id =: reservationId];
            recTypeName = reservObj.RecordType.Name;
            isNewRecord = false;
            System.debug('reservObj________________ '+reservObj);   
            System.debug('recTypeName________________ '+recTypeName);   
        }   
    }
    
    public PageReference save(){
        if(reservObj.Trip__c==null){
            isTripNull = true;
            return null;
        }           
        if(reservObj != null){
            System.debug('reservObj________________ '+reservObj);           
            clearOtherRtValues();
            System.debug('reservObj.RecordTypeId____________________ '+rsvRecType); 
            System.debug('reservObj.RecordTypeId____________________ '+reservObj.RecordTypeId); 
            if(reservObj.RecordTypeId==null){
                reservObj.RecordTypeId = rsvRecType;                
            }           
                Upsert reservObj;
                System.debug('reservObj________________ '+reservObj);               
            return new PageReference('/'+reservObj.Id); 
        }
        return null;  
    }  
    
    public PageReference cancel(){
        PageReference page;
        System.debug('getRetURL ::>'+getRetURL);
        if(getretURL!= null && getretURL!=''){
            page = new PageReference('/'+getRetURL);            
        } else {
            page = new PageReference('/'+Reservation__c.sObjectType.getDescribe().getKeyPrefix()+'/o');
        }
        page.setRedirect(true);
        return page; 
    }   
    
    public PageReference saveandnew(){              
        if(reservObj.Trip__c==null){
            isTripNull = true;
            return null;
        }   
        if(reservObj != null){
            System.debug('New_Button'); 
            clearOtherRtValues();
            if(reservObj.RecordTypeId==null)
                reservObj.RecordTypeId = rsvRecType;
                Upsert reservObj;
                isNewRecord = true;
                System.debug('reservObj________________ '+reservObj);                           
                Pagereference pg = new PageReference('/apex/NewReservationPage?RecordType='+reservObj.RecordTypeId+'&retURL='+reservObj.id);
                reservObj = new Reservation__c();
                if(getretURL!= null && getretURL.length()>14 && getretURL.startsWith(tripPrefix)){
                    reservObj.Trip__c = getretURL;
                    System.debug('reservObj.Trip___________________________'+reservObj.Trip__c);        
                } 

                if(getretURL.startsWith(reservationPrefix)){
                    pg.setRedirect(true);     
                }                          
                return pg;  
            
        }
        return null;
    }
    
    /***CopyPickupAddress */
    public PageReference CopyPickupAddress(){
        System.debug('Pickup_Location_Type____________________________ '+reservObj.Pickup_Location_Type__c);
        System.debug('Drop_off_at_same_location_as_Pickup____________________________ '+reservObj.Drop_off_at_same_location_as_Pickup__c);
        
        if(reservObj.Drop_off_at_same_location_as_Pickup__c == true && reservObj.Pickup_Location_Type__c != null){  
            reservObj.Drop_off_Location_Type__c = reservObj.Pickup_Location_Type__c;    
            System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Location_Type__c);
            if(reservObj.Pickup_Location_Type__c == 'Airport'){
                reservObj.Drop_off_Airport__c = reservObj.Pickup_Airport__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            } 
            if(reservObj.Drop_off_Location_Type__c=='FRN Facility'){
                reservObj.Drop_off_FRN_Facility__c = reservObj.Pickup_FRN_Facility__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            }  
            if(reservObj.Drop_off_Location_Type__c== 'Street Address'){
                reservObj.Drop_off_Address__c = reservObj.Pickup_Address__c;
                reservObj.Drop_off_City__c = reservObj.Pickup_City__c;
                reservObj.Drop_off_State_Province_Region__c = reservObj.Pickup_State_Province_Region__c;
                reservObj.Drop_off_Zip_Postal_Code__c = reservObj.Pickup_Zip_Postal_Code__c;
                reservObj.Drop_off_Country__c = reservObj.Pickup_Country__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            }         
        } else if(reservObj.Drop_off_at_same_location_as_Pickup__c == false){
            reservObj.Drop_off_Address__c = '';
            reservObj.Drop_off_City__c = '';
            reservObj.Drop_off_State_Province_Region__c = '';
            reservObj.Drop_off_Zip_Postal_Code__c = '';
            reservObj.Drop_off_Country__c = '';     
            reservObj.Drop_off_Location_Type__c = '';
            reservObj.Drop_off_Airport__c = '';
            reservObj.Drop_off_FRN_Facility__c = null;
        }
        return null;
    }   
    
    /*** Copy_AND_Change_PickupAddress ***/    
    public PageReference CopyChangePickupAddress(){
        System.debug('Drop_off_at_same_location_as_Pickup____________________________ '+reservObj.Drop_off_at_same_location_as_Pickup__c);
        
        if(reservObj.Drop_off_at_same_location_as_Pickup__c == true && reservObj.Pickup_Location_Type__c != null){  
            //reservObj.Drop_off_Location_Type__c = reservObj.Pickup_Location_Type__c;    
            System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Location_Type__c);  
            
            if(reservObj.Pickup_Location_Type__c == 'Airport'){
                reservObj.Drop_off_Airport__c = reservObj.Pickup_Airport__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            } 
            if(reservObj.Drop_off_Location_Type__c=='FRN Facility'){
                reservObj.Drop_off_FRN_Facility__c = reservObj.Pickup_FRN_Facility__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            }  
            if(reservObj.Drop_off_Location_Type__c== 'Street Address'){
                reservObj.Drop_off_Address__c = reservObj.Pickup_Address__c;
                reservObj.Drop_off_City__c = reservObj.Pickup_City__c;
                reservObj.Drop_off_State_Province_Region__c = reservObj.Pickup_State_Province_Region__c;
                reservObj.Drop_off_Zip_Postal_Code__c = reservObj.Pickup_Zip_Postal_Code__c;
                reservObj.Drop_off_Country__c = reservObj.Pickup_Country__c;
                System.debug('Drop_off_Airport____________________________ '+reservObj.Drop_off_Airport__c);
            }                                  
        }
        return null;
    }

    public void clearOtherRtValues(){       
        if(reservObj.Pickup_Location_Type__c == null || reservObj.Pickup_Location_Type__c == ''){ 
            System.debug('NULL:Pickup_Loc_Type__________________________ '+reservObj.Pickup_Location_Type__c);  
            reservObj.Pickup_FRN_Facility__c = null;
            reservObj.Pickup_Address__c = null;
            reservObj.Pickup_City__c = null;
            reservObj.Pickup_State_Province_Region__c = null;
            reservObj.Pickup_Zip_Postal_Code__c = null;
            reservObj.Pickup_Country__c = null; 
            reservObj.Pickup_Airport__c = null;
            reservObj.Pickup_Address__c = null;
            reservObj.Pickup_City__c = null;
            reservObj.Pickup_State_Province_Region__c = null;
            reservObj.Pickup_Zip_Postal_Code__c = null;
            reservObj.Pickup_Country__c = null; 
            reservObj.Pickup_Airport__c = null;
            reservObj.Pickup_FRN_Facility__c = null;
            
        } else if(reservObj.Pickup_Location_Type__c == 'Airport'){                
            reservObj.Pickup_FRN_Facility__c = null;
            reservObj.Pickup_Address__c = null;
            reservObj.Pickup_City__c = null;
            reservObj.Pickup_State_Province_Region__c = null;
            reservObj.Pickup_Zip_Postal_Code__c = null;
            reservObj.Pickup_Country__c = null; 
            
        } else if(reservObj.Pickup_Location_Type__c=='FRN Facility'){
            reservObj.Pickup_Airport__c = null;
            reservObj.Pickup_Address__c = null;
            reservObj.Pickup_City__c = null;
            reservObj.Pickup_State_Province_Region__c = null;
            reservObj.Pickup_Zip_Postal_Code__c = null;
            reservObj.Pickup_Country__c = null; 
            
        } else if(reservObj.Pickup_Location_Type__c== 'Street Address'){
            reservObj.Pickup_Airport__c = null;
            reservObj.Pickup_FRN_Facility__c = null;
            
        } 
        CopyChangePickupAddress();
    }    
}