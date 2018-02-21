@isTest
private class DAMAC_ThankYouCntlrExtTest {

	static NSIBPM__Service_Request__c serviceRequest ; 

	@isTest static void test_method_one() {
		Test.startTest();
		List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});
		List<NSIBPM__Service_Request__c> SRList  = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
        			new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
        											NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
        serviceRequest = SRList[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(serviceRequest);
        DAMAC_ThankYouCntlrExt thankYouController = new DAMAC_ThankYouCntlrExt(sc);
        Test.stopTest();
	}
	
}