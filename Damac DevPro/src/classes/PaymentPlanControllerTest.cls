@istest
public class PaymentPlanControllerTest{

    static testmethod void PaymentPlanController_methods(){
    
        Trg_Ctrl_Var__c active = new Trg_Ctrl_Var__c();
        active.name = 'trg_Campaign';
        active.Activate__c = true;
        insert active;
        
        
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Campaign__c c = new Campaign__c();
        c.Campaign_Name__c = 'Standalone';
        C.End_Date__c = system.today();
        C.Marketing_End_Date__c = system.today();
        C.Marketing_Start_Date__c = system.today();
        C.Start_Date__c = system.today();
        insert c;
    
        Promotion__c pro = new Promotion__c();
        pro.Start_Date__c= system.today().adddays(-10);
        pro.end_date__c = system.today().adddays(10);
        pro.Promotion_Title__c = 'abc';
        pro.campaign__c = c.id;
        insert pro;
        
        Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
        insert objLoc;   
        
        List<Inventory__c> lstInv = new List<Inventory__c>();
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv.add(InitializeSRDataTest.createInventory(objLoc.id));
        lstInv[0].Property_Country__c = 'United Arab Emirates';
        lstInv[0].Property_City__c = 'Dubai';
        lstInv[1].Property_Country__c = 'Lebanon';
        lstInv[1].Inventory_ID__c = '345wer';
        lstInv[0].Special_Price__c = 121;
        lstInv[1].Special_Price__c = 2212;
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
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Booking_Unit__c = bu.id;
        pp.Effective_From__c = system.today().adddays(-4);
        pp.Effective_To__c = system.today().adddays(7); 
        pp.Building_Location__c =  objLoc.id;      
        insert pp;
        
        Payment_Terms__c pt = new Payment_Terms__c();
        pt.Payment_Plan__c = pp.id;
        pt.Booking_Unit__c = bu.id;
        pt.Percent_Value__c = '5';
        insert pt;
        
        list<Payment_Plan__c> pplist = new list<Payment_Plan__c>();
        pplist.add(pp);
        
        map<string,payment_plan__c> payMap = new map<string,payment_plan__c>();
        paymap.put(string.valueof(lstInv[0].id),pp);
        
        /*
        InventoryQueueable qu = new InventoryQueueable(lstInv);
        System.enqueueJob(qu);
        ID jobID = System.enqueueJob(qu);
        */
        PaymentPlanController con = new PaymentPlanController();
       
       
        
        
        
        list<UtilityWrapperManager.InventoryBuyerWrapper> wrplst = new list<UtilityWrapperManager.InventoryBuyerWrapper>();
        UtilityWrapperManager.InventoryBuyerWrapper ibwn = new UtilityWrapperManager.InventoryBuyerWrapper(true,true, true, 32.2,3432432.234,pp.id,'test',pro.id,'test',3,lstInv[0],bu,payMap,buyerlst);
        wrplst.add(ibwn);
        con.getPaymentPlanOptions(wrplst);        
        con.inventoryBuyerWrapperMap = con.getInventories(wrplst); 
        con.selectedInventory = string.valueof(lstInv[0].id);
        con.totalDealValue = con.getTotalDealValue(wrplst); 
                    
        con.closePaymentTerms();
        con.getPromotionList();
        con.getPaymentTerms();
    
    }




}