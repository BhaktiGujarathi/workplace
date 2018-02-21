public with sharing class ResetMastersController {

    public String oppId { get; set; } 

	
    public ResetMastersController(ApexPages.StandardController controller) {
	
    	oppId = ApexPages.currentpage().getParameters().get('id');
        
	}

    
    public PageReference resetMasters() {

        List<UWVerification__c> verificationList = new List<UWVerification__c>();
        List<McaApp__Stips__c> stipList = new List<McaApp__Stips__c>();
        List<MerchantInterviewQuestion__c> questionList = new List<MerchantInterviewQuestion__c>();

        if ( oppId.trim().length() > 0 ) {
            
            verificationList = [SELECT Id FROM UWVerification__c WHERE Opportunity__c = :oppId];
            
            stipList = [SELECT Id FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :oppId];
            
            questionList = [SELECT Id FROM MerchantInterviewQuestion__c WHERE Opportunity__c = :oppId];            
            

            delete verificationList;
            delete stipList;
            delete questionList;
        }

        return new PageReference('/' + oppId);
    }
    
}