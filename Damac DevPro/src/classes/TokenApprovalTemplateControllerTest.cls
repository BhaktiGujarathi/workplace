@istest
public class TokenApprovalTemplateControllerTest{

    static testmethod void TokenApprovalTemplateController_methods(){
        
        Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
        insert objLoc;  
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',true,null);
        insert sr;
        
        List<Inventory__c> lstInv = new List<Inventory__c>();
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv[0].Property_Country__c = 'United Arab Emirates';
        lstInv[0].Property_City__c = 'Dubai';
        lstInv[1].Property_Country__c = 'Lebanon';
        lstInv[1].Inventory_ID__c = '345wer';
        insert lstInv;
        
        Booking__c book = new booking__c();
        book.Deal_SR__c = sr.id;
        book.Booking_Channel__c = 'Web';
        insert book;
        
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.Booking__c = book.id;
        bu.Payment_Method__c = 'Cash';
        bu.Primary_Buyer_s_Email__c = 'raviteja@nsiglobal.com';
        bu.Primary_Buyer_s_Name__c = 'testNSI';
        bu.Primary_Buyer_s_Nationality__c = 'test';
        bu.Inventory__c = lstInv[0].id;
        insert bu;
        
        buyer__c b = new buyer__c();
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
        b.booking__c = book.id;
        insert b;
        
        TokenApprovalTemplateController.CustomerDetailsWrapper innercls1 = new TokenApprovalTemplateController.CustomerDetailsWrapper();
        TokenApprovalTemplateController.SalesPersonnelDetailWrapper innercls2 = new TokenApprovalTemplateController.SalesPersonnelDetailWrapper();
        TokenApprovalTemplateController cls = new TokenApprovalTemplateController();
        cls.getBookingRelatedDetails(book.id); 
        cls.getBookingUnitsDetails(book.id);
        cls.getBuyers(book.id);
        set<string> paypln = new set<string>();
        paypln.add(book.id);
        cls.getPaymentPlans(paypln);
    
    
    }


}