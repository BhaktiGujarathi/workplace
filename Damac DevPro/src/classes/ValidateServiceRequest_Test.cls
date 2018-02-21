@isTest
private class ValidateServiceRequest_Test {

    static testMethod void myUnitTest() {
        List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});

        List<NSIBPM__Document_Master__c> DM_List = InitialiseTestData.createSRDocMasterRecords(5);
        NSIBPM__SR_Template_Docs__c SrTemplateDoc = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc.NSIBPM__Document_Master__c = DM_List[0].Id;
        SrTemplateDoc.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc.NSIBPM__On_Submit__c = true;
        insert SrTemplateDoc;
		
		List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
            new List<NSIBPM__Status__c>{
              new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_PC_CONFIRMATION'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'Approved',NSIBPM__Type__c='End'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'Rejected',NSIBPM__Type__c='End'),
              new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
		
        List<NSIBPM__Service_Request__c> SRList = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
                    new NSIBPM__Service_Request__c(NSIBPM__Internal_SR_Status__c = createStatus[2].id,Is_Submitted_For_Approval__c = false,Doc_ok__c = true,recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = SRTemplateList[0].Id),
                    new NSIBPM__Service_Request__c(NSIBPM__Internal_SR_Status__c= createStatus[1].id,Is_Submitted_For_Approval__c = true,Doc_ok__c = true,recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = SRTemplateList[0].Id),
                    new NSIBPM__Service_Request__c(NSIBPM__Internal_SR_Status__c= createStatus[2].id,Is_Submitted_For_Approval__c = false,Doc_ok__c = true,recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
        
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
          new List<NSIBPM__Step__c>{
            new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[2].Id, NSIBPM__SR_Step__c = srStep.id),
            new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[2].Id, NSIBPM__SR_Step__c = srStep.id)});                                            
        ValidateServiceRequest.isDealValidToProceed(SRList[0].id,'PC');
        ValidateServiceRequest.isDealValidToProceed(SRList[1].id,'PC');
        ValidateServiceRequest.isDealValidToProceed(SRList[2].id,'PC');
        ValidateServiceRequest.isDealValidToProceed(SRList[0].id,'Contracts');
        ValidateServiceRequest.isDealValidToProceed(SRList[2].id,'Cont');
        List<Booking__c> createBookingList = 
        	InitialiseTestData.createBookingRecords(
        		new List<Booking__c>{
        			new Booking__c(Deal_SR__c = SRList[0].Id)});
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
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c(NSIBPM__Parent_SR__c = SRList[0].Id,Agency__c = null,Change_Type__c = 'Remove',Agency_Name__c = null);
        insert sr;
        ValidateServiceRequest.validateCountryOfSale(sr.id);
    }
}