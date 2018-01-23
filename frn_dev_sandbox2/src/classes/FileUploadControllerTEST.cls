@isTest
private class FileUploadControllerTEST {

	static testMethod void uploadTest() {
        //Split string 'file' in to two chunks, first chunk must be divisible by 3 for base64 encode with no padding
        Blob part1 = Blob.valueOf('This text re'); //length is 12 
        Blob part2 = Blob.valueOf('presents a dummy file');
                
        String part1base64 = EncodingUtil.base64Encode(part1);
        String part2base64 = EncodingUtil.base64Encode(part2);
        
        //Create a test accound the 'file' can be attached to.
		contact con = new contact();
		con.LastName = 'test';
		insert con;
        Document__c doc = new Document__c();
		doc.Patient__c = con.id;
		insert doc;
        //Start the test
        Test.startTest();
        //Send first part of the file to be uploaded
        String attachmentId = FileUploadController.attachBlob(con.Id,'','','','fileName','text',part1base64);
        
        //Send the second piece of the file to be uploaded
        FileUploadController.attachBlob(con.Id,'','',attachmentId,'fileName','text',part2base64);
        Test.stopTest();
        
        //Assert one file has been attached to the test account
        List<Attachment> attachments = [select Id, Body from Attachment where ParentId = :doc.Id];
        //system.assert(attachments.size() == 1);
        
        //Assert the contents of the split file were recontructed correctly
        //system.assert(attachments[0].Body.toString() == 'This text represents a dummy file');
    }
}