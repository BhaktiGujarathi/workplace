public without sharing class NOCExtension{
    public Id srId;
    public NOCExtension(ApexPages.StandardController controller) {
        srId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public pageReference nocVerification() {
        Service_Request__c srObject = [select Id, LOA_Generated__c from Service_Request__c where Id =: srId];
        if(srObject.LOA_Generated__c) {
            srObject.NOC_Generated__c = true;
            update srObject;
        }
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
}