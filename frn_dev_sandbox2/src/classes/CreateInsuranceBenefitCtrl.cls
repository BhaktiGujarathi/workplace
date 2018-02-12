public class CreateInsuranceBenefitCtrl {   
    public String ibId;
    public boolean obj1boolean;
    public String getretURL;
    public String recordTypeName{get;set;}
    public Date pDOB{get;set;}
    public Insurance_Benefit__c ib{get;set;}
    public Integer patientAge{get;set;}
    public boolean redBoolead{get;set;}
    public String selectAccount{get;set;}
    public SelectOption[] selectedAccounts { get; set; }    
    public SelectOption[] allContacts { get; set; }
    
    public string SelectedRecordtyp{get;set;}
    public List<SelectOption> InBenefitRecordtyps{get;set;}
    public Map<string, string> RecordDetailMap{get;set;}    
    
    public List<EstimatedCoverageClass> coverageDaysWrpList {get;set;}
    public Integer rowToRemove {get;set;}
    public Patient_Insurance__c patDOB;
    public List<SelectOption> currentFrnFaclitityOptions {get; set;}
    public Integer totalDaysUsedCount {get; set;}

    public CreateInsuranceBenefitCtrl(ApexPages.StandardController controller){
        String idVal = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        for (String key : params.keySet()) {
          if (key.startsWith('CF') && key.endsWith('lkid')) {
            String val = params.get(key);
            
              idVal = val;
              break;
            
          }
        }
        system.debug('id'+idVal);
        selectedAccounts = new List<SelectOption>();
        allContacts = new List<SelectOption>();
        patientAge = 0;
        redBoolead = false;
        patDOB = new Patient_Insurance__c();
        coverageDaysWrpList = new List<EstimatedCoverageClass>();
        ib = new Insurance_Benefit__c();
        ibId = ((Insurance_Benefit__c)controller.getRecord()).id;
        String getcustomRetURL = ApexPages.currentPage().getParameters().get('customRetURL');
        String[] s;
        currentFrnFaclitityOptions = new List<SelectOption>();
        totalDaysUsedCount = 0;
        currentFrnFaclitityOptions = getAccountPicklist();
        if(getcustomRetURL != null){
            getretURL = getcustomRetURL;
            
        } else {            
            getretURL = ApexPages.currentPage().getParameters().get('retURL'); 
            
            if(getretURL != null && getretURL.length()>14){
                s = getretURL.split('/');
                getretURL=s[1];
            } else {
                getretURL = idVal;
            }
        }
     
        String getIbRecordType = ApexPages.currentPage().getParameters().get('ibRecType');  
        String selectedRecordType = '';
        if(getIbRecordType != null){
            selectedRecordType = getIbRecordType;
        } else {
            selectedRecordType = ((Insurance_Benefit__c)controller.getRecord()).RecordTypeId;       
        }
        if(selectedRecordType != null && selectedRecordType.length() >0){            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE Id =:selectedRecordType];
            recordTypeName = rt.Name;          
            ib.RecordTypeId = rt.Id;
            
            String paInPrefix = Patient_Insurance__c.sObjectType.getDescribe().getKeyPrefix();              
            if(getretURL!= null && getretURL.length()>14 && getretURL.startsWith(paInPrefix)){
                ib.Patient_Insurance__c = getretURL;
                patDOB = [Select Id,Opportunity__c,Accreditation__c,Accepts_Assignment_of_Benefits__c,COBRA_Account__c,Patient__r.Birthdate FROM Patient_Insurance__c Where id=: getretURL];
                if(patDOB.Patient__r.Birthdate != null){
                    pDOB = patDOB.Patient__r.Birthdate;
                    Integer age = calculateYears(patDOB.Patient__r.Birthdate);              
                    patientAge = age;                   
                } else { 
                    pDOB = null;
                }
                    
            }                
        }
        
        if(ibId != null){
            ib = [Select FRN_Facilities__c,
                         Insurance_Benefit__c.Name,
                         Insurance_Benefit__c.Applicable_For_Year__c,
                         Patient_Insurance__c,
                         Patient_Insurance__r.Opportunity__c,
                         Patient_Insurance__r.Accreditation__c,
                         Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,
                         Patient_Insurance__r.COBRA_Account__c,
                         RecordTypeId,
                         Disposition__c,
                         IOP_Pays_at__c,
                         Detox_Over__c,
                         DTX_Apply_Copay__c,
                         DTX_Copay_Type__c,
                         IOP_Copay_Type__c,
                         IOP_Apply_Copay__c,
                         PHP_Copay_Type__c,
                         PHP_Apply_Copay__c,
                         RTC_Copay_Type__c,
                         RTC_Apply_Copay__c,
                         Residential_Treatment_Override__c,
                         Partial_Hospitalization_Override__c,
                         Intensive_Outpatient_Override__c,
                         Deductible_Included_in_OOP__c,
                         Deductible__c,
                         Annual_Max__c,
                         Annual_Max_Remaining__c,
                         Annual_Max_Met__c,
                         Lifetime_Max_Remaining__c,
                         Lifetime_Max__c,
                         Max_Out_of_Pocket__c,
                         Max_Out_of_Pocket_Met__c,
                         Lifetime_Max_Met__c,
                         Day_Max_Inpatient__c,
                         Max_Out_of_Pocket_Remaining__c,
                         Day_Max_Outpatient__c,
                         Day_Max_Inpatient_Used__c,
                         Day_Max_Outpatient_Used__c,
                         No_Out_of_Network_Benefits__c,
                         Combined_Day_Max_IP_OP__c,
                         Detox_Covered__c,
                         Detox_Admit_Co_Payment__c,
                         Clinical_Assessment_Needed__c,
                         Detox_Pays_at__c,
                         Detox_Day_Max_Applies__c,
                         Detox_Ratio__c,
                         LOC_Benefits_are_the_Same__c,
                         PHP_Covered__c,
                         PHP_Admit_Co_Payment__c,
                         PHP_Pays_at__c,
                         PHP_Day_Max_Applies__c,
                         PHP_Ratio__c,
                         RTC_Covered__c,
                         RTC_Admit_Co_Payment__c,
                         RTC_Pays_at__c,
                         RTC_Day_Max_Applies__c,
                         RTC_Ratio__c,
                         IOP_Covered__c,
                         IOP_Admit_Co_Payment__c,
                         IOP_Day_Max_Applies__c,
                         IOP_Ratio__c,
                         Reimbursement_Structure__c,
                         Plan_Funded_by__c,
                         Shared_Savings__c,
                         Deductible_Remaining__c,
                         Percentage_of_Medicare_Rate__c,
                         RecordType.Name,
                         Patient_DOB__c,
                         Deductible_Met__c,
                         Num_Days_Uncovered__c,
                         Num_Days_Room__c,
                         Uncovered_Days_Rate__c,
                         R_B_Days__c,
                         Uncovered_Days__c,
                         Uncovered_Charges__c,
                         Insurance_Company_is_Out_of_Network__c,
                         Room_and_Board_Days_Rate__c,
                         Uncovered_Days_Override__c,
                         Room_and_Board_Days_Override__c,
                         Benefits_Check__c,
                         Co_Pay_Met__c,
                         Physician_Fees_Covered_Same__c,
                         Professional_Outpatient_Covered_Same__c,
                         Physician_Fees_Additional_Info__c,
                         Professional_OP_Additional_Info__c,
                         Current_Residential_facility__c,
                         DTX_Days_Used__c,
                         RTC_Days_Used__c,
                         PHP_Days_Used__c,
                         IOP_Days_Used__c,
                         Current_Daily_EIV__c,
                         Total_Used_Days__c
                    FROM Insurance_Benefit__c
                   WHERE Id =: ibId];
            if(ib.FRN_Facilities__c != null){ 
                for(String ss:ib.FRN_Facilities__c.split(', ')){
                    selectedAccounts.add(new SelectOption(ss, ss));
                } 
            }
            totalDaysUsedCount = Integer.valueOf(ib.Total_Used_Days__c);
            patDOB = new Patient_Insurance__c();
            patDOB.Id = ib.Patient_Insurance__c;
            patDOB.Opportunity__c = ib.Patient_Insurance__r.Opportunity__c;
            patDOB.Accreditation__c = ib.Patient_Insurance__r.Accreditation__c;
            patDOB.Accepts_Assignment_of_Benefits__c = ib.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c;
            patDOB.COBRA_Account__c = ib.Patient_Insurance__r.COBRA_Account__c;
            
            recordTypeName = ib.RecordType.Name;
            
            if(ib.Patient_DOB__c != null){
                pDOB = ib.Patient_DOB__c;
                Integer age = calculateYears(ib.Patient_DOB__c);
                patientAge = age;                
            }else{
                pDOB = null;
            }
            
            EstimatedCoverageClass estWrp;
            for(Estimated_Coverage_Days__c est:[Select Id,FRN_Facility__c,DTX_Days__c,Insurance_Benefit__c,IOP_Days__c,PHP_Days__c,RTC_Days__c,Total_Copay__c FROM Estimated_Coverage_Days__c WHERE Insurance_Benefit__c=:ibId]){
                estWrp = new EstimatedCoverageClass();
                estWrp.record = est;
                estWrp.index = coverageDaysWrpList.size();
                estWrp.total_days = Integer.valueOf(((est.DTX_Days__c!=null) ? est.DTX_Days__c:0) + ((est.IOP_Days__c!=null) ? est.IOP_Days__c:0) + ((est.PHP_Days__c!=null) ? est.PHP_Days__c:0) + ((est.RTC_Days__c!=null) ? est.RTC_Days__c:0));
                coverageDaysWrpList.add(estWrp);
            }
        }
        
        if(coverageDaysWrpList.size()==0){
            addNewEstRows();
        }

        InBenefitRecordtyps  = new List<SelectOption>(); 
        RecordDetailMap  = new Map<string, string>(); 
        for(RecordType rec : [SELECT Id, Name, Description FROM RecordType WHERE IsActive = true AND SobjectType = 'Insurance_Benefit__c']){         
            InBenefitRecordtyps.add(new SelectOption(rec.Id, rec.Name));
            RecordDetailMap.put(rec.Name, rec.Description);
        } 
    }
    
    public List<SelectOption> getAccountPicklist(){
        List<SelectOption> accList = new List<SelectOption>();
        accList.add(new SelectOption('', '--None--'));
        for(Account acc: [Select id, name from Account where FRN_Facility_Type__c = 'Residential Treatment']){
            accList.add(new SelectOption(acc.id, acc.name));
        }
        return accList;
    }
    
    public pagereference saveOppInfo(){
        try{
            if((ib.Detox_Pays_at__c!=null || ib.Detox_Pays_at__c!=0.00)&&(ib.IOP_Pays_at__c==null || ib.IOP_Pays_at__c==0.00)&&(ib.RTC_Pays_at__c==null || ib.RTC_Pays_at__c==0.00)&&(ib.PHP_Pays_at__c==null || ib.PHP_Pays_at__c==0.00)&&(ib.Detox_Pays_at__c==null || ib.IOP_Pays_at__c==0.00)){
                ib.IOP_Pays_at__c = ib.Detox_Pays_at__c;
                ib.RTC_Pays_at__c = ib.Detox_Pays_at__c;
                ib.PHP_Pays_at__c = ib.Detox_Pays_at__c;
                ib.Detox_Pays_at__c = ib.Detox_Pays_at__c;
                ib.FRN_Facilities__c = accountret();
            }
            if(ib.Physician_Fees_Covered_Same__c == 'Yes') {
                ib.Physician_Fees_Additional_Info__c = '';
            }
            if(ib.Professional_Outpatient_Covered_Same__c == 'Yes') {
                ib.Professional_OP_Additional_Info__c = '';
            }
            upsert ib;
            
            List<Estimated_Coverage_Days__c> estList = new List<Estimated_Coverage_Days__c>();
            Estimated_Coverage_Days__c est;
            for(EstimatedCoverageClass estWrp:coverageDaysWrpList){
                est = estWrp.record;
                est.Insurance_Benefit__c = ib.Id;
                if(est.FRN_Facility__c!=null) 
                    estList.add(est);
            }
            
            if(estList.size()>0){
                upsert estList;
            }
            PageReference pageRef = new PageReference('/'+ib.Id);
            pageRef.setRedirect(true);
            return pageRef;
        } catch(Exception e){
            return null;
        }
    }
    
    public string accountret() {
        String message = '';
        Boolean first = true;
        for ( SelectOption so : selectedAccounts ) {
            if (!first) {
                message += ', ';
            }
            message += so.getLabel();
            first = false;
        }
        
        return message;       
    }
    
    public pagereference saveNOppInfo(){
        try{
            if((ib.Detox_Pays_at__c!=null || ib.Detox_Pays_at__c!=0.00)&&(ib.IOP_Pays_at__c==null || ib.IOP_Pays_at__c==0.00)&&(ib.RTC_Pays_at__c==null || ib.RTC_Pays_at__c==0.00)&&(ib.PHP_Pays_at__c==null || ib.PHP_Pays_at__c==0.00)&&(ib.Detox_Pays_at__c==null || ib.IOP_Pays_at__c==0.00)){
                ib.IOP_Pays_at__c = ib.Detox_Pays_at__c;
                ib.RTC_Pays_at__c = ib.Detox_Pays_at__c;
                ib.PHP_Pays_at__c = ib.Detox_Pays_at__c;
                ib.Detox_Pays_at__c = ib.Detox_Pays_at__c;
                ib.FRN_Facilities__c = accountret();
            }
            upsert ib;
            
            List<Estimated_Coverage_Days__c> estList = new List<Estimated_Coverage_Days__c>();
            Estimated_Coverage_Days__c est;
            for(EstimatedCoverageClass estWrp:coverageDaysWrpList){
                //est = new Estimated_Coverage_Days__c();               
                est = estWrp.record;
                est.Insurance_Benefit__c = ib.Id;
                if(est.FRN_Facility__c!=null) 
                    estList.add(est);
            }
            
            if(estList.size()>0){
                upsert estList;
            }
            PageReference pageRef = Page.InBenefitRecordtyps;
            //pageRef.setRedirect(true);
            return pageRef;
        }catch(Exception e){
            return null;
        }
    }
    
    public void showDOB(){
        if(ib.Patient_Insurance__c != null){
            Patient_Insurance__c pi = [Select id,Patient__r.Birthdate from Patient_Insurance__c where Id =: ib.Patient_Insurance__c];
            if(pi.Patient__r.Birthdate != null){
                pDOB = pi.Patient__r.Birthdate;             
                //patientAge = pi.Patient__r.Birthdate.daysBetween(Date.Today());
                if(pi.Patient__r.Birthdate != null){
                    Integer age = calculateYears(pi.Patient__r.Birthdate);              
                    patientAge = age;           
                }                 
            } else {
                pDOB = null; 
            }            
        }        
    }
    
    public Integer calculateYears(Date dob){
        date patientDOB = dob; 
        Integer monthsCal = 0;      
        Integer returnYears = 0; 
        Integer cYear = System.Today().year();      
        Integer cMnth = System.Today().month();     
        Integer cDate = System.Today().day();
        
        Integer pYear = (patientDOB).year();    
        Integer pMnth = (patientDOB).month();   
        Integer pDate = (patientDOB).day();    
        date currentDate = system.today();                      
        //  birthdate = today        
        if(patientDOB == currentDate){         
            monthsCal = 0;             
            returnYears = 0;          
        } else if(patientDOB > currentDate){ 
            // birthday > today
            return null;
            //  birthday < today                    
        } else {
            monthsCal = patientDOB.monthsBetween(currentDate);          
            if (currentDate.day() < patientDOB.day()) monthsCal--;
            returnYears = monthsCal/12;                 
        }

        if(returnYears == 25){
            if(pMnth > cMnth){
                redBoolead = true;
            } else if(pMnth == cMnth && pDate >= cDate){
                redBoolead = true;
            }                   
        } else { 
            redBoolead = false; 
        }                            
        if(returnYears > 0){
            return returnYears;                
        }      
        return null;
    }

    public pagereference ContinueInBenefit(){
        String paramPatIns = '';        
        paramPatIns = Ib.Patient_Insurance__c;
        
        if(paramPatIns!= null || paramPatIns!= '' && SelectedRecordtyp!= null){
            pageReference page = new pageReference('/apex/CreateInsuranceBenefit?ibRecType='+SelectedRecordtyp+'&customRetURL='+paramPatIns);
            page.setRedirect(true);
            return page;            
        }
        return null;  
    }
    
    public List<SelectOption> getFRNFacilities(){
        List<SelectOption> frnFacilities = new List<SelectOption>();
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId(); 
        Opportunity oppObj = new Opportunity();
        Set<Id> accids = new Set<Id>();
        if(ib.Patient_Insurance__c!=null && patDOB.Opportunity__c!=null){
            String oppId = patDOB.Opportunity__c;
            if(oppId!=null){    
                oppObj = [SELECT Id,
                                 RecordTypeId,
                                 RecordType.Name
                          FROM   Opportunity
                          WHERE  Id =: oppId
                          LIMIT 1];
                for(Case cs:[Select Id, AccountId from Case where AccountId != null AND Opportunity__c =: oppId AND Status = 'Denied']){
                    accIds.add(cs.AccountId);
                }
            }               
        }
        
        frnFacilities.add(new SelectOption( '' ,'---Select---')); 
        String queryString = 'Select Id,Name,Ownership,Accreditation__c from Account WHERE RecordTypeId=:accRTId';        
        if(accIds.size()>0){
            queryString += ' AND ID NOT IN:accIds';
        }
        String fclityRest='';
        if(patDOB!=null){
            fclityRest = patDOB.Accreditation__c;         
        } 
        if(patDOB!=null && patDOB.Accepts_Assignment_of_Benefits__c=='No'){
            queryString+= ' AND Assignment_of_Benefits_Required__c != \'Yes\'';
        }
        if(patDOB!=null && patDOB.COBRA_Account__c=='Yes'){
            queryString+= ' AND COBRA_Accepted__c = \'Yes\'';
        }
        if((oppObj.RecordType.Name).equalsIgnoreCase('Residential Treatment')) {
            queryString += ' AND FRN_Facility_Type__c = \'Residential Treatment\'';
        }
        else if((oppObj.RecordType.Name).equalsIgnoreCase('Outpatient Treatment')) {
            queryString += ' AND FRN_Facility_Type__c = \'Intensive Outpatient\'';
        }
        List<Account> accList = Database.query(queryString);
        for(Account acc : accList){          
            if(acc.Accreditation__c != null && acc.Accreditation__c != '' && fclityRest!=null && fclityRest!=''){
                if(acc.Accreditation__c.contains(fclityRest)){
                    frnFacilities.add(new SelectOption(acc.id , acc.Name));
                }
            }            
        }
        return frnFacilities;
    }
    
    public class EstimatedCoverageClass{
        public Estimated_Coverage_Days__c record {get;set;}
        public integer index {get;set;}     
        public integer total_days {get;set;}        
        public EstimatedCoverageClass(){
            record = new Estimated_Coverage_Days__c();
            total_days = 0;
        }
    }
    
    public void addNewEstRows(){
        EstimatedCoverageClass newRecordWep = new EstimatedCoverageClass();
        Estimated_Coverage_Days__c est = new Estimated_Coverage_Days__c();
        newRecordWep.record = est;
        newRecordWep.index = coverageDaysWrpList.size();
        if(newRecordWep.index>0){
            Estimated_Coverage_Days__c oldLORecord = coverageDaysWrpList[newRecordWep.index-1].record;
            if(oldLORecord.FRN_Facility__c==null)
                 return;
        }
        coverageDaysWrpList.add(newRecordWep);     
    }
    
    public void removeRowFromEst(){
        Estimated_Coverage_Days__c est = coverageDaysWrpList[rowToRemove].record;
        if(est.Id!=null){
            delete est;
        }
        coverageDaysWrpList.remove(rowToRemove);
        if(coverageDaysWrpList.size()==0){
            addNewEstRows();
        }
    }
    
    public void calculateTotalCoPay(){
        decimal dtxAmount;
        decimal rtcAmount;
        decimal phpAmount;
        decimal iopAmount;
        Estimated_Coverage_Days__c est;
         
        for(EstimatedCoverageClass estWrp:coverageDaysWrpList){
            est = estWrp.record;
            dtxAmount = 0;
            estWrp.total_days = 0;
            estWrp.total_days += Integer.valueOf(((est.DTX_Days__c!=null) ? est.DTX_Days__c :0));
            if(ib.Detox_Admit_Co_Payment__c!=null && ib.Detox_Admit_Co_Payment__c!=0 && ib.DTX_Apply_Copay__c){             
                decimal dtxRate = (ib.DTX_Copay_Type__c=='Admit') ? 1: (ib.DTX_Copay_Type__c=='Per Day' && est.DTX_Days__c!=null)? est.DTX_Days__c:0;
                dtxAmount = ib.Detox_Admit_Co_Payment__c*dtxRate;
            }
            
            rtcAmount = 0;
            estWrp.total_days += Integer.valueOf(((est.RTC_Days__c!=null) ? est.RTC_Days__c:0));
            if(ib.RTC_Admit_Co_Payment__c!=null && ib.RTC_Admit_Co_Payment__c!=0 && ib.RTC_Apply_Copay__c){             
                decimal rtcRate = (ib.RTC_Copay_Type__c=='Admit') ? 1: (ib.RTC_Copay_Type__c=='Per Day' && est.RTC_Days__c!=null) ? est.RTC_Days__c:0; 
                rtcAmount = ib.RTC_Admit_Co_Payment__c*rtcRate;
            }
            
            phpAmount = 0;
            estWrp.total_days += Integer.valueOf(((est.PHP_Days__c!=null) ? est.PHP_Days__c :0));
            if(ib.PHP_Admit_Co_Payment__c!=null && ib.PHP_Admit_Co_Payment__c!=0 && ib.PHP_Apply_Copay__c){             
                decimal phpRate = (ib.PHP_Copay_Type__c=='Admit') ? 1: (ib.PHP_Copay_Type__c=='Per Day' && est.PHP_Days__c!=null) ? est.PHP_Days__c:0; 
                phpAmount = ib.PHP_Admit_Co_Payment__c*phpRate;
            }
            
            iopAmount = 0;
            estWrp.total_days += Integer.valueOf(((est.IOP_Days__c!=null) ? est.IOP_Days__c:0));
            if(ib.IOP_Admit_Co_Payment__c!=null && ib.IOP_Admit_Co_Payment__c!=0 && ib.IOP_Apply_Copay__c){             
                decimal iopRate = (ib.IOP_Copay_Type__c=='Admit') ? 1: (ib.IOP_Copay_Type__c=='Per Day' && est.IOP_Days__c!=null) ? est.IOP_Days__c:0; 
                iopAmount = ib.IOP_Admit_Co_Payment__c*iopRate;
            }
            est.Total_Copay__c = dtxAmount+rtcAmount+phpAmount+iopAmount;           
            estWrp.record = est;
        }
    }
    // Used as dummy action for rendering sections
    public void renderedSectionMethod() {
    }

    // method to calculate the total used day on value change of DTX, RTC, PHP, IOP days used.
    public void calculateTotalDaysUsed() {
        totalDaysUsedCount = (ib.DTX_Days_Used__c != null ? Integer.valueOf(ib.DTX_Days_Used__c) : 0)
                           + (ib.RTC_Days_Used__c != null ? Integer.valueOf(ib.RTC_Days_Used__c) : 0)
                           + (ib.PHP_Days_Used__c != null ? Integer.valueOf(ib.PHP_Days_Used__c) : 0)
                           + (ib.IOP_Days_Used__c != null ? Integer.valueOf(ib.IOP_Days_Used__c) : 0);
    }
}