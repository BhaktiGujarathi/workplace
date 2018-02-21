public with sharing class DAMAC_ThankYouCntlrExt {
    public NSIBPM__Service_Request__c SR {get;set;}
    public string basicInfoPageURl {get;set;}
    public boolean isSalesforceUser {get;set;}
    public boolean isGuestUser {get;set;}
    public boolean isCommUser {get;set;}
    
    public DAMAC_ThankYouCntlrExt (ApexPages.StandardController stdController) {
        isSalesforceUser = false;
        isGuestUser = false;
        isCommUser = false;
        try{
            User u = [select id,name,contactid,contact.accountid,Profile.UserLicense.name from user where id =: userinfo.getUserId()];
            if(u.Profile.UserLicense.name == 'Guest User License'){
                isGuestUser = true;
            }
            else if(u.ContactId == null){
                    isSalesforceUser = true;
            }
            else if(u.ContactId != null && u.Contact.accountid != null){
                isCommUser = false;
            }
        }
        catch(exception ex){
            system.debug('--->'+ex.getMessage());
        }
        
        SR  = (NSIBPM__Service_Request__c)stdController.getRecord();
        Id FlowId = apexpages.currentPage().getParameters().get('FlowId');
        String hostVal = ApexPages.currentPage().getHeaders().get('Host');
        if(isCommUser)
            basicInfoPageURl = '';
        if(isSalesforceUser)
            basicInfoPageURl = '/'+SR.Id;
        if(isGuestUser)  
            basicInfoPageURl = '/apex/Process_Flow?FlowId=' + FlowId + '&Id=' + SR.Id;

    }
    
}