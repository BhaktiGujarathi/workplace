@istest
public with sharing class InquiryConversionProcessTest {
    
    static testmethod void testConversionProcessPAcc(){
    
        Account a = new Account();
        a.Name = 'AsscoCust';
        insert a;
        
        // Insert Custom setting Mapping Data
         
        Inquiry_Conversion_Mapping__c mapping = new Inquiry_Conversion_Mapping__c();
        mapping.Name = 'First_Name__c';
        mapping.Person_Account_Field_Name__c = 'FirstName';
        mapping.Business_Account_Field_Name__c = null;
        mapping.Business_contact_Field_Name__c = 'FirstName';
        insert mapping;
        
        Inquiry_Conversion_Mapping__c mapping0 = new Inquiry_Conversion_Mapping__c();
        mapping0.Name = 'Last_Name__c';
        mapping0.Person_Account_Field_Name__c = 'LastName';
        mapping0.Business_Account_Field_Name__c = null;
        mapping0.Business_contact_Field_Name__c = 'LastName';
        insert mapping0;
        
       
        Inquiry_Conversion_Mapping__c mapping1 = new Inquiry_Conversion_Mapping__c();
        mapping1.Name = 'Organisation_Name__c';
        mapping1.Person_Account_Field_Name__c = null;
        mapping1.Business_Account_Field_Name__c = 'Name';
        mapping1.Business_contact_Field_Name__c = null;
        insert mapping1;
        
        Inquiry_Conversion_Mapping__c mapping2 = new Inquiry_Conversion_Mapping__c();
        mapping2.Name = 'ownerid';
        mapping2.Person_Account_Field_Name__c = 'OwnerId';
        mapping2.Business_Account_Field_Name__c = 'OwnerId';
        mapping2.Business_contact_Field_Name__c = 'OwnerId';
        insert mapping2;
        
        // Insert Inquiry        
        Inquiry__c i = new Inquiry__c();
        i.First_Name__c = 'Lead';
        i.Last_Name__c = 'Lead';
        i.Email__c = 'lead@lead.com';
        i.Inquiry_Source__c = 'Web';        
        insert i;
                
        // Insert Inquiry related tasks
        task tsk = new task();
        tsk.whatid = i.id;
        insert tsk;
        
       
        set<id> inqIds = new set<id>();
        inqIds.add(i.id);
        
       
        
        test.starttest();            
            InquiryConversionProcess.convertInquiry(inqIds);
        test.stoptest();
    
    }
    
    //
    
    static testmethod void testConversionProcessBAcc(){
        
        // Insert Custom setting Mapping Data
         
        Inquiry_Conversion_Mapping__c mapping = new Inquiry_Conversion_Mapping__c();
        mapping.Name = 'First_Name__c';
        mapping.Person_Account_Field_Name__c = 'FirstName';
        mapping.Business_Account_Field_Name__c = null;
        mapping.Business_contact_Field_Name__c = 'FirstName';
        insert mapping;
        
        Inquiry_Conversion_Mapping__c mapping0 = new Inquiry_Conversion_Mapping__c();
        mapping0.Name = 'Last_Name__c';
        mapping0.Person_Account_Field_Name__c = 'LastName';
        mapping0.Business_Account_Field_Name__c = null;
        mapping0.Business_contact_Field_Name__c = 'LastName';
        insert mapping0;
        
       
        Inquiry_Conversion_Mapping__c mapping1 = new Inquiry_Conversion_Mapping__c();
        mapping1.Name = 'Organisation_Name__c';
        mapping1.Person_Account_Field_Name__c = null;
        mapping1.Business_Account_Field_Name__c = 'Name';
        mapping1.Business_contact_Field_Name__c = null;
        insert mapping1;
        
        Inquiry_Conversion_Mapping__c mapping2 = new Inquiry_Conversion_Mapping__c();
        mapping2.Name = 'ownerid';
        mapping2.Person_Account_Field_Name__c = 'OwnerId';
        mapping2.Business_Account_Field_Name__c = 'OwnerId';
        mapping2.Business_contact_Field_Name__c = 'OwnerId';
        insert mapping2;
        
        // Insert Inquiry        
        Inquiry__c i = new Inquiry__c();
        i.First_Name__c = 'Lead';
        i.Last_Name__c = 'Lead';
        i.Email__c = 'lead@lead.com';
        i.Inquiry_Source__c = 'Web';
        i.Organisation_Name__c = 'abc';
        insert i;
        
        // Insert Inquiry related tasks
        task tsk = new task();
        tsk.whatid = i.id;
        insert tsk;
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',false,null);
        insert sr;
        
        Booking__c book = InitializeSRDataTest.createBooking(sr.id);
        insert book;
        
        buyer__c b = new buyer__c();
        b.inquiry__c = i.id;
        b.Booking__c = book.id;
        
        b.Buyer_Type__c =  'Individual';
        b.Address_Line_1__c =  'Ad1';
        b.Country__c =  'United Arab Emirates';
        b.City__c = 'Dubai' ;
        b.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b.Email__c = 'test@test.com';
        b.First_Name__c = 'firstname' ;
        b.Last_Name__c =  'lastname';
        b.Nationality__c = 'Indian' ;
        b.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b.Passport_Number__c = 'J0565556' ;
        b.Phone__c = '569098767' ;
        b.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b.Place_of_Issue__c =  'India';
        b.Title__c = 'Mr';
        insert b;
        
        set<id> inqIds = new set<id>();
       
        inqIds.add(i.id);
        
        test.starttest();            
            InquiryConversionProcess.convertInquiry(inqIds);
        test.stoptest();
    
    }
    
}