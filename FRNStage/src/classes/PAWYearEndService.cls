public with sharing class PAWYearEndService extends PAWValueCalculationService {
	public PAWYearEndService() {

	}

    // method to calculate the the value update for PAW
    public PAW_New_EditCntrllr.WraperClass calculateWraperValuesYearEnd(
                                                    PAW_New_EditCntrllr.WraperClass pWrprObj,
                                                    Boolean isPrimary) {
        if( !isPrimary ) {
            pWrprObj.pyAgrmntWrksht.Days_60_90_Fees__c = 0;
            pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c = 0;
            pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c = 0;
        }

        return pWrprObj;
    }

    public PAW_New_EditCntrllr.WraperClass createAndUpdatePAWDetailsRecordsYearEnd(PAW_New_EditCntrllr.WraperClass pWrprObj,
                                                    Map<Id, Facility_Program__c> pFcltyPrgmMap,
                                                    Boolean isPrimary) {
	    //if no facility program is selected cannot proceed.
        if( pWrprObj.fcltyPrgrmSelected==null || String.isBlank(pWrprObj.fcltyPrgrmSelected) ){
			return pWrprObj;
		}

        if( !isPrimary ) {
            Decimal daysFee = 0.00;
            Decimal ancillaryFee = 0.00;
            Decimal roomBoardDaysRate = 0.00;
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

			if( pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c != null ){
	            pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c = pWrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c
	                                                                  - (daysFee
	                                                                  + ancillaryFee
	                                                                  + roomBoardDaysRate);
			}
            pWrprObj.pyAgrmntWrksht.Total_Revenue__c = pWrprObj.pyAgrmntWrksht.Total_Revenue__c - daysFee;
                                                     
            //pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = pWrprObj.pyAgrmntWrksht.Daily_Revenue__c - daysFee;
                                                     
            decimal totaldays = pWrprObj.totalRowCount + (pWrprObj.insrncBnft.Uncovered_Days__c == null ? 0 : pWrprObj.insrncBnft.Uncovered_Days__c);

            if(totaldays>0){
                pWrprObj.pyAgrmntWrksht.Daily_Revenue__c = (pWrprObj.pyAgrmntWrksht.Total_Revenue__c
                                                            /((pWrprObj.fcltyPrgrmSelected != null
                                                                && pWrprObj.fcltyPrgrmSelected != ''
                                                                && pFcltyPrgmMap.containsKey(pWrprObj.fcltyPrgrmSelected)
                                                                && pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c != null
                                                              ) ? pFcltyPrgmMap.get(pWrprObj.fcltyPrgrmSelected).Program_Length__c
                                                              : 1));
            }
            pWrprObj.pyAgrmntWrksht.Days_60_90_Fees__c = 0;
            pWrprObj.pyAgrmntWrksht.Ancillary_Fees__c = 0;
            pWrprObj.pyAgrmntWrksht.Room_and_Board_Days_Rate__c = 0;
        }
        return pWrprObj;
    }

}