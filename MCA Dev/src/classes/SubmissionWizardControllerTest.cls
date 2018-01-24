/**
 * This class contains unit tests for validating the behavior of SubmissionWizardController
 * 
 *  Date - 12-02-2014
 *
 *  Created By - Sneha P.
 *  Modified By - Shraddha P.
 */
@isTest
//(OnInstall=false) 

private class SubmissionWizardControllerTest {
    public static SubmissionWizardController controllerInstance;
    public static List<Schema.FieldSetMember> oppFieldSet;
    public static Opportunity objOpp;
    public static Account objAcc;
    public static Id programsId;
    public static List<Submission__c> lSub;
    
    public static void testData() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Bank' Limit 1];
        objAcc = createAccount('TestAcc',1, rt.Id);
        Contact con = createContact('TestAcc',1);
        objOpp = new Opportunity(
                    Name = 'Test Opp', AccountId = objAcc.Id, StageName ='Prospecting' ,
                    CloseDate = System.today(),Credit_Score__c = 20, Average_Daily_Balance__c=100,
                    NSFs_Avg__c = 5, NDBs_Avg__c = 5, Avg_Number_Bank_Deposits__c = 10,
                    Owner_1__c = con.id, Gross_monthly_Sales__c = 2);
        insert objOpp;
        //oppFieldSet = Schema.SObjectType.Opportunity.FieldSets.SWDealSummary.getMap().values();
        oppFieldSet = SObjectType.Opportunity.FieldSets.SWDealSummary.getFields();
        list<Program__c> lstPrograms = createPrograms(25, objAcc.Id);
        insert lstPrograms;
        programsId = lstPrograms[0].Id; 
        Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = lstPrograms[0].Id);
        insert reqdDoc;
        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;
        list<Attachment> lstAttachments = createAttachments(2, objAcc.Id);
        insert lstAttachments;
        system.assertNotEquals(null,reqdDoc.Id);
        List<SWDefaultFilters__c> defaultFilterObj = createSWDDefaultFilter(1);
        insert defaultFilterObj;
        lSub =createsubmissions(2,lstPrograms[0].Id,objOpp.Id, objAcc.Id );
        insert lSub;
        list<Required_Documents__c> lstReqdDoc = createReqDocuments(4, lstPrograms);
        insert lstReqdDoc;
    }

    static testMethod void submissionWizardValidTest() {
        SWDefaultFilters__c insertCustomSetting = createCustomSetting();
        insert insertCustomSetting;
        insertCustomSetting.Attachments_Selected_on_Load__c =false;
        update insertCustomSetting;
        testData();
        PageReference pageRef = Page.SubmissionWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objOpp.Id);
        ApexPages.currentPage().getParameters().put('accId',objAcc.Id);
        controllerInstance = new SubmissionWizardController();
        submissionWizardFilterTest();
        submitBtnTest();
        submissionWizardCheckReqDocTest();
        submissionWizardSortTest();
    }

    static testMethod void submissionWizardSortingTest() {
        SWDefaultFilters__c insertCustomSetting = createCustomSetting();     
        //to insert all test data which is required for submission wizard
        testData();
        PageReference pageRef = Page.SubmissionWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objOpp.Id);
        ApexPages.currentPage().getParameters().put('accId',objAcc.Id);
        controllerInstance = new SubmissionWizardController();      
        submissionWizardFilterTest();
        SubmissionWizardController.sortDirection = 'DESC';
        submitBtnTest();
        controllerInstance.setSortDirection('ASC');
        controllerInstance.saveme();
        controllerInstance.indexToRemove = [select Id from Attachment limit 1].Id;
        controllerInstance.deleteAttachment();
        controllerInstance.resetAttachments();
        controllerInstance.cancel();
        controllerInstance.openAttachment(); 
        controllerInstance.CollectData();
        controllerInstance.getMapSize();
    }

    //submission wizard positive test case
    public static void submissionWizardFilterTest() {
        controllerInstance.clearFilter();
        controllerInstance.prefferedProgram = true;
        controllerInstance.getPrograms();
        controllerInstance.creditScore = '0';
        controllerInstance.yearInBusiness = '0';
        controllerInstance.minMonthlyDeposite = '0';
        controllerInstance.minDepositeCount = '0';
        controllerInstance.maxNSFs = '0';
        controllerInstance.maxNDBs = '0';
        controllerInstance.minAvgDailyBalance = '0';
        controllerInstance.searchQuery = 'Tes';
        SubmissionWizardController.sortDirection = 'ASC';
        controllerInstance.sortExpression = 'Minimum_Deposit_Count__c';
        controllerInstance.getPrograms();
        controllerInstance.creditScore = 'aaa';
        controllerInstance.yearInBusiness = 'aaaa';
        controllerInstance.minMonthlyDeposite = 'aaa';
        controllerInstance.minDepositeCount = 'aaa';
        controllerInstance.maxNSFs = 'aaa';
        controllerInstance.maxNDBs = 'aaa';
        controllerInstance.minAvgDailyBalance = 'aaa';
        controllerInstance.getPrograms();
        controllerInstance.creditScore = '';
        controllerInstance.yearInBusiness = '';
        controllerInstance.minMonthlyDeposite = '';
        controllerInstance.minDepositeCount = '';
        controllerInstance.maxNSFs = '';
        controllerInstance.maxNDBs = '11111111111111111111111111';
        controllerInstance.minAvgDailyBalance = '';
        controllerInstance.getPrograms();
        controllerInstance.maxNDBs = '';
        controllerInstance.prefferedProgram = true;
        controllerInstance.getPrograms();
        controllerInstance.showMore();
        controllerInstance.closePopup();
        controllerInstance.getSortDirection();
    }

    public static void submissionWizardSortTest() {
        SubmissionWizardController.sortDirection = 'ASC';
        controllerInstance.sortExpression = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Commission_Percentage__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Commission_Percentage__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Max_Amount__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Max_Amount__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Max_No_NSFs__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Max_No_NSFs__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Min_Avg_Daily_Bal__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Min_Avg_Daily_Bal__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Minimum_Deposit_Count__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Minimum_Deposit_Count__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Years_in_Business__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Years_in_Business__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Credit_Score__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Credit_Score__c';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'score';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'score';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Name';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Name';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Bank__r.Name';
        controllerInstance.viewSortedData_Program();
        controllerInstance.sortExpression = 'Bank__r.Name';
        controllerInstance.viewSortedData_Program();
    }

     public static void submitBtnTest() {
       controllerInstance.programWrapListLimit[0].submissionMethodValue = 'Manual';
       controllerInstance.programWrapListLimit[1].submissionMethodValue = 'Email';
       controllerInstance.programWrapListLimit[0].isSelected = true;
       controllerInstance.attachmentWrapperList[0].isRequired = true;
       controllerInstance.programWrapListLimit[1].isSelected = true;
       controllerInstance.attachmentWrapperList[1].isRequired = true;
       controllerInstance.submitToSend();
       Map<Id,Submission__c> mapProgIdsubmissionTest = new Map<Id,Submission__c>();
       mapProgIdsubmissionTest.put(programsId,lSub[0]);
       //controllerInstance.sendMail(mapProgIdsubmissionTest);
    }

    public static void submissionWizardCheckReqDocTest() {
        controllerInstance.programWrapListLimit[0].isSelected = true;
        controllerInstance.checkReqdDocument();
    }

    /**
     * To store selected  active program
     */
    public static void submissionWizardcheckSearchProgram() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        createPrograms(5, acc.Id);
        controllerInstance.clearFilter();
        controllerInstance.programWrapListLimit[0].isSelected = true;
        controllerInstance.searchQuery = 'Test';
        controllerInstance.getPrograms();
        controllerInstance.toStoreSelectedProgram();
    }
    public static list<Required_Documents__c> createReqDocuments(
            Integer pCount,
            list<Program__c> lstPrograms
    ){
        list<Required_Documents__c> lstRequiredDoc = new list<Required_Documents__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstRequiredDoc.add(new Required_Documents__c(Name = 'Doc 1',Program__c = lstPrograms[0].Id));
        }
        return lstRequiredDoc;
    }

    public static SWDefaultFilters__c createCustomSetting() {
        SWDefaultFilters__c defaultfilters = new SWDefaultFilters__c();
        defaultfilters.Name = 'Test_custom Setting';
        defaultfilters.Attachments_Selected_on_Load__c = true;
        defaultfilters.Credit_Score__c = true;
        defaultfilters.Years_in_Business__c = true;
        defaultfilters.Monthly_Deposits1__c= true;
        defaultfilters.Monthly_Deposits__c= true;
        defaultfilters.Avg_Daily_Balance__c= true;
        defaultfilters.Max_NSFs__c= true;
        defaultfilters.Max_NDBs__c= true;
        defaultfilters.Industry__c= true;
        defaultfilters.State__c= true;
        defaultfilters.Preferred_Programs__c= true;
        return defaultfilters;
    }

    //The method will create dummy records of Attachments.
    public static list<Attachment> createAttachments(Integer pCount, Id pAccountId){
        list<Attachment> lstTempAttachments = new list<Attachment>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempAttachments.add(new Attachment(Name = 'Test Doc' + index, 
                                                  ParentId = pAccountId, 
                                                  Body = Blob.valueOf('Test Attachment' + index)));
        }
        return lstTempAttachments;
    }//End createAttachments method.

    //The method will create dummy records of Account.
    public static Account createAccount(String pName,Integer cnt, Id recrdType){
        Account acc = new Account(
                Name = pName,Email__c = 'test@test.com'+cnt, Industry = 'Government',
                BillingState = 'CO', Years_in_Business__c = 6, NSFs_Avg__c = 5, NDBs_Avg__c = 5,
                Gross_monthly_Sales__c = 100, recordTypeId = recrdType);
        insert acc;
        return acc;
    }

    //The method will create dummy records of Contact.
    public static Contact createContact(String pName,Integer cnt){
        Contact con = new Contact(firstName = pName,lastname= pName,Email = 'test@test.com'+cnt );
        insert con;
        return con;
    }

    //The method will create dummy records of Program.
    public static list<Program__c> createPrograms(Integer pCount, Id accId){
        /*  EmailTemplate emailTemp = createEmailTemplate(1);
        insert emailTemp;*/
        EmailTemplate emailTemp = createEmailTemplate(1);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'standt', Email='MCA12345@CMB.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='MCA12345@CMB.com');
        System.runAs(u) 
        {
            insert emailTemp;
        }
        list<Program__c> lstTempPrograms = new list<Program__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempPrograms.add(new Program__c(Name= 'Test Program' + index,
                                               Bank__c = accId,
                                               Credit_Score__c = 20 + index,
                                               Min_Monthly_Deposits__c = 100 + index,
                                               Minimum_Deposit_Count__c = 10 + index,
                                               Restricted_Industry_List__c = 'Construction',
                                               Min_Avg_Daily_Bal__c = 100 + index,
                                               Max_No_NSFs__c =5 + index,
                                               Max_NDBs__c = 5 + index,
                                               Commission_Percentage__c = 10 + index,
                                               Funding_Amt_of_Monthly_Gross_Sales__c = 10 + index,
                                               Max_Amount__c = 100 + index,
                                               Years_in_Business__c = 6 + index,
                                               Preffered_Programs__c = true,
                                               Restricted_States__c = 'AK',                                               
                                               Submission_Email__c = 'test' + index + '@gmail.com',
                                               Submission_Email_CC_1__c= 'test' + index + '@gmail.com',
                                               Submission_Email_CC_2__c= 'test' + index + '@gmail.com',
                                               Email_Template_Id__c = emailTemp.Id
                                               ));
        }//End for.
        return lstTempPrograms;
    }//End createPrograms method.

    //The method will create dummy records of SubmissionMailsDetail.
    /*public static list<Submission_Mails_Detail__c> createSubmissionMailsDetail(Integer pCount){
        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = new list<Submission_Mails_Detail__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstSubmissionMailsDetail.add(new Submission_Mails_Detail__c(//Name= 'Test Program' + index,
                                               Is_Active__c = true,
                                               Message_Body__c = 'Test {!Opportunity.Name} AAA {!Opportunity.Account.Name} BBB' + 
                                                        '{!Opportunity.Owner_1__r.Name} ccc {!Program__c.Name} ddd {!SubmissionId} eee https://id={!SubmissionId}',
                                               Subject__c = 'Test Subject {!Opportunity.Account.Name}',
                                               CC_Address__c = 'test@gmail.com',
                                               Bcc_Address__c = 'test' + index + '@gmail.com'));
        }//End for.
        return lstSubmissionMailsDetail;
    }*///End SubmissionMailsDetail method.

    //The method will create dummy records of OrgWideEmail.
    public static list<OrgwideEmailAddress__c> createOrgWideEmail(Integer pCount){
        list<OrgwideEmailAddress__c> lstOrgWideEmail = new list<OrgwideEmailAddress__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstOrgWideEmail.add(new OrgwideEmailAddress__c(Name= 'SubmissionOrgWideEmail',
                                               IsOrgwideEmailAllowed__c = true,
                                               OrgEmailAddress__c = 'gabriel@cloudmybiz.com'
                                               ));
        }//End OrgWideEmail.
        return lstOrgWideEmail;
    }//End createOrgWideEmail method.

    //create custom setting records
    public static list<SWDefaultFilters__c> createSWDDefaultFilter(Integer pCount){
        list<SWDefaultFilters__c> lstDefaultFilters = new list<SWDefaultFilters__c>();
        for(Integer index = 0; index < pCount; index++) {
            lstDefaultFilters.add(new SWDefaultFilters__c(Name= 'DefaultFilter',
                                                       Industry__c = true, 
                                                       Credit_Score__c = true ,
                                                       Avg_Daily_Balance__c = true,
                                                       Max_NDBs__c = true,
                                                       Max_NSFs__c = true,
                                                       Monthly_Deposits1__c = true,
                                                       Monthly_Deposits__c = true,
                                                       Preferred_Programs__c = true,
                                                       State__c = true,
                                                       Years_in_Business__c = true
                                               ));
        }//End for.
        return lstDefaultFilters;
    }

    //The method will create dummy records of Submission.
    public static list<Submission__c> createsubmissions(Integer pCount ,Id pgmId, Id oppId, Id accId){ 
    list<Submission__c> lstSubmission = new list<Submission__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstSubmission.add(new Submission__c(//Name= 'Test Program' + index,
                                               Opportunity__c = oppId,
                                               Status__c = 'UW',
                                               Program__c = pgmId,
                                               Funder__c =accId
                                               //CC_Address__c = 'test' + index + '@gmail.com'
                                              ));
        }//End for.
          return lstSubmission;
    }//End

    public static EmailTemplate createEmailTemplate(Integer recordCount){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'SWEmailTemplate';
        validEmailTemplate.DeveloperName = 'SWEmailTemplate';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.Body = 'Hi';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        return validEmailTemplate;
    }
}