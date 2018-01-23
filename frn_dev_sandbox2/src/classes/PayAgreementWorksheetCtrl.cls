public class PayAgreementWorksheetCtrl{
    public Patient_Insurance__c pat{get;set;}
    public String selectedBenefit{get;set;}
    public String pid;
    public boolean show{get;set;}
    public boolean saveBtn{get;set;}
    public List<Pay_Agreement_Worksheet_Detail__c> AgreementDetaillist{get;set;}
    public LOCRelatedValues LOCValues {get;set;}
    public String selectdFRNFacility {get;set;}
    public String selectdFacilityProgram {get;set;}
    public Map<Id,Insurance_Benefit__c> ibfMap;
    public Map<Id,String> frnFacilityMap;
    public Map<Id,Facility_Program__c> frnFacilityPrgmMap {get;set;}
    public Integer totalRowCount {get;set;}
    public Integer totalTalbottDay {get;set;}
    public string opportunityId='';
    public boolean isFromInsBef;
    public boolean isTalbott {get;set;}
    public boolean showPILookup{get;set;}   
    public String retUrl {get;set;}
    public String Clone='';
    public String quotoId='';
    public decimal totalInsCoResp {get;set;}
    public Map<Id,Insurance_Company_Rate_Adjustment__c> icraMap;
    public String selectdRateAdjistment {get;set;}
    public List<SelectOption> facilityProgrammes {get;set;}
    public List<SelectOption> frnFacilities {get;set;}
    public Decimal targetEDR {get;set;}
    public boolean isFromConstructor;
    
    public Estimated_Coverage_Days__c est;
    public decimal totalCoPay {get;set;}
   
    public PayAgreementWorksheetCtrl(){
        String payPrefix = Pay_Agreement_Worksheet__c.sObjectType.getDescribe().getKeyPrefix();
       
        ibfMap = new Map<Id,Insurance_Benefit__c>();
        frnFacilityMap = new Map<Id,String>();
        frnFacilityPrgmMap = new Map<Id,Facility_Program__c>();
        LOCValues = new LOCRelatedValues();       
        totalRowCount = 0;
        totalTalbottDay = 0;
        totalInsCoResp = 0.00;
        totalCoPay = 0.00;
        show = false;
        saveBtn = true;
        isFromInsBef = false;
        isFromConstructor = false;
        isTalbott = false;
        facilityProgrammes = new List<SelectOption>();
        frnFacilities = new List<SelectOption>();
        AgreementDetaillist = new List<Pay_Agreement_Worksheet_Detail__c>();
        pid = Apexpages.currentpage().getparameters().get('id');
        retUrl = Apexpages.currentpage().getparameters().get('retURL');
        Clone = Apexpages.currentpage().getparameters().get('Clone');
        quotoId =Apexpages.currentpage().getparameters().get('quoteId');
        if(quotoId != null && quotoId != '')
        {
            system.debug('.... changed');
            Quote qot = [select Id,Pay_Agreement_Worksheet__c from quote where Id=:quotoId];
            pid=qot.Pay_Agreement_Worksheet__c;
        }
        if(pid==null) pid = retUrl;
        icraMap = new Map<Id,Insurance_Company_Rate_Adjustment__c>();
        System.debug('pid>>>>>>>>>>'+pid);
        if(pid!=null && pid.contains('?')){
            String[] extraValue = pid.split('\\?');
            pid= extraValue[0];
            System.debug('pid>>>>>>>>>>'+pid);
        }
        if(pid != null){
            String[] ss = pid.split('/');
            System.debug('pid>>>>>>>>>>'+ss);
            string pid1 = ss[ss.size()-1];
            System.debug('pid1____________________ '+pid1);      
            Schema.DescribeSObjectResult oppSchema = Opportunity.sObjectType.getDescribe();
            if(pid1.startsWith(oppSchema.getKeyPrefix())){
                showPILookup = false;
                opportunityId = pid1;
                getPatient();
                if(retUrl!=null && retUrl.contains('CreateOpportunity'))
                    pid = null;
            } else if(pid1.startsWith(payPrefix)){
                showPILookup = true;
                opportunityId = '';
                getPatient();
            } 
        }
        if(pid != null && pid.contains('/')){
            String[] ss = pid.split('/');
            pid = ss[1];
            Schema.DescribeSObjectResult ibfSchema = Insurance_Benefit__c.sObjectType.getDescribe();
            if(pid.startsWith(ibfSchema.getKeyPrefix()) && pid.length()>=15) {  
                showPILookup = false;
                Insurance_Benefit__c ibf = [SELECT Id,Patient_Insurance__c,Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,Patient_Insurance__r.COBRA_Account__c,Patient_Insurance__r.Accreditation__c,Patient_Insurance__r.Opportunity__c FROM Insurance_Benefit__c WHERE Id =: pid];  
                pid = ibf.Patient_Insurance__c;
                selectedBenefit = ibf.Id;
                pat = new Patient_Insurance__c();
                pat.Id = pid;
                pat.Accepts_Assignment_of_Benefits__c = ibf.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c;
                pat.COBRA_Account__c = ibf.Patient_Insurance__r.COBRA_Account__c;
                pat.Opportunity__c = ibf.Patient_Insurance__r.Opportunity__c;
                pat.Accreditation__c = ibf.Patient_Insurance__r.Accreditation__c;
                if(opportunityId==null || opportunityId=='')
                    opportunityId = ibf.Patient_Insurance__r.Opportunity__c;
                getBenefit();
                onBenefitChange();
                isFromConstructor = true;
                onFRNFacilitySelected();
                isFromConstructor = false;
                //updateLOCValues();
                isFromInsBef = true;
                System.debug('selectedBenefit ::>'+selectedBenefit);
            }
        } else {
            pid = Apexpages.currentpage().getparameters().get('id');
            if(quotoId != null && quotoId != ''){
                system.debug('.... changed');
                Quote qot = [select Id,Pay_Agreement_Worksheet__c from quote where Id=:quotoId];
                pid=qot.Pay_Agreement_Worksheet__c;
            }
        }
        System.debug('pid after slipt>>>>>>>>>'+pid);
        if(pid != null){
            Schema.DescribeSObjectResult piSchema = Patient_Insurance__c.sObjectType.getDescribe();
            String piKeyPrefix = piSchema.getKeyPrefix();
            String preFix = pid.substring(0, 3);
            
            Schema.DescribeSObjectResult pAWSchema = Pay_Agreement_Worksheet__c.sObjectType.getDescribe();
            String pAWKeyPrefix = pAWSchema.getKeyPrefix();
            if(preFix == piKeyPrefix){
                pat = [select Id,Name,Insurance_Company__c,Accepts_Assignment_of_Benefits__c,Accreditation__c,COBRA_Account__c,Opportunity__c from Patient_Insurance__c where id =: pid];
                System.debug('pat >>>>>>>>>'+pat.id);
                if(opportunityId==null || opportunityId=='')
                    opportunityId = pat.Opportunity__c;
                onBenefitChange();
                isFromConstructor = true;
                onFRNFacilitySelected();
                isFromConstructor = false;
                //saveBtn = false;
            }else if(pid.startsWith(pAWKeyPrefix) && pid.length()>3){
                Pay_Agreement_Worksheet__c paw = [Select Id,Patient_Insurance__c,Total_Insurance_Co_Responsibility__c,Patient_Insurance__r.Name,Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,Patient_Insurance__r.COBRA_Account__c,Patient_Insurance__r.Opportunity__c,Patient_Insurance__r.Insurance_Company__c,Patient_Insurance__r.Accreditation__c,Opportunity__c,Lifetime_Max__c,Lifetime_Max_Used__c,Annual_Max__c,Annual_Max_Used__c,Co_Pay_Met__c,Out_of_Pocket_Max__c,Out_of_Pocket_Max_Met__c,Deductible__c,Deductible_Met__c,Plan_Coverage__c,Ancillary_Fees__c,Miscellaneous_Fees__c,Deductible_Included_in_OOP__c,Detox_Over__c,Residential_Treatment_Override__c,Total_Applied_Deductible__c, RTC_Pays_at__c, Partial_Hospitalization_Override__c,FRN_Facility__c,FRN_Facility__r.Ownership,Facility_Program__c,PHP_Pays_at__c,Intensive_Outpatient_Override__c,Insurance_Benefit__c,Insurance_Benefit__r.Deductible_Remaining__c,Insurance_Benefit__r.Max_Out_of_Pocket_Remaining__c,Insurance_Benefit__r.Deductible_Included_in_OOP__c,Detox_Pays_at__c,IOP_Pays_at__c,Room_and_Board_Fees__c,Daily_Revenue__c ,Revision__c,Num_Days_Uncovered__c,Num_Days_Room__c,Uncovered_Days_Rate__c,Room_and_Board_Days_Rate__c,Uncovered_Days_Override__c,Room_and_Board_Days_Override__c,Days_60_90_Fees__c,Number_of_Days__c,Co_Pay_Remaining__c, Counter_Offer__c,Total_Co_Insurance__c,Insurance_Company_Rate_Adjustment__c,Total_Patient_Contribution__c,Total_Revenue__c,Insurance_Company_Rate_Adjustment__r.Type__c,Rate_Adjustment_Type__c,Co_Insurance_Amount_Requested__c,Uncovered_Charges__c,Deductible_Amount_Requested__c,Private_Pay__c,Co_Pay_Amount_Requested__c from Pay_Agreement_Worksheet__c WHERE Id=:pid];
                                
                LOCValues.pAWrkSht = paw;
                if(paw.Days_60_90_Fees__c==null){
                    LOCValues.pAWrkSht.Days_60_90_Fees__c = 0.00;
                }
                
                LOCValues.pAWrkSht.Plan_Coverage__c = 0.00;
                if(quotoId != null && quotoId != ''){
                    LOCValues.pAWrkSht.Counter_Offer__c=true;
                }
                if(paw.Total_Insurance_Co_Responsibility__c!=null)
                    totalInsCoResp = paw.Total_Insurance_Co_Responsibility__c;
                if(paw.Total_Applied_Deductible__c!=null)
                    LOCValues.pAWrkSht.Plan_Coverage__c = paw.Total_Applied_Deductible__c;
                if(paw.Total_Co_Insurance__c!=null)
                    LOCValues.pAWrkSht.Plan_Coverage__c += paw.Total_Co_Insurance__c;
                                        
                selectdFRNFacility = paw.FRN_Facility__c;
                selectdFacilityProgram = paw.Facility_Program__c;
                selectedBenefit = paw.Insurance_Benefit__c;  
                selectdRateAdjistment = paw.Insurance_Company_Rate_Adjustment__c;
                
                if(paw.FRN_Facility__r.Ownership=='Talbott'){
                    isTalbott = true;
                }                
                pat = new Patient_Insurance__c();
                pat.Id = paw.Patient_Insurance__c;
                pat.Name = paw.Patient_Insurance__r.Name;
                pat.Insurance_Company__c = paw.Patient_Insurance__r.Insurance_Company__c;
                pat.Accepts_Assignment_of_Benefits__c = paw.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c;
                pat.COBRA_Account__c = paw.Patient_Insurance__r.COBRA_Account__c;
                pat.Accreditation__c = paw.Patient_Insurance__r.Accreditation__c;
                if(opportunityId==null || opportunityId==''){
                    pat.Opportunity__c = paw.Patient_Insurance__r.Opportunity__c;
                    opportunityId = paw.Patient_Insurance__r.Opportunity__c;
                }
                System.debug('pat.Id ::>'+pat.Id);              
                
                getBenefit();
                onBenefitChange();
                isFromConstructor = true;
                onFRNFacilitySelected();
                isFromConstructor = false;
                selectdFacilityProgram = paw.Facility_Program__c;
                List<Pay_Agreement_Worksheet_Detail__c> payAgrWrkDetailList = [Select Id, Day__c, Level_of_Care__c, Billed_Rate__c, Insurance_Coverage__c, Beginning_Deductible__c, Applied_Deductible__c, Charge_After_Deductible__c, Beginning_Out_of_Pocket__c, Out_of_Pocket_After_Deductible__c, Calculated_Co_Insurance__c, Co_Insurance__c, Insurance_EIV__c, Patient_Responsibility__c, Insurance_Co_Responsibility__c from Pay_Agreement_Worksheet_Detail__c where Pay_Agreement_Worksheet__c =: pid];
                
                System.debug('AgreementDetaillist ::>'+payAgrWrkDetailList);
                Pay_Agreement_Worksheet_Detail__c payAWD;
                for(Pay_Agreement_Worksheet_Detail__c pawd:payAgrWrkDetailList){
                    payAWD = pawd;
                    payAWD.Id = null;                    
                    AgreementDetaillist.add(payAWD);
                }
                System.debug('LOCValues ::>'+LOCValues);
                If(AgreementDetaillist.size()>0){
                    show = true;
                    totalRowCount = AgreementDetaillist.size();
                }    
                
                saveBtn = false;    
                
            } else {
                /* ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Patient Insurance or Patient Insurance did not selected!');
                ApexPages.addMessage(myMsg); */
            }
        }
        
    }
     public List<SelectOption> getPatient(){ 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '' ,'---Select---'));
        if(opportunityId != null && opportunityId != ''){
            list<Patient_Insurance__c> patlist = new list<Patient_Insurance__c>([Select Id, Name from Patient_Insurance__c where Opportunity__c = : opportunityId]);
            System.debug('ibfMap ----'+ibfMap);            
            for(Patient_Insurance__c Insbenifit : patlist){
                options.add(new SelectOption(Insbenifit.id , Insbenifit.Name));
            }
        }        
        return options;  
    } 
    
    public void onPatientSelected(){
        if(LOCValues.pAWrkSht.Patient_Insurance__c != null){
            pat = [Select Id,Name,Insurance_Company__c,Accepts_Assignment_of_Benefits__c,Accreditation__c,COBRA_Account__c from Patient_Insurance__c where Id =: LOCValues.pAWrkSht.Patient_Insurance__c];
            pat.Name = null;    
            System.debug('patId______________________'+pat.id);         
        } else {
            pat = null;
        }
        ///updateLOCValues();   
        selectedBenefit = null;
        updateLOCValues();
    }
    
    public List<SelectOption> getBenefit(){ 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '' ,'---Select---'));
        if(pat != null){
            ibfMap = new Map<Id,Insurance_Benefit__c>([Select Id, Name, RecordType.Name, Uncovered_Charges__c, Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,Patient_Insurance__r.Opportunity__c,Patient_Insurance__r.Accreditation__c,PHP_Admit_Co_Payment__c,Detox_Admit_Co_Payment__c,RTC_Admit_Co_Payment__c,Deductible__c,Deductible_Met__c,IOP_Admit_Co_Payment__c,Max_Out_of_Pocket_Remaining__c,Insurance_Company_is_Out_of_Network__c,Annual_Max_Remaining__c,Deductible_Remaining__c, Detox_Pays_at__c, Detox_Over__c,RTC_Pays_at__c, Residential_Treatment_Override__c,PHP_Pays_at__c, Partial_Hospitalization_Override__c,IOP_Pays_at__c,Intensive_Outpatient_Override__c,Num_Days_Uncovered__c,Num_Days_Room__c,Uncovered_Days_Rate__c,Room_and_Board_Days_Rate__c,Uncovered_Days_Override__c,Room_and_Board_Days_Override__c,Deductible_Included_in_OOP__c,Uncovered_Days__c,Lifetime_Max__c,Lifetime_Max_Met__c,Annual_Max__c,Annual_Max_Met__c,Max_Out_of_Pocket__c,Max_Out_of_Pocket_Met__c,Co_Pay_Met__c from Insurance_Benefit__c where Patient_Insurance__c = : pat.Id]);
            System.debug('ibfMap ----'+ibfMap);            
            for(Insurance_Benefit__c Insbenifit : ibfMap.values()){
                options.add(new SelectOption(Insbenifit.id , Insbenifit.RecordType.Name+' - '+Insbenifit.name));
            }
        }
        System.debug('selectedBenefit ----'+selectedBenefit);
        if(selectedBenefit!=null && selectedBenefit!=''){
            LOCValues.insBf = ibfMap.get(selectedBenefit);
            //updateLOCValues();
            saveBtn = false;
        } else {
            LOCValues.insBf = null;
        }
        System.debug('LOCValues.insBf ----'+LOCValues.insBf);
        return options;  
    } 
    
    public void onBenefitChange(){  
        System.debug('selectdFRNFacility ::>'+selectdFRNFacility);
        frnFacilities = new List<SelectOption>();       
        frnFacilities.add(new SelectOption('' , '--None--'));
        if(selectedBenefit!=null && selectedBenefit!=''){
            LOCValues.insBf = ibfMap.get(selectedBenefit);
            LOCValues.pAWrkSht.Deductible_Included_in_OOP__c = ibfMap.get(selectedBenefit).Deductible_Included_in_OOP__c;
            
            for(Estimated_Coverage_Days__c est :[Select Id,DTX_Days__c,FRN_Facility__c,FRN_Facility__r.Name,FRN_Facility__r.Ownership,Insurance_Benefit__c,IOP_Days__c,PHP_Days__c,RTC_Days__c,Total_Copay__c FROM Estimated_Coverage_Days__c WHERE Insurance_Benefit__c=:selectedBenefit ORDER BY LastModifiedDate ASC]){
                frnFacilityMap.put(est.FRN_Facility__c,est.FRN_Facility__r.Ownership);
                frnFacilities.add(new SelectOption(est.FRN_Facility__c , est.FRN_Facility__r.Name));
            }           
        } else {
            LOCValues.pAWrkSht.Deductible_Included_in_OOP__c = null;
            LOCValues.insBf = null;
            est = null;
            totalCoPay = 0.00;
        }        
    }           
    
    public void onFRNFacilitySelected()
    { 
        
        
        if(!isFromConstructor) selectdFacilityProgram = selectdRateAdjistment = null;
        System.debug('selectdFacilityProgram ::>'+selectdFacilityProgram);
        facilityProgrammes = new List<SelectOption>(); 
        //List<SelectOption> options = new List<SelectOption>();
        facilityProgrammes.add(new SelectOption( '' ,'---Select---'));
        
        if(selectdFRNFacility!=null && selectdFRNFacility!=''){
            frnFacilityPrgmMap = new Map<Id,Facility_Program__c>([Select Id, Name,Pay_Agreement_Worksheet_Default__c,Total_Room_and_Board__c,Ancillary_Fees__c,Days_60_90_Fees__c, Program_Length__c, Target_EDR__c FROM Facility_Program__c WHERE FRN_Facility__c = : selectdFRNFacility ORDER BY Name ASC]);
            System.debug('frnFacilityPrgmMap----'+frnFacilityPrgmMap);           
            
            for(Facility_Program__c fcp : frnFacilityPrgmMap.values()){             
                facilityProgrammes.add(new SelectOption(fcp.id , fcp.Name));
                if((selectdFacilityProgram==null || selectdFacilityProgram=='') && fcp.Pay_Agreement_Worksheet_Default__c){ 
                    selectdFacilityProgram = fcp.Id;                    
                }
            }
            
            if(selectedBenefit!=null && selectedBenefit!=''){
                List<Estimated_Coverage_Days__c> estList = [Select Id,DTX_Days__c,FRN_Facility__c,Insurance_Benefit__c,IOP_Days__c,PHP_Days__c,RTC_Days__c,Total_Copay__c FROM Estimated_Coverage_Days__c WHERE Insurance_Benefit__c=:selectedBenefit AND FRN_Facility__c=:selectdFRNFacility limit 1];
                if(estList!=null && estList.size()>0){
                    est = estList[0];
                    totalCoPay = (est.Total_Copay__c!=null ? est.Total_Copay__c:0.00);
                }
            } else {
                est = null;
                totalCoPay = 0.00;
            }
        } else {
            est = null;
            totalCoPay = 0.00;
        }
        System.debug('selectdFacilityProgram ::>'+selectdFacilityProgram);
        System.debug('facilityProgrammes ::>'+facilityProgrammes);
        updateLOCValues();
        saveBtn = false;   
        //return options;  
    }
    
    public List<SelectOption> getRateAdjustment(){
        List<SelectOption> rateOption = new List<SelectOption>();
        rateOption.add(new SelectOption('','--None--'));
        if(selectdFRNFacility!=null && selectdFRNFacility!='' && pat!=null){
            icraMap = new Map<Id,Insurance_Company_Rate_Adjustment__c>([Select Id,Name,Type__c,Rate_Adjustment__c,In_Network_Rate_Adjustment__c,Out_of_Network_Rate_Adjustment__c, Active_Date__c, Term_Date__c from Insurance_Company_Rate_Adjustment__c WHERE Insurance_Company__c =:pat.Insurance_Company__c AND FRN_Facility__c=:selectdFRNFacility ORDER BY Type__c DESC]);
            System.debug('icraMap ::>'+icraMap.values());
            for(Insurance_Company_Rate_Adjustment__c icajList:icraMap.values()){
                if(icajList.Type__c!=null && checkIfActive(icajList))
                    rateOption.add(new SelectOption(icajList.Id,icajList.Type__c));
            }           
        }
        return rateOption;
    }
    
    public void updateLOCValues(){
        System.debug('updateLOCValues ::>'+selectedBenefit); 
        System.debug('LOCValues.insBf ::>'+LOCValues.insBf);
        saveBtn = true;   
        LOCValues.pAWrkSht.Rate_Adjustment_Type__c = null;
        if(selectdRateAdjistment!=null && selectdRateAdjistment!='' && icraMap.containsKey(selectdRateAdjistment)){
            LOCValues.pAWrkSht.Rate_Adjustment_Type__c = icraMap.get(selectdRateAdjistment).Type__c;
        }
        System.debug('LOCValues.pAWrkSht.Rate_Adjustment_Type__c ::>'+LOCValues.pAWrkSht.Rate_Adjustment_Type__c);
        if(selectdFRNFacility!=null && selectdFRNFacility!='' && frnFacilityMap.containsKey(selectdFRNFacility) && frnFacilityMap.get(selectdFRNFacility)=='Talbott'){
          isTalbott = true;
        } else {
          isTalbott = false;
        }
        LOCValues.insBf = (selectedBenefit!=null && selectedBenefit!='' ? ibfMap.get(selectedBenefit) : new Insurance_Benefit__c());
        System.debug('LOCValues.insBf ::>'+LOCValues.insBf);
        System.debug('LOCValues.insBf.Num_Days_Uncovered__c ::>'+LOCValues.insBf.Num_Days_Uncovered__c);
        totalRowCount = 0;
        
        if(est!=null){
            if(!isTalbott){
                totalRowCount = Integer.valueOf(est.DTX_Days__c!=null ? totalRowCount+est.DTX_Days__c:totalRowCount);
                totalRowCount = Integer.valueOf(est.RTC_Days__c!=null ? totalRowCount+est.RTC_Days__c:totalRowCount);
            }
            totalRowCount = Integer.valueOf(est.PHP_Days__c!=null ? totalRowCount+est.PHP_Days__c:totalRowCount);
            totalRowCount = Integer.valueOf(est.IOP_Days__c!=null ? totalRowCount+est.IOP_Days__c:totalRowCount);
            System.debug('totalRowCount ::>'+totalRowCount);
        }
        
        totalTalbottDay = 0;
        totalTalbottDay = Integer.valueOf(LOCValues.insBf.Num_Days_Uncovered__c!=null ? totalTalbottDay+LOCValues.insBf.Num_Days_Uncovered__c:totalTalbottDay);
        totalTalbottDay = Integer.valueOf(LOCValues.insBf.Num_Days_Room__c!=null ? totalTalbottDay+LOCValues.insBf.Num_Days_Room__c:totalTalbottDay);
        
        LOCValues.pAWrkSht.Num_Days_Detox_DTX__c = ((est!=null && est.DTX_Days__c!=null) ? est.DTX_Days__c:0);
        LOCValues.pAWrkSht.Detox_Over__c = (LOCValues.insBf.Detox_Over__c!=null ? LOCValues.insBf.Detox_Over__c:0.00);
        LOCValues.pAWrkSht.Detox_Pays_at__c = (LOCValues.insBf.Detox_Pays_at__c!=null ? LOCValues.insBf.Detox_Pays_at__c:0.00);
        System.debug('LOCValues.pAWrkSht.Detox_Over__c ::>'+LOCValues.pAWrkSht.Detox_Over__c);
        
        LOCValues.pAWrkSht.Num_Days_Residential_Treatment_RTC__c = ((est!=null && est.RTC_Days__c!=null) ? est.RTC_Days__c:0);
        LOCValues.pAWrkSht.Residential_Treatment_Override__c = (LOCValues.insBf.Residential_Treatment_Override__c!=null ? LOCValues.insBf.Residential_Treatment_Override__c:0.00);
        LOCValues.pAWrkSht.RTC_Pays_at__c = (LOCValues.insBf.RTC_Pays_at__c!=null ? LOCValues.insBf.RTC_Pays_at__c:0.00);
                    
        LOCValues.pAWrkSht.Num_Days_Partial_Hospitalization_PHP__c = ((est!=null && est.PHP_Days__c!=null)? est.PHP_Days__c:0);
        LOCValues.pAWrkSht.Partial_Hospitalization_Override__c = (LOCValues.insBf.Partial_Hospitalization_Override__c!=null ? LOCValues.insBf.Partial_Hospitalization_Override__c:0.00);
        LOCValues.pAWrkSht.PHP_Pays_at__c = (LOCValues.insBf.PHP_Pays_at__c!=null ? LOCValues.insBf.PHP_Pays_at__c:0.00);
        
        LOCValues.pAWrkSht.Num_Days_Intensive_Outpatient_IOP__c = ((est!=null && est.IOP_Days__c!=null) ? est.IOP_Days__c:0); 
        LOCValues.pAWrkSht.Intensive_Outpatient_Override__c = (LOCValues.insBf.Intensive_Outpatient_Override__c!=null ? LOCValues.insBf.Intensive_Outpatient_Override__c:0.00);
        LOCValues.pAWrkSht.IOP_Pays_at__c = (LOCValues.insBf.IOP_Pays_at__c!=null ? LOCValues.insBf.IOP_Pays_at__c:0.00);
        System.debug('LOCValues ::>'+LOCValues); 
        
        
        LOCValues.pAWrkSht.Num_Days_Uncovered__c  = (LOCValues.insBf.Uncovered_Days__c!=null)? LOCValues.insBf.Uncovered_Days__c:0;
        LOCValues.pAWrkSht.Uncovered_Days_Rate__c  = (LOCValues.insBf.Uncovered_Days_Rate__c!=null) ? LOCValues.insBf.Uncovered_Days_Rate__c:0;
        LOCValues.pAWrkSht.Uncovered_Days_Override__c  = (LOCValues.insBf.Uncovered_Days_Override__c!=null) ? LOCValues.insBf.Uncovered_Days_Override__c:0;
        LOCValues.pAWrkSht.Num_Days_Room__c  = (LOCValues.insBf.Num_Days_Room__c!=null) ? LOCValues.insBf.Num_Days_Room__c:0;
        if(isTalbott && selectdFacilityProgram!=null && selectdFacilityProgram!='' && frnFacilityPrgmMap.containsKey(selectdFacilityProgram)){
            LOCValues.pAWrkSht.Room_and_Board_Days_Rate__c = frnFacilityPrgmMap.get(selectdFacilityProgram).Total_Room_and_Board__c;                    
        } else {
            LOCValues.pAWrkSht.Room_and_Board_Days_Rate__c  = (LOCValues.insBf.Room_and_Board_Days_Rate__c!=null) ? LOCValues.insBf.Room_and_Board_Days_Rate__c:0;
        }        
        LOCValues.pAWrkSht.Room_and_Board_Days_Override__c  = (LOCValues.insBf.Room_and_Board_Days_Override__c!=null) ? LOCValues.insBf.Room_and_Board_Days_Override__c:0;
        
        System.debug('selectdFRNFacility ::>'+selectdFRNFacility);
        System.debug('LOCValues.pAWrkSht.Num_Days_Uncovered__c ::>'+LOCValues.pAWrkSht.Num_Days_Uncovered__c);
        System.debug('LOCValues.insBf.Num_Days_Uncovered__c ::>'+LOCValues.insBf.Num_Days_Uncovered__c);
        System.debug('LOCValues.pAWrkSht.Uncovered_Days_Rate__c ::>'+LOCValues.pAWrkSht.Uncovered_Days_Rate__c);
        System.debug('frnFacilityPrgmMap.containsKey(selectdFacilityProgram) ::>'+frnFacilityPrgmMap.containsKey(selectdFacilityProgram));
        if(selectdFRNFacility!=null && selectdFRNFacility!='' && selectdFacilityProgram!=null && selectdFacilityProgram!='' && frnFacilityPrgmMap.containsKey(selectdFacilityProgram)){
            if(!isTalbott){
                LOCValues.pAWrkSht.Ancillary_Fees__c = frnFacilityPrgmMap.get(selectdFacilityProgram).Ancillary_Fees__c;
                if(LOCValues.pAWrkSht.Ancillary_Fees__c==null)
                    LOCValues.pAWrkSht.Ancillary_Fees__c = 0.00;
            } else {
                LOCValues.pAWrkSht.Days_60_90_Fees__c = frnFacilityPrgmMap.get(selectdFacilityProgram).Days_60_90_Fees__c;
                if(LOCValues.pAWrkSht.Days_60_90_Fees__c==null){
                    LOCValues.pAWrkSht.Days_60_90_Fees__c = 0.00;
                }
                // added for defect #47
                LOCValues.pAWrkSht.Ancillary_Fees__c = frnFacilityPrgmMap.get(selectdFacilityProgram).Ancillary_Fees__c;
                if(LOCValues.pAWrkSht.Ancillary_Fees__c==null)
                    LOCValues.pAWrkSht.Ancillary_Fees__c = 0.00;
            }            
        } else {
            LOCValues.pAWrkSht.Ancillary_Fees__c = 0.00;
            LOCValues.pAWrkSht.Days_60_90_Fees__c = 0.00;
        }
        if(selectedBenefit!=null && ibfMap.containsKey(selectedBenefit)){
            if(LOCValues.pAWrkSht.Uncovered_Charges__c==null && LOCValues.pAWrkSht.Id==null){
                LOCValues.pAWrkSht.Uncovered_Charges__c = ibfMap.get(selectedBenefit).Uncovered_Charges__c;
            }
            decimal coPayRemaining = 0.00;
            if(ibfMap.get(selectedBenefit).Detox_Admit_Co_Payment__c!=null)
                coPayRemaining = LOCValues.pAWrkSht.Num_Days_Detox_DTX__c * ibfMap.get(selectedBenefit).Detox_Admit_Co_Payment__c;
            if(ibfMap.get(selectedBenefit).RTC_Admit_Co_Payment__c!=null)
                coPayRemaining = coPayRemaining + (LOCValues.pAWrkSht.Num_Days_Residential_Treatment_RTC__c * ibfMap.get(selectedBenefit).RTC_Admit_Co_Payment__c);
            if(ibfMap.get(selectedBenefit).PHP_Admit_Co_Payment__c!=null)
                coPayRemaining = coPayRemaining + (LOCValues.pAWrkSht.Num_Days_Partial_Hospitalization_PHP__c * ibfMap.get(selectedBenefit).PHP_Admit_Co_Payment__c);
            if(ibfMap.get(selectedBenefit).IOP_Admit_Co_Payment__c!=null)
                coPayRemaining = coPayRemaining + (LOCValues.pAWrkSht.Num_Days_Intensive_Outpatient_IOP__c * ibfMap.get(selectedBenefit).IOP_Admit_Co_Payment__c);
            if(coPayRemaining!=null) LOCValues.pAWrkSht.Co_Pay_Remaining__c = (coPayRemaining).setScale(2);
        } else {
            LOCValues.pAWrkSht.Co_Pay_Remaining__c = 0.00;
        }
    }
    
    public void updateDetail(){
        
        if(frnFacilityPrgmMap.containskey(selectdFacilityProgram))
        {
            targetEDR = frnFacilityPrgmMap.get(selectdFacilityProgram).Target_EDR__c;
        }
        
        try{
            show = false;
            saveBtn = false;
            decimal totalInsEIV = 0.00;
            totalInsCoResp = 0.00;
            decimal totalAppliedDeductible = 0.00;
            decimal totalCoInsurance = 0.00;
            decimal totalCoPayAmt = (LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c == null? 0.00 : LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c); 
            AgreementDetaillist = new List<Pay_Agreement_Worksheet_Detail__c>();
            Pay_Agreement_Worksheet_Detail__c pawdtx;
            
            System.debug('pat.Insurance_Company__c :::>'+pat.Insurance_Company__c);
            System.debug('selectdFRNFacility :::>'+selectdFRNFacility);
            System.debug('selectdFacilityProgram ::>'+selectdFacilityProgram);
            System.debug('facilityProgrammes ::>'+facilityProgrammes);
            System.debug('LOCValues.insBf.Uncovered_Charges__c ::>'+LOCValues.insBf.Uncovered_Charges__c);
        
            LOCValues.pAWrkSht.Insurance_Company_Rate_Adjustment__c = selectdRateAdjistment;
            LOCValues.dtxRate = null;
            LOCValues.iopRate = null;
            LOCValues.rtcRate = null;
            LOCValues.phpRate = null;
            //For DTX 
            getBilledRate();
            integer loopEndValue = 0;
            if(!isTalbott){
                loopEndValue = ((est!=null && est.DTX_Days__c!=null) ? Integer.valueOf(est.DTX_Days__c) : 0);
                for(Integer i=0;i<loopEndValue ; i++){
                    pawdtx = new Pay_Agreement_Worksheet_Detail__c();
                    pawdtx.Level_of_Care__c = 'Detox (DTX)';
                    System.debug('pawdtx.Billed_Rate__c ::>'+pawdtx.Billed_Rate__c);
                    System.debug('LOCValues.dtxRate ::>'+LOCValues.dtxRate);
                    if(LOCValues.pAWrkSht.Detox_Over__c==0 || LOCValues.pAWrkSht.Detox_Over__c==null){               
                        pawdtx.Billed_Rate__c = LOCValues.dtxRate;
                    } else {
                        pawdtx.Billed_Rate__c = LOCValues.pAWrkSht.Detox_Over__c;
                    }
                    pawdtx.Insurance_Coverage__c = LOCValues.pAWrkSht.Detox_Pays_at__c;
                    System.debug('LOCValues.pAWrkSht.Detox_Pays_at__c ::>'+LOCValues.pAWrkSht.Detox_Pays_at__c);
                    System.debug('pawdtx.Insurance_Coverage__c ::>'+pawdtx.Insurance_Coverage__c);
                    pawdtx.Beginning_Deductible__c  = 0.00;
                    if(AgreementDetaillist.size()==0){
                        if(selectedBenefit!=null && selectedBenefit!=''){
                            // decimal detoxAdmit = (ibfMap.get(selectedBenefit).Detox_Admit_Co_Payment__c!=null) ? ibfMap.get(selectedBenefit).Detox_Admit_Co_Payment__c : 0.00;                          
                            pawdtx.Beginning_Deductible__c = ibfMap.get(selectedBenefit).Deductible_Remaining__c + totalCoPay;
                        }
                    } 

                    pawdtx = updatePAWD(pawdtx);
                    totalInsEIV = totalInsEIV+pawdtx.Insurance_EIV__c;
                    if((selectedBenefit!=null && selectedBenefit!='') && (totalInsEIV > ibfMap.get(selectedBenefit).Annual_Max_Remaining__c)){
                        pawdtx.Insurance_Co_Responsibility__c = ibfMap.get(selectedBenefit).Annual_Max_Remaining__c - totalInsCoResp;
                    } else {
                        pawdtx.Insurance_Co_Responsibility__c = pawdtx.Insurance_EIV__c;
                    }
                    totalInsCoResp = totalInsCoResp+pawdtx.Insurance_Co_Responsibility__c;    
                    totalAppliedDeductible += pawdtx.Applied_Deductible__c;
                    totalCoInsurance += pawdtx.Co_Insurance__c;
                    AgreementDetaillist.add(pawdtx);
                }
                
                loopEndValue = ((est!=null && est.RTC_Days__c!=null) ? Integer.valueOf(est.RTC_Days__c) : 0);
                for(Integer i=0;i<loopEndValue ; i++){
                    pawdtx = new Pay_Agreement_Worksheet_Detail__c();
                    pawdtx.Level_of_Care__c = 'Residential Treatment (RTC)';
                    if(LOCValues.pAWrkSht.Residential_Treatment_Override__c==0.00 || LOCValues.pAWrkSht.Residential_Treatment_Override__c==null){               
                        pawdtx.Billed_Rate__c = LOCValues.rtcRate;
                    } else {
                        pawdtx.Billed_Rate__c = LOCValues.pAWrkSht.Residential_Treatment_Override__c;
                    }
                    pawdtx.Insurance_Coverage__c = LOCValues.pAWrkSht.RTC_Pays_at__c;
                    
                    pawdtx.Beginning_Deductible__c = 0.00;
                    if(AgreementDetaillist.size()==0){
                        if(selectedBenefit!=null && selectedBenefit!=''){
                            // decimal rtcAdmit = (ibfMap.get(selectedBenefit).RTC_Admit_Co_Payment__c!=null) ? ibfMap.get(selectedBenefit).RTC_Admit_Co_Payment__c:0.00;
                            pawdtx.Beginning_Deductible__c = ibfMap.get(selectedBenefit).Deductible_Remaining__c + totalCoPay;
                        }
                    }
                    pawdtx = updatePAWD(pawdtx);
                    totalInsEIV = totalInsEIV+pawdtx.Insurance_EIV__c;
                    if((selectedBenefit!=null && selectedBenefit!='') && (totalInsEIV > ibfMap.get(selectedBenefit).Annual_Max_Remaining__c)){
                        pawdtx.Insurance_Co_Responsibility__c = ibfMap.get(selectedBenefit).Annual_Max_Remaining__c - totalInsCoResp;
                    } else {
                        pawdtx.Insurance_Co_Responsibility__c = pawdtx.Insurance_EIV__c;
                    }
                    totalInsCoResp = totalInsCoResp+pawdtx.Insurance_Co_Responsibility__c; 
                    totalAppliedDeductible += pawdtx.Applied_Deductible__c;
                    totalCoInsurance += pawdtx.Co_Insurance__c;
                    AgreementDetaillist.add(pawdtx);
                }
            }
            
            loopEndValue = ((est!=null && est.PHP_Days__c!=null) ? Integer.valueOf(est.PHP_Days__c) : 0);
            for(Integer i=0;i<loopEndValue ; i++){
                pawdtx = new Pay_Agreement_Worksheet_Detail__c();
                pawdtx.Level_of_Care__c = 'Partial hospitalization (PHP)';
                if(LOCValues.pAWrkSht.Partial_Hospitalization_Override__c==0.00 || LOCValues.pAWrkSht.Partial_Hospitalization_Override__c==null){               
                    pawdtx.Billed_Rate__c = LOCValues.phpRate;
                } else {
                    pawdtx.Billed_Rate__c = LOCValues.pAWrkSht.Partial_Hospitalization_Override__c;
                }
                pawdtx.Insurance_Coverage__c = LOCValues.pAWrkSht.PHP_Pays_at__c;
                
                pawdtx.Beginning_Deductible__c = 0.00;
                if(AgreementDetaillist.size()==0){
                    if(selectedBenefit!=null && selectedBenefit!=''){
                        // decimal phpAdmit = (ibfMap.get(selectedBenefit).PHP_Admit_Co_Payment__c!=null) ? ibfMap.get(selectedBenefit).PHP_Admit_Co_Payment__c : 0.00;
                        pawdtx.Beginning_Deductible__c = ibfMap.get(selectedBenefit).Deductible_Remaining__c + totalCoPay;
                    } 
                }
                pawdtx = updatePAWD(pawdtx);
                totalInsEIV = totalInsEIV+pawdtx.Insurance_EIV__c;
                if((selectedBenefit!=null && selectedBenefit!='') && (totalInsEIV > ibfMap.get(selectedBenefit).Annual_Max_Remaining__c)){
                    pawdtx.Insurance_Co_Responsibility__c = ibfMap.get(selectedBenefit).Annual_Max_Remaining__c - totalInsCoResp;
                } else {
                    pawdtx.Insurance_Co_Responsibility__c = pawdtx.Insurance_EIV__c;
                }
                totalInsCoResp = totalInsCoResp+pawdtx.Insurance_Co_Responsibility__c;  
                totalAppliedDeductible += pawdtx.Applied_Deductible__c;
                totalCoInsurance += pawdtx.Co_Insurance__c;
                AgreementDetaillist.add(pawdtx);
            }
            
            loopEndValue = ((est!=null && est.IOP_Days__c!=null) ? Integer.valueOf(est.IOP_Days__c) : 0);
            for(Integer i=0;i<loopEndValue ; i++){
                pawdtx = new Pay_Agreement_Worksheet_Detail__c();
                pawdtx.Level_of_Care__c = 'Intensive Outpatient (IOP)';
                if(LOCValues.pAWrkSht.Intensive_Outpatient_Override__c==0.00 || LOCValues.pAWrkSht.Intensive_Outpatient_Override__c==null){               
                    pawdtx.Billed_Rate__c = LOCValues.iopRate;
                } else {
                    pawdtx.Billed_Rate__c = LOCValues.pAWrkSht.Intensive_Outpatient_Override__c;
                }
                pawdtx.Insurance_Coverage__c = LOCValues.pAWrkSht.IOP_Pays_at__c;
                
                pawdtx.Beginning_Deductible__c = 0.00;
                if(AgreementDetaillist.size()==0){
                    if(selectedBenefit!=null && selectedBenefit!=''){
                        // decimal iopAdmit = (ibfMap.get(selectedBenefit).IOP_Admit_Co_Payment__c!=null) ? ibfMap.get(selectedBenefit).IOP_Admit_Co_Payment__c : 0.00;
                        pawdtx.Beginning_Deductible__c = ibfMap.get(selectedBenefit).Deductible_Remaining__c + totalCoPay;
                    } 
                }
                
                pawdtx = updatePAWD(pawdtx);
                totalInsEIV = totalInsEIV+pawdtx.Insurance_EIV__c;
                if((selectedBenefit!=null && selectedBenefit!='') && (totalInsEIV > ibfMap.get(selectedBenefit).Annual_Max_Remaining__c)){
                    pawdtx.Insurance_Co_Responsibility__c = ibfMap.get(selectedBenefit).Annual_Max_Remaining__c - totalInsCoResp;
                } else {
                    pawdtx.Insurance_Co_Responsibility__c = pawdtx.Insurance_EIV__c;
                }
                totalInsCoResp = totalInsCoResp+pawdtx.Insurance_Co_Responsibility__c; 
                totalAppliedDeductible += pawdtx.Applied_Deductible__c;
                totalCoInsurance += pawdtx.Co_Insurance__c;
                AgreementDetaillist.add(pawdtx);
            }
            
            //AgreementDetaillist = pawDtxList;
            if(AgreementDetaillist.size()>0){
                show = true;
            }
            calculateFormula();
            LOCValues.pAWrkSht.Plan_Coverage__c = totalAppliedDeductible+totalCoInsurance; 
            if(LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c==null){
                LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c = 0;
            }if(LOCValues.pAWrkSht.Deductible_Amount_Requested__c==null){
                LOCValues.pAWrkSht.Deductible_Amount_Requested__c = 0;
            }
            system.debug('>>> after caluclate in update ; ');
            if(LOCValues.pAWrkSht.Plan_Coverage__c<(LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c+LOCValues.pAWrkSht.Deductible_Amount_Requested__c+totalCoPayAmt)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sum of Co-Insurance, Deductible Amount Requested and Co-pay Amount Requested exceeds Plan Coverage');
                ApexPages.addMessage(myMsg);
                system.debug('>>> msg1');
            }
            if(selectedBenefit!=null && selectedBenefit!=''){ 
                if(LOCValues.pAWrkSht.Deductible_Amount_Requested__c>ibfMap.get(selectedBenefit).Deductible_Remaining__c) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Deductible Amount Requested exceeds Deductible Remaining');
                    ApexPages.addMessage(myMsg);
                    system.debug('>>> msg2');
                }
            }
            if(LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c > totalCoPay) {        
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Pay Amount Requested exceeds Total Co-Pay Amount');        
                    ApexPages.addMessage(myMsg);
                    system.debug('>>> msg3');
            }
            System.debug('totalInsCoResp ::>'+totalInsCoResp);
        }catch(Exception e){
            System.debug('Exception while creating rows ::>'+e.getMessage());            
        }
            
        
        System.debug('saveBtn ::>'+saveBtn);
    }
    
    public void desableSaveButton(){
        saveBtn = true;
    }
    
    public Pay_Agreement_Worksheet_Detail__c updatePAWD(Pay_Agreement_Worksheet_Detail__c pawdtx){
        try{
            if(AgreementDetaillist.size()>1000){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Too many rows to process');
                ApexPages.addMessage(myMsg);
                return pawdtx;
            }
            if(pawdtx.Billed_Rate__c==null){
                pawdtx.Billed_Rate__c = 0.00;
            }        
            if(pawdtx.Insurance_Coverage__c==null){
                pawdtx.Insurance_Coverage__c = 0.00;
            }
            if(AgreementDetaillist.size()>0){
                Pay_Agreement_Worksheet_Detail__c prevPaAWD = AgreementDetaillist[AgreementDetaillist.size()-1];
                pawdtx.Beginning_Deductible__c = ((prevPaAWD.Beginning_Deductible__c-prevPaAWD.Applied_Deductible__c)>0 ? prevPaAWD.Beginning_Deductible__c-prevPaAWD.Applied_Deductible__c : 0.00);
            }
                    
            if(pawdtx.Billed_Rate__c<=pawdtx.Beginning_Deductible__c){
                pawdtx.Applied_Deductible__c = pawdtx.Billed_Rate__c;
            } else{
                pawdtx.Applied_Deductible__c = pawdtx.Beginning_Deductible__c;
            }
            pawdtx.Charge_After_Deductible__c = pawdtx.Billed_Rate__c - pawdtx.Applied_Deductible__c;
            if(AgreementDetaillist.size()==0){
                if(selectedBenefit!=null && selectedBenefit!=''){
                    pawdtx.Beginning_Out_of_Pocket__c = ibfMap.get(selectedBenefit).Max_Out_of_Pocket_Remaining__c;
                }
            } else {
                Pay_Agreement_Worksheet_Detail__c prevPaAWD = AgreementDetaillist[AgreementDetaillist.size()-1];
                pawdtx.Beginning_Out_of_Pocket__c = prevPaAWD.Out_of_Pocket_After_Deductible__c-prevPaAWD.Co_Insurance__c;
            }
            if(pawdtx.Beginning_Out_of_Pocket__c==null) {
                pawdtx.Beginning_Out_of_Pocket__c = 0.00;
            }
             if(selectedBenefit!=null && selectedBenefit!='' && ibfMap.get(selectedBenefit).Deductible_Included_in_OOP__c=='Yes'){              
                pawdtx.Out_of_Pocket_After_Deductible__c = pawdtx.Beginning_Out_of_Pocket__c - pawdtx.Applied_Deductible__c;
            } else {
                pawdtx.Out_of_Pocket_After_Deductible__c = pawdtx.Beginning_Out_of_Pocket__c;
            }
                    
            pawdtx.Calculated_Co_Insurance__c = ((1 - (pawdtx.Insurance_Coverage__c!=0.00 ? (pawdtx.Insurance_Coverage__c/100):0.00)) * pawdtx.Charge_After_Deductible__c).setScale(2);
            
            if((pawdtx.Charge_After_Deductible__c *(1-(pawdtx.Insurance_Coverage__c!=0.00 ? (pawdtx.Insurance_Coverage__c/100):0.00)))<= pawdtx.Out_of_Pocket_After_Deductible__c){
                pawdtx.Co_Insurance__c = (pawdtx.Charge_After_Deductible__c *(1-(pawdtx.Insurance_Coverage__c!=0.00 ? (pawdtx.Insurance_Coverage__c/100):0.00))).setScale(2);         
            } else {
                pawdtx.Co_Insurance__c = pawdtx.Out_of_Pocket_After_Deductible__c;
            }
            if(selectdRateAdjistment!=null && selectdRateAdjistment!='' && icraMap.containsKey(selectdRateAdjistment)){
                System.debug('rate adjust ::>'+icraMap.get(selectdRateAdjistment).Rate_Adjustment__c);
                decimal rateAdust = icraMap.get(selectdRateAdjistment).Rate_Adjustment__c;
                decimal outRate = ((rateAdust!=null && rateAdust!=0) ? (rateAdust/100):0.00);
                System.debug('outRate ::>'+outRate);
                pawdtx.Insurance_EIV__c = ((pawdtx.Charge_After_Deductible__c - pawdtx.Co_Insurance__c) * (1- outRate)).setScale(2);
                    
                /* if(selectedBenefit!=null && selectedBenefit!='' && ibfMap.get(selectedBenefit).Insurance_Company_is_Out_of_Network__c){
                    decimal outRate = ((icajList[0].Out_of_Network_Rate_Adjustment__c!=null && icajList[0].Out_of_Network_Rate_Adjustment__c!=0) ? (icajList[0].Out_of_Network_Rate_Adjustment__c/100):0.00);
                    pawdtx.Insurance_EIV__c = ((pawdtx.Charge_After_Deductible__c - pawdtx.Co_Insurance__c) * (1- outRate)).setScale(2);
                } else {
                    decimal inRate = ((icajList[0].In_Network_Rate_Adjustment__c!=null && icajList[0].In_Network_Rate_Adjustment__c!=0) ? (icajList[0].In_Network_Rate_Adjustment__c/100):0.00);
                    pawdtx.Insurance_EIV__c = ((pawdtx.Charge_After_Deductible__c - pawdtx.Co_Insurance__c) * (1- inRate)).setScale(2);
                } */
            }
            if(pawdtx.Insurance_EIV__c==null)
                pawdtx.Insurance_EIV__c = 0.00;
            pawdtx.Patient_Responsibility__c = pawdtx.Applied_Deductible__c + pawdtx.Co_Insurance__c;   
            
        }catch(Exception e){
            System.debug('Exception while creating rows ::>'+e.getMessage());           
        }
        return pawdtx;
    }
    
    public void getBilledRate(){
        System.debug('LOCValues.dtxRate ::>'+LOCValues.dtxRate);
        if(selectdFacilityProgram!=null && selectdFacilityProgram!=''){
            Id fpLOCRTIdDTX = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Detox (DTX)').getRecordTypeId();
            Id fpLOCRTIdRTC = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Residential Treatment (RTC)').getRecordTypeId();
            Id fpLOCRTIdPHP = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Partial Hospitalization (PHP)').getRecordTypeId();
            Id fpLOCRTIdIOP = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Intensive Outpatient (IOP)').getRecordTypeId();
            
            List<Facility_Program_Level_of_Care__c> fPLOCList = [Select Id,Billing_Rate__c,Facility_Program__c,isDefault__c,Insurance_Company__c,RecordTypeId from Facility_Program_Level_of_Care__c WHERE Facility_Program__c =:selectdFacilityProgram AND (Insurance_Company__c =: pat.Insurance_Company__c OR isDefault__c = true) ORDER BY LastModifiedDate DESC];            
            
            Facility_Program_Level_of_Care__c defaultDTXFPLOC;
            Facility_Program_Level_of_Care__c defaultRTCFPLOC;
            Facility_Program_Level_of_Care__c defaultPHPFPLOC;
            Facility_Program_Level_of_Care__c defaultIOPFPLOC;
            for(Facility_Program_Level_of_Care__c fpLoc:fPLOCList){
                if(fpLoc.RecordTypeId==fpLOCRTIdDTX && LOCValues.dtxRate==null && fpLoc.Insurance_Company__c==pat.Insurance_Company__c){
                    LOCValues.dtxRate = fpLoc.Billing_Rate__c;
                } else if(fpLoc.RecordTypeId==fpLOCRTIdRTC && LOCValues.rtcRate==null  && fpLoc.Insurance_Company__c==pat.Insurance_Company__c){
                    LOCValues.rtcRate = fpLoc.Billing_Rate__c;
                } else if(fpLoc.RecordTypeId==fpLOCRTIdPHP && LOCValues.phpRate==null  && fpLoc.Insurance_Company__c==pat.Insurance_Company__c){
                    LOCValues.phpRate = fpLoc.Billing_Rate__c;
                } else if(fpLoc.RecordTypeId==fpLOCRTIdIOP && LOCValues.iopRate==null  && fpLoc.Insurance_Company__c==pat.Insurance_Company__c){
                    LOCValues.iopRate = fpLoc.Billing_Rate__c;
                } else if(defaultDTXFPLOC==null && fpLoc.isDefault__c==true && fpLoc.RecordTypeId==fpLOCRTIdDTX){
                    defaultDTXFPLOC = fpLoc;
                } else if(defaultRTCFPLOC==null && fpLoc.isDefault__c==true && fpLoc.RecordTypeId==fpLOCRTIdRTC){
                    defaultRTCFPLOC = fpLoc;
                } else if(defaultPHPFPLOC==null && fpLoc.isDefault__c==true && fpLoc.RecordTypeId==fpLOCRTIdPHP){
                    defaultPHPFPLOC = fpLoc;
                } else if(defaultIOPFPLOC==null && fpLoc.isDefault__c==true && fpLoc.RecordTypeId==fpLOCRTIdIOP){
                    defaultIOPFPLOC = fpLoc;
                }
            }           
            
            if(LOCValues.dtxRate==null && defaultDTXFPLOC!=null)
                LOCValues.dtxRate = defaultDTXFPLOC.Billing_Rate__c;
            if(LOCValues.rtcRate==null && defaultRTCFPLOC!=null)
                LOCValues.rtcRate = defaultRTCFPLOC.Billing_Rate__c;
            if(LOCValues.phpRate==null && defaultPHPFPLOC!=null)
                LOCValues.phpRate = defaultPHPFPLOC.Billing_Rate__c;
            if(LOCValues.iopRate==null && defaultIOPFPLOC!=null)
                LOCValues.iopRate = defaultIOPFPLOC.Billing_Rate__c;    
                            
        }       
    }
    
    public PageReference saveDetail(){
        System.debug('saveDetail ::>');
        if(AgreementDetaillist.size()>1000){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Too many rows to process');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c==null){
            LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c = 0;
        }if(LOCValues.pAWrkSht.Deductible_Amount_Requested__c==null){
            LOCValues.pAWrkSht.Deductible_Amount_Requested__c = 0;
        }if(LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c==null){
            LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c = 0;
        }
        if(LOCValues.pAWrkSht.Plan_Coverage__c<(LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c+LOCValues.pAWrkSht.Deductible_Amount_Requested__c)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Insurance and Deductible Amount Requested exceeds Plan Coverage');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(selectedBenefit!=null && selectedBenefit!=''){ 
            if(LOCValues.pAWrkSht.Deductible_Amount_Requested__c>ibfMap.get(selectedBenefit).Deductible_Remaining__c) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Deductible Amount Requested exceeds Deductible Remaining');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        if(LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c > totalCoPay) {        
	        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Co-Pay Amount Requested exceeds Total Co-Pay Amount');        
	        ApexPages.addMessage(myMsg);        
        }
        List<Pay_Agreement_Worksheet_Detail__c> pawDtxList = new List<Pay_Agreement_Worksheet_Detail__c>();
        System.debug('selectedBenefit....>>'+selectedBenefit);
        
        Pay_Agreement_Worksheet__c paw = LOCValues.pAWrkSht;
        
        paw.Insurance_Benefit__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? selectedBenefit:null;
        paw.Deductible__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Deductible__c :0.00;
        paw.Deductible_Met__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Deductible_Met__c :0.00;
        paw.Lifetime_Max__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Lifetime_Max__c :0.00;
        paw.Lifetime_Max_Used__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Lifetime_Max_Met__c :0.00;
        paw.Annual_Max__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Annual_Max__c :0.00;
        paw.Annual_Max_Used__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Annual_Max_Met__c :0.00;
        
        paw.Co_Pay_Met__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Co_Pay_Met__c :0.00;
        paw.Out_of_Pocket_Max__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Max_Out_of_Pocket__c :0.00;
        paw.Out_of_Pocket_Max_Met__c = (selectedBenefit != null && selectedBenefit != '' && selectedBenefit.length() >0) ? ibfMap.get(selectedBenefit).Max_Out_of_Pocket_Met__c :0.00;
        
        if(opportunityId != null && opportunityId != ''){
            paw.Opportunity__c = opportunityId;
        }
        //paw.Id = null;
        System.debug('paw: '+paw);
        System.debug('Pat: '+Pat);
        
        if(Pat!=null)
            paw.Patient_Insurance__c = Pat.Id;
    
        paw.Facility_Program__c = selectdFacilityProgram;
        paw.FRN_Facility__c = selectdFRNFacility;
        if(Clone=='Clone'){
            paw.Id=null;         
        }   
        try{
            if(paw.Opportunity__c!=null && paw.Id==null){
                Opportunity pawOpp = [Select Id,StageName from Opportunity WHERE Id=:paw.Opportunity__c];
                Set<Id> vobProfileId = new Set<Id>();
                for(Profile prf:[SELECT Id FROM Profile WHERE Name Like 'FRN - Verification of Benefits (VOB)%']){
                    vobProfileId.add(prf.Id);
                }
                if(pawOpp.StageName == 'Determination Complete' && vobProfileId.contains(Userinfo.getProfileId())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can not create new record as the Opportunity stage is set to Determination Complete.'));
                    return null;
                }
            }
            
            if(quotoId != null && Clone=='Clone'){
                System.debug('inside if');
                Quote quo = [SELECT Id,Status__c,OpportunityId FROM Quote where Id =:quotoId];
                Opportunity oppObj = [Select id,StageName from Opportunity where Id=:quo.OpportunityId];
                Opportunity opp = new Opportunity();
                opp.Id=oppObj.Id;
                opp.StageName = 'Counter Offer Requested';
                update opp;
                
                List<Pay_Agreement_Worksheet__c> pawList = new List<Pay_Agreement_Worksheet__c>();
                List<Quote> estimateList = new List<Quote>();
                
                if(quotoId != null){
                    String pawid;
                    List<Quote> e =[SELECT Id,Status__c,Pay_Agreement_Worksheet__c,OpportunityId FROM Quote where Id =:quotoId And Pay_Agreement_Worksheet__c != null];
                    if(e.size()>0){
                       pawid = e[0].Pay_Agreement_Worksheet__c; 
                      }
                    for(Pay_Agreement_Worksheet__c p:[SELECT Id,Status__c,Opportunity__c  FROM Pay_Agreement_Worksheet__c where Id =:pawid]){
                       Pay_Agreement_Worksheet__c paw1 = new Pay_Agreement_Worksheet__c();
                       paw1.Id = p.Id;
                       paw1.Status__c = 'Cancelled';
                       pawList.add(paw1);
                    }
                      
                    for(Quote QE : [SELECT Id,Status__c,Pay_Agreement_Worksheet__c from Quote where Pay_Agreement_Worksheet__c In:pawList]){
                       Quote est = new Quote();
                       est.Id = QE.Id;
                       est.Status__c = 'Cancelled';
                       estimateList.add(est);
                    }

                      if(pawList.size() > 0){
                       update pawList;
                      }
                      
                      if(estimateList.size() > 0){
                      update estimateList;
                      } 
                     }  
                
            }
            if(paw.Id==null){
                paw.Status__c = 'Open';
            }
            upsert paw;
            
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        
        
        Schema.DescribeSObjectResult piSchema = Patient_Insurance__c.sObjectType.getDescribe();
        String piKeyPrefix = piSchema.getKeyPrefix();
        if(!pid.startsWith(piKeyPrefix)){
            pid = paw.Id;   
        }
        
        for(Pay_Agreement_Worksheet_Detail__c pawd:AgreementDetaillist){
            pawd.Pay_Agreement_Worksheet__c = paw.id;
            pawDtxList.add(pawd);
        }
        
        //To delete old Pay_Agreement_Worksheet_Detail__c records
        if(paw.Id!=null){
            delete [Select Id from Pay_Agreement_Worksheet_Detail__c WHERE Pay_Agreement_Worksheet__c =:paw.Id];
        }
        
        if(pawDtxList.size()>0){
            insert pawDtxList;
        }
        
        if(isFromInsBef){
            pid = selectedBenefit;
        }
        PageReference orderPage;
        if(retUrl!=null && retUrl.contains('CreateOpportunity')){
            orderPage = new PageReference('/apex/CreateOpportunity?id='+paw.Opportunity__c);
        } else {
            orderPage = new PageReference('/'+paw.id);
        }        
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    public PageReference cancelFromOpp(){
        PageReference orderPage = new PageReference('/apex/CreateOpportunity?id='+opportunityId);
        orderPage.setRedirect(true);
        return orderPage;
    }
    public PageReference cancel(){
        string redirtc='';
        if(quotoId != null && quotoId != ''){
            redirtc= quotoId;
        }else if(isFromInsBef){
            redirtc = selectedBenefit;
        }
        else{
            redirtc=pid;
        }
        
        PageReference orderPage = new PageReference('/'+redirtc);
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    public void calculateFormula(){
           system.debug('>>> in calculate');
        decimal TotalInsuranceCoResponsibility = 0.00 ;
        Integer TotalWorksheetDetail = 0;
        LOCValues.pAWrkSht.Total_Patient_Contribution__c = 0.00;
        LOCValues.pAWrkSht.Total_Revenue__c = 0.00;
        LOCValues.pAWrkSht.Daily_Revenue__c = 0.00;
        decimal revenue = 0.00;
        decimal daysRate = 0.00;
        decimal privatePayFee = (LOCValues.pAWrkSht.Private_Pay__c !=null) ? LOCValues.pAWrkSht.Private_Pay__c : 0.00;
        decimal coPayAmtRequested = (LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c : 0.00;
        
        // added to get program length
        Decimal prgrmLength = 1.00;
        Facility_Program__c facilityPrgrmObj = new Facility_Program__c();
        if(frnFacilityPrgmMap.containsKey(selectdFacilityProgram)) {
            facilityPrgrmObj = frnFacilityPrgmMap.get(selectdFacilityProgram);
            system.debug('>>> facilityPrgrmObj : '+facilityPrgrmObj);
            prgrmLength = (facilityPrgrmObj.Program_Length__c != null ? facilityPrgrmObj.Program_Length__c : 1);
            system.debug('>>> prgrmLength : '+prgrmLength);
        }
        
        if(selectedBenefit!=null && selectedBenefit!=''){
            Insurance_Benefit__c ib = new Insurance_Benefit__c();
            ib = [Select Patient_Insurance__r.Insurance_Company__r.Name,Uncovered_Charges__c,Uncovered_Days__c,Uncovered_Days_Rate__c FROM Insurance_Benefit__c WHERE id =:selectedBenefit];
            for(Pay_Agreement_Worksheet_Detail__c pawd:AgreementDetaillist){
                TotalWorksheetDetail += 1;
                if(pawd.Insurance_Co_Responsibility__c != null)
                TotalInsuranceCoResponsibility += pawd.Insurance_Co_Responsibility__c;
            }
            system.debug('>>> calculate talbott : '+isTalbott);
            if(isTalbott){
                decimal deductibleRequested = (LOCValues.pAWrkSht.Deductible_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Deductible_Amount_Requested__c : 0.00;
                decimal coInsAmtRequested = (LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c : 0.00;
                //decimal coPayAmtRequested = (LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c : 0.00;
                decimal uncoveredCharges = (LOCValues.pAWrkSht.Uncovered_Charges__c !=null) ? LOCValues.pAWrkSht.Uncovered_Charges__c : 0.00;
                
                if(totalInsCoResp ==null) totalInsCoResp = 0;
                if(ib.Uncovered_Days__c == null) ib.Uncovered_Days__c = 0;
                if(ib.Uncovered_Days_Rate__c == null) ib.Uncovered_Days_Rate__c = 0;
                daysRate = (ib.Uncovered_Days__c*ib.Uncovered_Days_Rate__c);
                revenue = (deductibleRequested+coInsAmtRequested+uncoveredCharges);
                decimal daysFee = 0.00;
                decimal ancillaryFee = 0.00;
                System.debug('daysRate ::>'+daysRate);
                System.debug('revenue ::>'+revenue);
                System.debug('selectdFacilityProgram ::>'+selectdFacilityProgram);
                if(selectdFacilityProgram!=null && selectdFacilityProgram!='' && frnFacilityPrgmMap.containsKey(selectdFacilityProgram)){
                    daysFee = frnFacilityPrgmMap.get(selectdFacilityProgram).Days_60_90_Fees__c;
                    ancillaryFee = frnFacilityPrgmMap.get(selectdFacilityProgram).Ancillary_Fees__c;
                    if(daysFee==null) daysFee = 0.00;
                    if(ancillaryFee==null) ancillaryFee = 0.00;
                }
                system.debug('>>> LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c : '+LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c);
                LOCValues.pAWrkSht.Total_Revenue__c = (revenue+totalInsCoResp+daysRate+daysFee+coPayAmtRequested+privatePayFee);
                LOCValues.pAWrkSht.Total_Patient_Contribution__c = (revenue+daysRate+ancillaryFee+daysFee+coPayAmtRequested+privatePayFee);
                if(LOCValues.pAWrkSht.Room_and_Board_Days_Rate__c != null){
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Room_and_Board_Days_Rate__c;
                }
            } else if(ib.Patient_Insurance__r.Insurance_Company__r.Name == 'Private Pay'){
                //decimal coPayAmtRequested = (LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c : 0.00;
                LOCValues.pAWrkSht.Total_Patient_Contribution__c = coPayAmtRequested+privatePayFee;
                LOCValues.pAWrkSht.Total_Revenue__c = coPayAmtRequested+privatePayFee;
                if(LOCValues.pAWrkSht.Miscellaneous_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Miscellaneous_Fees__c;
                if(LOCValues.pAWrkSht.Ancillary_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Revenue__c += (TotalInsuranceCoResponsibility - LOCValues.pAWrkSht.Ancillary_Fees__c);
            } else {
                //decimal coPayAmtRequested = (LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c !=null) ? LOCValues.pAWrkSht.Co_Pay_Amount_Requested__c : 0.00;
                LOCValues.pAWrkSht.Total_Patient_Contribution__c = coPayAmtRequested+privatePayFee;
                if(LOCValues.pAWrkSht.Miscellaneous_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Miscellaneous_Fees__c;
                if(LOCValues.pAWrkSht.Room_and_Board_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Room_and_Board_Fees__c;
                if(LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Co_Insurance_Amount_Requested__c;
                if(LOCValues.pAWrkSht.Deductible_Amount_Requested__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Deductible_Amount_Requested__c;
                if(LOCValues.pAWrkSht.Ancillary_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Patient_Contribution__c += LOCValues.pAWrkSht.Ancillary_Fees__c;
                
                System.debug('LOCValues.pAWrkSht.Total_Patient_Contribution__c ::>'+LOCValues.pAWrkSht.Total_Patient_Contribution__c);
                if(LOCValues.pAWrkSht.Ancillary_Fees__c != null)
                    LOCValues.pAWrkSht.Total_Revenue__c = (LOCValues.pAWrkSht.Total_Patient_Contribution__c + TotalInsuranceCoResponsibility) - LOCValues.pAWrkSht.Ancillary_Fees__c;
                else
                    LOCValues.pAWrkSht.Total_Revenue__c = (LOCValues.pAWrkSht.Total_Patient_Contribution__c + TotalInsuranceCoResponsibility);
            }           
            
            if(isTalbott){
                decimal totaldays = totalRowCount+ib.Uncovered_Days__c;
                
                System.debug('revenue ::>'+revenue);
                System.debug('totalInsCoResp ::>'+totalInsCoResp);
                System.debug('totaldays ::>'+totaldays);
                System.debug('daysRate ::>'+daysRate);
                
                LOCValues.pAWrkSht.Daily_Revenue__c = (revenue+totalInsCoResp+daysRate+privatePayFee+coPayAmtRequested);
                if(totaldays>0){
                    LOCValues.pAWrkSht.Daily_Revenue__c = LOCValues.pAWrkSht.Daily_Revenue__c/prgrmLength;
                }
            } else if(TotalWorksheetDetail >0) {

                LOCValues.pAWrkSht.Daily_Revenue__c = LOCValues.pAWrkSht.Total_Revenue__c/prgrmLength ;
            }
            System.debug('LOCValues.pAWrkSht.Daily_Revenue__c ::>'+LOCValues.pAWrkSht.Daily_Revenue__c);
            //if(LOCValues.DailyRevenue!=null) LOCValues.DailyRevenue = (LOCValues.DailyRevenue).setScale(2);
        }
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
    // method to redirect to error page if record is locked
    public PageReference redirectIfLocked() {
        return RecordLockUtility.redirectIfLocked(pid);
    }
    
    public class LOCRelatedValues{
        public decimal coPayRemaining {get;set;}
        public decimal deductibleRemaining {get;set;}
        public decimal opMaxRemaining {get;set;}
        public Pay_Agreement_Worksheet__c pAWrkSht{get;set;}
        public Insurance_Benefit__c insBf{get;set;}
        public Integer dtx {get;set;}
        public Integer php {get;set;}
        public Integer iop {get;set;}
        public Integer rtc {get;set;}
        public decimal dtxRate {get;set;}
        public decimal phpRate {get;set;}
        public decimal iopRate {get;set;}
        public decimal rtcRate {get;set;}
        public LOCRelatedValues(){
            coPayRemaining = 0.00;
            deductibleRemaining = 0.00;
            opMaxRemaining = 0.00;
            dtx = 0;
            php = 0;
            iop = 0;
            rtc = 0;
            pAWrkSht = new Pay_Agreement_Worksheet__c();
            insBf = new Insurance_Benefit__c();
        }
    }
}