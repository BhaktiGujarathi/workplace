@isTest
public class GRIDSubmissionControllerTest {
    
    static testMethod void submissionControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceSubmission = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Submission', 2, true, 'GRIDSubmissionFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDSubmissionController submissionControllerInstance = new GRIDSubmissionController();
        
            submissionControllerInstance.newSubmission();
            submissionControllerInstance.saveSubmissions();
            submissionControllerInstance.getsubmisionWrapperLst();
            submissionControllerInstance.editAllSubmissions();
            submissionControllerInstance.refreshSubmissions();
            submissionControllerInstance.nextSubmissions();
            submissionControllerInstance.beginningSubmissions();
            submissionControllerInstance.endSubmissions();
            submissionControllerInstance.previousSubmissions();
            submissionControllerInstance.submisionIndexToRemove = 0;
            submissionControllerInstance.deleteSubmission();
            submissionControllerInstance.submisionSortDirection= 'ASC';
            submissionControllerInstance.submisionSortExpression = 'Application_Number__c';
            ApexPages.currentPage().getParameters().put('submisionTypeParam','currency');
            submissionControllerInstance.sortSubmissions();
        
        Test.stopTest();
    }
}