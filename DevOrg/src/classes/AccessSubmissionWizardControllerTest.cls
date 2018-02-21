/* 
 * Test Class for AccessSubmissionWizard which download the attachments.
 *
 * Version     Author                     Date              Comments
 * 1.0         Yogesh Mahajan             12/29/2015        Initial Draft
 */

@isTest
private Class AccessSubmissionWizardControllerTest {
    static testMethod void downloadAttachmentOfSubmissionTest() {
        
        List<Account> listAccount = TestDataUtility.getAccountRecords(1);
        insert listAccount;
        System.assertNotEquals(null,listAccount);
        
        List<Contact> listOfContact = new List<Contact>();
        
        System.assertNotEquals(null, listOfContact);
        for(Contact cont :TestDataUtility.getContactRecords(4)) {
            cont.AccountId = listAccount[0].Id;
            listOfContact.add(cont);
        }
        insert listOfContact;
        System.assertNotEquals(null, listOfContact);
        
        List<Opportunity> listOpp = TestDataUtility.getOpportunityRecords(10);
        insert listOpp;
        
        listOpp[0].AccountId = listAccount[0].Id;
        listOpp[0].Owner_1__c = listOfContact[0].Id;
        listOpp[0].Owner_2__c = listOfContact[1].Id;
        update listOpp[0];
        
        List<Submission__c> submissionInstance = TestDataUtility.getSubmissionRecords(3,listOpp[0].Id);
        insert submissionInstance;
        System.assertNotEquals(null, submissionInstance);
        
        List<Attachment> listOfAttach = new List<Attachment>();
        for(Attachment attach :TestDataUtility.getattachmentRecords(4)) {
            attach.ParentId = submissionInstance[0].Opportunity__c;
            listOfAttach.add(attach);
        }
        insert listOfAttach;
        System.assertNotEquals(null, listOfAttach);
        
        AccessSubmissionWizardController controllerInstance = new AccessSubmissionWizardController();
        AccessSubmissionWizardController.oppId = submissionInstance[0].Opportunity__c;
        apexpages.currentpage().getparameters().put('id',submissionInstance[0].Id);
        controllerInstance.querySubmission();
        controllerInstance.getSubmission();
        System.assertEquals(submissionInstance[0].Id,controllerInstance.submission[0].Id);
        
        controllerInstance.getlistWrapperAttachment();
        
        controllerInstance.FirstPage();
        controllerInstance.previous();
        controllerInstance.next();
        controllerInstance.LastPage();
        controllerInstance.getprev();
        controllerInstance.getnxt();
        
        List<String> listOfString = new List<String>();
        listOfString.add(string.ValueOf(listOfAttach));
        AccessSubmissionWizardController.getAttachments(string.ValueOf(submissionInstance[0].Opportunity__c),listOfString,true );
        System.assertEquals(4, listOfAttach.size());
        
        AccessSubmissionWizardController.getAttachments(string.ValueOf(submissionInstance[0].Opportunity__c),listOfString,false);
        
        delete submissionInstance[0];
        apexpages.currentpage().getparameters().put('id',submissionInstance[0].Id);
        controllerInstance.querySubmission();
        controllerInstance.getSubmission();
    }
    
    static testMethod void downloadAttachmentOfSubmissionInvalidTest() {
        AccessSubmissionWizardController controllerInstance = new AccessSubmissionWizardController();
        controllerInstance.querySubmission();
    }
}