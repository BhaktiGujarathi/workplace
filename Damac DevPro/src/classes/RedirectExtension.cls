public without sharing class RedirectExtension{
    public Id srId;
    public RedirectExtension(ApexPages.StandardController controller){
         srId = ApexPages.currentPage().getParameters().get('id');
    }

    public pageReference redirectToVerification() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.RecordTypeId = '0127E0000000tX7';
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference redirectToGenerate() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.RecordTypeId = '0127E0000000tXC';
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference redirectToDelivery() {
        Service_Request__c srObject = new Service_Request__c();
        srObject.Id = srId;
        srObject.RecordTypeId = '0127E0000000tXH';
        update srObject;
        
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
    
}