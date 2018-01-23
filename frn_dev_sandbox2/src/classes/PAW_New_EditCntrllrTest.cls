/**
 * Test class to test the functionality on conrtoller for the page PAW_New_Edit
 */
@isTest
private class PAW_New_EditCntrllrTest {

    
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
        
        Insurance_Benefit__c insrncBnftObj = PAWTestDataFactory.createInsrncBnftRecord(
                                                                                ptntInsrnceObj.Id);
        insert insrncBnftObj;
        system.assertNotEquals(insrncBnftObj.Id, null);
        
        Estimated_Coverage_Days__c frnEstmteCvrgeDaysObj = PAWTestDataFactory.createEstmtCvrgeDaysRecord(
                                                                            insrncBnftObj.Id,
                                                                            frnAccObj.Id);
        insert frnEstmteCvrgeDaysObj;
        system.assertNotEquals(frnEstmteCvrgeDaysObj.Id, null);
        
        Estimated_Coverage_Days__c talbottEstmteCvrgeDaysObj = PAWTestDataFactory.createEstmtCvrgeDaysRecord(
                                                                            insrncBnftObj.Id,
                                                                            talbottAccObj.Id);
        insert talbottEstmteCvrgeDaysObj;
        system.assertNotEquals(talbottEstmteCvrgeDaysObj.Id, null);
        
        Insurance_Company_Rate_Adjustment__c frnRateAdjstmntObj = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            inscmpnyAccObj.Id,
                                                                            frnAccObj.Id);
        insert frnRateAdjstmntObj;
        system.assertNotEquals(frnRateAdjstmntObj.Id, null);
        
        Insurance_Company_Rate_Adjustment__c talbottRateAdjstmntObj = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            inscmpnyAccObj.Id,
                                                                            talbottAccObj.Id);
        insert talbottRateAdjstmntObj;
        system.assertNotEquals(talbottRateAdjstmntObj.Id, null);
    }
    
    // test contructor of the controller
    static testmethod void constructorOppTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
        Test.stopTest();
    }
    
    // method to test locking of record
    static testmethod void redirectIfLockedTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            
            cntrllrObj.redirectIfLocked();
        Test.stopTest();
    }
    
    // method to test get select options for patient insurances
    static testmethod void getPtntInsrnceOptionsTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            system.assertNotEquals(cntrllrObj.ptntInsrnceOptions.size(),0);
        Test.stopTest();
    }
    
    // method to test on selection of patient insurance on page
    static testmethod void onPatientSelectionTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            system.assertNotEquals(cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c, null);
        Test.stopTest();
    }
    
    // method to test getInsrncBnftOptions
    static testmethod void getInsrncBnftOptionsTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            
            cntrllrObj.getInsrncBnftOptions();
        Test.stopTest();
    }
    
    // method to test onBenefitSelection
    static testmethod void onBenefitSelectionTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
        Test.stopTest();
    }
    
    // method to test onFacilitySelection
    static testmethod void onFacilitySelectionTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
        Test.stopTest();
    }
    
    // method to test getRtAdjstmntOptions()
    static testmethod void getRtAdjstmntOptionsTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
            cntrllrObj.getRtAdjstmntOptions();
        Test.stopTest();
    }
    
    // method to test updateWraperValues
    static testmethod void frnUpdateWraperValuesTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            cntrllrObj.updateWraperValues();
        Test.stopTest();
    }
    
    // method to test updateWraperValues
    static testmethod void talbottUpdateWraperValuesTest() {
        Test.startTest();
            Opportunity oppObj = [Select id From Opportunity Limit 1];
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
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            cntrllrObj.updateWraperValues();
        Test.stopTest();
    }
    
    // method to test createAndUpdatePAWDetailsRecords()
    static testmethod void frnCreateAndUpdatePAWDetailsRecordsTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            cntrllrObj.updateWraperValues();
            
            cntrllrObj.createAndUpdatePAWDetailsRecords();
        Test.stopTest();
    }
    
    // method to test createAndUpdatePAWDetailsRecords()
    static testmethod void talbottCreateAndUpdatePAWDetailsRecordsTest() {
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
            cntrllrObj.updateWraperValues();            
            cntrllrObj.createAndUpdatePAWDetailsRecords();
        Test.stopTest();
    }
    
    // method to test saveTheUpdates()
    static testmethod void saveTheUpdatesTest() {
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
            cntrllrObj.updateWraperValues();
            cntrllrObj.createAndUpdatePAWDetailsRecords();
            cntrllrObj.saveTheUpdates();
        Test.stopTest();
    }
    
    // method to test editExistingPAWest
    static testmethod void editExistingPAWest() {
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
            cntrllrObj.updateWraperValues();
            cntrllrObj.createAndUpdatePAWDetailsRecords();
            cntrllrObj.saveTheUpdates();
            Pay_Agreement_Worksheet__c pawObj = [Select id From Pay_Agreement_Worksheet__c Limit 1];
            ApexPages.currentPage().getParameters().put('id', pawObj.Id);
            PAW_New_EditCntrllr pawCntrllrObj = new PAW_New_EditCntrllr();
        Test.stopTest();
    }
    
    // method to test cancel()
    static testmethod void cancelTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.cancel();
        Test.stopTest();
    }
    
    // method to test preparesObjectQueryString()
    static testmethod void preparesObjectQueryStringTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.preparesObjectQueryString('Opportunity', oppObj.Id);
        Test.stopTest();
    }

    // test contructor of the controller
    static testmethod void initializeTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            //cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.initialize();
        Test.stopTest();
    }

    static testmethod void getRedirectTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            cntrllrObj.getRedirect();
        Test.stopTest();
    }

    static testmethod void getCurrentPAWIdTest() {
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
            cntrllrObj.updateWraperValues();
            cntrllrObj.createAndUpdatePAWDetailsRecords();
            cntrllrObj.saveTheUpdates();
            Pay_Agreement_Worksheet__c pawObj = [Select id From Pay_Agreement_Worksheet__c Limit 1];
            ApexPages.currentPage().getParameters().put('id', pawObj.Id);

            PAW_New_EditCntrllr pawCntrllrObj = new PAW_New_EditCntrllr();
            pawCntrllrObj.initialize();
        Test.stopTest();
    }
}