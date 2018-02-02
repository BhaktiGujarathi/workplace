@isTest
private class OpportunityStepDownTest {
	
	// method to setup test data for the test class
    @testSetup static void setupTestData() {
    	// iop account
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'FRN Facility');
        accountObj = FRNOrgTestDataFactory.createFrnFacilityAccountRecord(accountObj, false);
        insert accountObj;
        system.assertNotEquals(accountObj.Id, null);

        // inscurance company record
        Account insuranceCompanyObj = new Account();
        insuranceCompanyObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Insurance Company');
        insuranceCompanyObj = FRNOrgTestDataFactory.createInsComapnyAccountRecord(insuranceCompanyObj);
        insert insuranceCompanyObj;

        // RTC Opportunity record
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        opportunityObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(opportunityObj);
        insert opportunityObj;
        system.assertNotEquals(opportunityObj.Id, null);

        // Patient Contact record
        Contact ptntContactObj = new Contact();
        ptntContactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Patient');
        ptntContactObj = FRNOrgTestDataFactory.createPatientContactRecord(ptntContactObj);
        insert ptntContactObj;
        system.assertNotEquals(ptntContactObj.Id, null);
        
        // Patient Insurance record
        Patient_Insurance__c ptntInsrnceObj = new Patient_Insurance__c();
        ptntInsrnceObj = FRNOrgTestDataFactory.createPtntInsrncRecord(ptntInsrnceObj,
                                                                      ptntContactObj.Id);
        ptntInsrnceObj.Opportunity__c = opportunityObj.Id;
        ptntInsrnceObj.Insurance_Company__c = insuranceCompanyObj.Id;
        insert ptntInsrnceObj;
        system.assertNotEquals(ptntInsrnceObj.Id, null);

        StepDown_Related_Objects_To_Clone__c customSettingObj = new StepDown_Related_Objects_To_Clone__c();
        customSettingObj.Opportunity_Relationship_API_Name__c = 'Patient_Insurances__r';
        customSettingObj.Name = 'Patient Insurance';
    	insert customSettingObj;
    }
	
	@isTest static void getOpportunityRelatedRecordsMapTest() {
        Map<String, String> customSettingmap = new Map<String, String>();
		Test.startTest();
            customSettingmap = OpportunityStepDown.getOpportunityRelatedRecordsMap();
        Test.stopTest();
        System.assertNotEquals(customSettingmap.size(), 0);
        System.assertEquals(customSettingmap.containsKey('Patient_Insurances__r'), true);
	}

    @isTest static void triggerRTCStepDownTest() {
        Opportunity oppObj = [SELECT Id
                              FROM Opportunity
                              LIMIT 1];
        oppObj.StageName = 'Admitted';
        update oppObj;
        Id assertClonedOpportunityId;
        Test.startTest();
            assertClonedOpportunityId = OpportunityStepDown.triggerRTCStepDown(oppObj.Id);
        Test.stopTest();
        System.assertNotEquals(assertClonedOpportunityId, null);
    }
}