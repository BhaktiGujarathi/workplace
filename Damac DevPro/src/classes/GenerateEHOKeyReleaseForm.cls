public with sharing class GenerateEHOKeyReleaseForm{
    
  
    
    public GenerateEHOKeyReleaseForm(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'EHO Key Release Form'; 
        objSRAtt1.SR__c = strPageID; 
        objSRAtt1.description__c = 'Key Release Form Details';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
       
        String strPDfName1 = 'Key Release Form Details';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('EHO Key Release Form'), ContentType='PDF');
        
        insert objAttachmnt1 ;
        
        list<Service_Request__c> lstSR = new list<Service_Request__c >();
        list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
        set<ID> setBUID = new set<ID>();
        For(Service_Request__c objSR : [select ID, Booking_Unit__c, Status__c from Service_Request__c where ID =: strPageID ]){
            objSR.Status__c = 'Closed';
            setBUID.add(objSR.Booking_Unit__c);
            lstSR.add(objSR );
        }
        Update lstSR;
        
        For(Booking_Unit__c ObjBU : [select ID, Early_Handover__c from Booking_Unit__c where ID IN : setBUID ]){
          ObjBU.Early_Handover__c  = true;
          lstBU.add(ObjBU);
        }
        update lstBU;
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateAgreement