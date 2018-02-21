public with sharing class UploadTDDocument{
    
  
    
    public UploadTDDocument(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'Valid Emirates ID Copy'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Valid Emirates ID Copy';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Valid Visa Copy'; 
        objSRAtt2.Case__c= strPageID; 
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
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;

        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End UploadTDDocument