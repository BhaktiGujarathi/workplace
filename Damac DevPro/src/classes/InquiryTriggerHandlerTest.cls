/*
* Name : Pavithra Gajendra
* Date : 02/08/2017
* Purpose : Test class for Inquiry Trigger handler 
* Company : NSI Gulf
* 
*/
@isTest(seeAllData=false)
private class InquiryTriggerHandlerTest {
    
    static Inquiry__c newInquiry ;
    static Inquiry_Score_Changes__c scoreChange ;
    static Inquire_Score__c newInquiryScore ;
    
    static testmethod void testdebug(){
        System.debug('### DEBUG');
    }
    
    static void init(){
        scoreChange = InitialiseTestData.inquiryScoreChanges('Active',  'Budget Constraint');
        insert scoreChange ;
        system.debug('init');
        newInquiryScore = new Inquire_Score__c();
        newInquiryScore.Name = 'Social';
        newInquiryScore.Lead_Score__c = 'Hot';
        insert newInquiryScore ; 
    }
    
    /*
    * Scenario 1 : New Inquiry of Inquiry RT 
    */
    @isTest static void createNewInquiry() {
        Test.startTest();
        system.debug('#### create new inquiry');
        init();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,125);
        newInquiry.Budget__c = '500K to 1M';
        insert newInquiry ;
        system.debug('#### creating new inquiry = '+newInquiry);
        newInquiry.Inquiry_Status__c = 'New';
        update newInquiry ;
        newInquiry.Inquiry_Status__c = 'Budget Constraint';
        update newInquiry ;
        Test.stopTest();
    }
        
    /*
    * Scenario 2 : New Inquiry of CIL  RT 
    */
    @isTest static void createNewCILInquiry() {
        Test.startTest();
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc1@damactest.com');
        insert pcUser ;
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_CIL_RT,126);
        insert newInquiry ;
        System.assertEquals(newInquiry.CreatedById,newInquiry.OwnerId);
        Test.stopTest();
    }

    /*
    * Scenario 3 : New Inquiry with Campaign
    */
    @isTest static void createNewCampaignInquiry() {
        Test.startTest();
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        insert pcUser ;
        Campaign__c markertingCamp = InitialiseTestData.getCampaignDetails();
        insert markertingCamp ;
        Assigned_PC__c assignPC = InitialiseTestData.assignPCToCampaign(pcUser.Id,markertingCamp.Id);
        insert assignPC ;
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry.Campaign__c = markertingCamp.Id ;  
        insert newInquiry ;
        System.debug('--assignPC-- '+assignPC);
        Test.stopTest();
    }
        
    /*
    * Scenario 4 : New Inquiry with Property
    */
    @isTest static void createNewPropertyInquiry() {
        Test.startTest();
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc3@damactest.com');
        insert pcUser ;
        Property__c property = InitialiseTestData.getPropertyDetails(178);
        insert property ;
        Assigned_Property_User__c propertyPC = InitialiseTestData.assignPCToProperty(pcUser.Id,property.Id);
        insert propertyPC ;
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,128);
        newInquiry.Property__c = property.Id ;
        insert newInquiry ;
        Test.stopTest();
    }
        
    /*
    * Scenario 5 : Duplicate Inquiry
    */
    @isTest static void createDuplicateInquiry() {
        Test.startTest();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,131);
        insert newInquiry ;
        Inquiry__c dupInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,131);
        insert dupInquiry ;
        Test.stopTest();
    }
        
    /*
    * Scenario 6 : Duplicate Inquiry of exisiting nuturing inquiry 
    */
     static testMethod void createDuplicateNurturingInquiry() {
        Test.startTest();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,130);
        insert newInquiry ;
        newInquiry.Inquiry_Status__c = DAMAC_Constants.NURTURING_STATUS ;
        update newInquiry ;
        Inquiry__c dupInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,130);
        insert dupInquiry ;
        Test.stopTest();
    }
        
     /*
    * Scenario 7 : New Inquiry of Inquiry RT with Status Prospecting 
    */
    static testMethod void createNewProspectingInquiry() {
        Test.startTest();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,132);
        newInquiry.Inquiry_Source__c = 'Prospecting';
        insert newInquiry ;
        Test.stopTest();
    }
    
    /*
    * Scenario 8 : New Inquiry of Inquiry RT by PC
    */
    static testMethod void createNewInquiryByPC() {
        Test.startTest();
        init();
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc4@damactest.com');
        insert pcUser ;
        System.runAs(pcUser){
            newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,132);
            newInquiry.Inquiry_Source__c = 'Walk in';
            insert newInquiry ;
        }
        Test.stopTest();
    }
        
        //
    static testmethod void Misc_Method_Coverage(){
        //            
        Id PerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';        
        insert pcUser ;
        
        User pcUser1 = InitialiseTestData.getPropertyConsultantUsers('pc3@damactest.com');
        pcUser1.Extension = '0098';
        pcUser1.Languages_Known__c = 'English';        
        insert pcUser1 ;
        
        Account a1 = new Account();
        a1.FirstName = 'Test Account';
        a1.LastName = 'Acc';
        a1.Phone_Key__c = 'ABC';
        a1.Email_Key__c = 'TEST@TEST.COM';
        a1.recordtypeid = PerRecordTypeId;
        insert a1;
        
        Account a2 = new Account();
        a2.FirstName = 'Test Account';
        a2.LastName = 'Acc';
        a2.Phone_Key__c = 'ABC';
        a2.Email_Key__c = 'TEST@TEST.COM';
        a2.recordtypeid = PerRecordTypeId;
        insert a2;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
        
        Assigned_PC__c assignPC = InitialiseTestData.assignPCToCampaign(pcUser.Id,camp.Id);
        assignPC.Start_Date__c = System.today().addDays(-60);
        assignPC.end_date__c = System.today().addDays(60);
        insert assignPC ;
        
        Inquiry__c newInquirya = new Inquiry__c();
        newInquirya = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquirya.Campaign__c = camp.Id ;  
        newInquirya.First_name__c = 'Test';        
        newInquirya.Last_name__c = 'Lead';
        newInquirya.inquiry_source__c = 'Call Center';
        newInquirya.email__c = 'TEST@TEST.COM';
        newInquirya.Phone_Unique_key__c = 'ABC';
        newInquirya.Email_Unique_key__c = 'TEST@TEST.COM';
        newInquirya.Preferred_Language__c = 'English';
        insert newInquirya ;
        
        Inquiry__c newInquiry1 = new Inquiry__c();
        newInquiry1 = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry1.Campaign__c = camp.Id ;  
        newInquiry1.First_name__c = 'Test';        
        newInquiry1.Last_name__c = 'Lead';
        newInquiry1.inquiry_source__c = 'Call Center';
        newInquiry1.email__c = 'TEST@TEST.COM';
        newInquiry1.Phone_Unique_key__c = 'ABC';
        newInquiry1.Email_Unique_key__c = 'TEST@TEST.COM';
        newInquiry1.Preferred_Language__c = 'English';
        insert newInquiry1 ;
        
        task t = new task();
        t.whatid = newInquiry1.id;
        insert t;
        
        newInquiry1.inquiry_status__c = 'Active';
        update newInquiry1;
        
        map<id,id> campInqId = new map<id,id>();
        campInqId.put(camp.id,newInquiry1.id);
        InquiryTriggerHandler cls = new InquiryTriggerHandler();
        cls.createCampaignMembers(campInqId);
        
        //
        Account_settings__c accountSetting = new Account_Settings__c();
        accountSetting.name = 'test';
        accountSetting.Campaign_PC__c = false;
        accountSetting.Existing_PC__c = true;
        accountSetting.Inquiry_Score__c = 'Hot';
        accountSetting.New_PC__c = false;
        accountSetting.Sales_Office_PC__c = false;
        insert accountSetting;
        system.debug('#### ==> Account Settings');
        cls.checkDuplicateAccount(newinquiry1,a1,newInquirya);
        system.debug('#### ==> check Duplicate Account');
        DAMAC_Constants.isExecutingFromReshufflingBatch = true;
        update newInquiry1;            
        //            
        try{
            //                
            newinquiry1.Mobile_Phone_Encrypt__c = '557080793';
            newinquiry1.Mobile_CountryCode__c = 'United Arab Emirates: 00971';
            update newinquiry1;           
            cls.validateMobileNumbers(newinquiry1);                
        }catch(exception e){}
    }
        
        
    static testmethod void phoneValidations(){
        Inquiry__c newInquiry1 = new Inquiry__c();
        newInquiry1 = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newinquiry1.Mobile_Phone_Encrypt__c = '557080793';
        newinquiry1.Mobile_CountryCode__c = 'United Arab Emirates: 00971';
        newinquiry1.Mobile_Phone_Encrypt_2__c = '557080793';
        newinquiry1.Mobile_Country_Code_2__c = 'United Arab Emirates: 00971';
        newinquiry1.Mobile_Phone_Encrypt_3__c = '557080793';         
        newinquiry1.Mobile_Country_Code_3__c= 'United Arab Emirates: 00971';
        newinquiry1.Mobile_Phone_Encrypt_4__c = '557080793';
        newinquiry1.Mobile_Country_Code_4__c= 'United Arab Emirates: 00971';
        newinquiry1.Mobile_Phone_Encrypt_5__c = '557080793';
        newinquiry1.Mobile_Country_Code_5__c= 'United Arab Emirates: 00971';
        
        Inquiry__c newInquiry2 = new Inquiry__c();
        newInquiry2 = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        
        newinquiry2.Mobile_Phone_Encrypt__c = 'jkl';
        newinquiry2.Mobile_CountryCode__c = NULL;
        
        newinquiry2.Mobile_Phone_Encrypt_2__c= 'jkl';
        newinquiry2.Mobile_Country_Code_2__c = NULL;
        
        newinquiry2.Mobile_Phone_Encrypt_3__c = 'jkl';         
        newinquiry2.Mobile_Country_Code_3__c= null;
        
        newinquiry2.Mobile_Phone_Encrypt_4__c= 'jkl';
        newinquiry2.Mobile_Country_Code_4__c= NULL;
        
        newinquiry2.Mobile_Phone_Encrypt_5__c= 'jkl';
        newinquiry2.Mobile_Country_Code_5__c= NULL;            
        try{                  
            insert newInquiry1 ;        
        }catch(exception e){
            
        }
        
        try{ 
            insert newInquiry2 ;                             
        }catch(exception e){}
        
    }
    
    static testmethod void testUpdateInquirySource(){
        Id roadshowRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Id digitalRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
        Id standaloneRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Id conventionalRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Conventional').getRecordTypeId();
        Id salesEventsRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Sales Events').getRecordTypeId();
        List<Campaign__c> campaignList = TestDataFactory.createCampaignRecords(new List<Campaign__c>{new Campaign__c(RecordTypeId=roadshowRt), new Campaign__c(RecordTypeId=salesEventsRt),
            new Campaign__c(RecordTypeId=standaloneRt), new Campaign__c(RecordTypeId=conventionalRt), new Campaign__c(RecordTypeId=digitalRt)});
        system.debug('##### update Inquiry Source');
        system.debug(campaignList[0]);
        system.debug(campaignList[1]);
        system.debug(campaignList[2]);
        system.debug(campaignList[3]);
        system.debug(campaignList[4]);
        
        TestDataFactory.createInquiryRecords(new List<Inquiry__c> {new Inquiry__c(Campaign__c=campaignList[0].Id, Inquiry_Source__c='', OwnerId = UserInfo.getUserId()),
            new Inquiry__c(Campaign__c=campaignList[1].Id, Inquiry_Source__c='', OwnerId = UserInfo.getUserId()), new Inquiry__c(Campaign__c=campaignList[2].Id, Inquiry_Source__c='', OwnerId = UserInfo.getUserId()),
            new Inquiry__c(Campaign__c=campaignList[3].Id, Inquiry_Source__c='', OwnerId = UserInfo.getUserId()), new Inquiry__c(Campaign__c=campaignList[4].Id, Inquiry_Source__c='', OwnerId = UserInfo.getUserId())});
    }
}