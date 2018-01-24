@isTest
public class GRIDLoanBalanceControllerTest {
    
    static testMethod void loanBalControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceLoanBal = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Loan Balance', 2, true, 'GRIDLoanBalanceFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDLoanBalanceController loanBalControllerInstance = new GRIDLoanBalanceController();
        
            loanBalControllerInstance.newLoanBalance();
            loanBalControllerInstance.loanBalWrapperLst[0].LoanBal.Funder__c = accInstance.Id;
            loanBalControllerInstance.saveLoanBalances();
            loanBalControllerInstance.getLoanBalWrapperLst();
            loanBalControllerInstance.editAllLoanBalances();
            loanBalControllerInstance.refreshLoanBalances();
            loanBalControllerInstance.nextLoanBalances();
            loanBalControllerInstance.beginningLoanBalances();
            loanBalControllerInstance.endLoanBalances();
            loanBalControllerInstance.previousLoanBalances();
            loanBalControllerInstance.loanBalIndexToRemove = 0;
            loanBalControllerInstance.deleteLoanBalance();
            loanBalControllerInstance.loanBalSortDirection = 'ASC';
            loanBalControllerInstance.loanBalSortExpression = 'Funder__c';
            ApexPages.currentPage().getParameters().put('loanBalTypeParam','reference');
            loanBalControllerInstance.sortLoanBalances();
        
        Test.stopTest();
    }
}