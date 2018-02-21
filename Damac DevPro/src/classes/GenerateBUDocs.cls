public with sharing class GenerateBUDocs {
    
  
    
    public GenerateBUDocs(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        list<Attachment> lstAttachment = new list<Attachment>();
       
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        String strPDfName1 = 'Parking Offer';
        String strPDfName2 = 'Furniture Offer';
        String strPDfName3 = 'TD Forms';
       
        Attachment objAttachmnt1 = new Attachment(parentId = strPageID , name= strPDfName1, body = blob.toPdf('Parking Offer'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        Attachment objAttachmnt2 = new Attachment(parentId = strPageID , name= strPDfName2, body = blob.toPdf('Furniture Offer'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        Attachment objAttachmnt3 = new Attachment(parentId = strPageID , name= strPDfName3, body = blob.toPdf('TD Forms'), ContentType='PDF');
        lstAttachment.add(objAttachmnt3);
        
        insert lstAttachment;
       
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateBUDocs