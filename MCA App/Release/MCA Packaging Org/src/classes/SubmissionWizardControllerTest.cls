/**
 * This class contains unit tests for validating the behavior of SubmissionWizardController
 * 
 *  Date - 12-02-2014
 *
 *  Created By - Sneha P.
 */
@isTest(OnInstall=false)
private class SubmissionWizardControllerTest {

    
    static testMethod void submissionWizardValidTest() {
        Account acc = createAccount('TestAcc',1);
        
        Contact con = createContact('TestAcc',1);
         
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Prospecting' ,
                                         CloseDate = System.today(),Credit_Score__c = 20, Average_Daily_Balance__c=100,
                                         NSFs_Avg__c = 5, NDBs_Avg__c = 5, Avg_Number_Bank_Deposits__c = 100,
                                         Owner_1__c = con.id);
        insert opp;
         
        list<Program__c> lstPrograms = SubmissionWizardControllerTest.createPrograms(25);
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
        
        PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('isSelected', 'true');
        test.setCurrentPage(pageRef);
        SubmissionWizardController controller = new SubmissionWizardController();
        
        controller.clearFilter();
        controller.creditScore = string.ValueOf(20);
        controller.minMonthlyDeposite = string.valueOf(100);
        controller.minDepositeCount =  string.valueOf(10);
        controller.maxNSFs = string.ValueOf(5);
        controller.maxNDBs = string.ValueOf(5);
        controller.yearInBusiness = string.valueOf(8);
        controller.minAvgDailyBalance = string.valueOf(100);
        controller.prefferedProgram = true;
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Credit_Score__c';
        controller.getPrograms();
        controller.showMore();
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Minimum_Deposit_Count__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Years_in_Business__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Bank__r.Name';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Name';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Min_Monthly_Deposits__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Max_NDBs__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Min_Avg_Daily_Bal__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Max_No_NSFs__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Max_Amount__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Commission_Percentage__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'DESC';
        controller.sortExpression = 'Funding_Amt_of_Monthly_Gross_Sales__c';
        controller.ViewSortedData_Program();
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Minimum_Deposit_Count__c';
        controller.ViewSortedData_Program();
        SubmissionWizardController.sortDirection = 'ASC';
        controller.sortExpression = 'Years_in_Business__c';
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
        controller.programMap.put(lstPrograms[0].Id, lstPrograms[0]);
        controller.mailsDetails.add(lstSubmissionMailsDetail[0]);
        
        controller.checkReqdDocument();
        controller.selectDeselectAtt1();
        controller.programWrapperList1[0].isSelected =true;
        controller.createWithoutSending();
        controller.sendWithoutAttachment();
        controller.sendSelectedAttachments();
        controller.resetAttachments();
        controller.cancel();
        controller.openAttachment();
        controller.closePopup();
        map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
        mapPgmAttachment.put(lstAttachments[0].Id,lstAttachments);
        
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
    public static Account createAccount(String pName,Integer cnt){
        Account acc = new Account(Name = pName,Email__c = 'test@test.com'+cnt, Industry = 'Government', BillingState = 'CO', Years_in_Business__c = 6,
                                    NSFs_Avg__c = 5, NDBs_Avg__c = 5, Gross_monthly_Sales__c = 100);
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
    public static list<Program__c> createPrograms(Integer pCount){
        list<Program__c> lstTempPrograms = new list<Program__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempPrograms.add(new Program__c(Name= 'Test Program' + index,
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
                                                        '{!Opportunity.Owner_1__r.Name} ccc {!Program__c.Name} ddd {!SubmissionId}',
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
    
    //The method will create dummy records of Submission.
    public static list<Submission__c> createsubmission(Integer pCount, Id oppId) { 
        list<Submission__c> lstSubmission = new list<Submission__c>();
        for(Integer index = 0; index <= pCount; index++) {
            lstSubmission.add(new Submission__c(//Name= 'Test Program' + index,
                                               Opportunity__c = oppId,
                                               //Program__c = progId,
                                               Status__c = 'UW'
                                               
                                               ));
                                               //CC_Address__c = 'test' + index + '@gmail.com'));
        }//End for.
        return lstSubmission;
    }//End createsubmission
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