@isTest 
private class BuyerTrgHandlerTest{
     @isTest static void Test1() {
         NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
        SR.Delivery_mode__c='Email';
        SR.Deal_ID__c='1001';
        SR.Registration_Date__c=system.today();
        insert SR;
        
        List<id> SRids = new List<id>();
        SRids.add(SR.id);
        NSIBPM__SR_Doc__c srdoc= new NSIBPM__SR_Doc__c();
        srdoc.NSIBPM__Service_Request__c=SR.id;
        insert srdoc;
        
        Booking__c bk= new Booking__c();
        bk.Deal_SR__c=SR.id;
        bk.Booking_channel__c='Office';
        insert bk;
        
        Buyer__c PB= new Buyer__c();
        PB.Primary_Buyer__c=true;
        PB.Buyer_Type__c='Individual';
        PB.Booking__c=bk.id;
        PB.Phone_Country_Code__c='India: 0091';
        PB.Passport_Expiry_Date__c='25/03/2017';
        PB.CR_Registration_Expiry_Date__c='25/12/2017';
        PB.City__c='Dubai';
        PB.Country__c='United Arab Emirates';
        PB.Address_Line_1__c='street1';
        PB.Address_Changed__c=true;
        PB.Date_of_Birth__c='25/12/1990';
        PB.Email__c='test@test.com';
        PB.First_Name__c='Buyer';
        PB.Last_Name__c='test';
        PB.Nationality__c='Indian'; 
        PB.Passport_Number__c='PP123'; 
        PB.Phone__c='53532255';
        PB.Place_of_Issue__c='Delhi'; 
        PB.Title__c='Mr.';
        insert PB;
        
        PB.First_Name__c='Buyer1';
        PB.Passport_Number__c='PP1234'; 
        PB.Phone__c='535322556';
        PB.Address_Line_1__c='street2';
        update PB;
        
        
        Buyer__c JB= new Buyer__c();
        JB.Primary_Buyer__c=false;
        JB.Buyer_type__c='Individual';
        JB.Booking__c=bk.id;
        JB.Passport_Expiry_Date__c='25/11/2017';
        JB.CR_Registration_Expiry_Date__c='25/06/2017';
        jb.status__c='New';
        jb.Date_of_Birth__c='25/12/1990';
        jb.City__c='Dubai';
        jb.Country__c='United Arab Emirates';
        jb.Address_Line_1__c='street1';
        jb.Email__c='test@test.com';
        jb.First_Name__c='Buyer';
        jb.Last_Name__c='test';
        jb.Nationality__c='Indian'; 
        jb.Passport_Number__c='PP123'; 
        jb.Phone__c='53532255';
        jb.Phone_Country_Code__c='India: 0091';
        jb.Place_of_Issue__c='Delhi'; 
        jb.Title__c='Mr.';
        insert JB;        
        
        jb.Status__c='Active';
        update jb;
        jb.First_Name__c='BuyerJB';
        update jb;
     }
}