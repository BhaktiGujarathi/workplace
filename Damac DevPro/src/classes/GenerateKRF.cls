public with sharing class GenerateKRF{

    public GenerateKRF(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        /*list<Attachment> lstAttachment = new list<Attachment>();
        
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'Key Release Form'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Key Release Form';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        String strPDfName = 'Key Release Form';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName, body = blob.toPdf('Key Release Form'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        
        insert lstAttachment;*/
        
        HandoverServices.generateDocument objKRF = HandoverServices.getKRFdocuemnt('41397');
        String KRFurl = objKRF.url;
        
        list<Case> lstCase = new list<Case>();
        for (Case objCase: [Select Id, Handover_Status__c, Early_Handover_Status__c, RecordTypeId, RecordType.DeveloperName From Case Where Id =: strPageID]) {
        if (objCase.RecordType.DeveloperName == 'Handover') {
            objCase.Handover_Status__c = 'Keys Handed-over';
        } else if (objCase.RecordType.DeveloperName == 'Early_Handover') {
            objCase.Early_Handover_Status__c = 'Key Release Form Generated';
        }
            lstCase.add(objCase);
        }
        
        update lstCase;
        
        list<SR_Attachments__c> lstCaseAttachment = new list<SR_Attachments__c>();
        if (KRFurl != null) {
        
            for (Case objCase: [Select Id, Handover_Status__c, Early_Handover_Status__c, RecordTypeId, RecordType.DeveloperName From Case Where Id =: strPageID]) {
                SR_Attachments__c objCaseAttachment = new SR_Attachments__c();
                objCaseAttachment.Case__c = objCase.id;
                objCaseAttachment.Name = 'PCC ' + objCase.CaseNumber;
                objCaseAttachment.Attachment_URL__c = KRFurl;
                objCaseAttachment.CurrencyIsoCode = 'AED - UAE Dirham';
                objCaseAttachment.Account__c = objCase.Seller__c;
                objCaseAttachment.Booking_Unit__c = objCase.Booking_Unit__c;
                lstCaseAttachment.add(objCaseAttachment );
            }
            system.debug('lstCaseAttachment '+lstCaseAttachment );
            insert lstCaseAttachment;
            system.debug('inserted');
            
            pagereference newpg = new Pagereference(KRFurl);
            newpg.setRedirect(true);
            return newpg;
        } else {
            return null;
        }
        
    }//End init
}