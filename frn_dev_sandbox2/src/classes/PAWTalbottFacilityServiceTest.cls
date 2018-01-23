@isTest
private class PAWTalbottFacilityServiceTest {

    // method to setup test data for the test class
    @testSetup static void setupTestData() {
        //frn account
        Account frnAccObj = PAWTestDataFactory.createFRNFacilityAccountRecord(false);
        insert frnAccObj;
        system.assertNotEquals(frnAccObj.Id, null);
        
        // talbott account
        Account talbottAccObj = PAWTestDataFactory.createFRNFacilityAccountRecord(true);
        insert talbottAccObj;
        system.assertNotEquals(talbottAccObj.Id, null);
        
        // insurance company account
        Account inscmpnyAccObj = PAWTestDataFactory.createInsCompanyAccountRecord();
        insert inscmpnyAccObj;
        system.assertNotEquals(inscmpnyAccObj.Id, null);
        
        //facility programs
        List<Facility_Program__c> frnFcltyPrgrmList = PAWTestDataFactory.createFcltyPrgrmRecords(3,
                                                                            frnAccObj.Id);
        insert frnFcltyPrgrmList;
        for(Facility_Program__c fcltyPrgrmInstance : frnFcltyPrgrmList) {
            system.assertNotEquals(fcltyPrgrmInstance.Id, null);
        }
        
        //facility programs
        List<Facility_Program__c> talbottfcltyPrgrmList = PAWTestDataFactory.createFcltyPrgrmRecords(3,
                                                                            talbottAccObj.Id);
        insert talbottfcltyPrgrmList;
        for(Facility_Program__c fcltyPrgrmInstance : talbottfcltyPrgrmList) {
            system.assertNotEquals(fcltyPrgrmInstance.Id, null);
        }
        
        //facility programs level of care
        List<Facility_Program_Level_of_Care__c> frnFcltyPrgrmCareList = PAWTestDataFactory.createFcltyPrgrmCareList(
                                                                            frnFcltyPrgrmList[0].Id);
        insert frnFcltyPrgrmCareList;
        for(Facility_Program_Level_of_Care__c fcltyPrgrmInstance : frnFcltyPrgrmCareList) {
            system.assertNotEquals(fcltyPrgrmInstance.Id, null);
        }
        
        //facility programs level of care
        List<Facility_Program_Level_of_Care__c> talbottFcltyPrgrmCareList = PAWTestDataFactory.createFcltyPrgrmCareList(
                                                                            talbottfcltyPrgrmList[0].Id);
        insert talbottFcltyPrgrmCareList;
        for(Facility_Program_Level_of_Care__c fcltyPrgrmInstance : talbottFcltyPrgrmCareList) {
            system.assertNotEquals(fcltyPrgrmInstance.Id, null);
        }
        
        // RTC Opportunity record
        Opportunity rtcOppObj = PAWTestDataFactory.createRtcOpportunityRecord();
        insert rtcOppObj;
        system.assertNotEquals(rtcOppObj.Id, null);
        
        // Patient Contact record
        Contact ptntContactObj = PAWTestDataFactory.createPatientContactRecord();
        insert ptntContactObj;
        system.assertNotEquals(ptntContactObj.Id, null);
        
        // Patient Insurance record
        Patient_Insurance__c ptntInsrnceObj = PAWTestDataFactory.createPtntInsrncRecord(
                                                                              ptntContactObj.Id,
                                                                              rtcOppObj.Id,
                                                                              inscmpnyAccObj.Id);
        insert ptntInsrnceObj;
        system.assertNotEquals(ptntInsrnceObj.Id, null);
        
        // insurance benefit record
        Insurance_Benefit__c insrncBnftObj = PAWTestDataFactory.createInsrncBnftRecord(
                                                                                ptntInsrnceObj.Id);
        insert insrncBnftObj;
        system.assertNotEquals(insrncBnftObj.Id, null);
        
        // estimate coverage days records for frn facility
        Estimated_Coverage_Days__c frnEstmteCvrgeDaysObj = PAWTestDataFactory.createEstmtCvrgeDaysRecord(
                                                                            insrncBnftObj.Id,
                                                                            frnAccObj.Id);
        insert frnEstmteCvrgeDaysObj;
        system.assertNotEquals(frnEstmteCvrgeDaysObj.Id, null);
        
        // estimate coverage days records for talbott facility
        Estimated_Coverage_Days__c talbottEstmteCvrgeDaysObj = PAWTestDataFactory.createEstmtCvrgeDaysRecord(
                                                                            insrncBnftObj.Id,
                                                                            talbottAccObj.Id);
        insert talbottEstmteCvrgeDaysObj;
        system.assertNotEquals(talbottEstmteCvrgeDaysObj.Id, null);
        
        // rate adjustment record for frn facility
        Insurance_Company_Rate_Adjustment__c frnRateAdjstmntObj = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            inscmpnyAccObj.Id,
                                                                            frnAccObj.Id);
        insert frnRateAdjstmntObj;
        system.assertNotEquals(frnRateAdjstmntObj.Id, null);
        
        // rate adjustment record for talbott facility
        Insurance_Company_Rate_Adjustment__c talbottRateAdjstmntObj = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            inscmpnyAccObj.Id,
                                                                            talbottAccObj.Id);
        insert talbottRateAdjstmntObj;
        system.assertNotEquals(talbottRateAdjstmntObj.Id, null);
    }
    
    // method to test calculateWraperValuesFRN()
    static testMethod void calculateWraperValuesTalbottTest() {
        Test.startTest();
	        Opportunity oppObj = [Select id from Opportunity Limit 1];
	        Account talbottAcc = [Select id From Account Where Name = 'TalbotFacility' LIMIT 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = talbottAcc.Id;
            cntrllrObj.onFacilitySelection();
            cntrllrObj.wrprObj.fcltyPrgrmSelected = cntrllrObj.fcltyPrgrmOptions[1].getValue();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            
            PAWTalbottFacilityService talbottServiceClass = new PAWTalbottFacilityService();
            talbottServiceClass.calculateWraperValuesTalbott(cntrllrObj.wrprObj,
                                                   cntrllrObj.fcltyPrgmMap,
                                                   cntrllrObj.cmpnyRateAdjstmntMap,
                                                   cntrllrObj.insrncBnftMap,
                                                   cntrllrObj.estmtCvrgeDaysObj);
        Test.stopTest();
    }
    
    // method to test createAndUpdatePAWDetailsRecordsFRN()
    static testMethod void createAndUpdatePAWDetailsRecordsTalbottTest() {
        Test.startTest();
	        Opportunity oppObj = [Select id from Opportunity Limit 1];
	        Account talbottAcc = [Select id From Account Where Name = 'TalbotFacility' LIMIT 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = talbottAcc.Id;
            cntrllrObj.onFacilitySelection();
            cntrllrObj.wrprObj.fcltyPrgrmSelected = cntrllrObj.fcltyPrgrmOptions[1].getValue();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            PAWTalbottFacilityService talbottServiceClass = new PAWTalbottFacilityService();
            talbottServiceClass.createAndUpdatePAWDetailsRecordsTalbott(cntrllrObj.wrprObj,
                                                   cntrllrObj.fcltyPrgmMap,
                                                   cntrllrObj.estmtCvrgeDaysObj,
                                                   cntrllrObj.cmpnyRateAdjstmntMap,
                                                   cntrllrObj.ptntInsrncObj);
        Test.stopTest();
    }
}