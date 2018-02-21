global class InquiryCountBatch implements Database.Batchable<sObject>, Database.Stateful{

   global final String query;
   global Map<Id, Campaign__c> campaignInquiryCountMap;
  
   global InquiryCountBatch(){
   	campaignInquiryCountMap = new Map<Id, Campaign__c>();
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
	   List<Inquiry__c> inquiryList = (List<Inquiry__c>)scope;
	   
	   for (Inquiry__c thisInquiry : inquiryList) {
	   
		   if (campaignInquiryCountMap.containskey(thisInquiry.Campaign__c)) {
			   	Campaign__c thisCampaign = campaignInquiryCountMap.get(thisInquiry.Campaign__c);
			   	thisCampaign.Total_No_of_Leads__c += 1;
			   	campaignInquiryCountMap.put(thisInquiry.Campaign__c, thisCampaign);
		   }
		   else{
		   		campaignInquiryCountMap.put(thisInquiry.Campaign__c, new Campaign__c (Id = thisInquiry.Campaign__c, Total_No_of_Leads__c = 1));
		   }
	         
	   }
   }
   

	global void finish(Database.BatchableContext BC){
	   
        system.debug(campaignInquiryCountMap.values());
	   try {
	   		update campaignInquiryCountMap.values();
	   }
	   catch (Exception Ex) {
	   		system.debug(Ex);
	   }
	   
	}
}