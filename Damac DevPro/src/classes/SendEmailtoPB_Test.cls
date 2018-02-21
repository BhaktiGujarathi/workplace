/*
* Test Class for SendEmailtoPB,BookingUnitTriggerHandler
*/
@isTest
private class SendEmailtoPB_Test {
    @testSetup static void setupData() {
        
        NSIBPM__SR_Template__c srTemplate = InitializeSRDataTest.createSRTemplate('Deal');
        insert srTemplate;
        
        NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',false,null);
        sr.ID_Type__c = null;
        sr.Agency_Type__c = 'Corporate';
        sr.NSIBPM__SR_Template__c = srTemplate.id;
        insert sr;
        
        NSIBPM__Step_Template__c stpTemplate =  InitializeSRDataTest.createStepTemplate('Deal','MANAGER_APPROVAL');
        insert stptemplate;
        
        List<string> statuses = new list<string>{'UNDER_MANAGER_REVIEW'};
        Map<string,NSIBPM__Status__c> stepStatuses = InitializeSRDataTest.createStepStatus(statuses);

        
        NSIBPM__Step__c stp = InitializeSRDataTest.createStep(sr.id,stepStatuses.values()[0].id,stptemplate.id);
        insert stp;
        
        List<Booking__c> lstbk = new List<Booking__c>();
        lstbk.add(InitializeSRDataTest.createBooking(sr.id));
        lstbk.add(InitializeSRDataTest.createBooking(sr.id));
        insert lstbk;
        
        
        Location__c loc = InitializeSRDataTest.createLocation('123','Building');
        insert loc;       
            
        List<Inventory__c> lstInv = new List<Inventory__c>();
        lstInv.add(InitializeSRDataTest.createInventory(loc.id));
        lstInv[0].Property_Country__c = 'United Arab Emirates';
        lstInv[0].Property_City__c = 'Dubai';
        lstInv[0].Unit_Location__c = loc.id;
        insert lstInv;
        
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.Booking__c = lstbk[0].id;
        bu.Payment_Method__c = 'Cash';
        bu.Primary_Buyer_s_Email__c = 'raviteja@nsiglobal.com';
        bu.Primary_Buyer_s_Name__c = 'testNSI';
        bu.Primary_Buyer_s_Nationality__c = 'Russia';
        bu.Inventory__c = lstinv[0].id;
        insert bu;
        
        //
        bu.Registration_Status_Code__c = 'abc';
        bu.tBits_Ready__c = true;
        bu.Receipt_ID__c = '67878';
        update bu;
        
        NSIBPM__SR_Doc__c srdoc = new NSIBPM__SR_Doc__c();
        srdoc.name= 'ppt';
        srdoc.Booking_Unit__c  = bu.id;
        srdoc.NSIBPM__Service_Request__c = sr.id;
        insert srdoc;
    }
    
    @isTest static void test_method_1() {
        SendEmailtoPB obj = new SendEmailtoPB();
        NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
        NSIBPM__Step__c stp = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id];
        string str = obj.EvaluateCustomCode(sr,stp);
    }
    @isTest static void test_method_2() {
        SendEmailtoPB obj = new SendEmailtoPB();
        string str = obj.EvaluateCustomCode(null,null);
    }
    @isTest static void test_method_3() {
        
        NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
        List<NSIBPM__Step_Template__c> lststtempl = new List<NSIBPM__Step_Template__c>();
        NSIBPM__Step_Template__c sttempl1 = new NSIBPM__Step_Template__c();
        sttempl1.NSIBPM__Step_RecordType_API_Name__c = 'Deal';
        sttempl1.NSIBPM__Code__c = 'DP_OK';
        lststtempl.add(sttempl1);
        NSIBPM__Step_Template__c sttempl2 = new NSIBPM__Step_Template__c();
        sttempl2.NSIBPM__Step_RecordType_API_Name__c = 'Deal';
        sttempl2.NSIBPM__Code__c = 'TOKEN_PAYMENT';
        lststtempl.add(sttempl2);
        NSIBPM__Step_Template__c sttempl3 = new NSIBPM__Step_Template__c();
        sttempl3.NSIBPM__Step_RecordType_API_Name__c = 'Deal';
        sttempl3.NSIBPM__Code__c = 'SPA_EXECUTION';
        lststtempl.add(sttempl3);
        insert lststtempl;

        List<NSIBPM__Status__c> lststpSt = new List<NSIBPM__Status__c>();
        NSIBPM__Status__c stpSt = new NSIBPM__Status__c();
        stpSt.NSIBPM__Code__c = 'DP_OK';
        lststpSt.add(stpst);
        NSIBPM__Status__c stpSt1 = new NSIBPM__Status__c();
        stpSt1.NSIBPM__Code__c = 'TOKEN_DEPOSIT_PAID';
        lststpSt.add(stpst1);
        NSIBPM__Status__c stpSt2 = new NSIBPM__Status__c();
        stpSt2.NSIBPM__Code__c = 'SPA_EXECUTED';
        lststpSt.add(stpSt2);
        NSIBPM__Status__c stpSt3 = new NSIBPM__Status__c();
        stpSt3.NSIBPM__Code__c = 'Test';
        lststpSt.add(stpSt3);
        insert lststpSt;
        
        List<NSIBPM__Step__c> lststp = new List<NSIBPM__Step__c>();
        NSIBPM__Step__c stp1 = new NSIBPM__Step__c();
        stp1.NSIBPM__SR__c = sr.id;
        stp1.NSIBPM__Status__c = stpSt3.id;
        stp1.NSIBPM__Step_Template__c = sttempl1.id;
        lststp.add(stp1);
        NSIBPM__Step__c stp2 = new NSIBPM__Step__c();
        stp2.NSIBPM__SR__c = sr.id;
        stp2.NSIBPM__Status__c = stpSt3.id;
        stp2.NSIBPM__Step_Template__c = sttempl2.id;
        lststp.add(stp2);
        NSIBPM__Step__c stp3 = new NSIBPM__Step__c();
        stp3.NSIBPM__SR__c = sr.id;
        stp3.NSIBPM__Status__c = stpSt3.id;
        stp3.NSIBPM__Step_Template__c = sttempl3.id;
        lststp.add(stp3);
        insert lststp;
        
        
        NSIBPM__SR_Status__c srstatus = new NSIBPM__SR_Status__c();
        srstatus.NSIBPM__Code__c = 'TOKEN_DEPOSIT_PAID';
        insert srstatus;
           
        List<ID> lstBUIDs = new List<Id>();
        for(Booking_Unit__c bu : [select id from Booking_Unit__c]){
            lstBUIDs.add(bu.id);
        }
        BookingUnitTriggerHandler.UpdateSR(lstBUIDs);
        
        sr.DP_ok__c = true;
        sr.Token_Deposit_Paid_Date_Time__c = system.Datetime.now();        
        update sr;
        BookingUnitTriggerHandler.mpSRRegStatusCodeLE.put(sr.id,true);
        set<id> stids = new set<id>();
        stids.add(sr.id);
        BookingUnitTriggerHandler.UpdateStepStatus(stids);
        
    }
}