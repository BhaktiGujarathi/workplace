public with sharing class GenerateSOAForRentalPool{
  
    public GenerateSOAForRentalPool(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'SOA'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'SOA';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;

        Case objCase = [Select Id,Status, RecordType.DeveloperName, RecordTypeId From Case Where Id =: strPageID];
        String strRecordType = objCase.RecordType.DeveloperName;
        objCase.Status = ' SOA Uploaded';
        update objCase;

        String strPDfName1 = 'SOA';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('SOA'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
       
        insert lstAttachment;
        
        Task objTask  = new Task();
        
        if (strRecordType == 'Rental_Pool_Assignment') {
            objTask.Subject = 'SOA Document Review for Rental Pool Assignment';
        } else {
            objTask.Subject = 'SOA Document Review';
        }
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;

        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateSOAForRentalPool