@isTest
public class GRIDPayablesControllerTest {
    
    static testMethod void payControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOncePay = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Payable', 2, true, 'GRIDPayableFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDPayablesController payControllerInstance = new GRIDPayablesController();
        
            payControllerInstance.newPay();
            payControllerInstance.savePayables();
            payControllerInstance.getPayWrapperLst();
            payControllerInstance.editAllPayables();
            payControllerInstance.refreshPayables();
            payControllerInstance.nextPayable();
            payControllerInstance.beginningPayable();
            payControllerInstance.endPayable();
            payControllerInstance.previousPayable();
            payControllerInstance.payIndexToRemove = 0;
            payControllerInstance.deletePay();
            payControllerInstance.paySortDirection = 'ASC';
            payControllerInstance.paySortExpression = 'Amount_Due__c';
            ApexPages.currentPage().getParameters().put('payTypeParam','currency');
            payControllerInstance.sortPayables();
        
        Test.stopTest();
    }
}