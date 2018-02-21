@isTest
public with sharing class LendersTest {

    public static Opportunity opp = null;
    public static Account acc = null;


    //DealMerchantInterviewController

    @isTest static void testDealMerchantInterview() {

        createAccount();

        createOpportunity();

        StipMaster__c stipMaster = new StipMaster__c();
        insert stipMaster;

        McaApp__Stips__c stip = new McaApp__Stips__c();
        stip.McaApp__Opportunity__c = opp.Id;
        stip.Name = 'testName';
        stip.McaApp__Status__c = 'Pending';
        stip.Notes__c = 'Some test notes'; 

        stip.StipMaster__c = stipMaster.Id;
        insert stip;

        MerchantInterviewQuestion__c question = new MerchantInterviewQuestion__c();
        question.Stips__c = stip.Id;
        question.Opportunity__c = opp.Id;

        insert question;

        List<MerchantInterviewQuestion__c> questions = new List<MerchantInterviewQuestion__c>();
        questions.add(question);
        ApexPages.currentPage().getParameters().put('Id', opp.Id);

        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(question);
        ApexPages.StandardSetController standardSetController = new ApexPages.standardSetController(questions);
        DealMerchantInterviewController controller = new DealMerchantInterviewController(stdcontroller);
        DealMerchantInterviewController setcontroller = new DealMerchantInterviewController(standardSetController); 


        setcontroller.saveQuestions();
        setcontroller.quickSave();
        setcontroller.cancel();

        
        question.Stips__c = null;

    }

    //LenderSettingsControllerTest
    @isTest static void testLendersSettingsController() {

        LendersSettingsController controller = new LendersSettingsController();

        controller.page = 'HomePage';
        controller.showSection();
        //System.assertEquals('/apex/HomePage', controller.iframeSource);

        controller.page = 'MastersSettings';
        controller.showSection();
        //System.assertEquals('/apex/MastersSettings', controller.iframeSource);
        
        controller.page = 'SomeOtherNonExistingPage';
        controller.showSection();
        //System.assertEquals('/apex/NotInstalledPage', controller.iframeSource);
 
 
    }


    @isTest static void testVerificationAfterInsertUpdate() {

        createAccount();
        createOpportunity();

        UWVerification__c verification = new UWVerification__c();
        
        verification.interview__c = true;
        insert verification;

        verification.interview__c = false;
        update verification;

        verification.Trade_Name__c = 'test';
        update verification;


        verification.interview__c = true;
        update verification;

    }


    @isTest static void StipAfterInsertUpdate() {

        createAccount();
        createOpportunity();

        McaApp__Stips__c stip = new McaApp__Stips__c();
        stip.McaApp__Opportunity__c = opp.Id;
        
        stip.interview__c = true;
        insert stip;

        stip.interview__c = false;
        update stip;

        stip.interview__c = true;
        update stip;

    }


    @istest static void testDealProgressPageController() {
        
        createOpportunity();
        McaApp__Stips__c stip = new McaApp__Stips__c();
        stip.McaApp__Opportunity__c = opp.Id;
        
        stip.interview__c = true;
        insert stip;

        DealProgressPageController controller = new DealProgressPageController(new ApexPages.StandardController(opp));

    }


    @isTest static void testOpportunityTrigger() {

        opp = new Opportunity();

        StipMaster__c stipMaster = new StipMaster__c(Name = 'test', Renewal__c = true, Stage__c = 'Underwriting', Type__c = 'ACH');
        insert stipMaster;

        MerchantInterviewQMaster__c qMaster = new MerchantInterviewQMaster__c();
        insert qMaster;

        MerchantInterviewQMaster__c qMasterNotAdded = new MerchantInterviewQMaster__c();
        

        qMasterNotAdded.Type__c = 'ACH';
        qMasterNotAdded.Stage__c = 'Underwriting';
        qMasterNotAdded.Sort_Order__c = 1;

        insert qMasterNotAdded;

        
        MerchantInterviewQuestion__c question = new MerchantInterviewQuestion__c();
        question.MerchantInterviewQuestionMaster__c = qMaster.Id;
        question.Opportunity__c = opp.Id;
        
        opp.Name =  'TestOpp';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = Date.today();
        opp.Type = 'Renewal';
        opp.ProgramType__c = 'ACH';
        opp.Underwriting_Stage__c = 'Underwriting';
        insert opp; 

        insert question;

        opp.Type = 'New Customer';
        update opp;

        System.debug('\n\n\n\n\n\n' + opp.Renewal__c);
    }


    @isTest static void testDealTriggerUtility() {
        
        opp = new Opportunity();
        opp.Name =  'TestOpp';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = Date.today();

        opp.Verifications_Completed__c = null;
        opp.Verifications_Total__c = null;
        opp.Interview_Completed_Count__c = null;
        opp.Interview_Total_Count__c = null;
        opp.Underwriting_Stage__c = 'Prequalification';
        opp.ProgramType__c = 'ACH';

        insert opp;

        StipMaster__c stipMaster = new StipMaster__c();
        stipMaster.Name = 'test Stip Master';
        stipMaster.Type__c = 'ACH';
        stipMaster.Stage__c = 'Underwriting';

        insert stipMaster;

        StipMaster__c stipMaster2 = new StipMaster__c();
        stipMaster2.Name = 'test Stip Master';
        stipMaster2.Type__c = 'ACH';
        stipMaster2.Stage__c = 'Underwriting';
        stipMaster2.Renewal__c = true;

        insert stipMaster2;
        
        StipMaster__c stipMaster3 = new StipMaster__c();
        stipMaster3.Name = 'test Stip Master';
        stipMaster3.Type__c = 'ACH';
        stipMaster3.Renewal__c = true;
        stipMaster3.Add_to_all_Deals__c = true;
        insert stipMaster3;

        VerificationMaster__c verificationMaster = new VerificationMaster__c();
        verificationMaster.Name = 'test Verification Master';
        verificationMaster.Type__c = 'ACH';
        verificationMaster.Stage__c = 'Underwriting';
        
        insert verificationMaster;

        VerificationMaster__c verificationMaster2 = new VerificationMaster__c();
        verificationMaster2.Name = 'test Verification Master2';
        verificationMaster2.Type__c = 'ACH';
        verificationMaster2.Stage__c = 'Underwriting';
        verificationMaster2.Renewal__c = true;
        insert verificationMaster2;

        MerchantInterviewQMaster__c questionMaster = new MerchantInterviewQMaster__c();
        questionMaster.Type__c = 'ACH';
        insert questionMaster;

        UWVerification__c verification = new UWVerification__c();
        verification.Name = 'test Verification';
        verification.Opportunity__c = opp.Id;
        verification.VerificationMaster__c = verificationMaster.Id;
        verification.Stage__c = 'Underwriting';

        insert verification;

        McaApp__Stips__c stip = new McaApp__Stips__c();
        stip.Name = 'test Stip';
        stip.McaApp__Opportunity__c = opp.Id;
        stip.Stage__c = 'Underwriting';
        stip.StipMaster__c = stipMaster.Id;

        insert stip;

        opp.Underwriting_Stage__c = 'Underwriting';
        update opp;

        Opportunity oppWithoutType = new Opportunity();
        oppWithoutType.Name =  'TestOpp';
        oppWithoutType.StageName = 'Prospecting'; 
        oppWithoutType.CloseDate = Date.today();

        oppWithoutType.Verifications_Completed__c = null;
        oppWithoutType.Verifications_Total__c = null;
        oppWithoutType.Interview_Completed_Count__c = null;
        oppWithoutType.Interview_Total_Count__c = null;
        oppWithoutType.Underwriting_Stage__c = 'Prequalification';
        

        insert oppWithoutType;

        StipMaster__c stipMasterWithoutType = new StipMaster__c();
        stipMasterWithoutType.Name = 'test Stip Master';
        stipMasterWithoutType.Type__c = 'ACH';
        stipMasterWithoutType.Stage__c = 'Underwriting';

        insert stipMasterWithoutType;

        StipMaster__c stipMasterWithoutType2 = new StipMaster__c();
        stipMasterWithoutType2.Name = 'test Stip Master';
        
        stipMasterWithoutType2.Stage__c = 'Underwriting';
        stipMasterWithoutType2.Renewal__c = true;

        insert stipMasterWithoutType2;
        
        StipMaster__c stipMasterWithoutType3 = new StipMaster__c();
        stipMasterWithoutType3.Name = 'test Stip Master';        
        stipMasterWithoutType3.Renewal__c = true;
        stipMasterWithoutType3.Add_to_all_Deals__c = true;
        insert stipMasterWithoutType3;

        VerificationMaster__c verificationMasterWithoutType = new VerificationMaster__c();
        verificationMasterWithoutType.Name = 'test Verification Master';
        verificationMasterWithoutType.Type__c = 'ACH';
        verificationMasterWithoutType.Stage__c = 'Underwriting';
        
        insert verificationMasterWithoutType;

        VerificationMaster__c verificationMasterWithoutType2 = new VerificationMaster__c();
        verificationMasterWithoutType2.Name = 'test Verification Master2';
        verificationMasterWithoutType2.Type__c = 'ACH';
        verificationMasterWithoutType2.Stage__c = 'Underwriting';
        verificationMasterWithoutType2.Renewal__c = true;
        insert verificationMasterWithoutType2;

        MerchantInterviewQMaster__c questionMasterWithoutType = new MerchantInterviewQMaster__c();
        questionMasterWithoutType.Type__c = 'ACH';
        insert questionMasterWithoutType;

        UWVerification__c verificationWithoutType = new UWVerification__c();
        verificationWithoutType.Name = 'test Verification';
        verificationWithoutType.Opportunity__c = oppWithoutType.Id;
        verificationWithoutType.VerificationMaster__c = verificationMasterWithoutType.Id;
        verificationWithoutType.Stage__c = 'Underwriting';

        insert verificationWithoutType;

        McaApp__Stips__c stipWithoutType = new McaApp__Stips__c();
        stipWithoutType.Name = 'test Stip';
        stipWithoutType.McaApp__Opportunity__c = oppWithoutType.Id;
        stipWithoutType.Stage__c = 'Underwriting';
        stipWithoutType.StipMaster__c = stipMaster.Id;

        insert stipWithoutType;
        oppWithoutType.Underwriting_Stage__c = 'Underwriting';
        update oppWithoutType;
        delete opp; 

    }

     @isTest static void testSendEmail() {

        createOpportunity();

        DealOfferController sendTest;

        DealOfferAttachmentController attachmentToSend;

        ApexPages.StandardController stdController;

        ApexPages.currentPage().getParameters().put('id', opp.Id);
     
        stdController =  new ApexPages.StandardController(opp);

        Attachment record = new Attachment();

        record.ParentId = opp.Id;
        record.Name = 'Test File';
        record.Body =  Blob.valueOf('/services/data/v35.0/sobjects/Attachment/00P37000000mVrHEAU/Body');

        insert record;

        sendTest = new DealOfferController(stdcontroller);

        attachmentToSend = new DealOfferAttachmentController(stdcontroller);

        attachmentToSend.getAllAttachments();

        attachmentToSend.insertAttachment();

        attachmentToSend.selectedAttachments();

        sendTest.upload();
    }

    @isTest static void testResetMasterController() {

        createOpportunity();

        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);

        ApexPages.currentpage().getParameters().put('id', opp.Id);

        ResetMastersController mastersController = new ResetMastersController(stdController);

        mastersController.resetMasters();
    }


    //ENVIRONMENT METHODS

    public static void createAccount() {

        acc = new Account();
        acc.Name = 'test';
        insert acc;
        
    }


    public static void createOpportunity() {
        
        Account acc2 = new Account();
        acc2.Name = 'test';
        insert acc2;


        opp = new Opportunity();
        opp.AccountId = acc2.Id;
        opp.Name =  'TestOpp';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = Date.today();
        insert opp; 
         
    }

}