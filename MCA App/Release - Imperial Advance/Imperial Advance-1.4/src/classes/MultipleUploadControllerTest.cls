@isTest
public with sharing class MultipleUploadControllerTest {

	 static testMethod void testAttachmentsforOpportunity(){
	 	Opportunity OppRecord = new Opportunity(Name = 'Rocky' ,  CloseDate = system.today(), 
												     StageName = 'Application Sent', ForecastCategoryName = 'Pipeline',
												     Amount = 1000);
		insert OppRecord;
		
		Opportunity OppRecord1 = new Opportunity(Name = 'Rocky1' ,  CloseDate = system.today(), 
												     StageName = 'Application Sent', ForecastCategoryName = 'Pipeline',
												     Amount = 1000);
		insert OppRecord1;
		
		Opportunity OppRecord2 = new Opportunity(Name = 'Rocky2' ,  CloseDate = system.today(), 
												     StageName = 'Application Sent', ForecastCategoryName = 'Pipeline',
												     Amount = 1000);
		insert OppRecord2;
		Opportunity OppRecord3 = new Opportunity(Name = 'Rocky3' ,  CloseDate = system.today(), 
												     StageName = 'Application Sent', ForecastCategoryName = 'Pipeline',
												     Amount = 1000);
		insert OppRecord3;
		Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=OppRecord.id;
        MultipleUploadController controller;
        test.startTest();
        controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord));
        controller.attachmentName='Unit Test Attachment';
        controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
        //controller.FileCount = '1';
        controller.filesCountList.add(new SelectOption('1' , '1'));
        
        controller.allFileList.add(attach);
        controller.SaveAttachments();
        controller.saveme();
        
        List<ApexPages.Message> lstMsgs = ApexPages.getMessages(); 
        if(lstMsgs.size() > 0){
        	System.assertequals('No record is associated. Please pass record Id in parameter.',lstMsgs.get(0).getSummary());
        }
        //
        string oppId1 = ''+OppRecord.id;
        controller.OppId = oppId1;
        controller.attachmentName='Unit Test Attachment';
        controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
        controller.FileCount = '1';
        controller.filesCountList.add(new SelectOption('1' , '1'));
        
        controller.allFileList.add(attach);
        controller.SaveAttachments();
        controller.saveme();
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:OppRecord.id];
        System.assertEquals(2, attachments.size());
        //
        string oppId2 = ''+OppRecord2.id;
        controller.OppId = oppId2;
        controller.attachmentName='Unit Test Attachment';
        controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
        //controller.FileCount = '1';
        controller.filesCountList.add(new SelectOption('1' , '1'));
        
        controller.allFileList.add(attach);
        //controller.CollectData();
        controller.SaveAttachments();
        //controller.saveme();
        
        lstMsgs = ApexPages.getMessages(); 
        system.debug('@@@'+lstMsgs);
        if(lstMsgs.size() > 0){
        	System.assertequals('Please select how many files you want to upload.',lstMsgs.get(2).getSummary());
        	//System.assertequals('2 File(s) are uploaded successfully',lstMsgs.get(1).getSummary());
        }
        //
        string oppId3 = ''+OppRecord3.id;
         controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord3));
        controller.OppId = oppId3;
        controller.FileCount = '1';
        //controller.filesCountList.add(new SelectOption('1' , '1'));
        controller.ChangeCount();
        controller.SaveAttachments();
        //controller.saveme();
        
        lstMsgs = ApexPages.getMessages(); 
        system.debug('@@@'+lstMsgs);
        if(lstMsgs.size() > 0){
        	System.assertequals('Please select at-least one file',lstMsgs.get(3).getSummary());
        	//System.assertequals('3 File(s) are uploaded successfully',lstMsgs.get().getSummary());
        }	
 		
 		
        test.stopTest();
	 }
}