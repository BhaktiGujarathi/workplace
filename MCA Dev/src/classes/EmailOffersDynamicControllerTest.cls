/**
**  Version     Author          Date(dd/mm/yyyy)        Description
**  1.0         Merul S         21/01/2017              Initial Draft[]
**  1.1         Ajinkya H       23/03/2017              Get Field Set from Custom Setting test
**
*/

@isTest
public class EmailOffersDynamicControllerTest {
    /**
    * Test offers available for opportunity
    */
    static testMethod void testOffersFieldset(){
        List<Opportunity> opprtunity = TestDataUtility.getOpportunityRecords(1);
        insert opprtunity;

        List<Submission__c> submissons = TestDataUtility.getSubmissionRecords(1, opprtunity[0].Id);
        insert submissons;

        FO_Email_Settings__c cstmSetting = new FO_Email_Settings__c(
            Name = 'Email Offers',
            Field_Set_API_Name__c = 'GRIDOfferFieldSet',
            Object_API_Name_for_Field_Set__c = 'Offer__c'
        );
        insert cstmSetting;

        List<Offer__c> offers = TestDataUtility.getOfferRecords(4,opprtunity[0].Id,submissons[0].Id);
        for(Offer__c offer :offers) {
            offer.Status__c = 'Rejected';
        }
        insert offers;
        EmailOffersDynamicController offerController = new EmailOffersDynamicController();
        offerController.getoffers();
        List<Offer__c> updatedOffers = [SELECT Id
                                             , Opportunity__c
                                        FROM Offer__c
                                        WHERE Opportunity__c =:opprtunity[0].Id];
        System.assertEquals(4, updatedOffers.size());
    }
}