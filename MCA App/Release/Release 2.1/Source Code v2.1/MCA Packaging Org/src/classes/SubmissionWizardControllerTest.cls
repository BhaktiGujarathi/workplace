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
        //Create Acc
        Account acc = createAccount('TestAcc',0);
        Account Bank1 = createAccount('Bank 1',1);
        Account Bank2 = createAccount('Bank 2',2);
        
        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;
       
        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = createSubmissionMailsDetail(1);
        insert  lstSubmissionMailsDetail;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',Credit_Score__c=100,Amount_Requested__c = 100, AccountId = acc.Id, StageName ='Application Missing Info' ,
                                         CloseDate = System.today());
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
            system.assertEquals(cntl.programWrapperList.size(), 9);
            
            cntl.program.Industry__c = 'Government';
            cntl.program.Credit_Score__c = 20;
            cntl.program.Years_in_Business__c = 5;           
            cntl.getPrograms();
            
           // system.assertEquals(cntl.programWrapperList.size(), 9);
            
            //Give the filter as Government, and check if 3 programs are displayed
            cntl.program.Industry__c = 'Government';
            cntl.program.Credit_Score__c = null;
            cntl.program.Years_in_Business__c = null;            
            cntl.getPrograms();
            //system.assert(cntl.programWrapperList.size() == 3);
            
            //Check if the required documents are shown in popup on click of button
            cntl.checkReqdDocument();
            system.assertEquals(cntl.displayPopup, true);
            // && cntl.prgmDocMap.size() == 1);
            cntl.closePopup();
            
            cntl.getMapSize();
            cntl.resetAttachments();
            
            
            cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[0].id);
            cntl.AttachmentWrapperList[0].selectedPrograms.add(lstAttachments[1].id);
            cntl.programWrapperList[0].isSelected = true;
            
            cntl.sendWithoutAttachment();
            cntl.sendSelectedAttachments();
            cntl.openAttachment();
            
            cntl.cancel();
            cntl.clearFilter();
            cntl.getSortDirection();
            cntl.setSortDirection('Desc');
            cntl.ViewSortedData_Program();
            SubmissionWizardController.sortDirection = 'ASC';
            cntl.programWrapperList.sort();
            SubmissionWizardController.sortDirection = 'DESC';
            cntl.programWrapperList.sort();
           Test.stopTest();
    }
    static testMethod void testCreateWoSending() {
         Account acc = createAccount('TestAcc',0);
        Account Bank1 = createAccount('Bank 1',1);
        Account Bank2 = createAccount('Bank 2',2);
        
        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = createSubmissionMailsDetail(1);
        insert  lstSubmissionMailsDetail;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',Credit_Score__c=100,Amount_Requested__c = 100, AccountId = acc.Id, StageName ='Application Missing Info' ,
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
            
            cntl.createWithoutSending();
            
            list<Submission__c> submissionList = [Select Id, Name, Opportunity__c 
                                                   from Submission__c 
                                                   where Opportunity__c =: opp.Id ] ;
            system.assert(submissionList.size() == 3);
            
        Test.StopTest();
    }
    
    static testMethod void myUnitTest2() {
         // TO DO: implement unit test
        //Create Acc
        Account acc = createAccount('TestAcc',0);
        Account Bank1 = createAccount('Bank 1',1);
        Account Bank2 = createAccount('Bank 2',2);
        
        list<Attachment> lstAttachments = SubmissionWizardControllerTest.createAttachments(3, acc.Id);
        insert lstAttachments;
        

        list<Submission_Mails_Detail__c> lstSubmissionMailsDetail = createSubmissionMailsDetail(1);
        insert  lstSubmissionMailsDetail;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',Credit_Score__c=100,Amount_Requested__c = 100, AccountId = acc.Id, StageName ='Application Missing Info' ,
                                         CloseDate = System.today());
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
            pageRef.getParameters().put('attId', lstAttachments[0].Id);
            test.setCurrentPage(pageRef);
                 
            SubmissionWizardController cntl = new SubmissionWizardController();
            
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
            //cntl.showMore();
            //cntl.messageBodyContent();
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
        Account acc = new Account(Name = pName,NSFs_Avg__c = 10,Email__c = 'test@test.com'+cnt);
        insert acc;
        return acc;
    }
    
    //The method will create dummy records of Program.
    public static list<Program__c> createPrograms(Integer pCount){
        list<Program__c> lstTempPrograms = new list<Program__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempPrograms.add(new Program__c(Name= 'Test Program' + index,
                                               Preffered_Programs__c = true,
                                               Credit_Score__c = 20 + index,
                                               Years_in_Business__c = 5 + index,
                                               Industry__c = 'Government',  
                                               Min_Monthly_Deposits__c = 100,                                           
                                               Submission_Email__c = 'test' + index + '@gmail.com'));
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
                                               CC_Address__c = 'test' + index + '@gmail.com'));                                             
        }//End for.
        return lstSubmissionMailsDetail;
    }//End SubmissionMailsDetail method.
    
  /* static testMethod void myUnitTest4() { 
    Account acc = new Account(Name ='TESTNAME',NSFs_Avg__c = 10,Email__c = 'test@test.com');
        insert acc;
   Opportunity opp = new Opportunity(Name = 'Test Opp',Credit_Score__c=100,Amount_Requested__c = 100, AccountId = acc.Id, StageName ='Application Missing Info' ,
                                         CloseDate = System.today());
        insert opp;
   PageReference pageRef = Page.SubmissionWizard;
   
   SubmissionWizardController cntl1 = new SubmissionWizardController();
   //cntl1.SubmissionWizardController(); 
   cntl1.showMore();
   cntl1.messageBodyContent();
       
   }*/
    
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