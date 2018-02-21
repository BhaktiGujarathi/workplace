public with sharing class GenerateNOCForTD{
  
    public GenerateNOCForTD(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'NOC For TD'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'NOC Details';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
       
        String strPDfName1 = 'NOC For TD';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('NOC For TD'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        
        
        insert lstAttachment;
        
        Task objTask  = new Task();
        objTask.Subject = 'NOC Document Review';
        objTask.WhatID = strPageID ; 
        objTask.OwnerID = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask; 

       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End UploadTDDocument