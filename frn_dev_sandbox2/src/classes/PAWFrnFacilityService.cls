public with sharing class PAWFrnFacilityService extends PAWValueCalculationService{
    public PAWFrnFacilityService() {
        
    }
    
    // method to calculate the the value update for PAW
    public PAW_New_EditCntrllr.WraperClass calculateWraperValuesFRN(
                                      PAW_New_EditCntrllr.WraperClass pWrprObj,
                                      Map<Id, Facility_Program__c> pFcltyPrgmMap,
                                      Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap,
                                      Map<Id, Insurance_Benefit__c> pInsrncBnftMap,
                                      Estimated_Coverage_Days__c pEstmtCvrgeDaysObj) {
        pWrprObj = calculateWraperValues(pWrprObj,
                                   pFcltyPrgmMap,
                                   pCmpnyRateAdjstmntMap,
                                   pInsrncBnftMap,
                                   pEstmtCvrgeDaysObj);
        return pWrprObj;
    }
    
    // method to update the PAWdetail records for PAW
    public PAW_New_EditCntrllr.WraperClass createAndUpdatePAWDetailsRecordsFRN(
                                                    PAW_New_EditCntrllr.WraperClass pWrprObj,
                                                    Map<Id, Facility_Program__c> pFcltyPrgmMap,
                                                    Estimated_Coverage_Days__c pEstmtCvrgeDaysObj,
                                                    Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap,
                                                    Patient_Insurance__c pPtntInsrncObj) {
        pWrprObj = createAndUpdatePAWDetailsRecords(pWrprObj,
                                      pFcltyPrgmMap,
                                      pEstmtCvrgeDaysObj,
                                      pCmpnyRateAdjstmntMap,
                                      pPtntInsrncObj);
        return pWrprObj;
   }
}