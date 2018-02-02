@isTest
private class PAWIopServiceTest {

    // method to setup test data for the test class
    @testSetup static void setupTestData() {
                
        // talbott account
        Account iopAccObj = PAWTestDataFactory.createIopFrnFacilityAccountRecord();
        insert iopAccObj;
        system.assertNotEquals(iopAccObj.Id, null);
        
        // insurance company account
        Account inscmpnyAccObj = PAWTestDataFactory.createInsCompanyAccountRecord();
        insert inscmpnyAccObj;
        system.assertNotEquals(inscmpnyAccObj.Id, null);
               
        //facility programs
        List<Facility_Program__c> iopfcltyPrgrmList = PAWTestDataFactory.createFcltyPrgrmRecords(3,
                                                                            iopAccObj.Id);
        insert iopfcltyPrgrmList;
        for(Facility_Program__c fcltyPrgrmInstance : iopfcltyPrgrmList) {
            system.assertNotEquals(fcltyPrgrmInstance.Id, null);
        }
        
        //facility programs level of care
        List<Facility_Program_Level_of_Care__c> iopFcltyPrgrmCareList = PAWTestDataFactory.createFcltyPrgrmCareList(
                                                                            iopfcltyPrgrmList[0].Id);
        insert iopFcltyPrgrmCareList;
        for(Facility_Program_Level_of_Care__c fcltyPrgrmInstance : iopFcltyPrgrmCareList) {
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
        Estimated_Coverage_Days__c iopEstmteCvrgeDaysObj = PAWTestDataFactory.createEstmtCvrgeDaysRecord(
                                                                            insrncBnftObj.Id,
                                                                            iopAccObj.Id);
        insert iopEstmteCvrgeDaysObj;
        system.assertNotEquals(iopEstmteCvrgeDaysObj.Id, null);
        
        // rate adjustment record for frn facility
        Insurance_Company_Rate_Adjustment__c iopRateAdjstmntObj = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            inscmpnyAccObj.Id,
                                                                            iopAccObj.Id);
        insert iopRateAdjstmntObj;
        system.assertNotEquals(iopRateAdjstmntObj.Id, null);
        
    }
    
    // method to test calculateWraperValuesFRN()
    static testMethod void calculateWraperValuesIOPTest() {
        Test.startTest();
            String queryStr = PAWTestDataFactory.preparesObjectQuery('Opportunity', '');
            Opportunity oppObj = Database.query(queryStr);

            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            PAW_New_EditCntrllr.WraperClass assertWrapperInstance = new PAW_New_EditCntrllr.WraperClass();
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
            cntrllrObj.wrprObj.fcltyPrgrmSelected = cntrllrObj.fcltyPrgrmOptions[1].getValue();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            
            PAWIopService iopServiceClass = new PAWIopService();
            assertWrapperInstance = iopServiceClass.calculateWraperValuesIOP(cntrllrObj.wrprObj,
                                                     cntrllrObj.fcltyPrgmMap,
                                                     cntrllrObj.cmpnyRateAdjstmntMap,
                                                     cntrllrObj.insrncBnftMap,
                                                     cntrllrObj.estmtCvrgeDaysObj);

            queryStr = PAWTestDataFactory.preparesObjectQuery('Estimated_Coverage_Days__c', '');
            Estimated_Coverage_Days__c estmtCovrgeObj = Database.query(queryStr);

            queryStr = PAWTestDataFactory.preparesObjectQuery('Insurance_Benefit__c', '');
            Insurance_Benefit__c bnftObj = Database.query(queryStr);


            system.assertEquals(estmtCovrgeObj.IOP_Days__c, assertWrapperInstance.pyAgrmntWrksht.Num_Days_Intensive_Outpatient_IOP__c);
            system.assertEquals((bnftObj.Intensive_Outpatient_Override__c !=null? bnftObj.Intensive_Outpatient_Override__c : 0),
                                 assertWrapperInstance.pyAgrmntWrksht.Intensive_Outpatient_Override__c);
            system.assertEquals(bnftObj.IOP_Pays_at__c, assertWrapperInstance.pyAgrmntWrksht.IOP_Pays_at__c);

            system.assertEquals(estmtCovrgeObj.PHP_Days__c, assertWrapperInstance.pyAgrmntWrksht.Num_Days_Partial_Hospitalization_PHP__c);
            system.assertEquals((bnftObj.Partial_Hospitalization_Override__c !=null? bnftObj.Partial_Hospitalization_Override__c : 0), 
                                 assertWrapperInstance.pyAgrmntWrksht.Partial_Hospitalization_Override__c);
            system.assertEquals(bnftObj.PHP_Pays_at__c, assertWrapperInstance.pyAgrmntWrksht.PHP_Pays_at__c);

        Test.stopTest();
    }
    
    // method to test createAndUpdatePAWDetailsRecordsFRN()
    static testMethod void createAndUpdatePAWDetailsRecordsIOPTest() {
        Test.startTest();
            String queryStr = PAWTestDataFactory.preparesObjectQuery('Opportunity', '');
            Opportunity oppObj = Database.query(queryStr);

            //ApexPages.currentPage().getParameters().put('id', oppObj.Id);
            PAW_New_EditCntrllr cntrllrObj = new PAW_New_EditCntrllr();
            cntrllrObj.oppId = oppObj.Id;
            PAW_New_EditCntrllr.WraperClass assertWrapperInstance = new PAW_New_EditCntrllr.WraperClass();
            cntrllrObj.getPtntInsrnceOptions();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected = cntrllrObj.faciltyOptions[1].getValue();
            cntrllrObj.onFacilitySelection();
            cntrllrObj.wrprObj.fcltyPrgrmSelected = cntrllrObj.fcltyPrgrmOptions[1].getValue();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            cntrllrObj.wrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c = 1000;
            cntrllrObj.wrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c = 1000;
            cntrllrObj.wrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c = 1000;

            PAWIopService iopServiceClass = new PAWIopService();
            assertWrapperInstance = iopServiceClass.createAndUpdatePAWDetailsRecordsIOP(cntrllrObj.wrprObj,
                                                   cntrllrObj.fcltyPrgmMap,
                                                   cntrllrObj.estmtCvrgeDaysObj,
                                                   cntrllrObj.cmpnyRateAdjstmntMap,
                                                   cntrllrObj.ptntInsrncObj);

            queryStr = PAWTestDataFactory.preparesObjectQuery('Insurance_Benefit__c', '');
            Insurance_Benefit__c bnftObj = Database.query(queryStr);


            system.assertEquals(assertWrapperInstance.pyAgrmntWrksht.Total_Patient_Contribution__c, 3000);

        Test.stopTest();
    }
}