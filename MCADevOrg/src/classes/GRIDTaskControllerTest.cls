@isTest
public class GRIDTaskControllerTest {
    
    static testMethod void taskControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceTask = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance; 
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Task', 2, true, 'GRIDTaskFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDTaskController taskControllerInstance = new GRIDTaskController();
        
            taskControllerInstance.newTask();
            taskControllerInstance.saveAllTasks();
            taskControllerInstance.getTaskWrapperLst();
            taskControllerInstance.editAllTasks();
            taskControllerInstance.refreshTasks();
            taskControllerInstance.next();
            taskControllerInstance.beginning();
            taskControllerInstance.end();
            taskControllerInstance.previous();
            taskControllerInstance.indexToRemove = 0;
            taskControllerInstance.deleteTask();
            taskControllerInstance.taskSortDirection = 'ASC';
            taskControllerInstance.taskSortExpression = 'Subject';
            ApexPages.currentPage().getParameters().put('taskTypeParam','combobox');
            taskControllerInstance.sortTask();
        
        Test.stopTest();
    }
}