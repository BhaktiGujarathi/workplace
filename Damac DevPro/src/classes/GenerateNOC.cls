public with sharing class GenerateNOC {
    
    public GenerateNOC(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Attachment> lstAttachment = new list<Attachment>();
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'NOC'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'NOC Details';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
       
        String strPDfName1 = 'NOC For TD';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('NOC'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);        
        insert lstAttachment;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;       
    }
}