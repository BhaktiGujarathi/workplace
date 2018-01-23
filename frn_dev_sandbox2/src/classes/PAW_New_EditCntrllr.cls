virtual public class PAW_New_EditCntrllr {

    public static Boolean yearEndMode = PAW_YearEnd_Config.fetch().Year_End_Mode_Enabled__c;

    // variable declaration

    public String recordId {set;get;}  // id of Opportunity or PAW
    public String isClone; // if clone button on PAW is clicked
    public String quoteId; // if counter offer on quote is clicked
    public String sObjectQueryStr; // string to hold the dynamic query string for sobject
    public string oppId=''; // holds id of parent Opportunity
    public List<SelectOption> ptntInsrnceOptions; // list of select options for patient insurances
    public List<SelectOption> insrncBnftOptions; // list of select options for insuarnce benefits
    public List<SelectOption> faciltyOptions{get; set;} // list of select options for facility centers
    public List<SelectOption> fcltyPrgrmOptions{get; set;}
    public List<SelectOption> rtAdjstmntOptions;

    public Patient_Insurance__c ptntInsrncObj{get;  set;} // instance of related Patient insurance record
    public Pay_Agreement_Worksheet__c pawObj;
    public Quote quoteObj; // instance of related Quote record
    public Map<Id, Patient_Insurance__c> ptntInsrncMap; // map of all patient insurance records related to the Opportunity
    public Map<Id, Insurance_Benefit__c> insrncBnftMap; // map of all insurance benefit records related to the Opportunity
    public Map<Id, String> idToOwnershipFacilityMap; // map of all facility centers with their ownership in value
    public Map<Id, Facility_Program__c> fcltyPrgmMap; // map of all facility programrelated to that particular facility
    public Map<Id, Estimated_Coverage_Days__c> estmtCnrgDaysMap; // map of estimate coverage days for selected benefit
    public Map<Id, Insurance_Company_Rate_Adjustment__c> cmpnyRateAdjstmntMap;
    public Estimated_Coverage_Days__c estmtCvrgeDaysObj; // instance of ecstimate coverage days object
    public Map<Id, String> idToTypeFacilityMap; // map of all facility centers with their facility type in value

    public WraperClass wrprObj{get; set;} // instance of wrapper for page refernce
    public Boolean showPILookup{get; set;} //
    public Boolean isTalbott{get; set;} //boolean to denot if the facility is talbott
    public Boolean isIop{get; set;}

    public static Map <String, Schema.SObjectType> globalSchemaMap;

    public PAW_Editor_YearEndController.MetaData meta          {set; get;}
    public Boolean isPrimary                                   {set; get;}


    public PAW_New_EditCntrllr(){


        globalSchemaMap = Schema.getGlobalDescribe();
        isTalbott = false;
        isIop = false;
        sObjectQueryStr = '';
        quoteObj = new Quote();
        wrprObj = new WraperClass();
        ptntInsrncObj = new Patient_Insurance__c();
        ptntInsrnceOptions = new List<SelectOption>();
        insrncBnftOptions = new List<SelectOption>();
        faciltyOptions = new List<SelectOption>();
        fcltyPrgrmOptions = new List<SelectOption>();
        rtAdjstmntOptions = new List<SelectOption>();
        idToOwnershipFacilityMap = new Map<Id,String>();
        idToTypeFacilityMap = new Map<Id,String>();
        insrncBnftMap = new Map<Id,Insurance_Benefit__c>();
        estmtCvrgeDaysObj = new Estimated_Coverage_Days__c();
        pawObj = new Pay_Agreement_Worksheet__c();
        recordId = Apexpages.currentpage().getparameters().get('id'); //Opportunity Id or PAW id
        isClone = Apexpages.currentpage().getparameters().get('Clone'); // counter offer from quote
        quoteId = Apexpages.currentpage().getparameters().get('quoteId'); // counter offer from quote
        meta = new PAW_Editor_YearEndController.MetaData();
        //initialize();
    }


    public PageReference initialize(){
         // if rediected from counter offer from quote record
         system.debug('>>> 1');
        if(quoteId != null && quoteId != '') {
            sObjectQueryStr = preparesObjectQueryString('QUOTE', quoteId);
            quoteObj = Database.query(sObjectQueryStr);
            recordId = getCurrentPAWId(quoteObj);
        }

        // if redirected form new button with Opp id
        if(recordId != null && recordId != '') {

            if(recordId.startsWith(globalSchemaMap.get('Opportunity').getDescribe().getKeyPrefix())) {
                showPILookup = false;
                oppId = recordId;
                getPtntInsrnceOptions();
            }
            if(recordId.startsWith(globalSchemaMap.get('Pay_Agreement_Worksheet__c').getDescribe().getKeyPrefix())) {
                getPtntInsrnceOptions();
                sObjectQueryStr = preparesObjectQueryString('Pay_Agreement_Worksheet__c', recordId);
                pawObj = Database.query(sObjectQueryStr);
                wrprObj.pyAgrmntWrksht = pawObj;
                wrprObj.pyAgrmntWrksht.Days_60_90_Fees__c = (pawObj.Days_60_90_Fees__c == null ? 0.00 : pawObj.Days_60_90_Fees__c);
                wrprObj.pyAgrmntWrksht.Plan_Coverage__c = 0.00;
                if(quoteId != null && quoteId != ''){
                    wrprObj.pyAgrmntWrksht.Counter_Offer__c = true;
                    wrprObj.pyAgrmntWrksht.Cloned_From_Pay_Agreement_Worksheet__c = pawObj.Id;
                }
                wrprObj.totalInsCoResp = (pawObj.Total_Insurance_Co_Responsibility__c!=null
                                          ? pawObj.Total_Insurance_Co_Responsibility__c
                                          : wrprObj.totalInsCoResp);
                wrprObj.pyAgrmntWrksht.Plan_Coverage__c = (pawObj.Total_Applied_Deductible__c!=null
                                                           ? pawObj.Total_Applied_Deductible__c
                                                           : wrprObj.pyAgrmntWrksht.Plan_Coverage__c);
                wrprObj.pyAgrmntWrksht.Plan_Coverage__c = (pawObj.Total_Co_Insurance__c!=null
                                                           ? (wrprObj.pyAgrmntWrksht.Plan_Coverage__c + pawObj.Total_Co_Insurance__c)
                                                           : wrprObj.pyAgrmntWrksht.Plan_Coverage__c);

                if(pawObj.FRN_Facility__r.Ownership == 'Talbott'){
                    isTalbott = true;
                    isIop = false;
                }
                if(pawObj.FRN_Facility__r.FRN_Facility_Type__c == 'Intensive Outpatient') {
                    isIop = true;
                    isTalbott = false;
                }
                sObjectQueryStr = preparesObjectQueryString('Patient_Insurance__c', pawObj.Patient_Insurance__c);
                ptntInsrncObj = Database.query(sObjectQueryStr);
                
                if(oppId == null || oppId == ''){
                    ptntInsrncObj.Opportunity__c = pawObj.Patient_Insurance__r.Opportunity__c;
                    oppId = pawObj.Patient_Insurance__r.Opportunity__c;
                }
                getInsrncBnftOptions();
                wrprObj.insrncBnftSelected = pawObj.Insurance_Benefit__c;
                onBenefitSelection();
                wrprObj.facilitySelected = pawObj.FRN_Facility__c;
                onFacilitySelection();
                wrprObj.fcltyPrgrmSelected = pawObj.Facility_Program__c;
                wrprObj.insrncBnftSelected = pawObj.Insurance_Benefit__c;
                getRtAdjstmntOptions();
                wrprObj.rateAdjstmntSelected = pawObj.Insurance_Company_Rate_Adjustment__c;
                updateWraperValues();
                wrprObj.relatedPAWDetailsList = [Select Id,
                                                        Day__c,
                                                        Level_of_Care__c,
                                                        Billed_Rate__c,
                                                        Insurance_Coverage__c,
                                                        Beginning_Deductible__c,
                                                        Applied_Deductible__c,
                                                        Charge_After_Deductible__c,
                                                        Beginning_Out_of_Pocket__c,
                                                        Out_of_Pocket_After_Deductible__c,
                                                        Calculated_Co_Insurance__c,
                                                        Co_Insurance__c,
                                                        Insurance_EIV__c,
                                                        Patient_Responsibility__c,
                                                        Pay_Agreement_Worksheet__c,
                                                        Insurance_Co_Responsibility__c
                                                   FROM Pay_Agreement_Worksheet_Detail__c
                                                  WHERE Pay_Agreement_Worksheet__c =: recordId];
                If(wrprObj.relatedPAWDetailsList.size()>0){
                    wrprObj.pawDetailListDisplayFlag = true;
                    wrprObj.totalRowCount = wrprObj.relatedPAWDetailsList.size();
                }
            }
        }
        return getRedirect();
    }

    public PageReference getRedirect(){
        system.debug('>>> 2');
        PageReference redirectPR = redirectIfLocked();
        if ( null != redirectPR ){
            return redirectPR;
        }

        if( yearEndMode == true ){
            PageReference pageReference = Page.PAW_Editor_YearEnd;
            pageReference.getParameters().putAll(Apexpages.currentpage().getparameters());
            pageReference.setRedirect(true);
            return pageReference;
        }

        return null;
    }

    // method to redirect to error page if record is locked
    public PageReference redirectIfLocked() {
        if( recordId == null ) {
            return null;
        }

        return RecordLockUtility.redirectIfLocked(recordId);
    }

    // method to get the list of Patient insurances related to that particular OpportunityId
    public List<SelectOption> getPtntInsrnceOptions(){



        ptntInsrnceOptions = new List<SelectOption>();
        ptntInsrnceOptions.add(new SelectOption( '','---Select---'));
        ptntInsrncMap = new Map<Id, Patient_Insurance__c> ([SELECT Id,
                                                                   Name,
                                                                   Insurance_Company__c
                                                              FROM Patient_Insurance__c
                                                             WHERE Opportunity__c = : oppId]);
        for(Patient_Insurance__c ptntInsrnceInstance : ptntInsrncMap.Values()){
            ptntInsrnceOptions.add(new SelectOption(ptntInsrnceInstance.id , ptntInsrnceInstance.Name));
        }
        
        return ptntInsrnceOptions;
    }

    // method to get the details of the selected Patient insurance Object
    public void onPatientSelection(){
        if(wrprObj.pyAgrmntWrksht.Patient_Insurance__c != null){
            ptntInsrncObj = ptntInsrncMap.get(wrprObj.pyAgrmntWrksht.Patient_Insurance__c);
        } else {
            ptntInsrncObj = null;
        }
        wrprObj.insrncBnftSelected = '';
        updateWraperValues();
    }

    public List<SelectOption> getInsrncBnftOptions(){
        insrncBnftOptions.clear();
        insrncBnftOptions.add(new SelectOption('' ,'---Select---'));
        if(ptntInsrncObj != null){
            insrncBnftMap = new Map<Id,Insurance_Benefit__c>([Select Id,
                                                                     Name,
                                                                     RecordType.Name,
                                                                     Uncovered_Charges__c,
                                                                     Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,
                                                                     Patient_Insurance__r.Opportunity__c,
                                                                     Patient_Insurance__r.Accreditation__c,
                                                                     Patient_Insurance__r.Insurance_Company__r.Name,
                                                                     PHP_Admit_Co_Payment__c,
                                                                     Detox_Admit_Co_Payment__c,
                                                                     RTC_Admit_Co_Payment__c,
                                                                     Deductible__c,
                                                                     Deductible_Met__c,
                                                                     IOP_Admit_Co_Payment__c,
                                                                     Max_Out_of_Pocket_Remaining__c,
                                                                     Insurance_Company_is_Out_of_Network__c,
                                                                     Annual_Max_Remaining__c,
                                                                     Deductible_Remaining__c,
                                                                     Detox_Pays_at__c,
                                                                     Detox_Over__c,
                                                                     RTC_Pays_at__c,
                                                                     Residential_Treatment_Override__c,
                                                                     PHP_Pays_at__c,
                                                                     Partial_Hospitalization_Override__c,
                                                                     IOP_Pays_at__c,
                                                                     Intensive_Outpatient_Override__c,
                                                                     Num_Days_Uncovered__c,
                                                                     Num_Days_Room__c,
                                                                     Uncovered_Days_Rate__c,
                                                                     Room_and_Board_Days_Rate__c,
                                                                     Uncovered_Days_Override__c,
                                                                     Room_and_Board_Days_Override__c,
                                                                     Deductible_Included_in_OOP__c,
                                                                     Uncovered_Days__c,
                                                                     Lifetime_Max__c,
                                                                     Lifetime_Max_Met__c,
                                                                     Annual_Max__c,
                                                                     Annual_Max_Met__c,
                                                                     Max_Out_of_Pocket__c,
                                                                     Max_Out_of_Pocket_Met__c,
                                                                     Co_Pay_Met__c
                                                                FROM Insurance_Benefit__c
                                                               WHERE Patient_Insurance__c = : ptntInsrncObj.Id]);

            for(Insurance_Benefit__c insrncBnftInstance : insrncBnftMap.values()){
                insrncBnftOptions.add(new SelectOption(insrncBnftInstance.id , insrncBnftInstance.RecordType.Name+' - '+insrncBnftInstance.name));
            }
        }
        if(wrprObj.insrncBnftSelected != null && wrprObj.insrncBnftSelected != ''){
            wrprObj.insrncBnft = insrncBnftMap.get(wrprObj.insrncBnftSelected);
        } else {
            wrprObj.insrncBnft = null;
        }
        return insrncBnftOptions;
    }

    // method
    public void onBenefitSelection() {
        faciltyOptions = new List<SelectOption>();
        fcltyPrgrmOptions = new List<SelectOption>();
        rtAdjstmntOptions = new List<SelectOption>();
        wrprObj.facilitySelected = '';
        faciltyOptions.add(new SelectOption('' , '--None--'));
        if(wrprObj.insrncBnftSelected != null && wrprObj.insrncBnftSelected != ''){
            wrprObj.insrncBnft = insrncBnftMap.get(wrprObj.insrncBnftSelected);
            wrprObj.pyAgrmntWrksht.Deductible_Included_in_OOP__c = wrprObj.insrncBnft.Deductible_Included_in_OOP__c;
            estmtCnrgDaysMap = new Map<Id, Estimated_Coverage_Days__c>([Select Id,
                                                                                DTX_Days__c,
                                                                                FRN_Facility__c,
                                                                                FRN_Facility__r.Name,
                                                                                FRN_Facility__r.Ownership,
                                                                                FRN_Facility__r.FRN_Facility_Type__c,
                                                                                Insurance_Benefit__c,
                                                                                IOP_Days__c,
                                                                                PHP_Days__c,
                                                                                RTC_Days__c,
                                                                                Total_Copay__c
                                                                           FROM Estimated_Coverage_Days__c
                                                                          WHERE Insurance_Benefit__c=:wrprObj.insrncBnftSelected
                                                                       ORDER BY LastModifiedDate ASC]);
            for(Estimated_Coverage_Days__c estmtInstance :estmtCnrgDaysMap.values()){
                idToOwnershipFacilityMap.put(estmtInstance.FRN_Facility__c,estmtInstance.FRN_Facility__r.Ownership);
                idToTypeFacilityMap.put(estmtInstance.FRN_Facility__c,estmtInstance.FRN_Facility__r.FRN_Facility_Type__c);
                faciltyOptions.add(new SelectOption(estmtInstance.FRN_Facility__c , estmtInstance.FRN_Facility__r.Name));
            }
        } else {
            wrprObj.pyAgrmntWrksht.Deductible_Included_in_OOP__c = null;
            wrprObj.insrncBnft = null;
            estmtCvrgeDaysObj = null;
            wrprObj.totalCoPayAmt = 0.00;
        }
    }

    // method to generate facility program select options on facility selection
    public void onFacilitySelection() {
        fcltyPrgrmOptions = new List<SelectOption>();
        fcltyPrgrmOptions.add(new SelectOption( '' ,'---Select---'));
        wrprObj.fcltyPrgrmSelected = '';
        if(wrprObj.facilitySelected != null && wrprObj.facilitySelected != ''){
            if(idToTypeFacilityMap.get(wrprObj.facilitySelected) == 'Intensive Outpatient') {
                isIop = true;
                isTalbott = false;
            }
            else if(idToOwnershipFacilityMap.get(wrprObj.facilitySelected) == 'Talbott') {
                isTalbott = true;
                isIop = false;
            }
            else {
                isIop = false;
                isTalbott = false;
            }
            fcltyPrgmMap = new Map<Id,Facility_Program__c>([SELECT Id,
                                                                   Name,
                                                                   Pay_Agreement_Worksheet_Default__c,
                                                                   Total_Room_and_Board__c,
                                                                   Ancillary_Fees__c,
                                                                   Days_60_90_Fees__c,
                                                                   Program_Length__c,
                                                                   Target_EDR__c,
                                                                   Number_of_Room_and_Board_Days__c,
                                                                   Room_and_Board_Daily_Rate__c,
                                                                   Uncovered_Day_Rate__c
                                                              FROM Facility_Program__c
                                                             WHERE FRN_Facility__c = : wrprObj.facilitySelected
                                                             ORDER BY Name ASC]);
            for(Facility_Program__c fcltyPrgrmInstance : fcltyPrgmMap.values()){
                fcltyPrgrmOptions.add(new SelectOption(fcltyPrgrmInstance.id, fcltyPrgrmInstance.Name));
                if((wrprObj.fcltyPrgrmSelected == null || wrprObj.fcltyPrgrmSelected =='') && fcltyPrgrmInstance.Pay_Agreement_Worksheet_Default__c == true) {
                    wrprObj.fcltyPrgrmSelected = fcltyPrgrmInstance.Id;
                }
            }
            if(wrprObj.insrncBnftSelected != null && wrprObj.insrncBnftSelected != ''){
                List<Estimated_Coverage_Days__c> estmtCovrgeList = [SELECT Id,
                                                                           DTX_Days__c,
                                                                           FRN_Facility__c,
                                                                           Insurance_Benefit__c,
                                                                           IOP_Days__c,
                                                                           PHP_Days__c,
                                                                           RTC_Days__c,
                                                                           Total_Copay__c
                                                                      FROM Estimated_Coverage_Days__c
                                                                     WHERE Insurance_Benefit__c=:wrprObj.insrncBnftSelected
                                                                       AND FRN_Facility__c=:wrprObj.facilitySelected
                                                                     limit 1];
                if(estmtCovrgeList!=null && estmtCovrgeList.size()>0){
                    estmtCvrgeDaysObj = estmtCovrgeList[0];
                    wrprObj.totalCoPayAmt = (estmtCvrgeDaysObj.Total_Copay__c!=null ? estmtCvrgeDaysObj.Total_Copay__c:0.00);
                }
            } else {
                estmtCvrgeDaysObj = null;
                wrprObj.totalCoPayAmt = 0.00;
            }
        } else {
            estmtCvrgeDaysObj = null;
            wrprObj.totalCoPayAmt = 0.00;
        }
        updateWraperValues();
    }

    // method to fetch rate adjustments from DB
    public List<SelectOption> getRtAdjstmntOptions(){
        rtAdjstmntOptions = new List<SelectOption>();
        rtAdjstmntOptions.add(new SelectOption('','--None--'));
        if(wrprObj.facilitySelected != null && wrprObj.facilitySelected != '' && ptntInsrncObj != null){
            cmpnyRateAdjstmntMap = new Map<Id, Insurance_Company_Rate_Adjustment__c>([Select Id,
                                                                                             Name,
                                                                                             Type__c,
                                                                                             Rate_Adjustment__c,
                                                                                             In_Network_Rate_Adjustment__c,
                                                                                             Out_of_Network_Rate_Adjustment__c,
                                                                                             Active_Date__c,
                                                                                             Term_Date__c
                                                                                        FROM Insurance_Company_Rate_Adjustment__c
                                                                                       WHERE Insurance_Company__c =:ptntInsrncObj.Insurance_Company__c
                                                                                         AND FRN_Facility__c=:wrprObj.facilitySelected
                                                                                    ORDER BY Type__c DESC]);
            for(Insurance_Company_Rate_Adjustment__c rateAdjstmntInstance: cmpnyRateAdjstmntMap.values()){
                if(rateAdjstmntInstance.Type__c != null && checkIfActive(rateAdjstmntInstance))
                    rtAdjstmntOptions.add(new SelectOption(rateAdjstmntInstance.Id, rateAdjstmntInstance.Type__c));
            }
        }
        return rtAdjstmntOptions;
    }

    // method to update the wraper values on selection of patient insurance
    public void updateWraperValues(){
        //if(wrprObj.facilitySelected != null && wrprObj.facilitySelected != '') {
            if(isIop) { // frn & talbott IOP
                wrprObj = new PAWIopService().calculateWraperValuesIOP(wrprObj,
                                                          fcltyPrgmMap,
                                                          cmpnyRateAdjstmntMap,
                                                          insrncBnftMap,
                                                          estmtCvrgeDaysObj);
            }
            else if(isTalbott) { //talbott residential
                wrprObj = new PAWTalbottFacilityService().calculateWraperValuesTalbott(wrprObj,
                                                          fcltyPrgmMap,
                                                          cmpnyRateAdjstmntMap,
                                                          insrncBnftMap,
                                                          estmtCvrgeDaysObj);
            }
            else { // frn residential
                wrprObj = new PAWFrnFacilityService().calculateWraperValuesFRN(wrprObj,
                                                          fcltyPrgmMap,
                                                          cmpnyRateAdjstmntMap,
                                                          insrncBnftMap,
                                                          estmtCvrgeDaysObj);
            }
            if(isPrimary != null) {         
                wrprObj = new PAWYearEndService().calculateWraperValuesYearEnd(wrprObj,
                                                                               isPrimary);
            }
        //}
    }

    // method to create and update the PAWdetail Records for the PAW
    public void createAndUpdatePAWDetailsRecords() {
        if(isIop) { // frn & talbott IOP
            wrprObj = new PAWIopService().createAndUpdatePAWDetailsRecordsIop(
                                                                            wrprObj,
                                                                            fcltyPrgmMap,
                                                                            estmtCvrgeDaysObj,
                                                                            cmpnyRateAdjstmntMap,
                                                                            ptntInsrncObj);
        }
        else if(isTalbott) { //talbott residential
            wrprObj = new PAWTalbottFacilityService().createAndUpdatePAWDetailsRecordsTalbott(
                                                                            wrprObj,
                                                                            fcltyPrgmMap,
                                                                            estmtCvrgeDaysObj,
                                                                            cmpnyRateAdjstmntMap,
                                                                            ptntInsrncObj);
            if(isPrimary != null) {         
                wrprObj = new PAWYearEndService().createAndUpdatePAWDetailsRecordsYearEnd(wrprObj,
                                                                               fcltyPrgmMap,
                                                                               isPrimary);
            }
        }
        else { // frn residential
            wrprObj = new PAWFrnFacilityService().createAndUpdatePAWDetailsRecordsFRN(
                                                                            wrprObj,
                                                                            fcltyPrgmMap,
                                                                            estmtCvrgeDaysObj,
                                                                            cmpnyRateAdjstmntMap,
                                                                            ptntInsrncObj);
        }
    }

    // method to save and commit the chnages to DB
    public PageReference saveTheUpdates() {
        //createAndUpdatePAWDetailsRecords();
        system.debug('>>> wrprObj  Total_Patient_Contribution__c : '+wrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c);
        createAndUpdatePAWDetailsRecords();
        return PAWValueCalculationService.commitToDB(wrprObj,
                                           oppId,
                                           ptntInsrncObj,
                                           isClone,
                                           quoteId);

    }

    // method to cancel and return back
    public PageReference cancel(){
        string redirtc='';
        if(quoteId != null && quoteId != ''){
            redirtc= quoteId;
        }else {
            redirtc = recordId;
        }

        PageReference orderPage = new PageReference('/'+redirtc);
        orderPage.setRedirect(true);
        return orderPage;
    }

    // method to verify if the rate adjustment is active
    // return true if active and else returns false.
    public Boolean checkIfActive(Insurance_Company_Rate_Adjustment__c pInsRateAdjustmentOnj) {
        Date todayDate = system.today();
        if(pInsRateAdjustmentOnj.Active_Date__c != null) {
            Date endDate = pInsRateAdjustmentOnj.Term_Date__c != null?pInsRateAdjustmentOnj.Term_Date__c:todayDate;
            if(todayDate >= pInsRateAdjustmentOnj.Active_Date__c && todayDate <= endDate) {
                return true;
            }
        }
        return false;
    }

    // method to form a dynamic query for a sobject given in parameter
    public String preparesObjectQueryString(String psObjectStr, String pRecordId) {
        String queryStr = '';
        String fieldStr = '';
        if(psObjectStr != null) {
            queryStr = 'SELECT ';
            for(Schema.SObjectField fieldInstance : globalSchemaMap.get(psObjectStr).getDescribe().fields.getMap().Values()) {
                fieldStr += fieldInstance.getDescribe().getname() + ', ';
            }
            fieldStr = fieldStr.removeEnd(', ');
            queryStr += fieldStr + ' FROM '+psObjectStr+ ' WHERE Id =\''+pRecordId+'\'';
        }
        return queryStr;
    }

    // wrapper class
    public class WraperClass{
        public Pay_Agreement_Worksheet__c pyAgrmntWrksht     {get; set;}
        public Insurance_Benefit__c insrncBnft               {get; set;}
        public String insrncBnftSelected                     {get; set;}
        public String facilitySelected                       {get; set;}
        public String fcltyPrgrmSelected                     {get; set;}
        public String rateAdjstmntSelected                   {get; set;}
        public Integer totalRowCount                         {get; set;}
        public Decimal totalTalbottDay                       {get; set;}
        public Decimal totalInsCoResp                        {get; set;}
        public Decimal totalCoPayAmt                         {get; set;}
        public Decimal targetEDR                             {get; set;}
        public Decimal dtxRate                               {get; set;}
        public Decimal phpRate                               {get; set;}
        public Decimal iopRate                               {get; set;}
        public Decimal rtcRate                               {get; set;}
        public Decimal totalAppliedDeductible;
        public Decimal totalCoInsurance;
        public Decimal totalInsEIVAmt;
        public Boolean pawDetailListDisplayFlag              {get; set;}
        public List<Pay_Agreement_Worksheet_Detail__c> relatedPAWDetailsList  {get; set;}

        public WraperClass(){
            pyAgrmntWrksht = new Pay_Agreement_Worksheet__c();
            insrncBnft = new Insurance_Benefit__c();
            insrncBnftSelected = '';
            facilitySelected = '';
            fcltyPrgrmSelected = '';
            rateAdjstmntSelected = '';
            totalRowCount = 0;
            totalTalbottDay = 0.00;
            totalInsCoResp = 0.00;
            totalCoPayAmt = 0.00;
            targetEDR = 0.00;
            totalAppliedDeductible = 0.00;
            totalCoInsurance = 0.00;
            totalInsEIVAmt = 0.00;
            pawDetailListDisplayFlag = false;
            relatedPAWDetailsList = new List<Pay_Agreement_Worksheet_Detail__c>();
        }
    }

    public virtual Id getCurrentPAWId(Quote quoteRecord){
        return quoteRecord.Pay_Agreement_Worksheet__c;
    }

    // year end method start
    public PAW_New_EditCntrllr setMeta( PAW_Editor_YearEndController.MetaData metaParam ){
        this.meta = metaParam;
        return this;
    }
}