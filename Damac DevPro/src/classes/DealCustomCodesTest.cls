/*This is the test class for following custom codes
CC_InvokeSPA
CC_OktoCall
CC_UpdateBuyer
CC_UpdateRegnStatus
CC_SendDoctoIPMS 
CC_PromoLetter
*/
@isTest
private class DealCustomCodesTest {
    
    @isTest static void Test1() {
      NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
      sr.country_of_sale__c = 'UAE';
      insert SR;
      
      NSIBPM__Step__c stp = new NSIBPM__Step__c();
      stp.NSIBPM__SR__c= SR.id;
      insert stp;
      
      NSIBPM__Document_Master__c DM = new NSIBPM__Document_Master__c();
      DM.name='test';
      DM.Promotion_Letter__c=true;
      insert DM;
      
      Promotion__c promo = new Promotion__c();
      promo.Promotion_Title__c='test';
      insert promo;
      Booking__c bk= new Booking__c();
      bk.Deal_SR__c=SR.id;
      bk.Booking_channel__c='Office';
      insert bk;
      
        Location__c loc=new Location__c();
        loc.Location_ID__c='123';
        insert loc;
        Inventory__c inv = new Inventory__c();
        inv.Unit_Location__c=loc.id;
        insert inv;
        
        Booking_Unit__c BU= new Booking_Unit__c ();
        BU.Booking__c=bk.id;
        BU.Inventory__c=inv.id;
        BU.Related_Promotion__c=promo.id;
        insert BU;
    
      Buyer__c PB= new buyer__c();
        PB.Buyer_Type__c =  'Individual';
        PB.Address_Line_1__c =  'Ad1';
        PB.Country__c =  'United Arab Emirates';
        PB.City__c = 'Dubai' ;
        PB.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        PB.Email__c = 'test@test.com';
        PB.First_Name__c = 'firstname' ;
        PB.Last_Name__c =  'lastname';
        PB.Nationality__c = 'Indian' ;
        PB.Passport_Expiry_Date__c = '25/06/2019';//string.valueof(system.today().addyears(20)) ;
        PB.CR_Registration_Expiry_Date__c='25/06/2019';//string.valueof(system.today().addyears(21));
        PB.Passport_Number__c = 'J0565556' ;
        PB.Phone__c = '569098767' ;
        PB.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        PB.Place_of_Issue__c =  'India';
        PB.Title__c = 'Mr';
        PB.booking__c = bk.id;
        PB.Primary_Buyer__c=true;
        PB.Address_Changed__c=true;
        insert PB;
      
      Buyer__c JB= new Buyer__c();
      
      JB.Buyer_Type__c =  'Individual';
        JB.Address_Line_1__c =  'Ad1';
        JB.Country__c =  'United Arab Emirates';
        JB.City__c = 'Dubai' ;
        JB.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        JB.Email__c = 'test@test.com';
        JB.First_Name__c = 'firstname' ;
        JB.Last_Name__c =  'lastname';
        JB.Nationality__c = 'Indian' ;
        JB.Passport_Expiry_Date__c = '25/06/2019';//string.valueof(system.today().addyears(20)) ;
        JB.CR_Registration_Expiry_Date__c='25/06/2019';//string.valueof(system.today().addyears(21));
        JB.Passport_Number__c = 'J0565556' ;
        JB.Phone__c = '569098767' ;
        JB.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        JB.Place_of_Issue__c =  'India';
        JB.Title__c = 'Mr';
        JB.booking__c = bk.id;
        JB.Primary_Buyer__c=false;
        JB.status__c='New';
      insert JB;
      
      CC_InvokeSPA cls = new CC_InvokeSPA();
      cls.EvaluateCustomCode(SR, stp);
      CC_OktoCall cls1 = new CC_OktoCall();
      cls1.EvaluateCustomCode(SR, stp);
      CC_UpdateBuyer cls2 = new CC_UpdateBuyer();
      cls2.EvaluateCustomCode(SR, stp);
      CC_UpdateRegnStatus cls3 = new CC_UpdateRegnStatus();
      cls3.EvaluateCustomCode(SR, stp);      
      CC_SendDoctoIPMS cls4 = new CC_SendDoctoIPMS();
      cls4.EvaluateCustomCode(SR, stp);
      CC_PromoLetter cls5 = new CC_PromoLetter();
      cls5.EvaluateCustomCode(SR, stp);
    }
    
}