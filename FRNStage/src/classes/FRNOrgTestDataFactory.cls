// class to create test data with org level validations
public with sharing class FRNOrgTestDataFactory {
    
    public FRNOrgTestDataFactory() {
    }
    
    // method to create Account record of type FRN facility
    public static Account createFrnFacilityAccountRecord(Account pAccountObj, Boolean pIsTalbott) {
        if(pIsTalbott) {
            pAccountObj.Name = 'TalbotFacility';
            pAccountObj.FRN_Facility_Type__c = 'Intensive Outpatient';
            pAccountObj.Ownership = 'Talbott';
        }
        else {
            pAccountObj.Name = 'FRNFacility';
            pAccountObj.FRN_Facility_Type__c = 'Intensive Outpatient';
            pAccountObj.Ownership = 'FRN';
        }
        return pAccountObj;
    }
    
    // method to create Account record of type Insurance company
    public static Account createInsComapnyAccountRecord(Account pAccountObj) {
        pAccountObj.Name = 'Test Insurance Company';
        
        return pAccountObj;
    }
    
    // method to create Facility Program record
    public static Facility_Program__c createFcltyPrgrmRecord(Facility_Program__c pFcltyPrgrmObj,
                                                             Integer pIndex) {
        pFcltyPrgrmObj.Name = 'Residential'+pIndex;
        
        return pFcltyPrgrmObj;
    }
    
    // method to create Facility_Program_Level_of_Care__c records for a particular facility Program
    public static Facility_Program_Level_of_Care__c createFciltyPrgrmLvlOfCareRecord(
                                        Facility_Program_Level_of_Care__c pFcltyPrgrmCareObj
                                        ) {
        return pFcltyPrgrmCareObj;
    }
    
    // method to create Opportunity record of RTC
    public static Opportunity createRtcOpportunityRecord(Opportunity pOpportunityObj) {
        pOpportunityObj.LeadSource = 'Alumini';
        pOpportunityObj.stageName = 'In Process';
        pOpportunityObj.CloseDate = system.Today().addMonths(5);
        pOpportunityObj.Name = 'Test Opportunity';
        
        return pOpportunityObj;
    }
    
    // method to create a patient contact record
    public static Contact createPatientContactRecord(Contact pContactObj) {
        pContactObj.firstName = 'TestFiestName';
        pContactObj.LastName = 'TestLastName';
        
        return pContactObj;
    }
    
    // method to create a Patient insurance record
    public static Patient_Insurance__c createPtntInsrncRecord(Patient_Insurance__c pPtntInsrncObj,
                                                              Id pParentPatientContactId) {
        pPtntInsrncObj.Name = 'Test Patient Insurance';
        pPtntInsrncObj.Patient__c = pParentPatientContactId;
        
        return pPtntInsrncObj;
    }
    
    // method to create a Patient insurance record
    public static Insurance_Benefit__c createInsrncBnftRecord(Insurance_Benefit__c pInsrncBnftObj,
                                                              Id pParentPatientInsrncId) {
        pInsrncBnftObj.Patient_Insurance__c = pParentPatientInsrncId;
        
        return pInsrncBnftObj;
    }
    
    // method to create a Estimate Coverage Days record
    public static Estimated_Coverage_Days__c createEstmtCvrgrDaysRecord(
                                                       Estimated_Coverage_Days__c pEstmtCvrgDaysObj,
                                                       Id pParentInsrncBnftId) {
        pEstmtCvrgDaysObj.Insurance_Benefit__c = pParentInsrncBnftId;
        
        return pEstmtCvrgDaysObj;
    }
    
    // method to create a Insurance Company Rate Adjustment
    public static Insurance_Company_Rate_Adjustment__c createRtAdjustmntRecord(
                                                       Insurance_Company_Rate_Adjustment__c pRtAdjstmntObj,
                                                       Id pParentInsrncCmpnyId
                                                       ) {
        pRtAdjstmntObj.Insurance_Company__c = pParentInsrncCmpnyId;
        pRtAdjstmntObj.Type__c = 'UCR';
        pRtAdjstmntObj.Active_Date__c = System.today();
        pRtAdjstmntObj.Term_Date__c = System.today().addDays(10);
        return pRtAdjstmntObj;
    }
    
    // method to create Quote record
    public static Quote createQuoteRecord(Quote pEstmateTrtmntObj) {
        
        return pEstmateTrtmntObj;
    }

    // create Pay_Agreement_Worksheet__c records
    public Static Pay_Agreement_Worksheet__c createPAWRecord(Pay_Agreement_Worksheet__c pPAWobj,
                                                             Id pParentOpportunityId,
                                                             Id pParentPatientInsuranceId,
                                                             Id pParentInsuranceBnftId,
                                                             Id pParentFRNFcltyId,
                                                             Id pParentFcltyPrgrmId) {
        pPAWObj.Opportunity__c = pParentOpportunityId;
        pPAWObj.Patient_Insurance__c = pParentPatientInsuranceId;
        pPAWObj.Insurance_Benefit__c = pParentInsuranceBnftId;
        pPAWObj.FRN_Facility__c = pParentFRNFcltyId;
        pPAWObj.Facility_Program__c = pParentFcltyPrgrmId;
        
        return pPAWObj;
    }
    
    // method to fetch the record type id based on sobject name and recordtype name
    public static Id getRecordtypeIdForSobjectAndRecordtypeName(String pSobjectName,
                                                                String pRecordTypeName) {
         Id recordTypeId;
         recordTypeId = Schema.getGlobalDescribe().get(pSobjectName).getDescribe().getRecordTypeInfosByName().get(pRecordTypeName).getRecordTypeId();
         return recordTypeId;
    }
    
    
}