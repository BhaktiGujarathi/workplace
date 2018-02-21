@isTest
private Class SubmissionSiteControllerTest {
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
        
        List<Attachment> listOfAttach = new List<Attachment>();
        for(Attachment attach :TestDataUtility.getattachmentRecords(4)) {
            attach.ParentId = listOpp[0].Id;
            listOfAttach.add(attach);
        }
        insert listOfAttach;
        System.assertNotEquals(null, listOfAttach);
        
        List<Submission__c> lstSubmission = new List<Submission__c>();
        for(Submission__c objSub :TestDataUtility.getSubmissionRecords(3,listOpp[0].Id)) {
            objSub.Selected_Attachment_Id__c = listOfAttach[0].Id+','+listOfAttach[1].Id;
            lstSubmission.add(objSub);
        }
        insert lstSubmission;
        System.assertNotEquals(null, lstSubmission);
        
        Blob cryptoKey = Blob.valueOf('1234567890123456');
        Blob data = Blob.valueOf(lstSubmission[0].Id);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
        String encryptedId = EncodingUtil.base64Encode(encryptedData);  
        system.debug('>>> encryptedId : '+encryptedId);
        
        SubmissionSiteController controllerInstance = new SubmissionSiteController();
        SubmissionSiteController.oppId = lstSubmission[0].Opportunity__c;                    
        
        apexpages.currentpage().getparameters().put('id',encryptedId);
        controllerInstance.querySubmission();
        controllerInstance.getSubmission();
        System.assertEquals(lstSubmission[0].Id,controllerInstance.submission[0].Id);
        
        controllerInstance.getlistWrapperAttachment();
        
        controllerInstance.FirstPage();
        controllerInstance.previous();
        controllerInstance.next();
        controllerInstance.LastPage();
        controllerInstance.getprev();
        controllerInstance.getnxt();
        List<String> listOfString = new List<String>();
        listOfString.add(string.ValueOf(listOfAttach));
        SubmissionSiteController.getAttachments(string.ValueOf(lstSubmission[0].Opportunity__c),listOfString);
        System.assertEquals(4, listOfAttach.size());
        
        SubmissionSiteController.getAttachments(string.ValueOf(lstSubmission[0].Opportunity__c),listOfString);
        delete lstSubmission[0];
        
        apexpages.currentpage().getparameters().put('id', encryptedId);
        controllerInstance.querySubmission();
        controllerInstance.getSubmission();
    }
    
    static testMethod void downloadAttachmentOfSubmissionInvalidTest() {
        SubmissionSiteController controllerInstance = new SubmissionSiteController();
        controllerInstance.querySubmission();
    }
}