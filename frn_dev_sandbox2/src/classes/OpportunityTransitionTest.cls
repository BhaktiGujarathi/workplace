@isTest
private class OpportunityTransitionTest {
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
        Opportunity rtcOpportunityObj = new Opportunity();
        rtcOpportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        rtcOpportunityObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(rtcOpportunityObj);
        rtcOpportunityObj.Name = 'RTCOpportunity';
        insert rtcOpportunityObj;
        system.assertNotEquals(rtcOpportunityObj.Id, null);

        // IOP Opportunity record
        Opportunity iopOpportunityObj = new Opportunity();
        iopOpportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Outpatient Treatment');
        iopOpportunityObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(iopOpportunityObj);
        iopOpportunityObj.Name = 'IOPOpportunity';
        insert iopOpportunityObj;
        system.assertNotEquals(iopOpportunityObj.Id, null);

        // Patient Contact record
        Contact ptntContactObj = new Contact();
        ptntContactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Patient');
        ptntContactObj = FRNOrgTestDataFactory.createPatientContactRecord(ptntContactObj);
        insert ptntContactObj;
        system.assertNotEquals(ptntContactObj.Id, null);

        Patient_Insurance__c rtcPtntInsrnceObj = new Patient_Insurance__c();
        rtcptntInsrnceObj = FRNOrgTestDataFactory.createPtntInsrncRecord(rtcPtntInsrnceObj,
                                                                      ptntContactObj.Id);
        rtcPtntInsrnceObj.Opportunity__c = rtcOpportunityObj.Id;
        rtcPtntInsrnceObj.Insurance_Company__c = insuranceCompanyObj.Id;
        insert rtcPtntInsrnceObj;
        system.assertNotEquals(rtcPtntInsrnceObj.Id, null);

        Patient_Insurance__c iopPtntInsrnceObj = new Patient_Insurance__c();
        iopPtntInsrnceObj = FRNOrgTestDataFactory.createPtntInsrncRecord(iopPtntInsrnceObj,
                                                                      ptntContactObj.Id);
        iopPtntInsrnceObj.Opportunity__c = iopOpportunityObj.Id;
        iopPtntInsrnceObj.Insurance_Company__c = insuranceCompanyObj.Id;
        insert iopPtntInsrnceObj;
        system.assertNotEquals(iopPtntInsrnceObj.Id, null);

        StepDown_Related_Objects_To_Clone__c customSettingObj = new StepDown_Related_Objects_To_Clone__c();
        customSettingObj.Opportunity_Relationship_API_Name__c = 'Patient_Insurances__r';
        customSettingObj.Name = 'Patient Insurance';
        insert customSettingObj;
    }

    @isTest static void triggerTransitionToRTCTest() {
        
        Test.startTest();
            Opportunity oppObj = [SELECT Id
                                  FROM Opportunity
                                  WHERE RecordType.Name = 'Outpatient Treatment'
                                  LIMIT 1];
            OpportunityTransition.triggerTransitionToRTC(oppObj.Id);
            
        Test.stopTest();
        List<Opportunity> assertIOPOppList = new List<Opportunity>();
        assertIOPOppList = [SELECT id,
                                RecordTypeId,
                                StageName
                           FROM Opportunity
                          WHERE Name = 'IOPOpportunity'];
        system.assertEquals(assertIOPOppList[0].StageName,'Closed');

        List<Opportunity> assertRTCOppList = new List<Opportunity>();
        assertRTCOppList = [SELECT id,
                                   RecordTypeId,
                                   StageName
                              FROM Opportunity
                             WHERE RecordType.Name = 'Residential Treatment'
                               AND Transitioned__c = true];
        system.assertEquals(assertRTCOppList.size(), 1);

    }

    @isTest static void triggerTransitionToIOPTest() {
        
        Test.startTest();
            Opportunity oppObj = [SELECT Id
                                  FROM Opportunity
                                  WHERE RecordType.Name = 'Residential Treatment'
                                  LIMIT 1];
            OpportunityTransition.triggerTransitionToIOP(oppObj.Id);
            
        Test.stopTest();
        List<Opportunity> assertRTCOppList = new List<Opportunity>();
        assertRTCOppList = [SELECT id,
                                RecordTypeId,
                                StageName
                           FROM Opportunity
                          WHERE Name = 'RTCOpportunity'];
        system.assertEquals(assertRTCOppList[0].StageName,'Closed');

        List<Opportunity> assertIOPOppList = new List<Opportunity>();
        assertIOPOppList = [SELECT id,
                                   RecordTypeId,
                                   StageName
                              FROM Opportunity
                             WHERE RecordType.Name = 'Outpatient Treatment'
                               AND Transitioned__c = true];
        system.assertEquals(assertIOPOppList.size(), 1);
    }
}