public with sharing class GenerateAgreement{
    
  
    
    public GenerateAgreement(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'EHO Lease Agreement'; 
        objSRAtt1.Case__c= strPageID; 
        objSRAtt1.description__c = 'Agreement Details';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'EHO Lease Addendum'; 
        objSRAtt2.Case__c= strPageID; 
        objSRAtt2.description__c = 'Agreement Details';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
       
        String strPDfName1 = 'Agreement Details';
        String strPDfName2 = 'Addendum Details';
        
        list<Attachment> lstAttachment = new list<Attachment>();
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Agreement Details'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName2, body = blob.toPdf('Addendum Details'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        insert lstAttachment;
        
        List<case> lstcase = new List<Case>();
        for (Case objCase : [Select Id, Early_Handover_Status__c From Case Where Id =:strPageID]) {
            objCase.Early_Handover_Status__c = 'Agreement Generated';
            lstcase.add(objCase);
        }
        
        update lstcase;
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateAgreement