public without sharing class PPFrnFacilitySelectionForPAWCreationExt {
    
    // list of FRN Facility from DB
    public MAp<Id, Account> frnFacilityDBMap;
    // selectoption list
    public List<SelectOption> frnFacilitySelectList                                     {get; set;}
    // FRN facility record type Id
    public Id frnFacililtyRecordTypeId;
    // list of wrapper to display on page
    public List<pawDetailsWrapper> pawDetailsWrapperList;
    // id to hold the id of sleectd FRN facility
    public Id frnFacilitySelectedId                                                     {get; set;}
    public Integer frnFacilitySelectedIndex                                             {get; set;}
    public List<SelectOption> facilityPrgrmSelectList                                   {get; set;}
    public List<SelectOption> blankSlectOptionList;
    public Id facilityPrgrmSelectedId                                                   {get; set;}
    public List<Pay_Agreement_Worksheet__c> payAgrmntList;
    public Id patientInsuranceId;
    public Patient_Insurance__c patientInsuarnceObj;
    // integer to hold the index of the PAW record to be deleted
    public Integer pawIndexToRemove                                                     {get; set;}
    public String customSettingName                                                     {get; set;}
        
    public PPFrnFacilitySelectionForPAWCreationExt() {
         
         frnFacilityDBMap = new Map<Id, Account>();
         frnFacilitySelectList = new List<SelectOption>();
         pawDetailsWrapperList = new List<pawDetailsWrapper>();
         blankSlectOptionList = new List<SelectOption>();
         payAgrmntList = new List<Pay_Agreement_Worksheet__c>();
         patientInsuarnceObj = new Patient_Insurance__c();
         
         patientInsuranceId = ApexPages.currentPage().getParameters().get('id');
         blankSlectOptionList.add(new SelectOption('', '--None--'));
         frnFacililtyRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
         frnFacilityDBMap = fetchFRNFaciltyDBMap();
         frnFacilitySelectList = getFrnFacilitySelectList(frnFacilityDBMap);
         fetchPatientInsurance(patientInsuranceId);
    }
    
    // method to fetch field details for patient insurance
    public void fetchPatientInsurance(Id pPatientInsuranceId) {
        patientInsuarnceObj = [SELECT id,
                                      Name,
                                      Opportunity__c,
                                      Insurance_Company__c
                                FROM Patient_Insurance__c
                                WHERE Id =: pPatientInsuranceId];
    }
    
    // method to get all FRN facility from db
    public Map<Id, Account> fetchFRNFaciltyDBMap() {
        if(frnFacililtyRecordTypeId <> null) {
            frnFacilityDBMap = new Map<Id, Account>([Select id, 
                                                            Name,
                                                            FRN_Facility_Type__c,
                                                            Ownership,
                                                            (Select id, 
                                                                    Name,
                                                                    Private_Pay_Fee__c,
                                                                    Program_Length__c,
                                                                    Auto_Add__c
                                                             From Facility_Programs__r 
                                                             Where Is_Private_Pay__c = true) 
                                                     From Account 
                                                     Where RecordTypeId =: frnFacililtyRecordTypeId]);
        }
        return frnFacilityDBMap;
    }
    
    // method to prepare a selection list of frn facility
    public List<SelectOption> getFrnFacilitySelectList(Map<Id, Account> pFrnFacilityDBMap) {
        frnFacilitySelectList.clear();
        frnFacilitySelectList.add(new SelectOption('', '--None--'));
        for(ID idInstance : pFrnFacilityDBMap.keySet()) {
            if(!(pFrnFacilityDBMap.get(idInstance).Facility_Programs__r).isEmpty()) {
                frnFacilitySelectList.add(new SelectOption (idInstance, pFrnFacilityDBMap.get(idInstance).Name));
            }
        }
        return frnFacilitySelectList;
    }
    
    public list<pawDetailsWrapper> getPawDetailsWrapperList() {
        if(pawDetailsWrapperList.isEmpty() || pawDetailsWrapperList == null) {
            pawDetailsWrapperList.add(new pawDetailsWrapper(new Map<Id, Facility_Program__c>(),
                                                            blankSlectOptionList,
                                                            0));
        }
        return pawDetailsWrapperList;
    }
    
    // method to be called on change of frn rfacility picklist value
    public void getProgramListForFacilitySelected() {
        
        customSettingName = '';
        // if index id not null
        if(frnFacilitySelectedIndex != null) {
            // get wrapper at that index
            pawDetailsWrapper pawDetailsWrapperObj = pawDetailsWrapperList[frnFacilitySelectedIndex];
            // assign frn facility at that index
            frnFacilitySelectedId = pawDetailsWrapperObj.pawFRNFacility;
            // prepare the name of custom setting depending on the ownership and type of facility selected.
            customSettingName = frnFacilityDBMap.get(frnFacilitySelectedId).Ownership +' '+frnFacilityDBMap.get(frnFacilitySelectedId).FRN_Facility_Type__c;
            system.debug('>>> customSettingName : '+customSettingName);
            pawDetailsWrapperObj.pawPrgmSelectList.clear();            
            // in frn facility db map check if program list is not null or empty
            if(!frnFacilityDBMap.get(frnFacilitySelectedId).Facility_Programs__r.isEmpty() 
                || frnFacilityDBMap.get(frnFacilitySelectedId).Facility_Programs__r != null) {
                //iterate over that list
                pawDetailsWrapperObj.pawPrgmSelectList.add(new SelectOption('', '--None--'));
                for(Facility_Program__c prgrmInstance :frnFacilityDBMap.get(frnFacilitySelectedId).Facility_Programs__r) {
                    // check if the prgram map in taht particular wrapper consists of that program id
                    if(!(pawDetailsWrapperObj.pawFacilitPrgmMap).containsKey(prgrmInstance.Id)) {
                        // if not add it to the map
                        pawDetailsWrapperObj.pawFacilitPrgmMap.put(prgrmInstance.Id, prgrmInstance);
                        // add that program as a select option in the select list
                        pawDetailsWrapperObj.pawPrgmSelectList.add(new SelectOption(prgrmInstance.Id, prgrmInstance.Name));
                    }
                }
            }
            pawDetailsWrapperList[frnFacilitySelectedIndex] = pawDetailsWrapperObj;
        }
    }

    
    // method to reflect the private fpay fee of the program
    public void getPrivatPayFeeForSelectedPrgrm() {
        if(frnFacilitySelectedIndex != null) {
            pawDetailsWrapper pawDetailsWrapperObj = pawDetailsWrapperList[frnFacilitySelectedIndex];
            facilityPrgrmSelectedId = pawDetailsWrapperObj.pawProgram;
            pawDetailsWrapperObj.pawPrivatePayFee = pawDetailsWrapperObj.pawFacilitPrgmMap.get(facilityPrgrmSelectedId).Private_Pay_Fee__c;
            pawDetailsWrapperList[frnFacilitySelectedIndex] = pawDetailsWrapperObj;
        }
    }
    
    // method to add new wrapper to list to display
    public void newPAWDetails() {
        pawDetailsWrapperList.add(new pawDetailsWrapper(new Map<Id, Facility_Program__c>(),
                                                        new List<SelectOption> {new SelectOption('', '--None--')},
                                                        pawDetailsWrapperList.size()));
    }
    
    // method to save the records of PAW
    public Pagereference savePAWRecords() {
        
        Id benefitRecordTypeId = Schema.SObjectType.Insurance_Benefit__c.getRecordTypeInfosByName().get('In Network').getRecordTypeId();
        Savepoint savePt = Database.setSavepoint();
        List<Estimated_Coverage_Days__c> estmtCvrageDaysList = new List<Estimated_Coverage_Days__c>();
        List<Pay_Agreement_Worksheet__c> payAgrmntList = new List<Pay_Agreement_Worksheet__c>();
        List<Pay_Agreement_Worksheet__c> payAgrmntDBList = new List<Pay_Agreement_Worksheet__c>();
        Set<Id> payAgrmntDBIdSet = new Set<Id>();
        List<Quote> estmtCostlist = new List<Quote>();
        Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
        List<PriceBook2> pricebooks = [select id, name, isActive from Pricebook2 where Name=:pricebookName.Default_Pricebook_Name__c limit 1];

        try {
            Insurance_Benefit__c insuranceBenefitObj = new Insurance_Benefit__c(Patient_Insurance__c = patientInsuranceId,
                                                                                RecordTypeId = benefitRecordTypeId,
                                                                                Disposition__c = 'Private Pay',
                                                                                Applicable_For_Year__c = String.valueOf( System.Today().year() ));
            insert insuranceBenefitObj;
            Pay_Agreement_Worksheet__c payAgrmntObj;
            Estimated_Coverage_Days__c estmtDayObj;
            PP_Estimate_Coverage_Days_For_Facility__c daysSettingObj;
            if(customSettingName != null && customSettingName != '') {
                daysSettingObj = PP_Estimate_Coverage_Days_For_Facility__c.getInstance(customSettingName);
                system.debug('>>> customSettingName :'+customSettingName);
                system.debug('>>> daysSettingObj :'+daysSettingObj);
            }     
            Decimal prgrmlength;
            Quote estmtObj;
            for(pawDetailsWrapper wrprInstance : pawDetailsWrapperList) {
            
                if(wrprInstance.pawFRNFacility != '' && wrprInstance.pawProgram!= '') {
                    system.debug('>>> daysSettingObj  :'+daysSettingObj);
                    system.debug('>>> daysSettingObj  :'+daysSettingObj.DTX_Days__c);
                    system.debug('>>> daysSettingObj  :'+daysSettingObj.RTC_Days__c);
                    system.debug('>>> daysSettingObj  :'+daysSettingObj.PHP_Days__c);
                    system.debug('>>> daysSettingObj  :'+daysSettingObj.IOP_Days__c);
                    estmtDayObj = new Estimated_Coverage_Days__c(Insurance_Benefit__c = insuranceBenefitObj.Id,
                                                                 FRN_Facility__c = (Id)wrprInstance.pawFRNFacility,
                                                                 DTX_Days__c = (daysSettingObj != null && daysSettingObj.DTX_Days__c != null)? daysSettingObj.DTX_Days__c : 0,
                                                                 RTC_Days__c = (daysSettingObj != null && daysSettingObj.RTC_Days__c != null)? daysSettingObj.RTC_Days__c : 0,
                                                                 PHP_Days__c = (daysSettingObj != null && daysSettingObj.PHP_Days__c != null)? daysSettingObj.PHP_Days__c : 0,
                                                                 IOP_Days__c = (daysSettingObj != null && daysSettingObj.IOP_Days__c != null)? daysSettingObj.IOP_Days__c : 0,
                                                                 Total_Copay__c = 0.00);
                    estmtCvrageDaysList.add(estmtDayObj);

                    payAgrmntObj = new Pay_Agreement_Worksheet__c(FRN_Facility__c = (Id)wrprInstance.pawFRNFacility,
                                                                  Facility_Program__c = (Id)wrprInstance.pawProgram,
                                                                  Private_Pay__c = (wrprInstance.pawPrivatePayFee = wrprInstance.pawPrivatePayFee==null?0.00:wrprInstance.pawPrivatePayFee),
                                                                  Patient_Insurance__c = patientInsuranceId,
                                                                  Status__c = 'Open',
                                                                  Opportunity__c = patientInsuarnceObj.Opportunity__c,
                                                                  Insurance_Benefit__c = insuranceBenefitObj.Id,
                                                                  Total_Patient_Contribution__c = (wrprInstance.pawPrivatePayFee = wrprInstance.pawPrivatePayFee==null?0.00:wrprInstance.pawPrivatePayFee),
                                                                  Total_Revenue__c = (wrprInstance.pawPrivatePayFee = wrprInstance.pawPrivatePayFee==null?0.00:wrprInstance.pawPrivatePayFee),
                                                                  Daily_Revenue__c = ((wrprInstance.pawPrivatePayFee = wrprInstance.pawPrivatePayFee==null?0.00:wrprInstance.pawPrivatePayFee)/(prgrmlength = wrprInstance.pawFacilitPrgmMap.get(wrprInstance.pawProgram).Program_Length__c==null?1:wrprInstance.pawFacilitPrgmMap.get(wrprInstance.pawProgram).Program_Length__c)),
                                                                  Uncovered_Charges__c = 0.00,
                                                                  Days_60_90_Fees__c = 0.00,
                                                                  Num_Days_Uncovered__c = 0,
                                                                  Uncovered_Days_Rate__c = 0.00,
                                                                  Room_and_Board_Days_Rate__c = 0.00,
                                                                  Ancillary_Fees__c = 0.00);
                   //Daily_Revenue__c = (wrprInstance.pawPrivatePayFee/(wrprInstance.pawFacilitPrgmMap.get((Id)wrprInstance.pawProgram).Program_Length__c))
                                                                  
                    payAgrmntList.add(payAgrmntObj);
                }   
            }
            
            if(!estmtCvrageDaysList.isEmpty()) {
                insert estmtCvrageDaysList;
            }
            
            if(!payAgrmntList.isEmpty()) {
                insert payAgrmntList;
            }
            
            for(Pay_Agreement_Worksheet__c pawInstance : payAgrmntList) {
                if(pawInstance.Id != null) {
                    payAgrmntDBIdSet.add(pawInstance.Id);
                }
            }
            
            payAgrmntDBList = [SELECT id,
                                      Opportunity__c,
                                      Opportunity__r.Name,
                                      FRN_Facility__c,
                                      Facility_Program__c
                               FROM Pay_Agreement_Worksheet__c
                               WHERE Id IN :payAgrmntDBIdSet];
            
            if(!payAgrmntDBList.isEmpty()) {
                for(Pay_Agreement_Worksheet__c pawInstance : payAgrmntDBList) {
                    if(pawInstance.Id != null) {
                        estmtObj = new Quote(OpportunityId = pawInstance.Opportunity__c,
                                             Pay_Agreement_Worksheet__c = pawInstance.Id,
                                             Status__c = 'Open',
                                             FRN_Facility__c = pawInstance.FRN_Facility__c,
                                             Facility_Program__c = pawInstance.Facility_Program__c,
                                             Name = pawInstance.Opportunity__r.name,
                                             Type__c = 'Official',
                                             Insurance_Company__c = patientInsuarnceObj.Insurance_Company__c,
                                             Pricebook2Id = pricebooks[0].Id
                                             );
                        estmtCostlist.add(estmtObj);
                    }
                }
            }
            
            if(!estmtCostlist.isEmpty()) {
                insert estmtCostlist;
                PageReference pageRef = new PageReference('/'+patientInsuarnceObj.Opportunity__c);
                return pageRef;
            }
            Database.rollback(savePt);
            return null;
        }
        catch(Exception exObj) {
            system.debug('>>> esObj :'+exObj);
            Database.rollback(savePt);
            return null;
        }
        
    }
    
    // method to redirect back to patient insurance record after click of cancel
    public Pagereference redirectToPatientInsurance() {
        PageReference pageRef = new PageReference('/'+patientInsuranceId);
        return pageRef;
    }
    
    // method to remove the added record
    public void removePAWRecord() {
        pawDetailsWrapperList.remove(pawIndexToRemove);
        //re-indexing
        for(Integer i=0;i<pawDetailsWrapperList.size();i++)
        {
           pawDetailsWrapperList[i].pawIndex = i;
        }
    }
    
    // method to auto add
    public void autoAddRecords() {
        Account frnObj;
        pawDetailsWrapper pawWrprObj;
        pawDetailsWrapperList.clear();
        for(Id idInstance : frnFacilityDBMap.keySet()) {
            frnObj = new Account();
            frnObj = frnFacilityDBMap.get(idInstance);
            for(Facility_Program__c prgrmInstance : frnObj.Facility_Programs__r) {
                if(prgrmInstance.Auto_Add__c == true) {
                    pawWrprObj = new pawDetailsWrapper(new Map<Id, Facility_Program__c>(),
                                               new List<SelectOption> {new SelectOption('', '--None--')},
                                               pawDetailsWrapperList.size());
                    pawWrprObj.pawFRNFacility = (String)idInstance;
                    pawWrprObj.pawProgram = (String)prgrmInstance.Id;
                    pawWrprObj.pawPrivatePayFee = prgrmInstance.Private_Pay_Fee__c;
                    pawWrprObj.pawPrgmSelectList.add(new SelectOption(prgrmInstance.Id, prgrmInstance.Name));
                    pawWrprObj.pawFacilitPrgmMap.put(prgrmInstance.Id, prgrmInstance);
                    pawDetailsWrapperList.add(pawWrprObj);
                }
            }
            
        }        
    }
    
    public class pawDetailsWrapper {
        public String pawFRNFacility                                                    {get; set;}
        public Map<Id, Facility_Program__c> pawFacilitPrgmMap;
        public List<SelectOption> pawPrgmSelectList                                     {get; set;}
        public String pawProgram                                                        {get; set;}
        public Decimal pawPrivatePayFee                                                 {get; set;}
        public Integer pawIndex                                                         {get; set;}
        public pawDetailsWrapper(Map<Id, Facility_Program__c> pPawFacilitPrgmMap, 
                                 List<SelectOption> pPawPrgmSelectList, 
                                 Integer pPawIndex) {
            pawFacilitPrgmMap = pPawFacilitPrgmMap;
            pawFRNFacility = '';
            pawProgram = '';
            pawPrgmSelectList = pPawPrgmSelectList;
            pawPrivatePayFee = 0.00;
            pawIndex = pPawIndex;
        }
    }
}