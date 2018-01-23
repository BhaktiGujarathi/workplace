public class RefEXTN{

    public Referral__c ReferralObj{get;set;}
   
    public String retURL;

    public RefEXTN(ApexPages.StandardController controller) {
        if(ReferralObj == null){
           ReferralObj = new Referral__c();
        }
        String current_User=UserInfo.getUserName() ;
        System.debug('current_User'+current_User); 
        retURL = apexpages.currentPage().getParameters().get('retURL');
    }
    public PageReference save(){
        
       // ReferralObj.Patient_ID__c = Userinfo.getUserID();
        insert ReferralObj;
        return new PageReference('/'+ReferralObj.Id);
    }
    
    public PageReference cancel(){
        return new PageReference(retUrl);
    }
    public PageReference saveandnew(){
      // ReferralObj.Patient_ID__c = Userinfo.getUserID();     
     insert ReferralObj;
        return new PageReference('/apex/New_Referral');
 
    }
}