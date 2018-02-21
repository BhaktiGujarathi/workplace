public without sharing class TransferAccountExtension{
    public Id srId;
    public TransferAccountExtension(ApexPages.StandardController controller) {
        srId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public pageReference transferAccountVerification() {
        Service_Request__c srObject = [select Id, Transfer_Account__c, Title_Deed_Generated__c from Service_Request__c where Id =: srId];
        if(srObject.Title_Deed_Generated__c) {
            srObject.Transfer_Account__c = true;
            update srObject;
        }
        PageReference  pg = new PageReference ('/'+srId);
        pg.setRedirect(true);
        return pg;
    }
}