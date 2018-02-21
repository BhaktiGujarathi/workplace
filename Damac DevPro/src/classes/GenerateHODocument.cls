public with sharing class GenerateHODocument{
    
  
    
    public GenerateHODocument(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'Handover Document'; 
        objSRAtt1.Case__c= strPageID; 
        objSRAtt1.description__c = 'Handover Document';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
       
        String strPDfName1 = 'Handover Documen';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Handover Document'), ContentType='PDF');
        
        insert objAttachmnt1 ;
        
        list<Case> lstCase = new list<Case>();
        for (Case objCase : [Select Id, Plot_Handover_Status__c From Case Where Id=: strPageID ]) {
            objCase.Plot_Handover_Status__c = 'Get Signature From Customer';
            lstCase.add(objCase);
        }
        
        update lstCase;
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateAgreement