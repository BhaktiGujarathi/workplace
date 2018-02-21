@isTest
public with sharing class MultipleUploadControllerTest {

     static testMethod void testAttachmentsforOpportunity(){
        Account objAcc = new Account(Name = 'test Account');
        insert objAcc;
        
        Opportunity OppRecord = new Opportunity(Name = 'Rocky' ,  CloseDate = system.today(), AccountId = objAcc.Id,
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord;
        System.assertNotEquals(null, OppRecord.Id);
        
        Opportunity OppRecord1 = new Opportunity(Name = 'Rocky1' ,  CloseDate = system.today(), 
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord1;
        System.assertNotEquals(null, OppRecord1.Id);
        
        Opportunity OppRecord2 = new Opportunity(Name = 'Rocky2' ,  CloseDate = system.today(), 
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord2;
        System.assertNotEquals(null, OppRecord2.Id);
        
        Opportunity OppRecord3 = new Opportunity(Name = 'Rocky3' ,  CloseDate = system.today(), 
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord3;
        System.assertNotEquals(null, OppRecord3.Id);
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        transient Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=OppRecord.id;
        insert attach;
        System.assertNotEquals(null, attach);
        
        MultipleUploadController controller;
        test.startTest();
            System.currentPagereference().getParameters().put('id', OppRecord.Id);
            System.currentPagereference().getParameters().put('retURL','%2Fapex%2Fsubmissionwizard%3Fid%3D0069000000j7K2pAAE');
            System.currentPagereference().getParameters().put('accID', objAcc.Id);
            System.currentPagereference().getParameters().put('isStips','false');
            //System.currentPagereference().getParameters().put(STIPS_ID);
            controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord));
            
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            //controller.FileCount = '1';
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.ShowPreview =true;
            controller.getbaseUrlOrg();
            controller.SaveAttachments();
            controller.saveme();
            controller.indexToRemove = String.ValueOf(attach.Id);
            controller.deleteAttachment();
        //
            //string oppId1 = ''+OppRecord.id;
            //controller.OppId = oppId1;
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            controller.FileCount = '1';
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.SaveAttachments();
            controller.saveme();
        
            List<Attachment> attachments=[select id, name from Attachment where parent.id=:OppRecord.id];
            //System.assertEquals(3, attachments.size());
        //
            //string oppId2 = ''+OppRecord2.id;
            //controller.OppId = oppId2;
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            //controller.FileCount = '1';
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.closedRedirect();
             ApexPages.currentPage().getParameters().put('data','data');
            controller.CollectData();
            controller.SaveAttachments();
            
            controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord3));
            //controller.OppId = oppId3;
            controller.FileCount = '1';
            //controller.filesCountList.add(new SelectOption('1' , '1'));
            controller.ChangeCount();
            controller.SaveAttachments();
            
        test.stopTest();
     }
     
     static testMethod void testInValidAttachmentsforOpportunity(){
        Account objAcc = new Account(Name = 'test Account');
        insert objAcc;
        Opportunity OppRecord = new Opportunity(Name = 'Rocky' ,  CloseDate = system.today(), AccountId = objAcc.Id,
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord;
        System.assertNotEquals(null, OppRecord.Id);
        
        Opportunity OppRecord2 = new Opportunity(Name = 'Rocky2' ,  CloseDate = system.today(), AccountId = objAcc.Id,
                                                     StageName = 'Application Sent', Amount = 1000);
        insert OppRecord2;
        System.assertNotEquals(null, OppRecord2.Id);
        
        Stips__c objStip = new Stips__c();
        objStip.Opportunity__c = OppRecord.Id;
        objStip.Name = 'test opp';
        insert objStip ;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        transient Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=OppRecord.id;
        insert attach;
        System.assertNotEquals(null, attach);
        test.startTest();
            System.currentPagereference().getParameters().put('id', OppRecord.Id);
            System.currentPagereference().getParameters().put('retURL','%2Fapex%2Fsubmissionwizard%3Fid%3D0069000000j7K2pAAE');
            System.currentPagereference().getParameters().put('accID', objAcc.Id);
            System.currentPagereference().getParameters().put('isStips','true');
            System.currentPagereference().getParameters().put('stipID',objStip.Id);
            MultipleUploadController controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord));
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            //controller.FileCount = '1';
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.ShowPreview =true;
            controller.getbaseUrlOrg();
            controller.SaveAttachments();
            controller.saveme();
            controller.indexToRemove = String.ValueOf(attach.Id);
            controller.deleteAttachment();
        //
            //string oppId1 = ''+OppRecord.id;
            //controller.OppId = oppId1;
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            controller.FileCount = '1';
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.SaveAttachments();
            controller.saveme();
        
            List<Attachment> attachments=[select id, name from Attachment where parent.id=:OppRecord.id];
            controller.attachmentName='Unit Test Attachment';
            controller.attachmentBody=Blob.valueOf('Unit Test Attachment Body');
            controller.filesCountList.add(new SelectOption('1' , '1'));
        
            controller.allFileList.add(attach);
            controller.closedRedirect();
             ApexPages.currentPage().getParameters().put('data','data');
            controller.CollectData();
            controller.SaveAttachments();
            
            controller=new MultipleUploadController(new ApexPages.StandardController(OppRecord2));
            controller.FileCount = '1';
            controller.ChangeCount();
            controller.SaveAttachments();
        
    }
}