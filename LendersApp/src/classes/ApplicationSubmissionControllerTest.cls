@isTest
public with sharing class ApplicationSubmissionControllerTest {
    

    @isTest
    public static void testApplicationSubmissionController() {
        
        Lead l = new Lead();
        l.LastName = 'Test';
        l.Company = 'Test';
        insert l;

    
        ApexPages.currentPage().getParameters().put('lid', l.Id);       
        
        ApplicationSubmissionController controller = new ApplicationSubmissionController();

        controller.bankStatement.File_Name__c = 'Test';
        controller.bankStatementsFileBody = Blob.valueOf('Test');
        
        controller.creditCardStatement.File_Name__c = 'Test';
        controller.creditCardStmtsFileBody = Blob.valueOf('Test');
        
        controller.driverLicense.File_Name__c = 'Test';
        controller.driversLicenseFileBody = Blob.valueOf('Test');

        controller.voidedCheck.File_Name__c = 'Test';
        controller.voidedCheckFileBody = Blob.valueOf('Test');

        controller.stage = 'stage4';
        controller.changeStage();

        controller.save();

        controller.stage = 'stage2';
        controller.changeStage();

        controller.save();


        Application__c a = new Application__c();
        a.Email_Address__c = 'test@test.com';
        a.Stage__c = 'Business Information';
        insert a;

        Application_Document__c ad1 = new Application_Document__c();
        ad1.Name = 'Bank Statement';
        ad1.Application__c = a.Id;
        insert ad1;

        Application_Document__c ad2 = new Application_Document__c();
        ad2.Name = 'Credit Card Statement';
        ad2.Application__c = a.Id;
        insert ad2;

        Application_Document__c ad3 = new Application_Document__c();
        ad3.Name = 'Copy of Drivers License';
        ad3.Application__c = a.Id;
        insert ad3;       

        Application_Document__c ad4 = new Application_Document__c();
        ad4.Name = 'Copy of Voided Check';
        ad4.Application__c = a.Id;
        insert ad4;         


        ApexPages.currentPage().getParameters().put('id', a.Id);
        controller = new ApplicationSubmissionController();

        controller.applicationNumber = [select Name from Application__c where Id = :a.Id].Name;
        controller.email = a.Email_Address__c;
        controller.queryApplicationByApplicationNumber();

        ApexPages.currentPage().getParameters().put('aid', ad1.Id);
        controller.deleteAttachment();

        ApexPages.currentPage().getParameters().put('aid', ad2.Id);
        controller.deleteAttachment();

        ApexPages.currentPage().getParameters().put('aid', ad3.Id);
        controller.deleteAttachment();

        ApexPages.currentPage().getParameters().put('aid', ad4.Id);
        controller.deleteAttachment();

        controller.submitApplication();
    }
}