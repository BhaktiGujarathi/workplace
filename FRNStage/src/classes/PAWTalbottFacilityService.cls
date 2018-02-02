public with sharing class PAWTalbottFacilityService extends PAWValueCalculationService{
    // constructor
    public PAWTalbottFacilityService () {
        
    }
    
    // method to calculate the the value update for PAW
    public PAW_New_EditCntrllr.WraperClass calculateWraperValuesTalbott(
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
        //for talbott do not consider the detox and RTC days
        pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.DTX_Days__c!=null 
                                    ? pWrprObj.totalRowCount - pEstmtCvrgeDaysObj.DTX_Days__c
                                    : pWrprObj.totalRowCount);
        pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.RTC_Days__c!=null
                                    ? pWrprObj.totalRowCount - pEstmtCvrgeDaysObj.RTC_Days__c
                                    : pWrprObj.totalRowCount);
        // get room rate from facility program
        if(pWrprObj.fcltyPrgrmSelected != null && pWrprObj.fcltyPrgrmSelected != '') {
          pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c = (
                    pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Total_Room_and_Board__c != null
                  ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Total_Room_and_Board__c
                  : 0.00);
          // calculate 60-90 days fees from facility program
          pWrprObj.pyAgrmntWrksht.Days_60_90_Fees__c = (
                        pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c != null
                      ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c
                      : 0.00);
        }
        return pWrprObj;
    }
    
    // method to update the PAWdetail records for PAW
    public PAW_New_EditCntrllr.WraperClass createAndUpdatePAWDetailsRecordsTalbott(
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
        pWrprObj.TotalInsEIVAmt = 0.00;
        pWrprObj.TotalAppliedDeductible = 0.00;
        pWrprObj.TotalCoInsurance = 0.00;
        pWrprObj.totalInsCoResp = 0.00;
        List<Pay_Agreement_Worksheet_Detail__c> pawDetailList = new List<Pay_Agreement_Worksheet_Detail__c>();
        decimal rateAdstmnt = (pWrprObj.rateAdjstmntSelected != '' && pWrprObj.rateAdjstmntSelected 
                             != null && pCmpnyRateAdjstmntMap.containsKey(pWrprObj.rateAdjstmntSelected) 
                            ? pCmpnyRateAdjstmntMap.get(pWrprObj.rateAdjstmntSelected).Rate_Adjustment__c/100 :
                            0);
        for(Integer i = 0; i < pWrprObj.relatedPAWDetailsList.size(); i++) {
            if( pWrprObj.relatedPAWDetailsList[i].Level_of_Care__c != 'Detox (DTX)' && 
                pWrprObj.relatedPAWDetailsList[i].Level_of_Care__c != 'Residential Treatment (RTC)') {
                //calculation of billed rate
                pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c = ((
                                        pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c == null
                                      ? 0
                                      : pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c)
                                        *(1 - rateAdstmnt));
                if(pawDetailList.size() > 0) {
                    pWrprObj.relatedPAWDetailsList[i].Beginning_Deductible__c = ((
                                pWrprObj.relatedPAWDetailsList[i-1].Beginning_Deductible__c
                              - pWrprObj.relatedPAWDetailsList[i-1].Applied_Deductible__c) > 0
                       ? (pWrprObj.relatedPAWDetailsList[i-1].Beginning_Deductible__c 
                       - pWrprObj.relatedPAWDetailsList[i-1].Applied_Deductible__c)
                       : 0.00);
                }
                // applied deductible
                if(pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c <=
                                        pWrprObj.relatedPAWDetailsList[i].Beginning_Deductible__c) {
                    pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c = (
                                           pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c == null
                                         ? 0
                                         : pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c);
                } else{
                    pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c =
                                          pWrprObj.relatedPAWDetailsList[i].Beginning_Deductible__c;
                }
                // charge after deductible
                pWrprObj.relatedPAWDetailsList[i].Charge_After_Deductible__c =
                                            pWrprObj.relatedPAWDetailsList[i].Billed_Rate__c
                                          - pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c;
                if(pawDetailList.size() == 0) {
                     if(pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != '') {
                        pWrprObj.relatedPAWDetailsList[i].Beginning_Out_of_Pocket__c =
                                pWrprObj.insrncBnft.Max_Out_of_Pocket_Remaining__c;
                     }
                }else {
                    
                   pWrprObj.relatedPAWDetailsList[i].Beginning_Out_of_Pocket__c =
                            pWrprObj.relatedPAWDetailsList[i-1].Out_of_Pocket_After_Deductible__c
                          - pWrprObj.relatedPAWDetailsList[i-1].Co_Insurance__c;
                }
                if(pWrprObj.insrncBnftSelected != null
                    && pWrprObj.insrncBnftSelected != ''
                    && pWrprObj.insrncBnft.Deductible_Included_in_OOP__c=='Yes') {
                    pWrprObj.relatedPAWDetailsList[i].Out_of_Pocket_After_Deductible__c =
                            pWrprObj.relatedPAWDetailsList[i].Beginning_Out_of_Pocket__c
                          - pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c;
                } else {
                    pWrprObj.relatedPAWDetailsList[i].Out_of_Pocket_After_Deductible__c =
                            pWrprObj.relatedPAWDetailsList[i].Beginning_Out_of_Pocket__c;
                }
                pWrprObj.relatedPAWDetailsList[i].Calculated_Co_Insurance__c = (
                    (1 - (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c != 0.00
                          ? (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c/100)
                          : 0.00))
                * pWrprObj.relatedPAWDetailsList[i].Charge_After_Deductible__c).setScale(2);
                if((pWrprObj.relatedPAWDetailsList[i].Charge_After_Deductible__c
                    *(1 - (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c != 0.00 
                           ? (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c/100)
                           : 0.00))) 
                <= pWrprObj.relatedPAWDetailsList[i].Out_of_Pocket_After_Deductible__c) {
                    pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c = (
                            pWrprObj.relatedPAWDetailsList[i].Charge_After_Deductible__c
                           *(1 - (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c != 0.00 
                                  ? (pWrprObj.relatedPAWDetailsList[i].Insurance_Coverage__c/100)
                                  : 0.00))).setScale(2);
                } else {
                    pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c = 
                        pWrprObj.relatedPAWDetailsList[i].Out_of_Pocket_After_Deductible__c;
                }
                
                pWrprObj.relatedPAWDetailsList[i].Insurance_EIV__c = (
                                    pWrprObj.relatedPAWDetailsList[i].Charge_After_Deductible__c
                                  - pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c);
                
                pWrprObj.relatedPAWDetailsList[i].Patient_Responsibility__c = 
                    pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c 
                  + pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c;
                  
                pWrprObj.TotalInsEIVAmt = pWrprObj.TotalInsEIVAmt + (pWrprObj.relatedPAWDetailsList[i].Insurance_EIV__c != null
                                                                   ? pWrprObj.relatedPAWDetailsList[i].Insurance_EIV__c
                                                                   : 0); 
                if((pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != '') 
                    && (pWrprObj.TotalInsEIVAmt > pWrprObj.insrncBnft.Annual_Max_Remaining__c)){
                    pWrprObj.relatedPAWDetailsList[i].Insurance_Co_Responsibility__c = 
                                                       pWrprObj.insrncBnft.Annual_Max_Remaining__c
                                                     - pWrprObj.totalInsCoResp;
                } else {
                    pWrprObj.relatedPAWDetailsList[i].Insurance_Co_Responsibility__c = (
                                         pWrprObj.relatedPAWDetailsList[i].Insurance_EIV__c != null
                                       ? pWrprObj.relatedPAWDetailsList[i].Insurance_EIV__c
                                       : 0);
                }
                pWrprObj.TotalAppliedDeductible += (pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c != null
                                                  ? pWrprObj.relatedPAWDetailsList[i].Applied_Deductible__c
                                                  : 0);
                pWrprObj.TotalCoInsurance += (pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c != null
                                            ? pWrprObj.relatedPAWDetailsList[i].Co_Insurance__c
                                            : 0);
                pWrprObj.totalInsCoResp = pWrprObj.totalInsCoResp + 
                                          (pWrprObj.relatedPAWDetailsList[i].Insurance_Co_Responsibility__c != null
                                        ? pWrprObj.relatedPAWDetailsList[i].Insurance_Co_Responsibility__c
                                        : 0);
                pawDetailList.add(pWrprObj.relatedPAWDetailsList[i]);
            }
            pWrprObj.pyAgrmntWrksht.Plan_Coverage__c = pWrprObj.totalAppliedDeductible
                                                       + pWrprObj.totalCoInsurance;
        }
        pWrprObj.relatedPAWDetailsList = pawDetailList;

        // variable initialization
        Decimal revenue = 0.00;
        Decimal uncoveredDaysCharges = 0.00;
        Decimal daysFee = 0.00;
        Decimal ancillaryFee = 0.00;
        Decimal roomBoardDaysRate = 0.00;
        Decimal insuranceEivAmt = (pWrprObj.TotalInsEIVAmt != null ? pWrprObj.TotalInsEIVAmt : 0.0);
        if(pWrprObj.totalInsCoResp == null) pWrprObj.totalInsCoResp = 0;
        if(pWrprObj.insrncBnft.Uncovered_Days__c == null) pWrprObj.insrncBnft.Uncovered_Days__c = 0;
        if(pWrprObj.insrncBnft.Uncovered_Days_Rate__c == null) pWrprObj.insrncBnft.Uncovered_Days_Rate__c = 0;
        
        // add up the room and board days to total contribution
        Decimal deductibleRequested = (pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c !=null)
                                       ? pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c
                                       : 0.00;
        // calculate coInsAmtRequested
        Decimal coInsAmtRequested = (pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c !=null)
                                     ? pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c
                                     : 0.00;
        // calculate uncoveredCharges
        Decimal uncoveredCharges = (pWrprObj.pyAgrmntWrksht.Uncovered_Charges__c !=null)
                                    ? pWrprObj.pyAgrmntWrksht.Uncovered_Charges__c
                                    : 0.00;
        // calculate privatepay fee
        Decimal privatePayFee = (pWrprObj.pyAgrmntWrksht.Private_Pay__c !=null) 
                                ? pWrprObj.pyAgrmntWrksht.Private_Pay__c : 0.00;
        // calculate coPayAmtRequested
        Decimal coPayAmtRequested = (pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c !=null) 
                                    ? pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c : 0.00;
        
        if(pWrprObj.fcltyPrgrmSelected!=null && pWrprObj.fcltyPrgrmSelected!='' 
            && pFcltyPrgmMap.containsKey(pWrprObj.fcltyPrgrmSelected)){
            // calculate daysFee
            daysFee = (pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c !=null)
                                       ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c
                                       : 0.00;
            // calculate ancillaryFee
            ancillaryFee = (pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Ancillary_Fees__c !=null)
                                       ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Ancillary_Fees__c
                                       : 0.00;
            // calculate roomBoardDaysRate
            roomBoardDaysRate = (((pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Number_of_Room_and_Board_Days__c !=null)
                                       ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Number_of_Room_and_Board_Days__c
                                       : 0.00)
                                * ((pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Room_and_Board_Daily_Rate__c !=null)
                                       ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Room_and_Board_Daily_Rate__c
                                       : 0.00));
        }
        // calculate uncoveredDaysCharges
        uncoveredDaysCharges = (pWrprObj.insrncBnft.Uncovered_Days__c * pWrprObj.insrncBnft.Uncovered_Days_Rate__c);

        pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c = roomBoardDaysRate;

        // total patient contribution calculation 
        pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c = privatePayFee
                                                              + deductibleRequested
                                                              + uncoveredCharges
                                                              + coPayAmtRequested
                                                              + coInsAmtRequested
                                                              + uncoveredDaysCharges
                                                              + ancillaryFee
                                                              + roomBoardDaysRate
                                                              + daysFee;
        // total revenue calculation 
        pWrprObj.pyAgrmntWrksht.Total_Revenue__c = privatePayFee
                                                 + deductibleRequested
                                                 + uncoveredCharges
                                                 + coPayAmtRequested
                                                 + coInsAmtRequested
                                                 + uncoveredDaysCharges
                                                 + pWrprObj.totalInsCoResp
                                                 + daysFee;
        
        decimal totaldays = pWrprObj.totalRowCount + pWrprObj.insrncBnft.Uncovered_Days__c;
        // calculation of total daily revenue
        pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = privatePayFee
                                                 + deductibleRequested
                                                 + uncoveredCharges
                                                 + coPayAmtRequested
                                                 + coInsAmtRequested
                                                 + pWrprObj.totalInsCoResp
                                                 + daysFee
                                                 + uncoveredDaysCharges;
        //if(totaldays>0){
            pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = (pWrprObj.pyAgrmntWrksht.Daily_Revenue__c
                                                        /((pWrprObj.fcltyPrgrmSelected != null 
                                                            && pWrprObj.fcltyPrgrmSelected != '' 
                                                            && pFcltyPrgmMap.containsKey(pWrprObj.fcltyPrgrmSelected) 
                                                            && pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c != null
                                                          ) ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c 
                                                          : 1));
        //}
        
        if(pWrprObj.pyAgrmntWrksht.Plan_Coverage__c<(pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c+pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c+pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sum of Co-Insurance, Deductible Amount Requested and Co-pay Amount Requested exceeds Plan Coverage');
            ApexPages.addMessage(myMsg);
        }
        if(pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != ''){
            if(pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c > pWrprObj.insrncBnft.Deductible_Remaining__c) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Deductible Amount Requested exceeds Deductible Remaining');
                ApexPages.addMessage(myMsg);
            }
        }
        if(pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c > pWrprObj.totalCoPayAmt) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Pay Amount Requested exceeds Total Co-Pay Amount');
            ApexPages.addMessage(myMsg);
        }
        return pWrprObj;
    }
}