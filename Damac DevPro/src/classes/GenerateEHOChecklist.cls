public with sharing class GenerateEHOChecklist{
    
 public GenerateEHOChecklist(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'Original SPA returned'; 
        objSRAtt1.Case__c= strPageID; 
        objSRAtt1.description__c = 'SPA Returned Document';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Lease Agreement'; 
        objSRAtt2.Case__c= strPageID; 
        objSRAtt2.description__c = 'Handover Pack Document';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
        
       
        String strPDfName1 = 'Original SPA returned';
        String strPDfName2 = 'Lease Agreement';
        
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Original SPA returned'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName2, body = blob.toPdf('Lease Agreement'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        
        
        insert lstAttachment;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateHandoverPack