/**************************************************************************************************
* Name               : InquiryScoreCalculatorTest                                                 *
* Description        : Test class for InquiryScoreCalculator batch class.                         *
* Created Date       : 25/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      25/05/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class InquiryScoreCalculatorTest {
	
	private static List<Inquiry__c> createdInquiryList = new List<Inquiry__c>();
	private static List<User> userRecordList = new List<User>();
	private static List<Event> eventList = new List<Event>();
	private static void init(){
		userRecordList = TestDataFactory.createTestUserRecords(new List<User>{ new User(), new User() }); 	 
		system.RunAs(new User(Id = UserInfo.getUserId())){
			createdInquiryList = TestDataFactory.createInquiryRecords(
				new List<Inquiry__c>{ 
					new Inquiry__c(Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS, OwnerId = userRecordList[0].Id, Duplicate__c = false), 
					new Inquiry__c(Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS, OwnerId = userRecordList[0].Id, Duplicate__c = false),
					new Inquiry__c(Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS, OwnerId = userRecordList[0].Id, Duplicate__c = false)}); 	 	
			eventList = TestDataFactory.createEventRecords(
				new List<Event>{
					new Event(WhatId = createdInquiryList[0].Id, Status__c = 'Completed', OwnerId = userRecordList[0].Id),
				    new Event(WhatId = createdInquiryList[0].Id, Status__c = 'Completed', OwnerId = userRecordList[0].Id), 
				    new Event(WhatId = createdInquiryList[0].Id, Status__c = 'Planned', OwnerId = userRecordList[0].Id),
				    new Event(WhatId = createdInquiryList[0].Id, Status__c = 'Planned', OwnerId = userRecordList[0].Id)});
		}	
	}
	
    static testMethod void testBatchExecution() {
    	init();
    	Test.startTest();
		InquiryScoreCalculator iscObject = new InquiryScoreCalculator();
		Database.executeBatch(iscObject, 10);		
		Test.stopTest();
    }
}// End of class.