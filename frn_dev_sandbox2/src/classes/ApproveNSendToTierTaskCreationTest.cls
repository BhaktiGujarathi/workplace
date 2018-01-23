@isTest
private class ApproveNSendToTierTaskCreationTest {
	
	// method to setup test data for the test class
    @testSetup static void setupTestData() {
        //frn account
                               
        Opportunity rtcOppObj = new Opportunity();
        rtcOppObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Outpatient Treatment');
        rtcOppObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(rtcOppObj);    
        rtcOppObj.StageName = 'Pending Appointment';    
        insert rtcOppObj;
        system.assertNotEquals(rtcOppObj.Id, null);        
    }

	// method to test calculateWraperValues()
    static testMethod void triggerOpportunityFinalizationTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            String assertStr = ApproveNSendToTierTaskCreationService.triggerTaskCreationForApproval(oppObj.Id);
        Test.stopTest();
    }
}