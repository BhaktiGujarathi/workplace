public with sharing class EHODocumentSubmission{
    
  
    
    public EHODocumentSubmission(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'PDC Details'; 
        objSRAtt1.Case__c= strPageID; 
        objSRAtt1.description__c = 'PDC Details';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Security Checks'; 
        objSRAtt2.Case__c= strPageID; 
        objSRAtt2.description__c = 'Security Check Details';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
        
        
        String strPDfName1 = 'PDC Details';
        String strPDfName2 = 'Security Checks';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('PDC Details'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName2, body = blob.toPdf('Security Checks'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        
        insert lstAttachment;
        
        Task objTaskCRE = new Task();        
        objTaskCRE.OwnerID= '0050Y000001SBxP';
        objTaskCRE.Priority = 'Normal';
        objTaskCRE.Status = 'Not Started';
        objTaskCRE.Subject = 'Verify and Approve SR';
        objTaskCRE.WhatId = strPageID;
        objTaskCRE.CurrencyIsoCode = 'AED';
        insert objTaskCRE;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End EHODocumentSubmission