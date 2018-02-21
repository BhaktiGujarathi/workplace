@isTest
public class GRIDSyndicationControllerTest {
    
    static testMethod void syndControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceSynd = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Syndication', 2, true, 'GRIDSyndicationsFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDSyndicationsController syndControllerInstance = new GRIDSyndicationsController();
        
            syndControllerInstance.newSynd();
            syndControllerInstance.saveAllSynd();
            syndControllerInstance.getSyndWrapperLst();
            syndControllerInstance.editAllSynd();
            syndControllerInstance.refreshSynd();
            syndControllerInstance.nextSynd();
            syndControllerInstance.beginningSynd();
            syndControllerInstance.endSynd();
            syndControllerInstance.previousSynd();
            syndControllerInstance.syndIndexToRemove = 0;
            syndControllerInstance.deleteSynd();
            syndControllerInstance.syndSortDirection = 'ASC';
            syndControllerInstance.syndSortExpression = 'Syndicated_By__c';
            ApexPages.currentPage().getParameters().put('syndTypeParam','reference');
            syndControllerInstance.sortSynd();
        
        Test.stopTest();
    }
}