/**
 * This class contains unit tests for validating the behavior of SubmissionWizardController
 * 
 *  Date - 12-02-2014
 *
 *  Created By - Sneha P.
 */
@isTest(OnInstall=false)
private class SubmissionWizardControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //Insert Custom setting record
       // list<OrgwideEmailAddress__c> lstSorgWideEmail =createOrgWideEmail(1);
        //insert lstSorgWideEmail;
        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;

        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = createSubmissionMailsDetail(1);
        insert  lstSubmissionMailsDetail;
        //Create Acc
        Account acc = createAccount('TestAcc',0);
        
        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today(), Credit_Score__c = 20,Average_Daily_Balance__c=100 );
        insert opp;

        //Create Programs
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(8);
        insert lstPrograms;

        Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = lstPrograms[0].Id);
        insert reqdDoc;
        Test.startTest();
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');

        test.setCurrentPage(pageRef);

        SubmissionWizardController cntl = new SubmissionWizardController();
        
        //Check if 2 programs are displayed
        //system.assertEquals(cntl.programWrapperList.size(), 10);
        cntl.getPrograms();
        //system.assert(cntl.programWrapperList.size() == 3);

        //system.assertEquals(cntl.displayPopup, true);
        // && cntl.prgmDocMap.size() == 1);
        cntl.closePopup();

        cntl.getMapSize();
        cntl.resetAttachments();

        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[0].id);
        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[1].id);
        cntl.programWrapperList[0].isSelected = true;
        cntl.mailsDetails.add(lstSubmissionMailsDetail[0]);
        cntl.sendWithoutAttachment();
        cntl.sendSelectedAttachments();
        
        cntl.AttachmentWrapperList[0].isRequired = false;
        cntl.sendSelectedAttachments();
        
        cntl.AttachmentWrapperList.clear();
        cntl.sendSelectedAttachments();
        
        cntl.mailsDetails.clear();
        cntl.sendSelectedAttachments();
        cntl.openAttachment();

        cntl.cancel();
        cntl.clearFilter();
        cntl.getStates();
        cntl.getSortDirection();
        cntl.setSortDirection('Desc');
        cntl.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        cntl.programWrapperList.sort();
        SubmissionWizardController.sortDirection = 'DESC';
        cntl.programWrapperList.sort();
        map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
        mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
        cntl.sendMail(mapPgmAttachment);

        cntl.program.Credit_Score__c = 20;
        cntl.program.Years_in_Business__c = 5;
        cntl.program.Min_Monthly_Deposits__c = 1000;
        cntl.program.Minimum_Deposit_Count__c = 10;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = true;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Commission_Percentage__c';
        cntl.getPrograms();
        
        cntl.programMap.put(cntl.programWrapperList[0].prgm.Id, cntl.programWrapperList[0].prgm);
        //Check if the required documents are shown in popup on click of button
        cntl.checkReqdDocument();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = 5;
        cntl.program.Min_Monthly_Deposits__c = 1000;
        cntl.program.Minimum_Deposit_Count__c = 10;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = true;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Max_Amount__c';
        cntl.getPrograms();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = 1000;
        cntl.program.Minimum_Deposit_Count__c = 10;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = true;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Max_No_NSFs__c';
        cntl.getPrograms();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = 1000;
        cntl.program.Minimum_Deposit_Count__c = 10;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Max_NDBs__c';
        cntl.getPrograms();

        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = 10;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Min_Monthly_Deposits__c';
        cntl.getPrograms();

        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = null;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = 5;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Minimum_Deposit_Count__c';
        cntl.getPrograms();

        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = null;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = null;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = true;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Years_in_Business__c';
        cntl.getPrograms();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = null;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = null;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = false;
        cntl.program.Preffered_Programs__c = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Min_Avg_Daily_Bal__c';
        cntl.getPrograms();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = null;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = null;
        cntl.program.Max_NDBs__c = 5;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = false;
        cntl.program.Preffered_Programs__c = false;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Credit_Score__c';
        cntl.getPrograms();
        
        cntl.program.Credit_Score__c = null;
        cntl.program.Years_in_Business__c = null;
        cntl.program.Min_Monthly_Deposits__c = null;
        cntl.program.Minimum_Deposit_Count__c = null;
        cntl.program.Industry__c = 'Government';
        cntl.program.Min_Avg_Daily_Bal__c = 100;
        cntl.program.Max_No_NSFs__c = null;
        cntl.program.Max_NDBs__c = null;
        cntl.restrictedIndustry = false;
        cntl.restrictedState = false;
        cntl.program.Preffered_Programs__c = false;
        SubmissionWizardController.sortDirection = 'DESC';
        SubmissionWizardController.sortExp = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        cntl.getPrograms();
        Test.stopTest();
    }
    static testMethod void testCreateWoSending() {

        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;
        
        Account acc = createAccount('TestAcc',0);

        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today());
        insert opp;

        //Create Programs
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(8);
        insert lstPrograms;

        Test.startTest();
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
       // pageRef.getParameters().put('attId', lstAttachments[0].Id);
        test.setCurrentPage(pageRef);

        SubmissionWizardController cntl = new SubmissionWizardController();

        system.debug('****'+cntl.programWrapperList);
        cntl.programWrapperList[0].isSelected = true;
        cntl.programWrapperList[1].isSelected = true;
        cntl.programWrapperList[2].isSelected = true;

        cntl.resetAttachments();
        cntl.programMap.clear();
        cntl.createWithoutSending();

        list<Submission__c> submissionList = [Select Id, Name, Opportunity__c 
                                               from Submission__c 
                                               where Opportunity__c =: opp.Id ] ;
        system.assert(submissionList.size() == 3);
        map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
        mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
        cntl.sendMail(mapPgmAttachment);
        Test.StopTest();
    }

    static testMethod void myUnitTest2() {
        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;

        Account acc = createAccount('TestAcc',0);

        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today());
        insert opp;

        //Create Programs
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(8);
        insert lstPrograms;
        system.debug('11111&&&&&111111'+lstPrograms);
        Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = lstPrograms[0].Id);
        insert reqdDoc;
        Test.startTest();
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
        pageRef.getParameters().put('attId', lstAttachments[0].Id);
        test.setCurrentPage(pageRef);

        SubmissionWizardController cntl = new SubmissionWizardController();
        system.debug('22222&&&&&2222'+cntl.programWrapperList);
        cntl.programWrapperList[0].isSelected = true;
        cntl.programWrapperList[1].isSelected = true;
        cntl.programWrapperList[2].isSelected = true;
        cntl.resetAttachments();

        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[0].id);
        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[1].id);
        try{ 
            cntl.checkUncheckAttachements();
            cntl.mailsDetails.clear();
            cntl.sendWithoutAttachment();
            cntl.sendSelectedAttachments();
            cntl.selectDeselectAtt1();
            map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
            mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
            cntl.sendMail(mapPgmAttachment);
        }catch(Exception e){

        system.assert(e.getMessage() == system.label.Submission_EmailLimitExceeded);
      }
        Test.stopTest();
    }//End myUnitTest2 method.

    static testMethod void myUnitTest3() {
        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;

        Account acc = createAccount('TestAcc',0);

        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;
        Map<Id,Program__c> programMap = new Map<Id,Program__c>();
        Program__c objProgram = new Program__c ();
        objProgram.Name= 'Test Program' ;
        objProgram.Preffered_Programs__c = true;
        objProgram.Credit_Score__c = 20 ;
        objProgram.Years_in_Business__c = 5 ; 
        objProgram.Industry__c = 'Government';
        objProgram.Restricted_States__c = 'CO';
        objProgram.Min_Monthly_Deposits__c = 100;
        objProgram.Max_No_NSFs__c =10;
        objProgram.Submission_Email__c = 'test@gmail.com';

        insert objProgram;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today(),
                                         Avg_Number_Bank_Deposits__c=12,
                                         Average_Daily_Balance__c = 12,
                                         Gross_monthly_Sales__c = 200);
        insert opp;
        
        //Create Programs
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(8);
        insert lstPrograms;
        
        Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = objProgram.Id);
        insert reqdDoc;
        Test.startTest();
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
        pageRef.getParameters().put('attId', lstAttachments[0].Id);
        test.setCurrentPage(pageRef);

        SubmissionWizardController cntl = new SubmissionWizardController();
        cntl.programMap.put(objProgram.Id,objProgram);
        cntl.program.Years_in_Business__c = 5;
        cntl.program.Min_Monthly_Deposits__c= 100;
        cntl.program.Min_Avg_Daily_Bal__c = 50;
        cntl.program.Minimum_Deposit_Count__c = 40;
        cntl.program.Max_No_NSFs__c = 10;
        cntl.program.Max_NDBs__c = 5;
        cntl.program.Preffered_Programs__c = true;
        cntl.clearFilter();
        cntl.getPrograms();
        system.debug('****programMap***'+programMap);
        cntl.programWrapperList[0].isSelected = true;
        cntl.programWrapperList[1].isSelected = true;
        cntl.programWrapperList[2].isSelected = true;
        cntl.resetAttachments();
        
        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[0].id);
        cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[1].id);
        try{  
            cntl.checkUncheckAttachements();
            cntl.sendWithoutAttachment();
            cntl.sendSelectedAttachments();
            cntl.selectDeselectAtt1();
            map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
            mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
            cntl.sendMail(mapPgmAttachment);
        }catch(Exception e){
            
            system.assert(e.getMessage() == system.label.Submission_EmailLimitExceeded);
        }
        Test.stopTest();
    }//End myUnitTest2 method.

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
    public static Account createAccount(String pName,Integer cnt){
        Account acc = new Account(Name = pName,Email__c = 'test@test.com'+cnt, Industry = 'Government', BillingState = 'CO', Years_in_Business__c = 6,
                                    NSFs_Avg__c = 5, NDBs_Avg__c = 5, Gross_monthly_Sales__c = 100);
        insert acc;
        return acc;
    }
    
    //The method will create dummy records of Program.
    public static list<Program__c> createPrograms(Integer pCount){
        list<Program__c> lstTempPrograms = new list<Program__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempPrograms.add(new Program__c(Name= 'Test Program' + index,
                                               Credit_Score__c = 20 + index,
                                               Min_Monthly_Deposits__c = 100,
                                               Minimum_Deposit_Count__c = 10,
                                               Restricted_Industry_List__c = 'Construction',
                                               Min_Avg_Daily_Bal__c = 100,
                                               Max_No_NSFs__c =5,
                                               Max_NDBs__c = 5,
                                               Years_in_Business__c = 1 + index,
                                               Preffered_Programs__c = true,
                                               Restricted_States__c = 'AK',
                                               Funding_Amt_of_Monthly_Gross_Sales__c = 100,
                                               Submission_Email__c = 'test' + index + '@gmail.com',
                                               Submission_Email_CC_1__c= 'test' + index + '@gmail.com',
                                               Submission_Email_CC_2__c= 'test' + index + '@gmail.com'));
        }//End for.
        return lstTempPrograms;
    }//End createPrograms method.
    
    //The method will create dummy records of SubmissionMailsDetail.
    public static list<Submission_Mails_Detail__c> createSubmissionMailsDetail(Integer pCount){
        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = new list<Submission_Mails_Detail__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstSubmissionMailsDetail.add(new Submission_Mails_Detail__c(Name= 'Test Program' + index,
                                               Is_Active__c = true,
                                               Message_Body__c = 'Test',
                                               Subject__c = 'Test Subject',
                                               CC_Address__c = 'test' + index + '@gmail.com',
                                               Bcc_Address__c = 'test' + index + '@gmail.com'));
        }//End for.
        return lstSubmissionMailsDetail;
    }//End SubmissionMailsDetail method.

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
/*    
    public static list<Submission__c> createsubmission( ){ 
    list<Submission__c> lstSubmission = new list<Submission__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstSubmissionMailsDetail.add(new Submission__c(Name= 'Test Program' + index,
                                               Opportunity__c = true,
                                               Status__c = 'UW',
                                               Program__c = ,
                                               CC_Address__c = 'test' + index + '@gmail.com'));
        }//End for.
          return lstSubmission;
    }//End
    
    */
}