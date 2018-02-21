@istest
public class CommissionTriggerHandlerTest{


    static testmethod void CommissionTriggerHandler_m1(){
    
    
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',false,null);
        insert sr;
        
        inventory__c inv = new inventory__c();        
        insert inv;
        
        Booking__c book = InitializeSRDataTest.createBooking(sr.id);
        insert book;
        
        Booking_unit__c bu = InitializeSRDataTest.createBookingUnit(book.id,inv.id);
        bu.Registration_ID__c ='reg123';
        insert bu;
        
        Agent_Commission__c com = new Agent_Commission__c();
        com.Booking__c = book.id;
        com.Booking_Unit__c = bu.id;
        com.Registration_ID__c = 'reg123';
        insert com;
        update com;
         
    
    }



}