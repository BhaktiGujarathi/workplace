@isTest
public class OppDocumentControllerTest 
{
 
    private static TestMethod  void OppDocumentController_UnitTest()
    {
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
		
		Contact con = new Contact(LastName = 'test');
		insert con;
		
						
		Document__c doc = new Document__c(Category__c = 'Benefit Forms', Description__c = 'test', Opportunity__c = opp.id, Patient__c = con.id);
		insert doc;
		
		
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=doc.id;
        insert attach;
		
		
        
        ApexPages.StandardController asd = new ApexPages.StandardController(opp);
        OppDocumentController odc = new OppDocumentController(asd);
		odc.bl = bodyBlob;
        
        
        odc.SelectedFiletype = 'test';
        odc.getCategoryType();
        odc.fileName = 'test.txt';
		odc.save();
		odc.fileName = 'test.exe';
		odc.savenNew();
        odc.Cancel();
        odc.getFileExtension('filename');
        
        
        
    }  

	private static TestMethod  void OppDocumentController_UnitTest1()
    {
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
		
		Contact con = new Contact(LastName = 'test');
		insert con;
		
						
		Document__c doc = new Document__c(Category__c = 'Benefit Forms', Description__c = 'test', Opportunity__c = opp.id, Patient__c = con.id);
		insert doc;
		
		
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=doc.id;
        insert attach;
		
		
        
        ApexPages.StandardController asd = new ApexPages.StandardController(opp);
        OppDocumentController odc = new OppDocumentController(asd);
		odc.bl = bodyBlob;
        
        odc.SelectedFiletype = 'test';
        odc.getCategoryType();
        odc.fileName = 'text.txt';
        
		odc.savenNew();
		odc.fileName = 'test.exe';
		odc.save();
        odc.Cancel();
        odc.getFileExtension('filename');
       
    }
}