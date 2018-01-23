// class to create test data with validations specific to PAW creation
public with sharing class PAWTestDataFactory {
    public PAWTestDataFactory() {
        
    }
    
    // method to get Account of FRN Facility record type of type Residential
    public static Account createFRNFacilityAccountRecord(Boolean pIsTalbott) {
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'FRN Facility');
        accountObj = FRNOrgTestDataFactory.createFrnFacilityAccountRecord(accountObj, pIsTalbott);
        
        return accountObj;
    }

    // method to get Account of FRN Facility record type of type IOP
    public static Account createIopFrnFacilityAccountRecord() {
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'FRN Facility');
        accountObj = FRNOrgTestDataFactory.createFrnFacilityAccountRecord(accountObj, false);
        accountObj.FRN_Facility_Type__c = 'Intensive Outpatient';
        return accountObj;
    }
    
    // method to create a account record of type insurance company
    public static Account createInsCompanyAccountRecord() {
        Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Insurance Company');
        accountObj = FRNOrgTestDataFactory.createInsComapnyAccountRecord(accountObj);
        
        return accountObj;
    }
    
    // method to create list of facilty program for a facility center
    public static List<Facility_Program__c> createFcltyPrgrmRecords(Integer pCount, Id pParentFrnFacilityId) {
        List<Facility_Program__c> fcltyPrgrmList = new List<Facility_Program__c>();
        for(Integer i = 1; i <= pCount; i++) {
	        Facility_Program__c fcltyPrgrmObj = new Facility_Program__c();
	        fcltyPrgrmObj = FRNOrgTestDataFactory.createFcltyPrgrmRecord(fcltyPrgrmObj, i);
	        fcltyPrgrmObj.Program_Length__c = 10*i;
	        fcltyPrgrmObj.Target_EDR__c = 10000*i;
	        fcltyPrgrmObj.Room_and_Board_Daily_Rate__c = 100*i;
	        fcltyPrgrmObj.Private_Pay_Fee__c = 150*i;
	        fcltyPrgrmObj.Days_60_90_Fees__c = 100*i;
	        fcltyPrgrmObj.Ancillary_Fees__c = 200*i;
	        fcltyPrgrmObj.FRN_Facility__c = pParentFrnFacilityId;
	        fcltyPrgrmList.add(fcltyPrgrmObj);
        }
        
        return fcltyPrgrmList;
    }
    
    // method to create a list of prgram care records for a facilty program
    public static List<Facility_Program_Level_of_Care__c> createFcltyPrgrmCareList(Id pParentFcltyPrgrmId) {
        List<Facility_Program_Level_of_Care__c> fcltyPrgrmCareList = 
                                                     new List<Facility_Program_Level_of_Care__c>();
        for(Schema.RecordTypeInfo recordtypeInstance : Schema.getGlobalDescribe().
                                                       get('Facility_Program_Level_of_Care__c').
                                                       getDescribe().getRecordTypeInfos()) {
            if(recordtypeInstance.getName() != 'Master') {
	            Facility_Program_Level_of_Care__c fcltyPrgrmCareObj = new Facility_Program_Level_of_Care__c();
	            fcltyPrgrmCareObj = FRNOrgTestDataFactory.createFciltyPrgrmLvlOfCareRecord(fcltyPrgrmCareObj);
	            fcltyPrgrmCareObj.RecordTypeId = recordtypeInstance.getRecordTypeId();
	            fcltyPrgrmCareObj.Billing_Rate__c = 100*(fcltyPrgrmCareList.size()+1);
	            fcltyPrgrmCareObj.isDefault__c = true;
	            fcltyPrgrmCareObj.Facility_Program__c = pParentFcltyPrgrmId;
	            
	            fcltyPrgrmCareList.add(fcltyPrgrmCareObj);
            }
        }
        
        return fcltyPrgrmCareList;
    }
    
    // method to create a Opportunity record of type RTC
    public static Opportunity createRtcOpportunityRecord() {
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        opportunityObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(opportunityObj);
        
        return opportunityObj;
    }
    
    // method to create a Contact record of type patient
    public static Contact createPatientContactRecord() {
        Contact ptntContactObj = new Contact();
        ptntContactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Patient');
        ptntContactObj = FRNOrgTestDataFactory.createPatientContactRecord(ptntContactObj);
        
        return ptntContactObj;
    }
    
    // method to create a Patient insurance record
    public static Patient_Insurance__c createPtntInsrncRecord(Id pParentPatientContactId,
                                                              Id pParentOpportunityId,
                                                              Id pParentInsrncCmpnyId) {
        Patient_Insurance__c ptntInsrnceObj = new Patient_Insurance__c();
        ptntInsrnceObj = FRNOrgTestDataFactory.createPtntInsrncRecord(ptntInsrnceObj,
                                                                      pParentPatientContactId);
        ptntInsrnceObj.Opportunity__c = pParentOpportunityId;
        ptntInsrnceObj.Insurance_Company__c = pParentInsrncCmpnyId;
        
        return ptntInsrnceObj;
    }
    
    // method to create a Patient insurance record
    public static Insurance_Benefit__c createInsrncBnftRecord(Id pParentPatientInsrncId) {
        Insurance_Benefit__c insrncBnftObj = new Insurance_Benefit__c();
        insrncBnftObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Insurance_Benefit__c', 'In Network');
        insrncBnftObj = FRNOrgTestDataFactory.createInsrncBnftRecord(insrncBnftObj,
                                                                     pParentPatientInsrncId);
        
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
        //insrncBnftObj.Reimbursement_Structure__c='UCR';
        insrncBnftObj.Room_and_Board_Days_Rate__c=2000.00;
        insrncBnftObj.Uncovered_Days_Rate__c=630.00;
        insrncBnftObj.Applicable_For_Year__c = string.valueOf(System.today().year());

        return insrncBnftObj;
    }
    
    // method to create a Patient insurance record
    public static Estimated_Coverage_Days__c createEstmtCvrgeDaysRecord(Id pParentInsrncBnftId,
                                                                        Id pParentFcltyId) {
        Estimated_Coverage_Days__c estmtCnrgeDaysObj = new Estimated_Coverage_Days__c();
        estmtCnrgeDaysObj = FRNOrgTestDataFactory.createEstmtCvrgrDaysRecord(estmtCnrgeDaysObj,
                                                                      pParentInsrncBnftId);
        estmtCnrgeDaysObj.FRN_Facility__c = pParentFcltyId;
        estmtCnrgeDaysObj.DTX_Days__c = 10;
        estmtCnrgeDaysObj.IOP_Days__c = 10;
        estmtCnrgeDaysObj.PHP_Days__c = 10;
        estmtCnrgeDaysObj.RTC_Days__c = 10;
        return estmtCnrgeDaysObj;
    }
    
    // method to create a Patient insurance record
    public static Insurance_Company_Rate_Adjustment__c createRtAdjustmntRecord(Id pParentInsrncCpnyId,
                                                                               Id pParentFcltyId) {
        Insurance_Company_Rate_Adjustment__c rtAdjstmntObj = new Insurance_Company_Rate_Adjustment__c();
        rtAdjstmntObj = FRNOrgTestDataFactory.createRtAdjustmntRecord(rtAdjstmntObj,
                                                                      pParentInsrncCpnyId);
        rtAdjstmntObj.FRN_Facility__c = pParentFcltyId;
        rtAdjstmntObj.Rate_Adjustment__c = 15;
        rtAdjstmntObj.Active_Date__c = System.Today();
        rtAdjstmntObj.Term_Date__c = System.Today().addDays(10);
        rtAdjstmntObj.Type__c = 'Contracted';
        return rtAdjstmntObj;
    }
    
    // method to create Quote record
    public static Quote createEstmtTrtmntRecord(Pay_Agreement_Worksheet__c pParentPawObj,
                                                Id pParentInsrncCmpnyId,
                                                Id pParentFcltyId,
                                                Id pParentFcltyPrgrmId) {
        Quote quoteObj = new Quote();
        quoteObj = FRNOrgTestDataFactory.createQuoteRecord(quoteObj);
        quoteObj.Pay_Agreement_Worksheet__c = pParentPawObj.Id;
        quoteObj.name = pParentPawObj.Patient_Insurance__r.opportunity__r.name;
        quoteObj.opportunityId = pParentPawObj.Patient_Insurance__r.opportunity__c;
        quoteObj.Insurance_Company__c = pParentInsrncCmpnyId;
        quoteObj.FRN_Facility__c = pParentFcltyId;
        quoteObj.Facility_Program__c = pParentFcltyPrgrmId;        
        return quoteObj;
    }

    // method to prepare a query string for any given object name by schema call
    public static String preparesObjectQuery(String psObjectName, String pWhereClause) {
        String querystr = 'SELECT ';
        String fieldStr = '';
        for(Schema.SObjectField fieldInstance : schema.getGlobalDescribe().get(psObjectName).getDescribe().fields.getMap().Values()) {
            fieldStr += fieldInstance.getDescribe().getname() + ', ';
        }
        fieldStr = fieldStr.removeEnd(', ');
        if(pWhereClause != '' && pWhereClause != null) {
            queryStr += fieldStr + ' FROM '+psObjectName+' WHERE '+pWhereClause;
        }
        else {
            queryStr += fieldStr + ' FROM '+psObjectName;
        }
        return querystr;
    }
}