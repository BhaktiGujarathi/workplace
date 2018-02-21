public with sharing class GenerateHandoverPack{
    
  
    
    public GenerateHandoverPack(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'Payment Received'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Handover Pack Document';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Documents received'; 
        objSRAtt2.Case__c = strPageID; 
        objSRAtt2.description__c = 'Handover Pack Document';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
        
        SR_Attachments__c objSRAtt3 = new SR_Attachments__c ();
        objSRAtt3.Name = 'Deposit received';
        objSRAtt3.Case__c = strPageID; 
        objSRAtt3.description__c = 'Handover Pack Document';
        objSRAtt3.type__c = 'PDF';
        insert objSRAtt3;
        
        SR_Attachments__c objSRAtt4 = new SR_Attachments__c ();
        objSRAtt4.Name = 'Mortgage flag';
        objSRAtt4.Case__c = strPageID; 
        objSRAtt4.description__c = 'Handover Pack Document';
        objSRAtt4.type__c = 'PDF';
        insert objSRAtt4;
        
        SR_Attachments__c objSRAtt5 = new SR_Attachments__c ();
        objSRAtt5.Name = 'Legal flag';
        objSRAtt5.Case__c = strPageID; 
        objSRAtt5.description__c = 'Handover Pack Document';
        objSRAtt5.type__c = 'PDF';
        insert objSRAtt5;
        
        SR_Attachments__c objSRAtt6 = new SR_Attachments__c ();
        objSRAtt6.Name= 'Payment plan'; 
        objSRAtt6.Case__c = strPageID; 
        objSRAtt6.description__c = 'Handover Pack Document';
        objSRAtt6.type__c = 'PDF';
        insert objSRAtt6;
        
        String strPDfName1 = 'Payments received';
        String strPDfName2 = 'Documents received';
        String strPDfName3 = 'Deposit received';
        String strPDfName4 = 'Mortgage flag';
        String strPDfName5 = 'Legal flag';
        String strPDfName6 = 'Payment plan';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Payments received'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName2, body = blob.toPdf('Documents received'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        Attachment objAttachmnt3 = new Attachment(parentId = objSRAtt3.ID, name= strPDfName3, body = blob.toPdf('Deposit received'), ContentType='PDF');
        lstAttachment.add(objAttachmnt3);
         Attachment objAttachmnt4 = new Attachment(parentId = objSRAtt4.ID, name= strPDfName4, body = blob.toPdf('Mortgage flag'), ContentType='PDF');
        lstAttachment.add(objAttachmnt4);
         Attachment objAttachmnt5 = new Attachment(parentId = objSRAtt5.ID, name= strPDfName5, body = blob.toPdf('Legal flag'), ContentType='PDF');
        lstAttachment.add(objAttachmnt5);
         Attachment objAttachmnt6 = new Attachment(parentId = objSRAtt6.ID, name= strPDfName6, body = blob.toPdf('Payment plan'), ContentType='PDF');
        lstAttachment.add(objAttachmnt6);
        
        insert lstAttachment;
        string strBookingUnitId;
        List<Case> lstCase = new List<Case>();
        for (Case objCase : [Select Id, Handover_Status__c, Booking_Unit__c From Case Where Id =: strPageID]) {
            objCase.Handover_Status__c = 'Handover Pack Generated';
            strBookingUnitId = objCase.Booking_Unit__c;
            lstCase.add(objCase);
        }
        update lstCase;
        
        List<Task> lstTask = new List<Task>();
        Task objTaskAdmin = new Task();
        objTaskAdmin.OwnerId = '0050Y000001SBxE';
        objTaskAdmin.Priority = 'Normal';
        objTaskAdmin.Status = 'Not Started';
        objTaskAdmin.Subject = 'Send Handover Courier to Customer';
        objTaskAdmin.WhatId = strPageID;
        objTaskAdmin.CurrencyIsoCode = 'AED';
        objTaskAdmin.Process_Name__c = 'Handover';
        lstTask.add(objTaskAdmin);
        
        insert lstTask;
        
        List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
        for(Booking_Unit__c objBU : [Select Id, SR_Handover_Status__c From Booking_Unit__c Where Id =: strBookingUnitId]) {
           objBU.SR_Handover_Status__c = 'Handover Pack Generated';
           lstBookingUnit.add(objBU);
        }
        update lstBookingUnit;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateHandoverPack