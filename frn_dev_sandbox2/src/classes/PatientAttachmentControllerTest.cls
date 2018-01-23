@isTest
private class PatientAttachmentControllerTest 
{
 
    Static testMethod void PatientAttachmentController_Test()
    {
        
        Contact con =new Contact();
       con.LastName ='test';
         insert con; 
        
        Document__c doc= new Document__c();
        doc.Category__c='Others';
        doc.Patient__c=con.id;
        insert doc;
        
        
        Attachment att = new Attachment();
        att.Name = 'test';
        att.ParentId = doc.id;
        att.ContentType = 'PDF';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        att.body=bodyBlob;
        insert att;
        
        PatientAttachmentController pac = new PatientAttachmentController();
        //pac.searchPat('testtest1');
       pac.doc=doc;
        pac.AttachmentsType();
        
     }  
}