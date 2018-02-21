public with sharing class GenerateCRFDocument{
  
    public GenerateCRFDocument(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
        string strBookingUnitID;
        string strRecordTypeName;
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'CRF'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'CRF';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;

        Case objCase = [select ID, RecordType.DeveloperName, Booking_Unit__c, Status from Case where ID =: strPageID];
        strBookingUnitID = objCase.Booking_Unit__c;
        strRecordTypeName = objCase.RecordType.DeveloperName;
        objCase.Status = ' CRF Generated';
        update objCase;

         if (objCase.RecordType.DeveloperName == 'Rental_Pool_Agreement') {
            Booking_Unit__c objBU = [select ID, Rental_Pool_Status__c from Booking_Unit__c  where ID =: strBookingUnitID];
            objBU.Rental_Pool_Status__c  = 'Rental Pool In-Progress';
            update objBU ;
         }

        String strPDfName1 = 'CRF';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('CRF'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
       
        insert lstAttachment;
        
        Task objTask  = new Task();
        objTask.Subject = 'CRF Document Review & Get Customer Singature';
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;

        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateCRFDocument