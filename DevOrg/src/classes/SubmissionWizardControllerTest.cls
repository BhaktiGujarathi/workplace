/**
 * This class contains unit tests for validating the behavior of SubmissionWizardController
 * 
 *  Date - 12-02-2014
 *
 *  Created By - Sneha P.
 */
@isTest(OnInstall=false) 

private class SubmissionWizardControllerTest {

    //submission wizard positive test case
    static testMethod void submissionWizardValidTest() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Bank' Limit 1];
        Account acc = createAccount('TestAcc',1, rt.Id);
        Contact con = createContact('TestAcc',1);
         
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today(),Credit_Score__c = 20, Average_Daily_Balance__c=100,
                                         NSFs_Avg__c = 5, NDBs_Avg__c = 5, Avg_Number_Bank_Deposits__c = 10,
                                         Owner_1__c = con.id, Gross_monthly_Sales__c = 2);
        insert opp;
         
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(25, acc.Id);
        insert lstPrograms;
        
        OrgwideEmailAddress__c lstOrgWideEmail = new OrgwideEmailAddress__c();
        lstOrgWideEmail.Name= 'SubmissionOrgWideEmail';
        lstOrgWideEmail.IsOrgwideEmailAllowed__c = true;
        lstOrgWideEmail.OrgEmailAddress__c = 'gabriel@cloudmybiz.com';
        insert lstOrgWideEmail;
        
        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(2, acc.Id);
        insert lstAttachments;
        
        Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = lstPrograms[0].Id);
        insert reqdDoc;
        
        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = createSubmissionMailsDetail(1);
        insert  lstSubmissionMailsDetail;
        
        List<SWDefaultFilters__c> defaultFilterObj = createSWDDefaultFilter(1);
        insert defaultFilterObj;
        
        List<Submission__c> lSub =createsubmissions(2,lstPrograms[0].Id,opp.Id, acc.Id );
        insert lSub;
        
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
        test.setCurrentPage(pageRef);
        SubmissionWizardController controller = new SubmissionWizardController();
        SubmissionWizardController.ProgramWrapper wrprobj= new SubmissionWizardController.ProgramWrapper(lstPrograms[0], true, 10, 100, true, '75');
        SubmissionWizardController.ProgramWrapper wrprobj1= new SubmissionWizardController.ProgramWrapper(lstPrograms[1], true, 12, 1000, true, '76');
        
        controller.clearFilter();
        controller.creditScore = string.ValueOf(20);
        controller.yearInBusiness = string.ValueOf(5);
        controller.minMonthlyDeposite = string.ValueOf(1000);
        controller.minDepositeCount = string.ValueOf(10);
        controller.minAvgDailyBalance = string.ValueOf(100);
        controller.maxNSFs = string.ValueOf(5);
        controller.maxNDBs = string.ValueOf(5);
        controller.prefferedProgram = true;
        SubmissionWizardController.sortDirection = 'ASC';
        SubmissionWizardController.sortExp = 'Commission_Percentage__c';
        controller.getPrograms();
        
        integer rtrnObj = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        SubmissionWizardController.sortExp = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        integer rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Commission_Percentage__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Max_Amount__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Max_No_NSFs__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Commission_Percentage__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Min_Avg_Daily_Bal__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Max_NDBs__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Min_Monthly_Deposits__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Minimum_Deposit_Count__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Years_in_Business__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Credit_Score__c';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Bank__r.Name';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        
        SubmissionWizardController.sortExp = 'Name';
        rtrnObj1 = wrprobj1.CompareTo(wrprobj);
        SubmissionWizardController.sortDirection = 'DESC';
        controller.prevSortdire = 'DESC';
        controller.getSortDirection();
        controller.getStates();
        controller.closePopup();
        controller.getMapSize();
        controller.showMore();
        ApexPages.CurrentPage().getParameters().put('isSelected', 'true');
        ApexPages.CurrentPage().getParameters().put('attId', lstAttachments[0].Id );
        controller.checkUncheckAttachements();
        controller.mailsDetails.add(lstSubmissionMailsDetail[0]);
        
        controller.checkReqdDocument();
        controller.selectDeselectAtt1();
        controller.programWrapperList[0].isSelected =true;
        controller.programWrapperList1[0].isSelected =true;
        controller.createSubmission(con.Id, acc.Id,  lstPrograms[0].Id,'',  'test@gmail.com');
        controller.programMap.put(lstPrograms[0].Id , lstPrograms[0]);
        controller.createWithoutSending();
        
        controller.sendWithoutAttachment();
        controller.sendSelectedAttachments();
        controller.checkReqdDocument();
        controller.programWrapperList1[0].isSelected = true;
        controller.resetAttachments();
        controller.cancel();
        controller.openAttachment();
        controller.getMapSize();
        
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'TestLogo';
        document.FolderId = UserInfo.getUserId();
        insert document;
        controller.messageBodyContent('doc');
        ApexPages.CurrentPage().getParameters().put('isSelected', 'false');
        ApexPages.CurrentPage().getParameters().put('attId', lstAttachments[0].Id );
        controller.checkUncheckAttachements();
        map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
        mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
        
        try {
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            Messaging.Singleemailmessage message1 = new Messaging.Singleemailmessage();
            controller.setMessage(message1, lstPrograms[0].Id,lSub[0].Id);
            controller.sendMail(mapPgmAttachment);
        } catch(Exception ex) {
            
        }
        
    }
    
    //test for negative testing
    static testMethod void submissionWizardValid2Test() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Bank' Limit 1];
        
        Account acc = createAccount('TestAcc',1 ,rt.Id);
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='open' ,
                                         CloseDate = System.today(),Credit_Score__c = 20, Average_Daily_Balance__c=100,
                                         NSFs_Avg__c = 5, NDBs_Avg__c = 5, Avg_Number_Bank_Deposits__c = 100, Submission_Counter__c = 1
                                       );
        insert opp;
        
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(1, acc.Id);
        insert lstPrograms;
        
        Program__c objProgram = new Program__c();
        objProgram.Name= 'Test Program';
        objProgram.Bank__c = acc.Id;
        insert objProgram;
        
        List<SWDefaultFilters__c> defaultFilterObj = createSWDDefaultFilter(1);
        insert defaultFilterObj;
        
        String testLbl = Label.CountOfProgram;
        testLbl = string.valueOf(0);
        
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
        test.setCurrentPage(pageRef);
        SubmissionWizardController controller = new SubmissionWizardController();
        controller.sendSelectedAttachments();
        SubmissionWizardController.ProgramWrapper wrprobj= new SubmissionWizardController.ProgramWrapper(objProgram, true, 10, 100, true, '75');
        SubmissionWizardController.ProgramWrapper wrprobj1= new SubmissionWizardController.ProgramWrapper(objProgram, true, 12, 1000, true, '76');
        
        controller.prevSortdire = 'ASC';
        controller.getSortDirection();
        controller.setSortDirection(controller.prevSortdire);
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Minimum_Deposit_Count__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Credit_Score__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Years_in_Business__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'score';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Bank__r.Name';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Name';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Min_Monthly_Deposits__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Max_NDBs__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Min_Avg_Daily_Bal__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Max_No_NSFs__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Max_Amount__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Commission_Percentage__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        controller.ViewSortedData_Program();
        
        controller.sendWithoutAttachment();
        controller.createWithoutSending();
        controller.sendWithoutAttachment();
        ApexPages.currentPage().getParameters().put('isSelected', 'true');
        controller.checkUncheckAttachements();
        controller.checkReqdDocument();
        
        map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
        try {
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            controller.sendMail(mapPgmAttachment);
        } catch(Exception ex) {
        }
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
        Account acc = new Account(Name = pName,Email__c = 'test@test.com'+cnt, Industry = 'Government', BillingState = 'CO', Years_in_Business__c = 6,
                                    NSFs_Avg__c = 5, NDBs_Avg__c = 5, Gross_monthly_Sales__c = 100, recordTypeId = recrdType
                                    );
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
                                               Years_in_Business__c = 1 + index,
                                               Preffered_Programs__c = true,
                                               Restricted_States__c = 'AK',                                               
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
            lstSubmissionMailsDetail.add(new Submission_Mails_Detail__c(//Name= 'Test Program' + index,
                                               Is_Active__c = true,
                                               Message_Body__c = 'Test {!Opportunity.Name} AAA {!Opportunity.Account.Name} BBB' + 
                                                        '{!Opportunity.Owner_1__r.Name} ccc {!Program__c.Name} ddd {!SubmissionId} eee https://id={!SubmissionId}',
                                               Subject__c = 'Test Subject {!Opportunity.Account.Name}',
                                               CC_Address__c = 'test@gmail.com',
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
}