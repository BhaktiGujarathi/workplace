@isTest(seeAllData=false)
public class GRIDStipsControllerTest {
    
    static testMethod void stipsControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceStips = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        Submission__c submissionInstance = GRIDTestDataFactory.getSubmissionRecord(oppInstance.Id);
        insert submissionInstance;
        Attachment attchmntInstance = GRIDTestDataFactory.getGRIDAttachmentRecord(oppInstance.Id);
        insert attchmntInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Stip', 2, true, 'GRIDStipsFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDStipsController stipsControllerInstance = new GRIDStipsController();
            
            
            stipsControllerInstance.newStips();
            stipsControllerInstance.stipsWrapperLst[0].stips.Submission__c = submissionInstance.Id;
            stipsControllerInstance.saveAllStips();
            GRIDStipsController.getAttachments(oppInstance.Id, string.valueOf(attchmntInstance.Id));
            stipsControllerInstance.getStipsWrapperLst();
            stipsControllerInstance.editAllStips();
            stipsControllerInstance.refreshStips();
            stipsControllerInstance.nextStips();
            stipsControllerInstance.beginningStips();
            stipsControllerInstance.endStips();
            stipsControllerInstance.previousStips();
            stipsControllerInstance.stipsIndexToRemove = 0;
            stipsControllerInstance.deleteStips();
            stipsControllerInstance.stipsSortDirection = 'ASC';
            stipsControllerInstance.stipsSortExpression = 'Submission__c';
            ApexPages.currentPage().getParameters().put('stipstypeParam','reference');
            stipsControllerInstance.sortStips();
            ApexPages.currentPage().getParameters().put('data', 'attchmntInstance.Id');
            stipsControllerInstance.collectStipData();
        
        Test.stopTest();
    }
}