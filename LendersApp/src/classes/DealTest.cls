@isTest
public with sharing class DealTest {

    private static McaApp__Stips__c stip = null;
    private static StipMaster__c stipMaster = null;
    private static DealOfferController.OfferCustom customOffer = null;
    private static Account account = null;
    private static Opportunity opp = null;
    private static McaApp__Submission__c submission = null;
    private static McaApp__Offer__c offer = null;
    private static ProgramMaster__c pMaster = null;
    private static Contact contact = null;
    private static Offer_Email_Detail__c offerDetail = null;
    private static final String EMAIL_ADDRESS = 'test@test.com';

    static testMethod void testDealOfferController() {

        createSettings();        
        createAccount();
        createContact();
        createOpportunity();
        createSubmission();
        createOffer();
        createProgramMaster();
        
        createStipMaster();
        createStipMaster();
        createStip();
        createUser();
        
        createOfferCustom();
        createOfferDetail();
        
        createOffer();
        //createOfferDetail();
        
        DealOfferController controller = null;
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));


        Test.startTest();

        controller = new DealOfferController(new ApexPages.StandardController(opp));
        //createOfferDetail();
        //controller.add(new DealOfferController.OfferCustom(offer,pMaster.Id, true, 'PrgrmMasterName', true));
        controller.emailToAddress = EMAIL_ADDRESS;

        controller.getOrgWideEmailAddress();
        controller.goToStep3();

        controller.goToStep4();

        controller.emailBCCAddress = 'mail@test.qt.com';
        controller.emailCCAddress = 'mymail@qt.test.com';
        controller.stipSaveAndClose();
        controller.stipCancelNew();
        controller.getOffers(); 
        controller.setOverrideFilter = false;
        controller.getOffers();
        controller.stipDone();
        
        controller.goToStep1();

        controller.addOffer();

        controller.addToChosenOffers();
        controller.addOffer();
        controller.removeFromChosenOffers();
        controller.addToChosenOffers();
        offerDetail.Active__c = true;
        offerDetail.To__c = '';
        offerDetail.CC__c = '';
        offerDetail.BCC__c = '';
        offerDetail.Subject__c = '';
        offerDetail.Header__c = '';
        offerDetail.Footer__c = '';
        update offerDetail;
        controller.goToStep4();
        controller.saveSelectedOfferAndStip();
        
        controller.newStip();
        controller.addOffer();
        
        controller.backTostep1();
        controller.addOffer();
        controller.backTostep3();
        controller.goToStep1();

        controller.emailSubject='test';
       OrgWideEmailAddress e = [select id, Address from OrgWideEmailAddress];
       // OrgWideEmailAddress e = new OrgWideEmailAddress(Address = 'standarduser@testorg.com', DisplayName = 'test', IsAllowAllProfiles = true);

        controller.updateDeal();
        controller.emailToAddress = 'test@testorg.com';
        controller.emailFromAddress = e.Id;
        controller.emailCCAddress = 'mymail@qt.test.com';
        controller.sendEmail();

        controller.lstSelectedOffer.clear();
        controller.goToStep2();
        
        controller.stipSaveAndClose();
        controller.saveOffersStips();

        DealOfferController.doFormatting(1.2, 1, 'test', 'more test');
        DealOfferController.doFormatting(10.50, 1, 'test', '300,000.00');
        DealOfferController.doFormatting(-30.00, 0, 'test', '-300,000.00');
        DealOfferController.doFormatting(-30, 0, 'test', '-300,000.00');

        controller.backToDefaultPage();
        controller.backTostep2();
        
        controller.goToStep2();
        controller.stipDone();
        
        Test.stopTest();

    }

    //private testmethod static void testDealOfferControllerUtils() {
    //    createContact();
    //    createAccount();
    //    account.McaApp__Email__c = EMAIL_ADDRESS;
    //    update account;
    //    createOpportunity();
    //    opp.McaApp__Owner_1__c = contact.Id;
    //    createContact();
    //    opp.McaApp__ISO__c = account.Id;
    //    //opp.McaApp__Sales_Rep__c = contact.Id;

    //    update opp;
    //    createOfferDetail();


    //    DealOfferControllerUtils controller = new DealOfferControllerUtils(offerDetail, opp);
    //}

    // Auxiliary Methods

    private static void createSettings() {

        DealDefaultFieldValue__c settings = DealDefaultFieldValue__c.getOrgDefaults();

        settings.Max_Gross__c = 50;
        settings.Min_Factor_per_Month__c = 1.5;
        upsert settings;
    }


    private static void createAccount() {

        account = new Account();
        account.Name = 'Test Account'; 
        RecordType[] rt = [SELECT Id, Name, SobjectType, DeveloperName FROM RecordType WHERE Name = 'Bank' AND SobjectType = 'Account'];
        account.RecordType = rt[0];
        account.McaApp__Years_in_Business__c = 5;
        insert account;
    }


    private static void createOffer() {
        offer = new McaApp__Offer__c();  
        offer.McaApp__Deal_Type__c = 'ACH';
        offer.McaApp__Submission__c = submission.Id;
        offer.McaApp__Opportunity__c = opp.Id;
        insert offer;
    }
    
    private static void createOfferCustom() {
        customOffer = new DealOfferController.OfferCustom(offer,pMaster.Id, true, 'PrgrmMasterName', true);
        
    }

    private static void createProgramMaster() {
        pMaster = new ProgramMaster__c();
        pMaster.Active__c = true;
        pMaster.Term__c = 2;
        pMaster.Program_Type__c = 'MCA';
        pMaster.DealScore__c = 'A';
        pMaster.Min_Credit_Score__c = 500;
        pMaster.Min_Monthly_Gross_Sales__c = 5000;
        pMaster.Min_Time_in_business__c = 5;
        insert pMaster;
    }


    private static void createOpportunity() {
        opp = new Opportunity();
        opp.Name =  'TestOpp';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = Date.today();
        opp.AccountId = account.Id;
        opp.McaApp__ISO__c = account.Id;
        opp.Terms_to_Offer__c = '02';
        opp.ProgramType__c = 'MCA';
        opp.Deal_Rating__c = 'A';
        opp.McaApp__Credit_Score__c = 500;
        opp.McaApp__Gross_monthly_Sales__c = 5000;
        insert opp;

    }


    private static void createStip() {

        stip = new McaApp__Stips__c();
        stip.McaApp__Opportunity__c = opp.Id;
        stip.StipMaster__c = stipMaster.Id;
        insert stip;
    }  


    private static void createSubmission() {
        submission = new McaApp__Submission__c();
        submission.McaApp__Opportunity__c = opp.Id;
        insert submission;
    }


    private static void createStipMaster(){
        stipMaster = new StipMaster__c();
        stipMaster.Include_in_Offers__c = 'Always include in offers';
        insert stipMaster;
    }


    private static void createUser(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testing.com');
        
        insert u;
    }


    private static void createContact() { 

        contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Testing';
        contact.Email = 'email@email.com';
        contact.Account = account;
        insert contact;
    }
    
     private static void createOfferDetail() { 
        offerDetail = new Offer_Email_Detail__c();
        offerDetail.Active__c = true;
        offerDetail.To__c = '[ISOSalesRepEmail]';
        offerDetail.CC__c = '[OWNER1EMail]';
        offerDetail.BCC__c = '[OWNER2EMail]';
        offerDetail.Subject__c = 'Offers notification';
        offerDetail.Header__c = 'Hi [RECIPIENTNAME],';
        offerDetail.Footer__c = 'regards,[OWNERNAME]';
        insert offerDetail;
     }
     
}