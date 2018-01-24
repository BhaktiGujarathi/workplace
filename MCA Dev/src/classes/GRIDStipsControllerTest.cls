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
        Stips__c stip = GRIDTestDataFactory.getStipRecord(oppInstance.Id);
        insert stip;
        Attachment attchmntInstance = GRIDTestDataFactory.getGRIDAttachmentRecord(oppInstance.Id);
        insert attchmntInstance;
        
        FO_Email_Settings__c foEmailSetting = GRIDTestDataFactory.createCustomSettingRecord(
            'Email Stips', 'GridStipsEmail', 'Stips__c', 'Reply_to_Address__c', 'Sender_s_Name__c'
        );
        insert foEmailSetting;
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
            ApexPages.currentPage().getParameters().put('stipID', stip.Id);
            stipsControllerInstance.collectStipData();
            stipsControllerInstance.stipBulkUpdate();
        Test.stopTest();
    }

    static testMethod void stipsControllerInValidTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceStips = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        Submission__c submissionInstance = GRIDTestDataFactory.getSubmissionRecord(oppInstance.Id);
        insert submissionInstance;
        Attachment attchmntInstance = GRIDTestDataFactory.getGRIDAttachmentRecord(oppInstance.Id);
        insert attchmntInstance;
        
        FO_Email_Settings__c foEmailSetting = GRIDTestDataFactory.createCustomSettingRecord(
            'Email Stips', 'GridStipsEmail', 'Stips__c', 'Reply_to_Address__c', 'Sender_s_Name__c'
        );
        insert foEmailSetting;

        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',null);
            GRIDStipsController stipsControllerInstance = new GRIDStipsController();
        Test.stopTest();
    }
}