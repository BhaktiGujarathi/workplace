public class PAW_YearEnd_Controller extends PAW_New_EditCntrllr {
    public Id pawRecordId                                      {set; get;} 
    public String year                                         {set; get;}
	public List<SelectOption> ptntInsrnceSelectOptions;
	public List<SelectOption> insrncBnftSelectOptions;
	public Patient_Insurance__c ptntInsrncSelectObj            {set; get;}

    public PAW_YearEnd_Controller() {
		ptntInsrnceSelectOptions = new List<SelectOption>();
		insrncBnftSelectOptions = new List<SelectOption>();
        system.debug('>>> Year : '+year);
	}

    //Builder Pattern
	public List<SelectOption> getPtntInsrnceSelectOptions(){
		ptntInsrnceSelectOptions = new List<SelectOption>();
		ptntInsrnceSelectOptions.add(new SelectOption( '' ,'---Select---'));
        String alternativeYear = ( Year == String.valueOf(System.today().year()) ? null : String.valueOf(System.today().year() + 1) );
        ptntInsrncMap = new Map<Id, Patient_Insurance__c> ([SELECT Id,
                                                                   Name,
                                                                   Insurance_Company__c
                                                              FROM Patient_Insurance__c
                                                             WHERE Opportunity__c = : oppId
                                                              AND Id
                                                              IN ( SELECT Patient_Insurance__c
                                                                     FROM Insurance_Benefit__c
                                                                   WHERE (Applicable_For_Year__c =: year
                                                                       OR Applicable_For_Year__c =: alternativeYear))]);
        for(Patient_Insurance__c ptntInsrnceInstance : ptntInsrncMap.Values()){
            ptntInsrnceSelectOptions.add(new SelectOption(ptntInsrnceInstance.id, ptntInsrnceInstance.Name));
        }
        return ptntInsrnceSelectOptions;
	}

	public List<SelectOption> getInsrncBnftSelectOptions(){
        insrncBnftSelectOptions.clear();
        insrncBnftSelectOptions.add(new SelectOption('' ,'---Select---'));
        String alternativeYear = ( Year == String.valueOf(System.today().year()) ? null : String.valueOf(System.today().year() + 1) );
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
                                                               WHERE Patient_Insurance__c = : ptntInsrncObj.Id
															   AND (Applicable_For_Year__c =: year
                                                                 OR Applicable_For_Year__c =: alternativeYear)]);

            for(Insurance_Benefit__c insrncBnftInstance : insrncBnftMap.values()){
                insrncBnftSelectOptions.add(new SelectOption(insrncBnftInstance.id , insrncBnftInstance.RecordType.Name+' - '+insrncBnftInstance.name));
            }
        }
        if(wrprObj.insrncBnftSelected != null && wrprObj.insrncBnftSelected != ''){
            wrprObj.insrncBnft = insrncBnftMap.get(wrprObj.insrncBnftSelected);
        } else {
            wrprObj.insrncBnft = null;
        }
        return insrncBnftSelectOptions;
    }

    public PAW_YearEnd_Controller setRecordId(Id recordIdParam){
        this.recordId = recordIdParam;
        return this;
    }

    public PAW_YearEnd_Controller setIsPrimary( Boolean value ) {
        this.isPrimary = value;
        return this;
    }

    public PAW_YearEnd_Controller setYear(String yearParam){
        this.year = yearParam;
        return this;
    }

    public PAW_YearEnd_Controller init(){
        this.initialize();
        return this;
    }

    public PAW_YearEnd_Controller setMetaData( PAW_Editor_YearEndController.MetaData metaParam ){
        //this.meta = metaParam;
        super.setMeta( metaParam );
        return this;
    }

    public override Id getCurrentPAWId(Quote quoteRecord){
        if( isPrimary == true ){
            return quoteRecord.Pay_Agreement_Worksheet__c;
        } else {
            return quoteRecord.Secondary_Pay_Agreement_Worksheet__c;
        }
    }

    public void createDetailRecordsForPAW() {
        createAndUpdatePAWDetailsRecords();
    }

    public PageReference savePAWRecords() {
        createAndUpdatePAWDetailsRecords();
        PageReference pageRef = saveTheUpdates();
        if(pageRef != null) {
            String url = pageRef.getUrl();
            Integer lastIndex = url.lastIndexOf('/');
            this.pawRecordId  = url.substring(lastIndex+1);
        }
        
        return null;
    }
}