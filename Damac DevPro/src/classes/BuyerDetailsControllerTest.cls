@istest

public class BuyerDetailsControllerTest{



    static testmethod void BuyerDetailsController_methods(){
    
        Inquiry_Conversion_Mapping__c invMap = new Inquiry_Conversion_Mapping__c();
        invMap.name = 'Name';
        invMap.order__c = 1;
        invMap.Buyer__c = 'Name';
        invMap.Business_Contact_Field_Name__c = 'Name';
        invMap.Business_Account_Field_Name__c = 'Name';
        invMap.Person_Account_Field_Name__c = 'FirstName';
        insert invMap;
        
        Account a = new account();
        a.lastname = 'lastname';
        a.firstname = 'firstname';
        a.Passport_Number__pc  = 'J0565556';
        a.Nationality__pc = 'Indian';
        a.OwnerId = userinfo.getuserid();
        insert a;
        
        Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
        inquiry__c iq = new inquiry__c();
        iq.Associated_Customer__c = a.id;
        iq.ownerid = a.ownerid;
        iq.email__c = 'test@test.com';
        iq.first_name__c = a.firstname;        
        iq.last_name__c = a.lastname;
        iq.Inquiry_Status__c = 'New';
        iq.recordtypeid = inquiryRecordTypeId;
        insert iq;
        
        Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
        insert objLoc;   
        
        List<Inventory__c> lstInv = new List<Inventory__c>();
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv[0].Property_Country__c = 'United Arab Emirates';
        lstInv[0].Property_City__c = 'Dubai';
        lstInv[1].Property_Country__c = 'Lebanon';
        lstInv[1].Inventory_ID__c = '345wer';
        insert lstInv;
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',true,null);
        insert sr;
        
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
        
        
        buyer__c b1 = new buyer__c();
        b1.Buyer_Type__c =  'Individual';
        b1.Address_Line_1__c =  'Ad1';
        b1.Country__c =  'United Arab Emirates';
        b1.City__c = 'Dubai' ;
        b1.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b1.Email__c = 'test@test.com';
        b1.First_Name__c = 'firstname' ;
        b1.Last_Name__c =  'lastname';
        b1.Nationality__c = 'Indian' ;
        b1.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b1.Passport_Number__c = 'J0565556' ;
        b1.Phone__c = '569098767' ;
        b1.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b1.Place_of_Issue__c =  'India';
        b1.Title__c = 'Mr';
        b1.booking__c = book.id;
        insert b1;
        
        list<buyer__c> buyerLst = new list<buyer__c>();
        buyerlst.add(b);
        buyerlst.add(b1);
        
        BuyerDetailsController con = new BuyerDetailsController();
        
        con.selectedInventory = string.valueof(lstInv[0].id);
        list<UtilityWrapperManager.InventoryBuyerWrapper> wrplst = new list<UtilityWrapperManager.InventoryBuyerWrapper>();
        UtilityWrapperManager.InventoryBuyerWrapper ibwn = new UtilityWrapperManager.InventoryBuyerWrapper(true,true, true, 32.2,3432432.234,'test','test','test','test',3,lstInv[0],bu,new Map<String, Payment_Plan__c>(),buyerlst);
        wrplst.add(ibwn);
        con.getInventories(wrplst);        
        con.inventoryBuyerWrapperMap = con.getInventories(wrplst);  
        
        con.getBuyerTypes();
        con.addJointBuyer();
        con.removeJointBuyer();
        con.populateSamePrimaryBuyers();
        con.populateSameJointBuyers();
        con.openSearchSection();
        //con.searchForExistingAccount();
        con.saveExistingBuyerDetails(); 
        con.closeSearchSection();
        
        
        BuyerDetailsController.searchExistingCustomer('J0565556','Indian');
        BuyerDetailsController.getCustomerRelatedAccount('firstname','Individual');
        BuyerDetailsController.getCustomerRelatedInquiry('firstname');
        set<id> buyerids = new set<id>();
        buyerids.add(b.id);
        BuyerDetailsController.validateBuyers(buyerids);
    }

}