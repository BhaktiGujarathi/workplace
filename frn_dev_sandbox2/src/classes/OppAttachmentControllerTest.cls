@isTest
public class OppAttachmentControllerTest 
{
 
    private static TestMethod  void OppAttachmentController_UnitTest()
    {
        
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
        
        Document__c doc= new Document__c();
        doc.Category__c='Others';
        doc.Opportunity__c=opp.id;
        insert doc;
        
        Attachment att = new Attachment();
        att.Name = 'test';
        att.ParentId = doc.id;
        att.ContentType = 'PDF';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        att.body=bodyBlob;
        insert att;
        
        OppAttachmentController oac = new OppAttachmentController();
        oac.docobj=doc;
        oac.AttachmentsType();
        
        
     }  
}