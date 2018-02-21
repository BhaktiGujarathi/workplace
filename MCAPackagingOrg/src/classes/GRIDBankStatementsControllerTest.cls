@isTest
public class GRIDBankStatementsControllerTest {
    
    static testMethod void bankStmntControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceBankStatement = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Bank Statement', 2, true, 'GRIDBankStatementFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDBankStatementsController bankStmntControllerInstance = new GRIDBankStatementsController();
        
            bankStmntControllerInstance.newBankStatement();
            bankStmntControllerInstance.saveBankStatements();
            bankStmntControllerInstance.getBankStmntWrapperLst();
            bankStmntControllerInstance.editAllBankStatements();
            bankStmntControllerInstance.refreshBankStatements();
            bankStmntControllerInstance.nextBankStatements();
            bankStmntControllerInstance.beginningBankStatements();
            bankStmntControllerInstance.endBankStatements();
            bankStmntControllerInstance.previousBankStatements();
            bankStmntControllerInstance.bankStmntIndexToRemove = 0;
            bankStmntControllerInstance.deleteBankStatement();
            bankStmntControllerInstance.bankStmntSortDirection = 'ASC';
            bankStmntControllerInstance.bankStmntSortExpression = 'Include_in_average__c';
            ApexPages.currentPage().getParameters().put('bankStmntTypeParam','checkbox');
            bankStmntControllerInstance.sortBankStatements();
        
        Test.stopTest();
    }
}