public class CreateTitleDeedSR{

    @InvocableMethod public static void CreateTDSR(List<Booking_Unit__c> lstBU){
        string strBUID;
        for(Booking_Unit__c objBU : lstBU){
         strBUID = objBU.ID;
        }
        Case objCase = new Case();
        objCase.Booking_Unit__c = strBUID;
        objCase.Priority = 'Medium';
        objCase.Status = 'Draft Request';
        insert objCase;
        
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'Valid Emirates ID Copy'; 
        objSRAtt1.Case__c = objCase.ID; 
        objSRAtt1.description__c = 'Valid Emirates ID Copy';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Valid Visa Copy'; 
        objSRAtt2.Case__c= objCase.ID; 
        objSRAtt2.description__c = 'Valid Visa Copy';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
        
        
        String strPDfName1 = 'Valid Emirates ID Copy';
        String strPDfName2 = 'Valid Visa Copy';
       
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Valid Emirates ID Copy'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName2, body = blob.toPdf('Valid Visa Copy'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        
        insert lstAttachment;
        
        Task objTask  = new Task();
        objTask.Subject = 'TD Document Review';
        objTask.WhatID = objCase.ID; 
        objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;

    }//End CreateTDSR
}//End CreateTitleDeedSR