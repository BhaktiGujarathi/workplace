public virtual class PAWValueCalculationService {
    public static Boolean skipDML;
    public static Pay_Agreement_Worksheet__c pawObj;
    // constructor
    public PAWValueCalculationService() {
        skipDML = false;
    }

    // method to calculate the the value update for PAW
    public PAW_New_EditCntrllr.WraperClass calculateWraperValues(PAW_New_EditCntrllr.WraperClass pWrprObj,
                                      Map<Id, Facility_Program__c> pFcltyPrgmMap,
                                      Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap,
                                      Map<Id, Insurance_Benefit__c> pInsrncBnftMap,
                                      Estimated_Coverage_Days__c pEstmtCvrgeDaysObj) {
        // assign rate type to PAW
        pWrprObj.pyAgrmntWrksht.Rate_Adjustment_Type__c = null;
        if(pWrprObj.rateAdjstmntSelected!=null && pWrprObj.rateAdjstmntSelected!=''
            && pCmpnyRateAdjstmntMap.size() > 0
            && pCmpnyRateAdjstmntMap.containsKey(pWrprObj.rateAdjstmntSelected)){
            pWrprObj.pyAgrmntWrksht.Rate_Adjustment_Type__c = pCmpnyRateAdjstmntMap.get(pWrprObj.rateAdjstmntSelected).Type__c;
        }

        // assign insurance benefit
        pWrprObj.insrncBnft = (pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != ''
                               ? pInsrncBnftMap.get(pWrprObj.insrncBnftSelected) : new Insurance_Benefit__c());
        pWrprObj.totalRowCount = 0;
        pWrprObj.totalTalbottDay = 0;
        if(pEstmtCvrgeDaysObj != null) {
            pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.PHP_Days__c!=null ?
                                     pWrprObj.totalRowCount+pEstmtCvrgeDaysObj.PHP_Days__c:pWrprObj.totalRowCount);
            pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.IOP_Days__c!=null ?
                                     pWrprObj.totalRowCount+pEstmtCvrgeDaysObj.IOP_Days__c:pWrprObj.totalRowCount);
            pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.DTX_Days__c!=null ?
                                     pWrprObj.totalRowCount+pEstmtCvrgeDaysObj.DTX_Days__c:pWrprObj.totalRowCount);
            pWrprObj.totalRowCount = Integer.valueOf(pEstmtCvrgeDaysObj.RTC_Days__c!=null ?
                                     pWrprObj.totalRowCount+pEstmtCvrgeDaysObj.RTC_Days__c:pWrprObj.totalRowCount);
        }


        pWrprObj.totalTalbottDay = Integer.valueOf(pWrprObj.insrncBnft.Num_Days_Uncovered__c!=null
                                   ? pWrprObj.totalTalbottDay + pWrprObj.insrncBnft.Num_Days_Uncovered__c
                                   :pWrprObj.totalTalbottDay);
        pWrprObj.totalTalbottDay = Integer.valueOf(pWrprObj.insrncBnft.Num_Days_Room__c!=null ?
                                   pWrprObj.totalTalbottDay + pWrprObj.insrncBnft.Num_Days_Room__c
                                   :pWrprObj.totalTalbottDay);

        pWrprObj.pyAgrmntWrksht.Num_Days_Detox_DTX__c = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.DTX_Days__c!=null) ? pEstmtCvrgeDaysObj.DTX_Days__c:0);
        pWrprObj.pyAgrmntWrksht.Detox_Over__c = (pWrprObj.insrncBnft.Detox_Over__c!=null ? pWrprObj.insrncBnft.Detox_Over__c:0.00);
        pWrprObj.pyAgrmntWrksht.Detox_Pays_at__c = (pWrprObj.insrncBnft.Detox_Pays_at__c!=null ? pWrprObj.insrncBnft.Detox_Pays_at__c:0.00);

        pWrprObj.pyAgrmntWrksht.Num_Days_Residential_Treatment_RTC__c = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.RTC_Days__c!=null) ? pEstmtCvrgeDaysObj.RTC_Days__c:0);
        pWrprObj.pyAgrmntWrksht.Residential_Treatment_Override__c = (pWrprObj.insrncBnft.Residential_Treatment_Override__c!=null ? pWrprObj.insrncBnft.Residential_Treatment_Override__c:0.00);
        pWrprObj.pyAgrmntWrksht.RTC_Pays_at__c = (pWrprObj.insrncBnft.RTC_Pays_at__c!=null ? pWrprObj.insrncBnft.RTC_Pays_at__c:0.00);

        pWrprObj.pyAgrmntWrksht.Num_Days_Partial_Hospitalization_PHP__c = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.PHP_Days__c!=null)? pEstmtCvrgeDaysObj.PHP_Days__c:0);
        pWrprObj.pyAgrmntWrksht.Partial_Hospitalization_Override__c = (pWrprObj.insrncBnft.Partial_Hospitalization_Override__c!=null ? pWrprObj.insrncBnft.Partial_Hospitalization_Override__c:0.00);
        pWrprObj.pyAgrmntWrksht.PHP_Pays_at__c = (pWrprObj.insrncBnft.PHP_Pays_at__c!=null ? pWrprObj.insrncBnft.PHP_Pays_at__c:0.00);

        pWrprObj.pyAgrmntWrksht.Num_Days_Intensive_Outpatient_IOP__c = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.IOP_Days__c!=null) ? pEstmtCvrgeDaysObj.IOP_Days__c:0);
        pWrprObj.pyAgrmntWrksht.Intensive_Outpatient_Override__c = (pWrprObj.insrncBnft.Intensive_Outpatient_Override__c!=null ? pWrprObj.insrncBnft.Intensive_Outpatient_Override__c:0.00);
        pWrprObj.pyAgrmntWrksht.IOP_Pays_at__c = (pWrprObj.insrncBnft.IOP_Pays_at__c!=null ? pWrprObj.insrncBnft.IOP_Pays_at__c:0.00);

        pWrprObj.pyAgrmntWrksht.Num_Days_Uncovered__c  = (pWrprObj.insrncBnft.Uncovered_Days__c!=null)? pWrprObj.insrncBnft.Uncovered_Days__c:0;
        pWrprObj.pyAgrmntWrksht.Uncovered_Days_Rate__c  = (pWrprObj.insrncBnft.Uncovered_Days_Rate__c!=null) ? pWrprObj.insrncBnft.Uncovered_Days_Rate__c:0;
        pWrprObj.pyAgrmntWrksht.Uncovered_Days_Override__c  = (pWrprObj.insrncBnft.Uncovered_Days_Override__c!=null) ? pWrprObj.insrncBnft.Uncovered_Days_Override__c:0;
        pWrprObj.pyAgrmntWrksht.Num_Days_Room__c  = (pWrprObj.insrncBnft.Num_Days_Room__c!=null) ? pWrprObj.insrncBnft.Num_Days_Room__c:0;

        //pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c  = (pWrprObj.insrncBnft.Room_and_Board_Days_Rate__c!=null) ? pWrprObj.insrncBnft.Room_and_Board_Days_Rate__c:0;

        pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Override__c  = (pWrprObj.insrncBnft.Room_and_Board_Days_Override__c!=null) ? pWrprObj.insrncBnft.Room_and_Board_Days_Override__c:0;
        if(pWrprObj.fcltyPrgrmSelected != null && pWrprObj.fcltyPrgrmSelected != '' && pFcltyPrgmMap.containsKey(pWrprObj.fcltyPrgrmSelected)){
            if(pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Number_of_Room_and_Board_Days__c != null && pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Room_and_Board_Daily_Rate__c != null)
                pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c = pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Number_of_Room_and_Board_Days__c * pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Room_and_Board_Daily_Rate__c;
            pWrprObj.pyAgrmntWrksht.Days_60_90_Fees__c = (pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c != null ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Days_60_90_Fees__c : 0);
            pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c = (pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Ancillary_Fees__c != null ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Ancillary_Fees__c : 0);
        }
        if(pWrprObj.pyAgrmntWrksht.Uncovered_Charges__c==null /*&& pWrprObj.pyAgrmntWrksht.Id==null*/){
            pWrprObj.pyAgrmntWrksht.Uncovered_Charges__c = pWrprObj.insrncBnft.Uncovered_Charges__c;
        }
        decimal coPayRemaining = 0.00;
        coPayRemaining = pWrprObj.pyAgrmntWrksht.Num_Days_Detox_DTX__c * (pWrprObj.insrncBnft.Detox_Admit_Co_Payment__c != null ? pWrprObj.insrncBnft.Detox_Admit_Co_Payment__c : 0);
        coPayRemaining = coPayRemaining + (pWrprObj.pyAgrmntWrksht.Num_Days_Residential_Treatment_RTC__c * (pWrprObj.insrncBnft.RTC_Admit_Co_Payment__c != null ? pWrprObj.insrncBnft.RTC_Admit_Co_Payment__c : 0));
        coPayRemaining = coPayRemaining + (pWrprObj.pyAgrmntWrksht.Num_Days_Partial_Hospitalization_PHP__c * (pWrprObj.insrncBnft.PHP_Admit_Co_Payment__c != null ? pWrprObj.insrncBnft.PHP_Admit_Co_Payment__c : 0));
        coPayRemaining = coPayRemaining + (pWrprObj.pyAgrmntWrksht.Num_Days_Intensive_Outpatient_IOP__c * (pWrprObj.insrncBnft.IOP_Admit_Co_Payment__c != null ? pWrprObj.insrncBnft.IOP_Admit_Co_Payment__c : 0));
        pWrprObj.pyAgrmntWrksht.Co_Pay_Remaining__c = (coPayRemaining).setScale(2);
        return pWrprObj;
    }

    // method to update the PAWdetail records for PAW
    public PAW_New_EditCntrllr.WraperClass createAndUpdatePAWDetailsRecords(
                                                    PAW_New_EditCntrllr.WraperClass pWrprObj,
                                                    Map<Id, Facility_Program__c> pFcltyPrgmMap,
                                                    Estimated_Coverage_Days__c pEstmtCvrgeDaysObj,
                                                    Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap,
                                                    Patient_Insurance__c pPtntInsrncObj
                                                    ) {
        if(pWrprObj.fcltyPrgrmSelected != null
            && pWrprObj.fcltyPrgrmSelected != ''
            && pFcltyPrgmMap.containskey(pWrprObj.fcltyPrgrmSelected))
        {
            pWrprObj.targetEDR = pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Target_EDR__c;
        }
        try {
            pWrprObj.pawDetailListDisplayFlag = false;
            decimal totalInsEIV = 0.00;
            pWrprObj.totalInsCoResp = 0.00;
            Integer loopValue = 0;
            pWrprObj.dtxRate = null;
            pWrprObj.iopRate = null;
            pWrprObj.rtcRate = null;
            pWrprObj.phpRate = null;
            /*decimal totalCoPayAmt = (pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c == null? 0.00 : pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c); */
            pWrprObj.totalCoPayAmt = (pEstmtCvrgeDaysObj.Total_Copay__c == null? 0.00 : pEstmtCvrgeDaysObj.Total_Copay__c);
            pWrprObj.pyAgrmntWrksht.Insurance_Company_Rate_Adjustment__c = pWrprObj.rateAdjstmntSelected;
            Pay_Agreement_Worksheet_Detail__c pawDetailObj;
            pWrprObj.relatedPAWDetailsList = new list<Pay_Agreement_Worksheet_Detail__c>();
            pWrprObj = calculateBilledRate(pWrprObj, pPtntInsrncObj);
            pWrprObj.TotalAppliedDeductible = 0;
            pWrprObj.TotalCoInsurance = 0;
            // for Detox Care level
            loopValue = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.DTX_Days__c!=null) ? Integer.valueOf(pEstmtCvrgeDaysObj.DTX_Days__c) : 0);
            pWrprObj = createPAWDetailsRecords(loopValue,
                                               'Detox (DTX)',
                                               'Detox_Over__c',
                                               'dtxRate',
                                               'Detox_Pays_at__c',
                                               pWrprObj,
                                               pCmpnyRateAdjstmntMap);

            // for Residential Treatment care level
            loopValue = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.RTC_Days__c!=null) ? Integer.valueOf(pEstmtCvrgeDaysObj.RTC_Days__c) : 0);
            pWrprObj = createPAWDetailsRecords(loopValue,
                                               'Residential Treatment (RTC)',
                                               'Residential_Treatment_Override__c',
                                               'rtcRate',
                                               'RTC_Pays_at__c',
                                               pWrprObj,
                                               pCmpnyRateAdjstmntMap);

            // for Partial hospitalization care level
            loopValue = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.PHP_Days__c!=null) ? Integer.valueOf(pEstmtCvrgeDaysObj.PHP_Days__c) : 0);
            pWrprObj = createPAWDetailsRecords(loopValue,
                                               'Partial hospitalization (PHP)',
                                               'Partial_Hospitalization_Override__c',
                                               'phpRate',
                                               'PHP_Pays_at__c',
                                               pWrprObj,
                                               pCmpnyRateAdjstmntMap);

            // for Intensive Outpatient care level
            loopValue = ((pEstmtCvrgeDaysObj!=null && pEstmtCvrgeDaysObj.IOP_Days__c!=null) ? Integer.valueOf(pEstmtCvrgeDaysObj.IOP_Days__c) : 0);
            pWrprObj = createPAWDetailsRecords(loopValue,
                                               'Intensive Outpatient (IOP)',
                                               'Intensive_Outpatient_Override__c',
                                               'iopRate',
                                               'IOP_Pays_at__c',
                                               pWrprObj,
                                               pCmpnyRateAdjstmntMap);
            if(pWrprObj.relatedPAWDetailsList.size()>0){
                pWrprObj.pawDetailListDisplayFlag = true;
            }
            pWrprObj = calculatePAWDetailsValues(pWrprObj, pFcltyPrgmMap);
            pWrprObj.pyAgrmntWrksht.Plan_Coverage__c = 0;
            pWrprObj.pyAgrmntWrksht.Plan_Coverage__c = pWrprObj.totalAppliedDeductible
                                                       + pWrprObj.totalCoInsurance;
            if(pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c == null){
                pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c = 0;
            }
            if(pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c == null){
                pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c = 0;
            }
            if(pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c == null){
                pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c = 0;
            }

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
        }
        catch(Exception exObj) {
            system.debug('>>> exObj :'+exObj);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exObj.getMessage());
            ApexPages.addMessage(myMsg);
        }

        return pWrprObj;
    }

    // method to create and update PAWDetail records for number of days given
    public PAW_New_EditCntrllr.WraperClass createPAWDetailsRecords(Integer pLoopSize,
                                  String pLevelOfCareString,
                                  String pBilledRate,
                                  String pCareLevelRate,
                                  String pInsrnceCvrge,
                                  PAW_New_EditCntrllr.WraperClass pWrprObj,
                                  Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap) {
        Pay_Agreement_Worksheet_Detail__c pPawDetailObj;
        for(Integer i = 0; i < pLoopSize; i++){
            pPawDetailObj = new Pay_Agreement_Worksheet_Detail__c();
            pPawDetailObj.Level_of_Care__c = pLevelOfCareString;
            if(pWrprObj.pyAgrmntWrksht.get(pBilledRate) != 0.00) {
                pPawDetailObj.Billed_Rate__c = (Decimal)(pWrprObj.pyAgrmntWrksht.get(pBilledRate));
            }
            else {
                if(pCareLevelRate == 'dtxRate') {
                    pPawDetailObj.Billed_Rate__c = pWrprObj.dtxRate;
                }
                else if(pCareLevelRate == 'phpRate') {
                    pPawDetailObj.Billed_Rate__c = pWrprObj.phpRate;
                }
                else if(pCareLevelRate == 'iopRate') {
                    pPawDetailObj.Billed_Rate__c = pWrprObj.iopRate;
                }
                else if(pCareLevelRate == 'rtcRate') {
                    pPawDetailObj.Billed_Rate__c = pWrprObj.rtcRate;
                }
            }
            pPawDetailObj.Insurance_Coverage__c = (Decimal)(pWrprObj.pyAgrmntWrksht.get(pInsrnceCvrge) == null ? 0 :pWrprObj.pyAgrmntWrksht.get(pInsrnceCvrge));
            pPawDetailObj.Beginning_Deductible__c  = 0.00;

            if(pWrprObj.relatedPAWDetailsList.size() == 0) {
                if(pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != ''){
                    pPawDetailObj.Beginning_Deductible__c = pWrprObj.insrncBnft.Deductible_Remaining__c
                                                            + pWrprObj.totalCoPayAmt;
                }
            }
            pPawDetailObj = updatePAWDetailsRecordValues(pWrprObj, pPawDetailObj, pCmpnyRateAdjstmntMap);
            pWrprObj.TotalInsEIVAmt = pWrprObj.TotalInsEIVAmt + (pPawDetailObj.Insurance_EIV__c != null ? pPawDetailObj.Insurance_EIV__c : 0);
            if((pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != '')
                && (pWrprObj.TotalInsEIVAmt > pWrprObj.insrncBnft.Annual_Max_Remaining__c)){
                pPawDetailObj.Insurance_Co_Responsibility__c = pWrprObj.insrncBnft.Annual_Max_Remaining__c - pWrprObj.totalInsCoResp;
            } else {
                pPawDetailObj.Insurance_Co_Responsibility__c = (pPawDetailObj.Insurance_EIV__c != null ? pPawDetailObj.Insurance_EIV__c : 0);
            }
            pWrprObj.totalInsCoResp = pWrprObj.totalInsCoResp + (pPawDetailObj.Insurance_Co_Responsibility__c != null ? pPawDetailObj.Insurance_Co_Responsibility__c : 0);
            pWrprObj.TotalAppliedDeductible += (pPawDetailObj.Applied_Deductible__c != null ? pPawDetailObj.Applied_Deductible__c : 0);
            pWrprObj.TotalCoInsurance += (pPawDetailObj.Co_Insurance__c != null ? pPawDetailObj.Co_Insurance__c : 0);
            pWrprObj.relatedPAWDetailsList.add(pPawDetailObj);
        }
        return pWrprObj;
    }

    // method to calulate the values of PAWDetail records
    public Pay_Agreement_Worksheet_Detail__c updatePAWDetailsRecordValues(
                                        PAW_New_EditCntrllr.WraperClass pWrprObj,
                                        Pay_Agreement_Worksheet_Detail__c pPawDetailObj,
                                        Map<Id, Insurance_Company_Rate_Adjustment__c> pCmpnyRateAdjstmntMap) {
        if(pWrprObj.relatedPAWDetailsList.size() > 1000){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Too many rows to process');
            ApexPages.addMessage(myMsg);
            return pPawDetailObj;
        }
        pPawDetailObj.Billed_Rate__c = (pPawDetailObj.Billed_Rate__c == null ? 0: pPawDetailObj.Billed_Rate__c);
        if(pWrprObj.relatedPAWDetailsList.size()>0) {
            Pay_Agreement_Worksheet_Detail__c prevPawDetail = pWrprObj.relatedPAWDetailsList[pWrprObj.relatedPAWDetailsList.size()-1];
            pPawDetailObj.Beginning_Deductible__c = ((prevPawDetail.Beginning_Deductible__c-prevPawDetail.Applied_Deductible__c)>0
               ? prevPawDetail.Beginning_Deductible__c-prevPawDetail.Applied_Deductible__c : 0.00);
        }
        if(pPawDetailObj.Billed_Rate__c <= pPawDetailObj.Beginning_Deductible__c) {
            pPawDetailObj.Applied_Deductible__c = (pPawDetailObj.Billed_Rate__c == null ? 0: pPawDetailObj.Billed_Rate__c);
        } else{
            pPawDetailObj.Applied_Deductible__c = pPawDetailObj.Beginning_Deductible__c;
        }
        pPawDetailObj.Charge_After_Deductible__c = pPawDetailObj.Billed_Rate__c - pPawDetailObj.Applied_Deductible__c;
        if(pWrprObj.relatedPAWDetailsList.size()==0) {
            if(pWrprObj.insrncBnftSelected != null && pWrprObj.insrncBnftSelected != '') {
                pPawDetailObj.Beginning_Out_of_Pocket__c = pWrprObj.insrncBnft.Max_Out_of_Pocket_Remaining__c;
            }
        } else {
            Pay_Agreement_Worksheet_Detail__c prevPawDetail = pWrprObj.relatedPAWDetailsList[pWrprObj.relatedPAWDetailsList.size()-1];
            pPawDetailObj.Beginning_Out_of_Pocket__c = prevPawDetail.Out_of_Pocket_After_Deductible__c-prevPawDetail.Co_Insurance__c;
        }
        if(pWrprObj.insrncBnftSelected != null
            && pWrprObj.insrncBnftSelected != ''
            && pWrprObj.insrncBnft.Deductible_Included_in_OOP__c=='Yes') {
            pPawDetailObj.Out_of_Pocket_After_Deductible__c = pPawDetailObj.Beginning_Out_of_Pocket__c - pPawDetailObj.Applied_Deductible__c;
        } else {
            pPawDetailObj.Out_of_Pocket_After_Deductible__c = pPawDetailObj.Beginning_Out_of_Pocket__c;
        }
        pPawDetailObj.Calculated_Co_Insurance__c = ((1 - (pPawDetailObj.Insurance_Coverage__c!=0.00
                                                          ? (pPawDetailObj.Insurance_Coverage__c/100)
                                                          : 0.00))
                                                    * pPawDetailObj.Charge_After_Deductible__c).setScale(2);
        if((pPawDetailObj.Charge_After_Deductible__c *(1-(pPawDetailObj.Insurance_Coverage__c!=0.00
                                                          ? (pPawDetailObj.Insurance_Coverage__c/100)
                                                          : 0.00)))
                                                     <= pPawDetailObj.Out_of_Pocket_After_Deductible__c) {
            pPawDetailObj.Co_Insurance__c = (pPawDetailObj.Charge_After_Deductible__c *(1-(pPawDetailObj.Insurance_Coverage__c!=0.00 ? (pPawDetailObj.Insurance_Coverage__c/100):0.00))).setScale(2);
        } else {
            pPawDetailObj.Co_Insurance__c = pPawDetailObj.Out_of_Pocket_After_Deductible__c;
        }
        if(pWrprObj.rateAdjstmntSelected!=null && pWrprObj.rateAdjstmntSelected!='' && pCmpnyRateAdjstmntMap.containsKey(pWrprObj.rateAdjstmntSelected)) {
            decimal rateAdust = pCmpnyRateAdjstmntMap.get(pWrprObj.rateAdjstmntSelected).Rate_Adjustment__c;
            decimal outRate = ((rateAdust!=null && rateAdust!=0) ? (rateAdust/100):0.00);
            pPawDetailObj.Insurance_EIV__c = ((pPawDetailObj.Charge_After_Deductible__c - pPawDetailObj.Co_Insurance__c) * (1- outRate)).setScale(2);
        }
        pPawDetailObj.Patient_Responsibility__c = pPawDetailObj.Applied_Deductible__c + pPawDetailObj.Co_Insurance__c;

        return pPawDetailObj;
    }

    // method to calulate the values of PAWDetail records
    public PAW_New_EditCntrllr.WraperClass calculatePAWDetailsValues(
                                        PAW_New_EditCntrllr.WraperClass pWrprObj,
                                        Map<Id, Facility_Program__c> pFcltyPrgmMap) {
        Decimal TotalInsuranceCoResponsibility = 0.00;
        Integer TotalWorksheetDetail = 0;
        Decimal revenue = 0.00;
        Decimal daysRate = 0.00;
        Decimal privatePayFee = (pWrprObj.pyAgrmntWrksht.Private_Pay__c !=null)
                                ? pWrprObj.pyAgrmntWrksht.Private_Pay__c : 0.00;
        Decimal coPayAmtRequested = (pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c !=null)
                                    ? pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c : 0.00;
        Decimal prgrmLength = 1.00;
        pWrprObj.pyAgrmntWrksht.Total_Revenue__c = 0.00;
        pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = 0.00;
        pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c = 0.00;

        if(pWrprObj.fcltyPrgrmSelected != null
            && pWrprObj.fcltyPrgrmSelected != ''
            && pFcltyPrgmMap.containsKey(pWrprObj.fcltyPrgrmSelected)) {
            prgrmLength = (pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c != null
                          ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c : 1);
        }
        if(pWrprObj.insrncBnftSelected!=null && pWrprObj.insrncBnftSelected!='') {
            for(Pay_Agreement_Worksheet_Detail__c pawDetailInstance:pWrprObj.relatedPAWDetailsList) {
                TotalWorksheetDetail += 1;
                if(pawDetailInstance.Insurance_Co_Responsibility__c != null)
                TotalInsuranceCoResponsibility += pawDetailInstance.Insurance_Co_Responsibility__c;
            }
            pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c = coPayAmtRequested + privatePayFee;
            if(pWrprObj.insrncBnft.Patient_Insurance__r.Insurance_Company__r.Name != 'Private Pay') {
                //pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c = coPayAmtRequested + privatePayFee;
                if(pWrprObj.pyAgrmntWrksht.Room_and_Board_Fees__c != null)
                    pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c += pWrprObj.pyAgrmntWrksht.Room_and_Board_Fees__c;
                if(pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c != null)
                    pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c += pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c;
                if(pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c != null)
                    pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c += pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c;
                if(pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c != null)
                    pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c += pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c;
            }
            if(pWrprObj.pyAgrmntWrksht.Miscellaneous_Fees__c != null)
                pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c += pWrprObj.pyAgrmntWrksht.Miscellaneous_Fees__c;
            if(pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c != null)
                pWrprObj.pyAgrmntWrksht.Total_Revenue__c = (pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c + TotalInsuranceCoResponsibility) - pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c;
            else
                pWrprObj.pyAgrmntWrksht.Total_Revenue__c = (pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c + TotalInsuranceCoResponsibility);

            //if(TotalWorksheetDetail >0) {
                pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = pWrprObj.pyAgrmntWrksht.Total_Revenue__c/prgrmLength;
           // }
        }
        return pWrprObj;
    }

    // method to save and commit the chnages to DB
    public static PageReference commitToDB(PAW_New_EditCntrllr.WraperClass pWrprObj,
                                    String pOpportunityId,
                                    Patient_Insurance__c pPtntInsrncObj,
                                    String pIsClone,
                                    String pQuoteId) {
        List<Pay_Agreement_Worksheet_Detail__c> pawDetailList = new List<Pay_Agreement_Worksheet_Detail__c>();
        pawObj = new Pay_Agreement_Worksheet__c();

        if(pWrprObj.relatedPAWDetailsList.size() > 1000) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Too many rows to process');
            ApexPages.addMessage(myMsg);
            return null;
        }
        pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c = treatNullAsZero(pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c);
        pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c = treatNullAsZero(pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c);
        pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c = treatNullAsZero(pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c);
        // validations
        if(pWrprObj.pyAgrmntWrksht.Plan_Coverage__c <
            (pWrprObj.pyAgrmntWrksht.Co_Insurance_Amount_Requested__c
                + pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Insurance and Deductible Amount Requested exceeds Plan Coverage');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(pWrprObj.insrncBnftSelected!=null && pWrprObj.insrncBnftSelected!='') {
            if(pWrprObj.pyAgrmntWrksht.Deductible_Amount_Requested__c > pWrprObj.insrncBnft.Deductible_Remaining__c) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Deductible Amount Requested exceeds Deductible Remaining');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        if(pWrprObj.pyAgrmntWrksht.Co_Pay_Amount_Requested__c > pWrprObj.totalCoPayAmt) {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Pay Amount Requested exceeds Total Co-Pay Amount');
          ApexPages.addMessage(myMsg);
        }

        system.debug('>>> pWrprObj.pyAgrmntWrksht : '+pWrprObj.pyAgrmntWrksht);
        pawObj = pWrprObj.pyAgrmntWrksht.clone(true, true, false, false);
        system.debug('>>> pawObj : '+pawObj);
        pawObj.Insurance_Benefit__c = (pWrprObj.insrncBnftSelected != null
                                        && pWrprObj.insrncBnftSelected != ''
                                        && pWrprObj.insrncBnftSelected.length() >0)
                                      ? pWrprObj.insrncBnftSelected
                                      : null;
        pawObj.Deductible_Included_in_OOP__c = pWrprObj.insrncBnft.Deductible_Included_in_OOP__c;
        pawObj.Facility_Program__c = ((pWrprObj.fcltyPrgrmSelected != null && pWrprObj.fcltyPrgrmSelected != '') ? pWrprObj.fcltyPrgrmSelected : null);
        pawObj.FRN_Facility__c = pWrprObj.facilitySelected;
        pawObj.Deductible__c = treatNullAsZero(pWrprObj.insrncBnft.Deductible__c);
        pawObj.Deductible_Met__c = treatNullAsZero(pWrprObj.insrncBnft.Deductible_Met__c);
        pawObj.Lifetime_Max__c = treatNullAsZero(pWrprObj.insrncBnft.Lifetime_Max__c);
        pawObj.Lifetime_Max_Used__c = treatNullAsZero(pWrprObj.insrncBnft.Lifetime_Max_Met__c);
        pawObj.Annual_Max__c = treatNullAsZero(pWrprObj.insrncBnft.Annual_Max__c);
        pawObj.Annual_Max_Used__c = treatNullAsZero(pWrprObj.insrncBnft.Annual_Max_Met__c);
        pawObj.Co_Pay_Met__c = treatNullAsZero(pWrprObj.insrncBnft.Co_Pay_Met__c);
        pawObj.Out_of_Pocket_Max__c = treatNullAsZero(pWrprObj.insrncBnft.Max_Out_of_Pocket__c);
        pawObj.Out_of_Pocket_Max_Met__c = treatNullAsZero(pWrprObj.insrncBnft.Max_Out_of_Pocket_Met__c);
        pawObj.Co_Pay__c = pWrprObj.totalCoPayAmt;

        if(pOpportunityId != null && pOpportunityId != '') {
            pawObj.Opportunity__c = pOpportunityId;
        }
        if(pPtntInsrncObj!=null) {
            pawObj.Patient_Insurance__c = pPtntInsrncObj.Id;
        }
        if(pIsClone == 'Clone') {
            pawObj.Id=null;
        }
        try {
            Opportunity parentOpportunity = new Opportunity();
            if(pawObj.Opportunity__c != null && pawObj.Id == null) {
                parentOpportunity = [SELECT Id,
                                            StageName
                                       FROM Opportunity
                                      WHERE Id =: pawObj.Opportunity__c];
                Set<Id> vobProfileId = new Set<Id>();
                for(Profile prfl:[SELECT Id FROM Profile WHERE Name Like 'FRN - Verification of Benefits (VOB)%']) {
                    vobProfileId.add(prfl.Id);
                }
                if(parentOpportunity.StageName == 'Determination Complete' && vobProfileId.contains(Userinfo.getProfileId())) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                            'Can not create new record as the Opportunity stage is set to Determination Complete.'));
                    return null;
                }
            }

            if(pQuoteId != null && pIsClone == 'Clone') {
                Quote quoteObj = new Quote();
                Opportunity quoteOpportunity = new Opportunity();
                Pay_Agreement_Worksheet__c pawInst = new Pay_Agreement_Worksheet__c();
                quoteObj = [SELECT Id,
                                   Status__c,
                                   OpportunityId,
                                   Pay_Agreement_Worksheet__c
                              FROM Quote
                             WHERE Id =: pQuoteId];
                if(quoteObj.OpportunityId != pawObj.Opportunity__c){
                    quoteOpportunity = [SELECT Id,
                                               StageName
                                          FROM Opportunity
                                         WHERE Id =: quoteObj.OpportunityId];
                }
                quoteOpportunity = parentOpportunity;
                quoteOpportunity.StageName = 'Counter Offer Requested';
                update quoteOpportunity;

                pawInst = [SELECT Id,
                                  Status__c,
                                  Opportunity__c
                             FROM Pay_Agreement_Worksheet__c
                            WHERE Id =:quoteObj.Pay_Agreement_Worksheet__c];
               pawInst.Status__c = 'Cancelled';
               update pawInst;

               quoteObj.Status__c = 'Cancelled';
               update quoteObj;
            }
            if(pawObj.Id == null) {
                pawObj.Status__c = 'Open';
            }
            upsert pawObj;

            for(Pay_Agreement_Worksheet_Detail__c pawd:pWrprObj.relatedPAWDetailsList){
                Pay_Agreement_Worksheet_Detail__c pawDEtailInstnace = pawd.Clone(false, true, false, false);
                pawDEtailInstnace.Pay_Agreement_Worksheet__c = pawObj.id;
                pawDetailList.add(pawDEtailInstnace);
            }

            //To delete old Pay_Agreement_Worksheet_Detail__c records
            if(pawObj.Id!=null){
                delete [Select Id from Pay_Agreement_Worksheet_Detail__c WHERE Pay_Agreement_Worksheet__c =:pawObj.Id];
            }
            if(pawDetailList.size()>0 ){
                insert pawDetailList;
            }
        }
        catch (Exception exObj) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exObj.getMessage());
            ApexPages.addMessage(myMsg);
        }
        PageReference orderPage;
        orderPage = new PageReference('/'+pawObj.id);
        orderPage.setRedirect(true);
        return orderPage;
    }

    // method to get billed rate
    public static PAW_New_EditCntrllr.WraperClass calculateBilledRate(
                                                    PAW_New_EditCntrllr.WraperClass pWrprObj,
                                                    Patient_Insurance__c pPtntInsrncObj) {
        if(pWrprObj.fcltyPrgrmSelected != null && pWrprObj.fcltyPrgrmSelected != '') {
            Id fpLOCRTIdDTX = Schema.SObjectType.Facility_Program_Level_of_Care__c
                              .getRecordTypeInfosByName().get('Detox (DTX)').getRecordTypeId();
            Id fpLOCRTIdRTC = Schema.SObjectType.Facility_Program_Level_of_Care__c
                              .getRecordTypeInfosByName().get('Residential Treatment (RTC)').getRecordTypeId();
            Id fpLOCRTIdPHP = Schema.SObjectType.Facility_Program_Level_of_Care__c
                              .getRecordTypeInfosByName().get('Partial Hospitalization (PHP)').getRecordTypeId();
            Id fpLOCRTIdIOP = Schema.SObjectType.Facility_Program_Level_of_Care__c
                              .getRecordTypeInfosByName().get('Intensive Outpatient (IOP)').getRecordTypeId();
            List<Facility_Program_Level_of_Care__c> fcltyPrgrmLvlOfCareList =
                                    [Select Id,
                                            Billing_Rate__c,
                                            Facility_Program__c,
                                            isDefault__c,
                                            Insurance_Company__c,
                                            RecordTypeId
                                       from Facility_Program_Level_of_Care__c
                                      WHERE Facility_Program__c =:pWrprObj.fcltyPrgrmSelected
                                       AND (Insurance_Company__c =:pPtntInsrncObj.Insurance_Company__c
                                         OR isDefault__c = true)
                                   ORDER BY Insurance_Company__c ASC nulls Last,
                                            LastModifiedDate DESC];

            Facility_Program_Level_of_Care__c defaultDTXFPLOC;
            Facility_Program_Level_of_Care__c defaultRTCFPLOC;
            Facility_Program_Level_of_Care__c defaultPHPFPLOC;
            Facility_Program_Level_of_Care__c defaultIOPFPLOC;
            for(Facility_Program_Level_of_Care__c fcltyPrgrmCareLevelInstance : fcltyPrgrmLvlOfCareList) {

                if(fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdDTX
                    && pWrprObj.dtxRate==null
                    && fcltyPrgrmCareLevelInstance.Insurance_Company__c == pPtntInsrncObj.Insurance_Company__c){
                    pWrprObj.dtxRate = fcltyPrgrmCareLevelInstance.Billing_Rate__c;
                }
                else if(fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdRTC
                    && pWrprObj.rtcRate==null
                    && fcltyPrgrmCareLevelInstance.Insurance_Company__c == pPtntInsrncObj.Insurance_Company__c){
                    pWrprObj.rtcRate = fcltyPrgrmCareLevelInstance.Billing_Rate__c;
                }
                else if(fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdPHP
                    && pWrprObj.phpRate==null
                    && fcltyPrgrmCareLevelInstance.Insurance_Company__c == pPtntInsrncObj.Insurance_Company__c){
                    pWrprObj.phpRate = fcltyPrgrmCareLevelInstance.Billing_Rate__c;
                }
                else if(fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdIOP
                    && pWrprObj.iopRate==null
                    && fcltyPrgrmCareLevelInstance.Insurance_Company__c == pPtntInsrncObj.Insurance_Company__c){
                    pWrprObj.iopRate = fcltyPrgrmCareLevelInstance.Billing_Rate__c;
                }
                else if(defaultDTXFPLOC==null && fcltyPrgrmCareLevelInstance.isDefault__c==true
                        && fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdDTX){
                    defaultDTXFPLOC = fcltyPrgrmCareLevelInstance;
                }
                else if(defaultRTCFPLOC==null && fcltyPrgrmCareLevelInstance.isDefault__c==true
                        && fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdRTC){
                    defaultRTCFPLOC = fcltyPrgrmCareLevelInstance;
                }
                else if(defaultPHPFPLOC==null && fcltyPrgrmCareLevelInstance.isDefault__c==true
                        && fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdPHP){
                    defaultPHPFPLOC = fcltyPrgrmCareLevelInstance;
                }
                else if(defaultIOPFPLOC==null && fcltyPrgrmCareLevelInstance.isDefault__c==true
                        && fcltyPrgrmCareLevelInstance.RecordTypeId==fpLOCRTIdIOP){
                    defaultIOPFPLOC = fcltyPrgrmCareLevelInstance;
                }

                if(pWrprObj.dtxRate==null && defaultDTXFPLOC!=null) {
                    pWrprObj.dtxRate = defaultDTXFPLOC.Billing_Rate__c;
                }
                if(pWrprObj.rtcRate==null && defaultRTCFPLOC!=null) {
                    pWrprObj.rtcRate = defaultRTCFPLOC.Billing_Rate__c;
                }
                if(pWrprObj.phpRate==null && defaultPHPFPLOC!=null) {
                    pWrprObj.phpRate = defaultPHPFPLOC.Billing_Rate__c;
                }
                if(pWrprObj.iopRate==null && defaultIOPFPLOC!=null) {
                    pWrprObj.iopRate = defaultIOPFPLOC.Billing_Rate__c;
                }
            }
        }
        return pWrprObj;
    }

    public static Integer treatNullAsZero(Integer pIntgerToTreat) {
        if(pIntgerToTreat != null) {
            return pIntgerToTreat;
        }
        else {
            return 0;
        }
    }

    public static Decimal treatNullAsZero(Decimal pIntgerToTreat) {
        if(pIntgerToTreat != null) {
            return pIntgerToTreat;
        }
        else {
            return 0.00;
        }
    }

    public static PAW_New_EditCntrllr.WraperClass calculateBilledRate(
                                                    PAW_New_EditCntrllr.WraperClass pWrprObj) {

      return pWrprObj;
    }
}