/**
 *  Version     Author          Date(DD/MM/YYYY)        Description
 *  1.0                                                 Initial Draft[]
 *  1.1         Ajinkya H       23/03/2017              Get Field Set from Custom Setting Test
*/
@isTest
private class EmailStipsDynamicControllerTest {

	static testMethod void testemailStips() {
        List<Opportunity> opprtunity = TestDataUtility.getOpportunityRecords(1);
        insert opprtunity;

        List<Submission__c> submissons = TestDataUtility.getSubmissionRecords(1, opprtunity[0].Id);
        insert submissons;

        FO_Email_Settings__c cstmSetting = new FO_Email_Settings__c(
            Name = 'Email Stips',
            Field_Set_API_Name__c = 'GRIDStipsFieldSet',
            Object_API_Name_for_Field_Set__c = 'Stips__c'
        );
        insert cstmSetting;
        
        List<Stips__c> Stips = TestDataUtility.getStipRecords(4,opprtunity[0].Id);
        for(Stips__c stip :Stips) {
            stip.Status__c = 'Pending';
        }
        insert Stips;
        EmailStipsDynamicController stipController = new EmailStipsDynamicController();
        stipController.getStips();
        List<Stips__c> updatedstips = [SELECT Id
                                             , Opportunity__c
                                        FROM Stips__c
                                        WHERE Opportunity__c =:opprtunity[0].Id];
        System.assertEquals(4, updatedstips.size());
	}
}