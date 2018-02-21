@isTest
public class SRUtility_Test {
    @testSetup static void setupData() {
        set<string> stProfileNames = new set<string>{'Customer Community - Owner','Agent Admin Manager'};
        Map<string,profile> mpProfile = InitializeSRDataTest.getprofiles(stProfileNames);
        
        Map<id,integer> mpprofileidUsercount = new Map<Id,integer>();
        Map<id,integer> mpprofileidUsercountinternal = new Map<Id,integer>();
       
        for(profile p : mpprofile.values()){
            if(p.name == 'Customer Community - Owner')
            mpprofileidUsercount.put(p.id,1);
           if(p.name == 'Agent Admin Manager')
            mpprofileidUsercountinternal.put(p.id,1);
        }
        List<User> lstUsers = new list<user>();
        lstUsers.addall(InitializeSRDataTest.createportalUser(mpprofileidUsercount));
        lstUsers.addall(InitializeSRDataTest.createInternalUser(mpprofileidUsercountinternal));
        insert lstUsers;
        
    }
    
    @isTest static void unitTest_1() {
        Test.startTest();
        {
            Account a = [select id,name from account where name = 'TestAccount' and Agency_Short_Name__c='testAGN' limit 1];
            
            List<string> statuses = new list<string>{'Approved'};
                Map<string,NSIBPM__SR_Status__c> mpsrStatus =  InitializeSRDataTest.createSRStatus(statuses);
            
            User u = [select id,name from user where lastname like '%McTesty%' limit 1];
            Id RecType = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Agent Registration').getRecordTypeId();
            system.runAs(u){
                NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
                sr.NSIBPM__Customer__c = a.id;
                sr.RecordTypeId = rectype;
                sr.Eligible_to_Sell_in_Dubai__c = true;
                sr.Agency_Email_2__c = 'test2@gmail.com';
                sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
                sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
                sr.NSIBPM__External_SR_Status__c = mpsrStatus.get('Approved').id;
                sr.NSIBPM__Internal_SR_Status__c = mpsrStatus.get('Approved').id;
                insert sr;
            }
            
            Map<Id,Account> mpAccount = new Map<Id,Account>{a.id => a};
            SRUtility.CreateChatterGroup(mpAccount);
        }
        Test.stopTest();
    }
    
    @isTest static void unitTest_2() {
        Test.startTest();
        {
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
            
            insert sr;
            Amendment__c amd = InitializeSRDataTest.getAmendment(sr.id);
            insert amd;
            
            List<Amendment__c> lstamd = SRUtility.getAllAmendments(sr.id);
            
            user u = [select id,name from user where profile.name='Agent Admin Manager' and isactive = true limit 1];
            boolean isacces = false;
            system.runAs(u){
               isacces = SRUtility.isUserwithEditPermissions();
            }
            isacces = SRUtility.isUserwithEditPermissions();
            
            NSIBPM__Service_Request__c objsrtest = SRUtility.getSRDetails(SR.id);
        }
        Test.stopTest();
    }
    
    @isTest static void unitTest_4() {
        Test.startTest();
        {
            List<Account> lstaccount = new List<account>();
            Id RecTypeIndividualAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Agency').getRecordTypeId();
            Id RecTypeCorporateAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
            lstaccount.add(new account(recordtypeid = RecTypeIndividualAgency, firstname='test',lastname='test',ID_Type__pc='Passport',ID_Number__pc='12345'));
            lstaccount.add(new account(recordtypeid = RecTypeCorporateAgency, name='test',Trade_License_Number__c = 'test'));                  
            insert lstaccount;
            
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
            sr.Agency_Type__c = 'Corporate';
            sr.Trade_License_Number__c = 'test';
            insert sr;
            
            List<Amendment__c> lstamd = new List<Amendment__c>();
            lstamd.add(InitializeSRDataTest.getAmendment(sr.id));
            lstamd.add(InitializeSRDataTest.getAmendment(sr.id));
            lstamd.add(InitializeSRDataTest.getAmendment(sr.id));
            lstamd.add(InitializeSRDataTest.getAmendment(sr.id));
            lstamd[0].Authorised_Signatory__c = true;
            lstamd[2].Agent_Representative__c = true;
            lstamd[3].Portal_Administrator__c = true;
            lstamd[3].Owner__c = true;
            lstamd[3].Shareholding__c = 100;
            insert lstamd;
            
            string str = srutility.validateSRSubmit(sr.id);
            
            lstamd[1].Authorised_Signatory__c = true;
            update lstamd[1];
            str = srutility.validateSRSubmit(sr.id);
            
            sr.Agency_Type__c = 'Individual';
            update sr;
            str = srutility.validateSRSubmit(sr.id); 
            List<Account> lstDupAcc = srutility.checkDupTLNumber(sr.Trade_License_Number__c,'Agent_Registration','Individual','Passport','12345');
            lstDupAcc = srutility.checkDupTLNumber(sr.Trade_License_Number__c,'Agent_Registration','Corporate','Passport','12345');
            lstDupAcc =srutility.checkDupTLNumber(sr.Trade_License_Number__c,'Agent_Registration');
            
            List<string> statuses = new list<string>{'fromcode','tocode'};
            Map<string,NSIBPM__Status__c> stepStatuses = InitializeSRDataTest.createStepStatus(statuses);

            Map<string,NSIBPM__SR_Status__c> srStatuses = InitializeSRDataTest.createSRStatus(statuses);
            
            List<NSIBPM__Transition__c> trsition = new List<NSIBPM__Transition__c>();
            trsition.add(new NSIBPM__Transition__c(NSIBPM__From__c = stepStatuses.values()[0].id, NSIBPM__To__c = stepStatuses.values()[1].id,NSIBPM__Transition_Code__c = 'test11'));
            insert trsition;
            
            NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
            insert srStep;
            
            List<NSIBPM__Step_Transition__c> lstStepTrans = new List<NSIBPM__Step_Transition__c>();
            lstStepTrans.add(new NSIBPM__Step_Transition__c(NSIBPM__SR_Step__c=srStep.id,NSIBPM__Transition__c =trsition[0].id,NSIBPM__SR_Status_Internal__c = srStatuses.values()[0].Id, NSIBPM__SR_Status_External__c = srStatuses.values()[0].Id));
            insert lstStepTrans;
            
            id trsnid = srutility.getSRStatusFromTransition(srStep.id, 'fromcode', 'tocode');

        }
    }
    
    @isTest static void unitTest_5() {
        Test.startTest();
        {
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
            insert sr;
            
            List<Contact> lstc = new List<Contact>();
            lstc.add(new contact(accountid = sr.NSIBPM__Customer__c,firstname='test1',lastname='test2'));
            lstc.add(new contact(accountid = sr.NSIBPM__Customer__c,firstname='test4',lastname='test3'));
            insert lstc;
            
            List<Amendment__c> lstamd = new List<Amendment__c>();
            lstamd.add(InitializeSRDataTest.getAmendment(sr.id));
            lstamd[0].contact__c = lstc[0].id;
            insert lstamd;

            srutility.getAllAmendmentsForContacts(SR);
            
            List<sobject> lstobj = srutility.getRecords('Contact','');
        }
        Test.stopTest();
    }
    
   
    
    /*@isTest static void unitTest_3() {
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
            lstbuyrs[0].Passport_Number__c = '23456';
            lstbuyrs[1].Passport_Number__c = '7865';
            lstbuyrs[1].Nationality__c = 'qatari';
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
            
            list<Buyer__c> lstbuyers = SRUTILITY.getRecords('Buyer__c',' where booking__c =\''+bk.id+'\'');
            Map<Id,list<Buyer__c>> mpBookingIDlstBuyers = new Map<Id,list<Buyer__c>>();
            mpBookingIDlstBuyers.put(bk.id,lstbuyers);
            Map<Id,List<NSIBPM__SR_Doc__c>> buyerDocs = SRUTILITY.CreateSrdocsforBuyers(sr.id,mpBookingIDlstBuyers);
            
            
           SRUTILITY.callAsyncReceiptWebservice(sr.id);
        }
        Test.stopTest();
    }*/
    
}