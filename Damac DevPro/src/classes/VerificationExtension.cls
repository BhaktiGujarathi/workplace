public without sharing class VerificationExtension{
    public Id srId;
    public VerificationExtension(ApexPages.StandardController controller){
         srId = ApexPages.currentPage().getParameters().get('id');
    }

    public pageReference documentVerification() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.Document_Verified__c = true;
        srObject.Document_Description__c = '';
        srObject.OCR_verified__c = true;
        srObject.Status__c = 'Submitted';
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference paymentVerification() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.Payment_Verified__c = true;
        srObject.Payment_Description__c = '';
        update srObject; 
        
        PageReference pg = new PageReference('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference oqoodVerification() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.OQOOD_verified__c = true;
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference MortgageEligibilityCheck() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.Eligible_for_Mortgage__c = true;
        srObject.Rule_Engine_Response_Received__c = true;
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference IPMSCallout() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.IPMS_Updated__c = true;
        
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
}