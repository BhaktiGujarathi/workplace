@isTest
public class GRIDCreditCardsControllerTest {
    
    static testMethod void creditCardsControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceCreditCard = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Credit Card', 2, true, 'GRIDCreditCardFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDCreditCardsController syndControllerInstance = new GRIDCreditCardsController();
        
            syndControllerInstance.newCreditCard();
            syndControllerInstance.saveCreditCards();
            syndControllerInstance.getCardWrapperLst();
            syndControllerInstance.editAllCreditCards();
            syndControllerInstance.refreshCreditCards();
            syndControllerInstance.nextCreditCards();
            syndControllerInstance.beginningCreditCards();
            syndControllerInstance.endCreditCards();
            syndControllerInstance.previousCreditCards();
            syndControllerInstance.cardIndexToRemove = 0;
            syndControllerInstance.deleteCreditCard();
            syndControllerInstance.cardSortDirection= 'ASC';
            syndControllerInstance.cardSortExpression = 'Number_of_Transactions_All__c';
            ApexPages.currentPage().getParameters().put('cardTypeParam','number');
            syndControllerInstance.sortCreditCards();
        
        Test.stopTest();
    }
}