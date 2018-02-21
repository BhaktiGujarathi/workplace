public with sharing class GenerateLT{

    public GenerateLT(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
        
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'Letter of Termination'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Letter of Termination';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        String strPDfName = 'Letter of Termination';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName, body = blob.toPdf('Key Release Form'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        
        insert lstAttachment;
    
        pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
        newpg.setRedirect(true);
        return newpg;
        
    }//End init
}