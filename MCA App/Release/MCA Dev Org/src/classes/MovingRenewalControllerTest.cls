/**

 *  Description -  Test Class for MovingRenewalController
 *
 * Version     Author                      Date                 Description
 * 1.0         Ajay Singh Solanki          03/31/2014           Initial Draft
 *                                                          
 */
    
@isTest(SeeAlldata=True)
private class MovingRenewalControllerTest {

    //method for testing MovingRenewalController class for save method.
    static testMethod void ManageRenewalSaveTest() {
       //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       insert oppList; //opportunity list inserted
       
       //created list of contract record
       List<Contract> conList = MovingRenewalControllerTest.createContractRecords(accRecord.Id, oppList);
       insert conList; //contract list inserted
       
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       //created intence of MovingRenewalController class
       MovingRenewalController movingRenewal = new MovingRenewalController();
        if(movingRenewal.RenewalWrapperLst.size()>0 && movingRenewal.RenewalWrapperLst != null){
           movingRenewal.RenewalWrapperLst[0].isSelected = true;
          }
                 
       oppList[0].Current_Balance_Date__c = system.today();
       movingRenewal.save();
       Test.stopTest();
    }
    
    //method for testing MovingRenewalController class for delayFunctionality method.
    static testMethod void ManageRenewalDelayEligibilityTest() {
       //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       insert oppList; //opportunity list inserted
       
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       //created instance of MovingRenewalController class
       MovingRenewalController movingRenewal = new MovingRenewalController();
                 movingRenewal.RenewalWrapperLst[0].isSelected = true;
                 movingRenewal.displayDelayEligibility();
                 movingRenewal.DelayTime = '1';
                 movingRenewal.delayTime();
                 Opportunity con = [select Id,Estimated_Renewal_Date__c 
                                 from Opportunity 
                                 where Id =: oppList[0].Id];
                 system.assertEquals(oppList[0].Estimated_Renewal_Date__c,con.Estimated_Renewal_Date__c); 
        movingRenewal.SelectedUser = '--Opportunity Owner--';       
        movingRenewal.createOpportunities();
        movingRenewal.clearFilter();
        movingRenewal.RenewalWrapperLst[0].isSelected = false;
        movingRenewal.createOpportunities();
        Test.stopTest();
       
    }
    
    //method for testing filter Functionality MovingRenewalController class
    static testMethod void ManageRenewalFilterFunctionalityTest() {
         //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       for(Opportunity opp :oppList){
           opp.AccountId = accRecord.Id;
       }
       insert oppList; //opportunity list inserted
       
       List<Submission_Mails_Detail__c> submissionDetailList = MovingRenewalControllerTest.createSubmissionDetails(1);
       insert submissionDetailList;
        
       //created intence of MovingRenewalController class
       MovingRenewalController movingRenewal = new MovingRenewalController();
       movingRenewal.RenewalDateFunded = '--None--';
       movingRenewal.Cont = new Opportunity();
       movingRenewal.Cont.Estimated_Renewal_Date__c = system.today();
       movingRenewal.RenewalEligibilityPer = '0';
       movingRenewal.Cont.Bank_Name__c = null;
       movingRenewal.getContractsAfterFilter();
       movingRenewal.Cont.Bank_Name__c = accRecord.Id;
       movingRenewal.RenewalEligibilityPer = '1';
       //movingRenewal.bankName = 'abc';
       movingRenewal.cont.Estimated_Renewal_Date__c = system.today();
       movingRenewal.RenewalDateFunded = '1-3 Months Ago';
       movingRenewal.myDealsCheckbox = true;
       movingRenewal.getContractsAfterFilter();
       movingRenewal.RenewalEligibilityPer = '1';
        movingRenewal.RenewalDateFunded = '4-6 Months Ago';
        movingRenewal.getContractsAfterFilter();
        movingRenewal.RenewalDateFunded = '7-9 Months Ago';
        movingRenewal.getContractsAfterFilter();
        movingRenewal.RenewalDateFunded = '10-12 Months ago';
        movingRenewal.getContractsAfterFilter();
        movingRenewal.RenewalDateFunded = '12+ Months';
        movingRenewal.getContractsAfterFilter();
        movingRenewal.uploadFile();
        movingRenewal.strBcc = 'abc@abc.com';
        list<Attachment> lstAttachments = MovingRenewalControllerTest.createAttachments(3, oppList[0].Id);
        insert lstAttachments;
        movingRenewal.attachFile();
        movingRenewal.strSubject = 'Renewal';
        //movingRenewal.RenewalWrapperLst[0].isSelected = true;
        movingRenewal.sendAnEmail();
        movingRenewal.getAttachments();
        movingRenewal.cancelTemplate();
        movingRenewal.removeAttachment();
        movingRenewal.selectTemplate();
        movingRenewal.cancel();        
        movingRenewal.SendMail();
        movingRenewal.displayMessageBodyContent();
        movingRenewal.messageBodyContent('leo','abc,Thanks, xyz','Dev','CMB');
        movingRenewal.displayCreateFollowupTask();
        movingRenewal.ClosePopupTask();
        movingRenewal.CloseUserTaskPopup();
        movingRenewal.ViewSortedData_Contract();
        movingRenewal.displayCreateOpportunities();
        movingRenewal.ClosePopup();
        movingRenewal.CloseUserPopup();
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       movingRenewal.init();
       movingRenewal.RenewalWrapperLst[0].isSelected = true;
       movingRenewal.createFollowupTask() ;
       movingRenewal.getContractsAfterFilter();
        
        movingRenewal.setSortDirection('Desc');
        movingRenewal.getSortDirection();
        movingRenewal.sortExpression = 'Name';
        movingRenewal.ViewSortedData_Contract();    
        movingRenewal.uploadFile();
        movingRenewal.strBcc = 'abc@abc.com';
        list<Attachment> lstAttachments1 = MovingRenewalControllerTest.createAttachments(3, oppList[0].Id);
        insert lstAttachments1;
        movingRenewal.attachFile();
        movingRenewal.strSubject = 'Renewal';
        //movingRenewal.RenewalWrapperLst[0].isSelected = true;
        movingRenewal.sendAnEmail();
       
        movingRenewal.getAttachments();
        movingRenewal.cancelTemplate();
        movingRenewal.removeAttachment();
        movingRenewal.selectTemplate();
        movingRenewal.cancel();   
        movingRenewal.init();
        if(movingRenewal.RenewalWrapperLst.size()>0 && movingRenewal.RenewalWrapperLst != null){
                 movingRenewal.RenewalWrapperLst[0].isSelected = true;
          }    
        movingRenewal.SendMail();
        movingRenewal.displayMessageBodyContent();
        movingRenewal.messageBodyContent('leo','abc,Thanks, xyz','Dev','CMB');
        movingRenewal.displayCreateFollowupTask();
        movingRenewal.ClosePopupTask();
        movingRenewal.CloseUserTaskPopup();
        movingRenewal.ViewSortedData_Contract();
        movingRenewal.displayCreateOpportunities();
        movingRenewal.ClosePopup();
        movingRenewal.CloseUserPopup();   
        Test.stopTest();
         movingRenewalControllertest.sendAnEmail();
    }//End filterFunctionalityTest method.
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
        
       Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '0223455712');   
      
        return account;
    }
    
    //Method will create dummy records of Contract
    public static List<Contract> createContractRecords(string pAccountId, list<Opportunity> lstOpp){
        
        list<Contract> conRecordList = new List<Contract>();
        for(Integer oppCount = 1; oppCount <=10; oppCount++){
            
            conRecordList.add(new Contract(Name = 'Test Contract1'+ oppCount,Bank__c=pAccountId,
                                          Status='Draft',AccountId=pAccountId, Opportunity__c = lstOpp[oppCount-1].Id
                                           ));
        }//for
        return conRecordList;
    } 
    
    //Method will create dummy records of Opportunity 
    public static list<Opportunity> createOpportunityRecord(Integer pCountOfOpportunity){
    
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer intIndex = 0; intIndex < pCountOfOpportunity; intIndex ++){
            
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'testOpp' + intIndex;
            objOpp.StageName = 'Application Sent';
            objOpp.CloseDate = Date.today();
            objOpp.Funding_Amount__c = 5000;
            objOpp.Payback_Amount__c = 8000;
            
            objOpp.ForecastCategoryName = 'Pipeline';
            oppList.add(objOpp);                       
        }//End for
        return oppList;
    }    
    
     public static list<Attachment> createAttachments(Integer pCount, Id pOppId){
        list<Attachment> lstTempAttachments = new list<Attachment>();
        for(Integer index = 0; index <= pCount; index++){
            lstTempAttachments.add(new Attachment(Name = 'Test Doc' + index, 
                                                  ParentId = pOppId, 
                                                  Body = Blob.valueOf('Test Attachment' + index)));
        }
                
        return lstTempAttachments;
    }//End createAttachments method.
    
    public static list<Submission_Mails_Detail__c> createSubmissionDetails(Integer pCount){
        list<Submission_Mails_Detail__c> lstSubmissionDetails = new list<Submission_Mails_Detail__c>();
        for(Integer index = 0; index <= pCount; index++){
            lstSubmissionDetails.add(new Submission_Mails_Detail__c(Name = 'Renewal Email', 
                                                            Is_Active__c = True,
                                                                     Message_Body__c = 'Details of Submissions in mail')
                                    );
        }
                
        return lstSubmissionDetails;
    }//End createAttachments method.
    
    //Method will return Record Type Id.
    public Id getBankRecordTypeId(Id pRecordTypeName){
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get(pRecordTypeName);
        return rtByName.getRecordTypeId();
    }//End returnBankRecordTypeId method.
    
    static testmethod void sendAnEmail(){
        String strAdditionalTo = '';
        String strSubject = '';
        Messaging.SingleEmailMessage mail 
            = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        MovingRenewalController movingRenewal =   
                 new MovingRenewalController();
        List<Attachment> lstAttachment = new list<Attachment>();
        Attachment atc =new Attachment();
        atc.Name='Test Attachment';
        lstAttachment.add(atc);
        system.debug('Attachment added'+lstAttachment);
        allMails.add(mail);
        //system.Test.startTest();
        movingRenewal.strAdditionalTo = 'abc@abc.com';
        movingRenewal.strSubject  = '{Account Name}';
        movingRenewal.SendAnEmail();
        //system.Test.stopTest();
    }
}