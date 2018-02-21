@isTest
private class CC_ConvertInquiry_Test {

    static testMethod void myUnitTest() {
        List<NSIBPM__SR_Template__c> createSrTemplateList = InitialiseTestData.createTestTemplateRecords(
			new List<NSIBPM__SR_Template__c>{
				new NSIBPM__SR_Template__c()});
        List<NSIBPM__SR_Status__c> createSrStatusList = InitialiseTestData.createSrStatusRecords(
        	new List<NSIBPM__SR_Status__c>{
    			new NSIBPM__SR_Status__c(Name = 'Draft', NSIBPM__Code__c = 'Draft'), 
    			new NSIBPM__SR_Status__c(Name = 'Submitted', NSIBPM__Code__c = 'Submitted')});
        List<NSIBPM__Service_Request__c> createServiceRequestList = 
        	InitialiseTestData.createtestServiceRequestRecords(
        		new List<NSIBPM__Service_Request__c>{
        			new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal'),
        										   NSIBPM__SR_Template__c = createSrTemplateList[0].Id)});
        List<Booking__c> createBookingList = 
        	InitialiseTestData.createBookingRecords(
        		new List<Booking__c>{
        			new Booking__c(Deal_SR__c = createServiceRequestList[0].Id)});
        Location__c loc=new Location__c();
	    loc.Location_ID__c='123';
	    insert loc;
	    Inventory__c inv = new Inventory__c();
	    inv.Unit_Location__c=loc.id;
	    insert inv;
        List<Booking_Unit__c> createBookingUnitList = 
        	InitialiseTestData.createBookingUnitRecords(
        		new List<Booking_Unit__c>{
        			new Booking_Unit__c(Booking__c = createBookingList[0].Id, Inventory__c = inv.Id)});
       	Inquiry__c inq = InitialiseTestData.getInquiryDetails('Inquiry',1234);
       	insert inq;
       	buyer__c b1 = new buyer__c();
        b1.Buyer_Type__c =  'Individual';
        b1.Address_Line_1__c =  'Ad1';
        b1.Country__c =  'United Arab Emirates';
        b1.City__c = 'Dubai' ;
        b1.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b1.Email__c = 'test@test.com';
        b1.First_Name__c = 'firstname' ;
        b1.Last_Name__c =  'lastname';
        b1.Nationality__c = 'Indian' ;
        b1.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b1.Passport_Number__c = 'J0565556' ;
        b1.Phone__c = '569098767' ;
        b1.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b1.Place_of_Issue__c =  'India';
        b1.Title__c = 'Mr';
        b1.booking__c = createBookingList[0].Id;
        b1.Inquiry__c = inq.id;
        insert b1;
        
        List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
            new List<NSIBPM__Status__c>{
              new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_PC_CONFIRMATION'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'Approved',NSIBPM__Type__c='End'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'Rejected',NSIBPM__Type__c='End'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
          new List<NSIBPM__Step__c>{
            new NSIBPM__Step__c(NSIBPM__SR__c = createServiceRequestList[0].id, NSIBPM__Status__c = createStatus[2].Id, NSIBPM__SR_Step__c = srStep.id),
            new NSIBPM__Step__c(NSIBPM__SR__c = createServiceRequestList[0].id, NSIBPM__Status__c = createStatus[2].Id, NSIBPM__SR_Step__c = srStep.id)});
        
        CC_ConvertInquiry objCC = new CC_ConvertInquiry();
        objCC.EvaluateCustomCode(createServiceRequestList[0],new NSIBPM__Step__c(NSIBPM__SR__c = createServiceRequestList[0].id));
        
        NSIBPM__Step__c step = [Select id,name from NSIBPM__Step__c WHERE ID =:createStepList[0].id ];
        try{
        objCC.EvaluateCustomCode(createServiceRequestList[0],step);
        }Catch(Exception ex){}
    }
}