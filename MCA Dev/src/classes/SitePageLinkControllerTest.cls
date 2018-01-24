/* 
 * Test Class for SitePageLinkController which download the attachments.
 *
 * Version     Author                     Date              Comments
 * 1.0         Merul Shah            12/29/2015        Initial Draft
 */

@isTest
private Class SitePageLinkControllerTest {

    static testMethod void validEncryptionTest() {
        List<Opportunity> listOpp = TestDataUtility.getOpportunityRecords(1);
        insert listOpp;
        
        List<Submission__c> lstSubmission = TestDataUtility.getSubmissionRecords(1,listOpp[0].Id);
        insert lstSubmission;
        
        SitePageLinkController controllerInstance = new SitePageLinkController();
        controllerInstance.submissionId = lstSubmission[0].Id;
        controllerInstance.encryptedId = controllerInstance.getEncryptedId();
        System.assertNotEquals(null, controllerInstance.encryptedId);
        
    }
    
    static testMethod void inValidEncryptionTest() {
        List<Opportunity> listOpp = TestDataUtility.getOpportunityRecords(1);
        insert listOpp;
        
        List<Submission__c> lstSubmission = TestDataUtility.getSubmissionRecords(1,listOpp[0].Id);
        insert lstSubmission;
        
        SitePageLinkController controllerInstance = new SitePageLinkController();
        controllerInstance.submissionId = null;
        controllerInstance.encryptedId = controllerInstance.getEncryptedId();
        System.assertEquals(null, controllerInstance.encryptedId);
    }
}