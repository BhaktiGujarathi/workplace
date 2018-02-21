@isTest
public class SubmissionSettingsControllerTest {
    
    static testMethod void submissionSettingTestMethod() {
        
    
        Test.startTest();
            PageReference pageRef = Page.SubmissionSettings;
            Test.setCurrentPage(pageRef);
            
            SubmissionWizardSettingsController submissionsettingControllerInstance = new SubmissionWizardSettingsController();
            submissionsettingControllerInstance.getCustomMetaDataofParentMap();            
            ApexPages.currentPage().getParameters().put('pageId','SubmissionWizardSettings');
            submissionsettingControllerInstance.page = 'SubmissionWizardSettings';
            submissionsettingControllerInstance.showSection();
            submissionsettingControllerInstance.page = 'GridSettings';
            submissionsettingControllerInstance.showSection();
            submissionsettingControllerInstance.page = 'newSettings';
            submissionsettingControllerInstance.showSection();
        Test.stopTest();
    }
}