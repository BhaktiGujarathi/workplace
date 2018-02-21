@isTest
public class GRIDOffersControllerTest {
    
    static testMethod void offersControllerTest() {
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        insert accInstance;
        GRIDOnloadStaticVariable.runOnceOffer = true;
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        insert oppInstance;
        Submission__c submissionInstance = GRIDTestDataFactory.getSubmissionRecord(oppInstance.Id);
        insert submissionInstance;
        
        /*
        GRIDTabSetting__c settingInstance = GRIDTestDataFactory.getGRIDTabSettingRecord('Offer', 2, true, 'GRIDOfferFieldSet');
        insert settingInstance;
        */
        
        Test.startTest();
            PageReference pageRef = Page.GRIDHomePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',oppInstance.Id);
            GRIDOffersController offrControllerInstance = new GRIDOffersController();
        
            offrControllerInstance.newOffer();
            //offrControllerInstance.offrWrapperLst[0].offr.Submission__c = submissionInstance.Id;
            offrControllerInstance.offrWrapperLst[0].offrSubmissionValue = submissionInstance.Id;
            offrControllerInstance.saveOffers();
            offrControllerInstance.getOffrWrapperLst();
            offrControllerInstance.editAllOffers();
            offrControllerInstance.refreshOffers();
            offrControllerInstance.nextOffers();
            offrControllerInstance.beginningOffers();
            offrControllerInstance.endOffers();
            offrControllerInstance.previousOffers();
            offrControllerInstance.offrIndexToRemove = 0;
            offrControllerInstance.deleteOffer();
            offrControllerInstance.offrSortDirection = 'ASC';
            offrControllerInstance.offrSortExpression = 'Funder__c';
            ApexPages.currentPage().getParameters().put('offrTypeParam','reference');
            offrControllerInstance.sortOffers();
        
        Test.stopTest();
    }
}