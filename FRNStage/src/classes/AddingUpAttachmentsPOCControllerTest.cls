@isTest
private class AddingUpAttachmentsPOCControllerTest {
	
	@testSetup static void setupTestData() {
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Referral Source');
        accountObj.Name = 'Test referral';
        accountObj.Phone = '9865321471';
        accountObj.Type = 'Active';
        accountObj.Master_Referral_Type__c = 'Lawyer';
        accountObj.Special_Instructions__c = 'Special Instructions to be followed while treating the patients referred by this Account:';

        insert accountObj;

        Contact patientContactObj = new Contact();
        patientContactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Patient');
        patientContactObj.LastName = 'Patientcontact';
        insert patientContactObj;

        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        opportunityObj.Contact__c = patientContactObj.Id;
        opportunityObj.LeadSource = 'Alumni';
        opportunityObj.stageName = 'In Process';
        opportunityObj.CloseDate = system.Today().addMonths(5);
        opportunityObj.Name = 'Test Opportunity';

        insert opportunityObj;

        Document__c docObj = new Document__c();
        docObj.Account__c = accountObj.Id;
        docObj.Category__c = 'Referral Documents';
        insert docObj;

        Attachment attachmntObj = new Attachment();     
        attachmntObj.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachmntObj.body = bodyBlob;
        attachmntObj.parentId = docObj.id;
        insert attachmntObj;

        Document__c oppDocObj = new Document__c();
        oppDocObj.Opportunity__c = opportunityObj.Id;
        oppDocObj.Category__c = 'Referral Documents';
        oppDocObj.Linked_Document__c = docObj.Id;
        insert oppDocObj;
    }

    static testMethod void getFileIdTest() {
        Opportunity opportunityObj = [SELECT id,
                                             Referral_Instruction__c
                                        FROM Opportunity
                                       LIMIT 1];
        System.assertNotEquals(opportunityObj, null);

        Test.startTest();
            ApexPages.StandardController stdCntrllr = new ApexPages.StandardController(opportunityObj);
            AddingUpAttachmentsPOCController contrllr = new AddingUpAttachmentsPOCController(stdCntrllr);
            contrllr.getFileId();
        Test.stopTest();
    }

    static testMethod void getAttachedDocsListTest() {
        Opportunity opportunityObj = [SELECT id,
                                             Referral_Instruction__c
                                        FROM Opportunity
                                       LIMIT 1];
        System.assertNotEquals(opportunityObj, null);

        Test.startTest();
            ApexPages.StandardController stdCntrllr = new ApexPages.StandardController(opportunityObj);
            AddingUpAttachmentsPOCController contrllr = new AddingUpAttachmentsPOCController(stdCntrllr);
            AddingUpAttachmentsPOCController.getAttachedDocsList(opportunityObj.Id);
        Test.stopTest();
    }
	
}