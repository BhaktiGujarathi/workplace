/*
* Test Class for ManageBuyerDocs.
*/
@isTest
private class ManageBuyerDocs_Test {
    @testSetup static void setupData() {
        NSIBPM__Service_Request__c sr =  InitializeSRDataTest.getSerReq('Deal',false,null);
        sr.ID_Type__c = null;        
        insert sr;
        
        NSIBPM__Step__c stp =  InitializeSRDataTest.createStep(sr.id,null,null);
        insert stp;
        
        Booking__c bk = InitializeSRDataTest.createBooking(sr.id);
        insert bk;
        
        Buyer__c br = InitializeSRDataTest.createBuyer(bk.id,false);
        br.Passport_Number__c = 'safdsdfw';
        insert br;
    }
    
    @isTest static void test_method_0() {
        Test.startTest();
        {
            NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
            NSIBPM__Step__c stp =  [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id limit 1];
            ManageBuyerDocs obj = new ManageBuyerDocs();
            obj.EvaluateCustomCode(sr,stp);
            obj.EvaluateCustomCode(null,null);
            
            Buyer__c b = [select id,name from Buyer__c limit 1];
            b.Passport_Number__c = null;
             b.Buyer_Type__c =  'Individual';
            b.Address_Line_1__c =  'Ad1';
            b.Country__c =  'United Arab Emirates';
            b.City__c = 'Dubai' ;
            //b.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
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
            update b;
            obj.EvaluateCustomCode(sr,stp);
        }
        Test.stopTest();
    }
    
    @isTest static void unitTest_1() {
        Test.startTest();
        {
            
            
            NSIBPM__SR_Template__c srTemplate = InitializeSRDataTest.createSRTemplate('Deal');
            insert srTemplate;
            
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',false,null);
            sr.ID_Type__c = null;
            sr.NSIBPM__SR_Template__c = srTemplate.id;
            insert sr;
            
            List<string> lstDocNames = new List<string>{'TestDoc','TestDoc1'};
                List<NSIBPM__Document_Master__c> lstMdocs = InitializeSRDataTest.createMasterDocs(lstDocNames);
            insert lstMdocs;
            
            List<NSIBPM__SR_Template_Docs__c> lstTempDocs =  InitializeSRDataTest.createSRTemplateDocs(lstMdocs,srTemplate.id);
            insert lstTempDocs;
            
            Booking__c bk = InitializeSRDataTest.createBooking(sr.id);
            insert bk;
            
            List<Buyer__c> lstbuyrs = new List<Buyer__c>();
            lstbuyrs.add(InitializeSRDataTest.createBuyer(bk.id,false));
            lstbuyrs.add(InitializeSRDataTest.createBuyer(bk.id,false));
            lstbuyrs.add(InitializeSRDataTest.createBuyer(bk.id,false));
            lstbuyrs[0].Buyer_Type__c = 'Individual';
            lstbuyrs[1].Buyer_Type__c = 'Individual';
            lstbuyrs[2].Buyer_Type__c = 'Individual';
            lstbuyrs[0].Passport_Number__c = '23456';
            lstbuyrs[1].Passport_Number__c = '7865';
            lstbuyrs[1].Nationality__c = 'Qatari';
            lstbuyrs[2].Passport_Number__c = '435678';
            lstbuyrs[2].Date_of_Birth__c = '12/3/2000';
            insert lstbuyrs;
            
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
            
            List<Booking_Unit__c> lstBU = new List<Booking_Unit__c>();
            lstBU.add(InitializeSRDataTest.createBookingUnit(bk.id,lstInv[0].id));
            lstBU.add(InitializeSRDataTest.createBookingUnit(bk.id,lstInv[0].id));
            lstBU.add(InitializeSRDataTest.createBookingUnit(bk.id,lstInv[1].id));
            lstBU.add(InitializeSRDataTest.createBookingUnit(bk.id,lstInv[1].id));
            insert lstBU;
            
            List<Constants__c> lstConstants = new List<Constants__c>();
            lstConstants.add(new Constants__c(Associate_Type__c = 'Individual',Country__c = 'United Arab Emirates',City__c = 'Dubai',Doc_Code__c = 'TestDoc',IsBuyerReqDocs__c = true,Filter_Doc__c='Is UAE'));
            lstConstants.add(new Constants__c(Associate_Type__c = 'Individual',Country__c = 'United Arab Emirates',City__c = 'Dubai',Doc_Code__c = 'TestDoc1',IsBuyerReqDocs__c = true));
            lstConstants.add(new Constants__c(Associate_Type__c = 'Minor',Country__c = 'United Arab Emirates',City__c = 'Dubai',Doc_Code__c = 'TestDoc',IsBuyerReqDocs__c = true));
            lstConstants.add(new Constants__c(Associate_Type__c = 'Individual',Country__c = 'Lebanon',Doc_Code__c = 'TestDoc1',IsBuyerReqDocs__c = true,Filter_Doc__c='Is GCC'));
            lstConstants.add(new Constants__c(Associate_Type__c = 'Individual',Country__c = 'Lebanon',Doc_Code__c = 'TestDoc1',IsBuyerReqDocs__c = true));
            lstConstants.add(new Constants__c(Associate_Type__c = 'Minor',Country__c = 'Lebanon',Doc_Code__c = 'TestDoc',IsBuyerReqDocs__c = true));
            insert lstConstants;
            
            ManageBuyerDocs.createdocsforBuyer(sr.ID, 'Deal');
        }
        Test.stopTest();
    }
}