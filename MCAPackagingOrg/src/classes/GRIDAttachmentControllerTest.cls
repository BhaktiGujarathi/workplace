@isTest
public class GRIDAttachmentControllerTest {
    
    static testMethod void attchmntControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceAttachment = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        Attachment attchmntInstance = GRIDTestDataFactory.getGRIDAttachmentRecord(oppInstance.Id);
        insert attchmntInstance;        
        /*Submission__c submissionInstance = GRIDTestDataFactory.getSubmissionRecord(oppInstance.Id);
        insert submissionInstance;*/
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Attachment', 2, true, '');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDAttachmentController attchmntControllerInstance = new GRIDAttachmentController ();
        
            attchmntControllerInstance.saveAttachments();
            attchmntControllerInstance.getAttchmntWrapperLst();
            attchmntControllerInstance.editAllAttachments();
            attchmntControllerInstance.refreshAttachments();
            attchmntControllerInstance.nextAttachments();
            attchmntControllerInstance.beginningAttachments();
            attchmntControllerInstance.endAttachments();
            attchmntControllerInstance.previousAttachments();
            attchmntControllerInstance.attchmntIndexToRemove = 0;
            attchmntControllerInstance.deleteAttachment();
            attchmntControllerInstance.attchmntSortDirection = 'ASC';
            attchmntControllerInstance.attchmntSortExpression = 'Name';
            ApexPages.currentPage().getParameters().put('attchmntTypeParam','text');
            attchmntControllerInstance.sortAttachments();
            ApexPages.currentPage().getParameters().put('data', 'attchmntInstance.id');
            ApexPages.currentPage().getParameters().put('id', attchmntInstance.ParentId);
            ApexPages.currentPage().getParameters().put('name', attchmntInstance.Name);
            attchmntControllerInstance.CollectData();
        
        Test.stopTest();
    }
}