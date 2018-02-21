@isTest
public class GRIDContactRolesControllerTest {
    
    static testMethod void creditCardsControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        
        GRIDOnloadStaticVariable.runOnceConRol = true;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        Contact conInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        insert conInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Contact Role', 2, true, '');
        insert settingInstance;
        */
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDContactRolesController conRolControllerInstance = new GRIDContactRolesController();
        
            conRolControllerInstance.newContactRole();
            conRolControllerInstance.conRoleWrapperLst[0].conRole.ContactId = conInstance.Id;
            conRolControllerInstance.saveContactRoles();
            
            conRolControllerInstance.getConRoleWrapperLst();
            conRolControllerInstance.editAllContactRoles();
            conRolControllerInstance.refreshContactRoles();
            conRolControllerInstance.nextContactRoles();
            conRolControllerInstance.beginningContactRoles();
            conRolControllerInstance.endContactRoles();
            conRolControllerInstance.previousContactRoles();
            conRolControllerInstance.conRoleIndexToRemove = 0;
            conRolControllerInstance.deleteContactRole();
            conRolControllerInstance.conRoleSortDirection = 'ASC';
            conRolControllerInstance.conRoleSortExpression = 'ContactId';
            ApexPages.currentPage().getParameters().put('conRoleTypeParam','reference');
            conRolControllerInstance.sortContactRoles();
        
        Test.stopTest();
    }
}