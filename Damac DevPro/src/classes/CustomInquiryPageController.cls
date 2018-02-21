public class CustomInquiryPageController{

    public Inquiry__c inquiry {get;set;}
    //public String encryptedMobile {get;set;}
    //public String extno {get;set;}
    //public String currentPageURL {get;set;}
    public boolean hideSavebtn {get;set;}
    public CustomInquiryPageController(ApexPages.StandardController controller){
        hideSavebtn = false;
        inquiry = new Inquiry__c();
        String encryptedNumber = Apexpages.currentPage().getParameters().get('epn'); 
        inquiry.User_Ext_No__c = Apexpages.currentPage().getParameters().get('ext');
        system.debug('#### encryptedNumber = '+encryptedNumber);
        if(String.isNotBlank(encryptedNumber)){
          populateMobile(encryptedNumber); 
        }
        String campaignNumber = Apexpages.currentPage().getParameters().get('campaign');
        system.debug('#### campaignNumber = '+campaignNumber);
        system.debug('#### inquiry = '+inquiry);
        if(String.isNotBlank(campaignNumber)){
          populateCampaignNumber(campaignNumber); 
        }
    }
    
    public void populateMobile(String encryptedMobile){
        //inquiry.Mobile_Phone_Encrypt__c = UtilityHelperCls.decryptMobile(encryptedMobile);
        inquiry.Mobile_Phone__c = UtilityHelperCls.decryptMobile(encryptedMobile);
        if(String.isNotBlank(inquiry.Mobile_Phone__c)){
            Schema.DescribeFieldResult fieldResult = Inquiry__c.Mobile_CountryCode__c.getDescribe();
            for (Schema.PicklistEntry picklistValue : fieldResult.getPicklistValues()) {
                String countryCode = String.valueOf(picklistValue.getValue()).subStringAfter(': ').trim();
                if(String.isNotBlank(inquiry.Mobile_Phone__c) && inquiry.Mobile_Phone__c.startsWith(countryCode)){
                        inquiry.Mobile_CountryCode__c = picklistValue.getValue();
                        inquiry.Mobile_Phone_Encrypt__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone__c);
                        break;
                }
            }
        }
    }
  
  public void populateCampaignNumber(String campaignNumber){
    for(JO_Campaign_Virtual_Number__c thisRecord : [SELECT Id, Related_Campaign__c,Related_Campaign__r.Campaign_Category_New__c,Related_Campaign__r.Language__c, Related_Virtual_Number__c, Related_Virtual_Number__r.Name
                                FROM JO_Campaign_Virtual_Number__c 
                            WHERE Related_Virtual_Number__r.Name =: campaignNumber 
                                                            AND Related_Campaign__r.Marketing_Start_Date__c <= TODAY 
                                                            AND Related_Campaign__r.Marketing_End_Date__c >= TODAY]){
          System.debug('thisRecord = '+thisRecord);
          System.debug('language = '+thisRecord.Related_Campaign__r.Language__c);
          System.debug('Source = '+thisRecord.Related_Campaign__r.Campaign_Category_New__c);
          inquiry.Campaign__c = thisRecord.Related_Campaign__c;
          inquiry.Preferred_Language__c = thisRecord.Related_Campaign__r.Language__c;
          inquiry.Inquiry_Source__c = thisRecord.Related_Campaign__r.Campaign_Category_New__c;
          break;         
        }   
  }
  
    public void SaveInquiry(){
        try{
            DAMAC_Constants.IS_BYPASS_TRIGGER = true;//to by pass the Inquiry Assignment logic
            Database.upsert(inquiry);
            hideSavebtn = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Inquiry is saved sucessfully.'));            
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
    }
}// End of class.