/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DocumentViewerTest {

    static testMethod void myUnitTest() {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Phone = '1234567890';
        insert objAccount;
        
        NSIBPM__Service_Request__c objSR = new NSIBPM__Service_Request__c();
        objSR.Agency__c = objAccount.Id;
        insert objSR;
        
        NSIBPM__SR_Doc__c objSRDoc = new NSIBPM__SR_Doc__c();
        objSRDoc.NSIBPM__Service_Request__c = objSR.Id;
        insert objSRDoc;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Document';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = objAccount.Id;
        
        Attachment objAttachment1 = new Attachment();
        objAttachment1.Name = 'Test Document';
        objAttachment1.Body = blob.valueOf('test');
        objAttachment1.ParentId = objSRDoc.Id;
        insert objAttachment1;
        
        Apexpages.currentPage().getParameters().put('id',objSR.Id);
        DocumentViewer objDocumentViewer = new DocumentViewer();
        System.assertNOTEquals(null,objDocumentViewer.strObjectId);
        //System.assertEquals('Default Actions',objBR.Action_Type__c);
        objDocumentViewer.strObjectId = objSR.Id;
        objDocumentViewer.FileName = 'Test Doc.pdf';
        objDocumentViewer.document = objAttachment;
        objDocumentViewer.Cancel();
        objDocumentViewer.strSRDocId = objSRDoc.Id;
        objDocumentViewer.document = objAttachment;
        objDocumentViewer.strComments = 'Test Comments';
        objDocumentViewer.strExternalComments = 'Test Comments';
        objDocumentViewer.Upload();
        objDocumentViewer.AgrDocId = objSRDoc.Id;
        objDocumentViewer.EditDoc();
        objDocumentViewer.SaveDoc();
        objDocumentViewer.SaveDoc();
        objDocumentViewer.Back_To_SR();
    }
}