@isTest
public class GRIDReceivablesControllerTest {
    
    static testMethod void recControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceRec = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Receivable', 2, true, 'GRIDReceivableFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDReceivablesController recControllerInstance = new GRIDReceivablesController();
        
            recControllerInstance.newRec();
            recControllerInstance.saveReceivables();
            recControllerInstance.getRecWrapperLst();
            recControllerInstance.editAllReceivables();
            recControllerInstance.refreshReceivables();
            recControllerInstance.nextReceivable();
            recControllerInstance.beginningReceivable();
            recControllerInstance.endReceivable();
            recControllerInstance.previousReceivable();
            recControllerInstance.recIndexToRemove = 0;
            recControllerInstance.deleteRec();
            recControllerInstance.recSortDirection= 'ASC';
            recControllerInstance.recSortExpression = 'Amount__c';
            ApexPages.currentPage().getParameters().put('recTypeParam','currency');
            recControllerInstance.sortReceivables();
        
        Test.stopTest();
    }
}