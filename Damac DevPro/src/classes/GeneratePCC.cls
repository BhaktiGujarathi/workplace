public with sharing class GeneratePCC{
    
    public GeneratePCC(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        HandoverServices.generateDocument objPCC = HandoverServices.getPCCdocuemnt('41397');
        //GenerateSOAController.soaResponse objSOA = GenerateSOAController.getSOADocument('41332');
        String PCCurl = objPCC.url;
        /*list<Attachment> lstAttachment = new list<Attachment>();
        
        Case objCase = [Select Id, RecordTypeId, RecordType.DeveloperName From Case Where Id =:strPageID];
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name= 'PCC'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'PCC Document';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
        
        String strPDfName = 'Payment Completion Certificate';
        
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName, body = blob.toPdf('Payment Completion Certificate'), ContentType='PDF');
        lstAttachment.add(objAttachmnt1);
        
        if (objCase.RecordType.DeveloperName == 'Early_Handover') {
            
        SR_Attachments__c objSRAtt2 = new SR_Attachments__c ();
        objSRAtt2.Name= 'Partial PCC'; 
        objSRAtt2.Case__c = strPageID; 
        objSRAtt2.description__c = 'Partial PCC Document';
        objSRAtt2.type__c = 'PDF';
        insert objSRAtt2;
        
        String strPDfName1 = 'Partial Payment Completion Certificate';
        
        Attachment objAttachmnt2 = new Attachment(parentId = objSRAtt2.ID, name= strPDfName1, body = blob.toPdf('Partial Payment Completion Certificate'), ContentType='PDF');
        lstAttachment.add(objAttachmnt2);
        
        insert lstAttachment; */
        list<Case> lstCase = new list<Case>();
        
        for (Case objCase1: [Select Id, Early_Handover_Status__c From Case Where Id =:strPageID]) {
            objCase1.Early_Handover_Status__c = 'PCC Generated';
            lstCase.add(objCase1);
        }
        update lstCase;
        
        list<SR_Attachments__c> lstCaseAttachment = new list<SR_Attachments__c>();
        if (PCCurl != null) {
            for (Case objCase1: [Select Id, Early_Handover_Status__c From Case Where Id =:strPageID]) {
                SR_Attachments__c objCaseAttachment = new SR_Attachments__c();
                objCaseAttachment.Case__c = objCase1.id;
                objCaseAttachment.Name = 'PCC ' + objCase1.CaseNumber;
                objCaseAttachment.Attachment_URL__c = PCCurl;
                objCaseAttachment.CurrencyIsoCode = 'AED - UAE Dirham';
                objCaseAttachment.Account__c = objCase1.Seller__c;
                objCaseAttachment.Booking_Unit__c = objCase1.Booking_Unit__c;
                lstCaseAttachment.add(objCaseAttachment );
            }
            system.debug('lstCaseAttachment '+lstCaseAttachment );
            insert lstCaseAttachment;
            system.debug('inserted');
            PageReference newpg = new PageReference(PCCurl);
            newpg.setRedirect(true);
            return newpg;
        } else {
            return null;
        }
    }//End init
}