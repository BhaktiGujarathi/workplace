@isTest
private class UpdateCancelledAppointmentServiceTest {
	
	// method to setup test data for the test class
    @testSetup static void setupTestData() {
                       
        Opportunity rtcOppObj = new Opportunity();
        rtcOppObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Outpatient Treatment');
        rtcOppObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(rtcOppObj);        
        insert rtcOppObj;
        system.assertNotEquals(rtcOppObj.Id, null);
        
        Event eventObj = new Event();
        eventObj.Subject = 'Appointment';
        eventObj.WhatId = rtcOppObj.Id;
        eventObj.StartDateTime = system.now();
        eventObj.EndDateTime = system.now().AddDays(1);
        eventObj.Type = 'Appointment - In Person';
        insert eventObj;
        system.assertNotEquals(eventObj.Id, null);
    }

    // method to test calculateWraperValues()
    static testMethod void triggerAppointmentCancellationTest() {
        Test.startTest();
            Event eventObj = [Select id from Event Limit 1];
            Boolean assertFlag = UpdateCancelledAppointmentService.triggerAppointmentCancellation(eventObj.Id);
        Test.stopTest();
    }
	
}