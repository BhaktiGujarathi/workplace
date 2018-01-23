@isTest
private class NewReservationExt_Test {
 
    Static testMethod void NewReservationExt_UNIT() {
        Trip__c trpObj = new Trip__c();
            trpObj.Trip_Name__c = 'test_Name';
            insert trpObj;
        
        
        Id rsvRecType = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
        
        Reservation__c rsvObj = new Reservation__c();
            rsvObj.RecordTypeId = rsvRecType;
            rsvObj.Trip__c = trpObj.Id;
            rsvObj.Ticket_Number__c = '123456';
            rsvObj.Airline__c = 'Airline__Airways';
            rsvObj.Confirmation_Number__c = '1098765432';
            rsvObj.Flight_Number__c = '555555';
            rsvObj.Cabin__c = '69';
            rsvObj.Status__c = 'Confirmed';
            rsvObj.Seat_Assignment__c = '1';
            rsvObj.Additional_Details__c =  'Additional_test_Details';
            rsvObj.Info_Warnings__c = '_INFO_testWarning';
            rsvObj.Departure_Date_Time__c = system.now()+'';
            rsvObj.Departure_Airport__c = 'Dep';
            rsvObj.Arrival_Date_Time__c = system.now()+'';
            rsvObj.Arrival_Airport__c = 'Arr';
            rsvObj.Total_Amount_Charged__c = 50;
            insert rsvObj;
            
        apexpages.currentPage().getParameters().put('id',rsvObj.Id);
        apexpages.currentPage().getParameters().put('RecordType',rsvRecType);

        ApexPages.StandardController rsv = new ApexPages.StandardController(rsvObj);        
        NewReservationExt rsvExt = new NewReservationExt(rsv);       
            rsvExt.Cancel();
            rsvExt.save();
            rsvExt.CopyPickupAddress();
            rsvExt.CopyChangePickupAddress();
            rsvExt.clearOtherRtValues();
       
    }
    
    
    Static testMethod void NewReservationExt_UNIT1() {
        Id accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
        
                Reservation__c rsvObj = new Reservation__c();
                rsvObj.Pickup_Location_Type__c='FRN Facility';
                rsvObj.Pickup_Airport__c='Pickup_Airport__c';
                
        Account acc = new Account();
            acc.RecordTypeId = accRectype;
            acc.name='test';
            acc.phone= '(123) 456-7890';
            insert acc;     
        
        Trip__c trpObj = new Trip__c();
            trpObj.Trip_Name__c = 'test_Name';
            insert trpObj;
                
        Id rsvRecType = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Car Service').getRecordTypeId();
        

            rsvObj.RecordTypeId = rsvRecType;
            rsvObj.Trip__c = trpObj.Id;
            rsvObj.Total_Amount_Charged__c = 50;
            rsvObj.Car_Service_Company_Name__c = 'test_Car_Service_Company_Name';
            rsvObj.Car_Service_Company_Phone__c = '0123456789';
            rsvObj.Pickup_Date_Time__c = system.now();
            rsvObj.Drop_off_at_same_location_as_Pickup__c = true;
            rsvObj.Pickup_Address__c = 'testPickup_Address';
            rsvObj.Pickup_City__c = 'Pickup_City_test';
            rsvObj.Pickup_Location_Type__c = 'Airport';
            rsvObj.Pickup_State_Province_Region__c = 'test_State_Province';
            rsvObj.Pickup_Airport__c = 'Pickup_Airport_test';           
            rsvObj.Pickup_Zip_Postal_Code__c = '1234';          
            rsvObj.Pickup_FRN_Facility__c = acc.Id;         
            rsvObj.Pickup_Country__c = 'Pickup_Country_test';           
            rsvObj.Drop_Off_Date_Time__c = system.now();
            rsvObj.Drop_off_Address__c = 'Drop_off_Address_test';
            rsvObj.Drop_off_City__c = 'Drop_off_City-test';
            rsvObj.Drop_off_Location_Type__c = 'Airport';
            rsvObj.Drop_off_Zip_Postal_Code__c = '1234';
            rsvObj.Drop_off_Airport__c = 'Drop_off_Airport_test';
            rsvObj.Drop_off_State_Province_Region__c = 'test_State_Province';
            rsvObj.Drop_off_FRN_Facility__c = acc.Id;           
            rsvObj.Drop_off_Country__c = 'Drop_off_Country_test';
            rsvObj.Rate__c = 100;
            insert rsvObj;
        String tripPrefix = Trip__c.sObjectType.getDescribe().getKeyPrefix();
        
        apexpages.currentPage().getParameters().put('id',rsvObj.Id);
        apexpages.currentPage().getParameters().put('RecordType',rsvRecType);
        apexpages.currentPage().getParameters().put('retURL',tripPrefix);
        
        
        ApexPages.StandardController rsv = new ApexPages.StandardController(rsvObj);        
        NewReservationExt rsvExt = new NewReservationExt(rsv);       
            rsvExt.Cancel();
            rsvExt.saveandnew();
            rsvExt.CopyPickupAddress();
            rsvExt.CopyChangePickupAddress();
            rsvExt.clearOtherRtValues();
       
    }

    Static testMethod void NewReservationExt_UNIT2() {
        Id accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
             
             Reservation__c rsvObj = new Reservation__c();
                rsvObj.Pickup_Location_Type__c='FRN Facility';
                rsvObj.Pickup_Airport__c='Pickup_Airport__c';
             
        Account acc = new Account();
            acc.RecordTypeId = accRectype;
            acc.name='test';
            acc.phone= '(123) 456-7890';
            insert acc;     
        
        Trip__c trpObj = new Trip__c();
            trpObj.Trip_Name__c = 'test_Name';
            insert trpObj;
                
        Id rsvRecType = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Car Service').getRecordTypeId();
        
        /* Reservation__c rsvObj = new Reservation__c(); */
            rsvObj.RecordTypeId = rsvRecType;
            rsvObj.Trip__c = trpObj.Id;
            rsvObj.Total_Amount_Charged__c = 50;
            rsvObj.Car_Service_Company_Name__c = 'test_Car_Service_Company_Name';
            rsvObj.Car_Service_Company_Phone__c = '0123456789';
            rsvObj.Pickup_Date_Time__c = system.now();
            rsvObj.Drop_off_at_same_location_as_Pickup__c = true;
            rsvObj.Pickup_Address__c = 'testPickup_Address';
            rsvObj.Pickup_City__c = 'Pickup_City_test';
            rsvObj.Pickup_Location_Type__c = 'Street Address';
            rsvObj.Pickup_State_Province_Region__c = 'test_State_Province';
            rsvObj.Pickup_Airport__c = 'Pickup_Airport_test';           
            rsvObj.Pickup_Zip_Postal_Code__c = '1234';          
            rsvObj.Pickup_FRN_Facility__c = acc.Id;         
            rsvObj.Pickup_Country__c = 'Pickup_Country_test';           
            rsvObj.Drop_Off_Date_Time__c = system.now();
            rsvObj.Drop_off_Address__c = 'Drop_off_Address_test';
            rsvObj.Drop_off_City__c = 'Drop_off_City-test';
            rsvObj.Drop_off_Location_Type__c = 'Street Address';
            rsvObj.Drop_off_Zip_Postal_Code__c = '1234';
            rsvObj.Drop_off_Airport__c = 'Drop_off_Airport_test';
            rsvObj.Drop_off_State_Province_Region__c = 'test_State_Province';
            rsvObj.Drop_off_FRN_Facility__c = acc.Id;           
            rsvObj.Drop_off_Country__c = 'Drop_off_Country_test';
            rsvObj.Rate__c = 100;
            insert rsvObj;
        String tripPrefix = Trip__c.sObjectType.getDescribe().getKeyPrefix();
        
        apexpages.currentPage().getParameters().put('id',rsvObj.Id);
        apexpages.currentPage().getParameters().put('RecordType',rsvRecType);
        apexpages.currentPage().getParameters().put('retURL',tripPrefix);
        
        
        ApexPages.StandardController rsv = new ApexPages.StandardController(rsvObj);        
        NewReservationExt rsvExt = new NewReservationExt(rsv);       
            rsvExt.Cancel();
            rsvExt.saveandnew();
            rsvExt.CopyPickupAddress();
            rsvExt.CopyChangePickupAddress();
            rsvExt.clearOtherRtValues();
             
            rsvObj.Drop_off_at_same_location_as_Pickup__c = true;
            rsvObj.Pickup_Location_Type__c = 'Airport';
            update rsvObj;

            rsv = new ApexPages.StandardController(rsvObj);        
            rsvExt = new NewReservationExt(rsv);
            rsvExt.CopyPickupAddress();
            
            rsvObj.Pickup_Location_Type__c = 'FRN Facility';
            update rsvObj;
            
            rsv = new ApexPages.StandardController(rsvObj);        
            rsvExt = new NewReservationExt(rsv);
            rsvExt.CopyPickupAddress();
            rsvExt.clearOtherRtValues();
            
            rsvObj.Pickup_Location_Type__c = 'Street Address';
            update rsvObj;
            
            rsv = new ApexPages.StandardController(rsvObj);        
            rsvExt = new NewReservationExt(rsv);
            rsvExt.CopyPickupAddress();
            rsvExt.saveandnew();
    }
    
    
}