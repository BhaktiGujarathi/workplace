@isTest
private class OpportunityIOPFinalizeServiceTest {
	
	 // method to setup test data for the test class
    @testSetup static void setupTestData() {
        //frn account
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'FRN Facility');
        accountObj = FRNOrgTestDataFactory.createFrnFacilityAccountRecord(accountObj, false);
        accountObj.FRN_Facility_Type__c = 'Intensive Outpatient';
        insert accountObj;
               
        Account inscmpnyAccObj = new Account();
        inscmpnyAccObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Insurance Company');
        inscmpnyAccObj = FRNOrgTestDataFactory.createInsComapnyAccountRecord(accountObj);
        system.assertNotEquals(inscmpnyAccObj.Id, null);
        
        Facility_Program__c fcltyPrgrmObj = new Facility_Program__c();
        fcltyPrgrmObj = FRNOrgTestDataFactory.createFcltyPrgrmRecord(fcltyPrgrmObj,1);
        fcltyPrgrmObj.Program_Length__c = 10;
        fcltyPrgrmObj.Target_EDR__c = 10000;
        fcltyPrgrmObj.Room_and_Board_Daily_Rate__c = 100;
        fcltyPrgrmObj.Private_Pay_Fee__c = 150;
        fcltyPrgrmObj.Days_60_90_Fees__c = 100;
        fcltyPrgrmObj.Ancillary_Fees__c = 200;
        fcltyPrgrmObj.FRN_Facility__c = accountObj.Id;
        insert fcltyPrgrmObj;
                
        Opportunity rtcOppObj = new Opportunity();
        rtcOppObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Outpatient Treatment');
        rtcOppObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(rtcOppObj);        
        insert rtcOppObj;
        system.assertNotEquals(rtcOppObj.Id, null);
        
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
        ptntInsrnceObj.Opportunity__c = rtcOppObj.Id;
        ptntInsrnceObj.Insurance_Company__c = inscmpnyAccObj.Id;
        insert ptntInsrnceObj;
        system.assertNotEquals(ptntInsrnceObj.Id, null);
        
        Insurance_Benefit__c insrncBnftObj = new Insurance_Benefit__c();
        insrncBnftObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Insurance_Benefit__c', 'In Network');
        insrncBnftObj = FRNOrgTestDataFactory.createInsrncBnftRecord(insrncBnftObj,
                                                                     ptntInsrnceObj.Id);
        
        insrncBnftObj.DTX_Apply_Copay__c=false;
        insrncBnftObj.Day_Max_Inpatient_Used__c=0.00;
        insrncBnftObj.Day_Max_Inpatient__c=365.00;
        insrncBnftObj.Day_Max_Outpatient_Used__c=0.00;
        insrncBnftObj.Day_Max_Outpatient__c=365.00;
        insrncBnftObj.Deductible_Included_in_OOP__c='No';
        insrncBnftObj.Deductible_Met__c=1000.00;
        insrncBnftObj.Deductible__c=4500.00;
        insrncBnftObj.Detox_Covered__c='Yes';
        insrncBnftObj.Detox_Pays_at__c=75.00;
        insrncBnftObj.IOP_Admit_Co_Payment__c=10.00;
        insrncBnftObj.IOP_Apply_Copay__c=true;
        insrncBnftObj.IOP_Copay_Type__c='Per Day';
        insrncBnftObj.IOP_Covered__c='Yes';
        insrncBnftObj.IOP_Pays_at__c=75.00;
        insrncBnftObj.Insurance_Company_is_Out_of_Network__c=false;
        insrncBnftObj.LOC_Benefits_are_the_Same__c=true;
        insrncBnftObj.Lifetime_Max_Met__c=0.00;
        insrncBnftObj.Lifetime_Max__c=1000000.00;
        insrncBnftObj.Max_Out_of_Pocket_Met__c=1000.00;
        insrncBnftObj.Max_Out_of_Pocket__c=10000.00;
        insrncBnftObj.No_Out_of_Network_Benefits__c=false;
        insrncBnftObj.PHP_Admit_Co_Payment__c=10.00;
        insrncBnftObj.PHP_Apply_Copay__c=true;
        insrncBnftObj.PHP_Copay_Type__c='Per Day';
        insrncBnftObj.PHP_Covered__c='Yes';
        insrncBnftObj.PHP_Pays_at__c=75.00;
        insrncBnftObj.RTC_Apply_Copay__c=false;
        insrncBnftObj.RTC_Covered__c='Yes';
        insrncBnftObj.RTC_Pays_at__c=75.00;
        insrncBnftObj.Room_and_Board_Days_Rate__c=2000.00;
        insrncBnftObj.Uncovered_Days_Rate__c=630.00;
        insert insrncBnftObj;

        system.assertNotEquals(insrncBnftObj.Id, null);
        
        Estimated_Coverage_Days__c estmtCnrgeDaysObj = new Estimated_Coverage_Days__c();
        estmtCnrgeDaysObj = FRNOrgTestDataFactory.createEstmtCvrgrDaysRecord(estmtCnrgeDaysObj,
                                                                      insrncBnftObj.Id);
        estmtCnrgeDaysObj.FRN_Facility__c = accountObj.Id;
        estmtCnrgeDaysObj.DTX_Days__c = 10;
        estmtCnrgeDaysObj.IOP_Days__c = 10;
        estmtCnrgeDaysObj.PHP_Days__c = 10;
        estmtCnrgeDaysObj.RTC_Days__c = 10;
        insert estmtCnrgeDaysObj;
        system.assertNotEquals(estmtCnrgeDaysObj.Id, null);
        
        // PAW record 
        Pay_Agreement_Worksheet__c pawObj = new Pay_Agreement_Worksheet__c();
        pawObj = FRNOrgTestDataFactory.createPAWRecord(pawObj,
                                                        rtcOppObj.Id,
                                                        ptntInsrnceObj.Id,
                                                        insrncBnftObj.Id,
                                                        accountObj.Id,
                                                        fcltyPrgrmObj.Id);
        insert pawObj;
        system.assertNotEquals(pawObj.Id, null);

        Quote quoteObj = new Quote();
        quoteObj = FRNOrgTestDataFactory.createQuoteRecord(quoteObj);
        quoteObj.Insurance_Company__c = inscmpnyAccObj.Id;
        quoteObj.Pay_Agreement_Worksheet__c = pawObj.Id;
        quoteObj.OpportunityId = rtcOppObj.Id;
        quoteObj.FRN_Facility__c = accountObj.Id;
        quoteObj.Facility_Program__c = fcltyPrgrmObj.Id;
        quoteObj.Select_as_Final_Quote__c = true;
        quoteObj.Name = 'TestQuote';
        insert quoteObj;
    }

    // method to test calculateWraperValues()
    static testMethod void triggerOpportunityFinalizationTest() {
        Test.startTest();
            Opportunity oppObj = [Select id from Opportunity Limit 1];
            String assertStr = OpportunityIOPFinalizeService.triggerOpportunityFinalization(oppObj.Id);
        Test.stopTest();
	}
}