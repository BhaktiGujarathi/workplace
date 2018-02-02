public class EditPatInsController {
    public Patient_Insurance__c pat{get;set;}
   
    public Contact con{get;set;}
    public String patconEmployer{get;set;}   
    public String Selectedsubscriber{get;set;}
    public Integer conAge {get;set;}
    public boolean redBoolead{get;set;}
    public boolean IOIC{get;set;}
    public String oppid;
    public Opportunity opp;
    
    public List<PatientContactsWrp> patConWrpList;
    public List<repInfoWrapper> lstRepInfoWrp;
    public List<Representative_Information__c> lstRepInfo {get;set;}
    public Patient_Contact__c patcon {get;set;}
    public Integer repInfoTndexToRemove                                                 {get; set;}
    public Map<Id, Representative_Information__c> repInfoDBMap;
    
    public EditPatInsController(ApexPages.StandardController controller)
    {
        patconEmployer = '';
        conAge = 0;
        redBoolead = false;
        IOIC = false;
        oppid = apexpages.currentpage().getparameters().get('id');
        pat = new Patient_Insurance__c();
        con = new Contact();
        if(oppid != null && oppid != '')
        {
            pat = [select id,
                          VOB_Assigned__c,
                          VOB_status__c,
                          Patient__c,
                          Patient__r.Name,
                          Is_this_Medicare_Medicaid__c,
                          Patient_Social_Security_Number__c,
                          Patient_DOB__c,
                          Patient_Age__c,
                          Opportunity__c,
                          Subscriber_is_Patient__c,
                          Subscriber__c,
                          Benefits_Check__c,
                          Insurance_Plan__c,
                          Insurance_Company__c,
                          Insurance_Company__r.Is_Other_Insurance_Company__c,
                          Other_Insurance_Company__c,
                          Provider_Services_Phone__c,
                          Member_ID__c,
                          Behavioral_Health_Phone__c,
                          Group_Number__c,
                          Type_Order__c,
                          Policy_Effective_Date__c,
                          COB_Completed__c,
                          Renewal_Date__c,
                          COB_Needed__c,
                          Term_Date__c,
                          State_of_Origination__c,
                          Claims_Billing_Address__c,PreCert_Required__c,
                          Accreditation__c,Vendor__c,
                          Free_Standing_RTC_Facility__c,
                          PreCert_Phone__c,Free_Standing_Facility__c,
                          PreCert_Penalty_Description__c,
                          Travel_Out_of_State_for_Non_Emergent_Tx__c,
                          Accepts_Assignment_of_Benefits__c,
                          Prior_Auth_Before_Travel__c,
                          Referral_Needed__c,
                          Pharmacy_Coverage__c,
                          Rx_Vendor__c,
                          Rx_Phone__c,
                          ACA_Policy__c,
                          ACA_Policy_Paid_Through_Date__c,
                          COBRA_Account__c,
                          Subscriber_Employer__c,
                          COBRA_Effective_Date__c,
                          COBRA_Paid_Through_Date__c,
                          Approving_Without_Medical_Records__c,
                          Patient_is_High_Acuity__c
                     from Patient_Insurance__c 
                    where Id =: oppid];
            
            if(pat.Insurance_Company__r.Is_Other_Insurance_Company__c){
                IOIC = true;
            }            
        }         
        patcon = new Patient_Contact__c();
        patConWrpList = new List<PatientContactsWrp>();
        lstRepInfoWrp = new List<repInfoWrapper>();
        
        if(pat != null)
        {
            if(pat.Subscriber_is_Patient__c){
                Selectedsubscriber = pat.Patient__c;
            } else {
                Selectedsubscriber = pat.Subscriber__c;
            }
            patconEmployer = pat.Subscriber_Employer__c;
            conDetail();
            if(pat.Opportunity__c != null){
                opp  = [SELECT Contact__c, Contact__r.FirstName, Contact__r.LastName ,Contact__r.Social_Security_Number__c FROM Opportunity where Id =: pat.Opportunity__c];
                 
                PatientContactsWrp patConWrp;
                for(Patient_Contact__c pCon:[Select Id,First_Name__c,Last_Name__c,Employer__c FROM Patient_Contact__c Where Opportunity__c=:pat.Opportunity__c AND (First_Name__c!=null OR Last_Name__c!=null) Order by CreatedDate DESC]){
                    patConWrp = new PatientContactsWrp();
                    patConWrp.record = pCon;
                    patConWrp.uniqueNmbr = patConWrpList.size();
                    patConWrpList.add(patConWrp);
                }
            }
        }
        repInfoDBMap = new Map<Id, Representative_Information__c>();
        // Retrive of RepInfo Logic
        lstRepInfo = getRepInfoFromDB();
        
    }
 
    public List<SelectOption> getInsuranceCompany(){
        List<SelectOption> InsuranceCompany  = new List<SelectOption>();
        String name ;
        if(oppid!=null || pat.Opportunity__c != null){
            InsuranceCompany.add(new SelectOption('','--None--'));
            for(Account acc:[SELECT Id,  Name FROM Account where RecordType.Name = 'Insurance Company' ORDER BY Name ASC]){          
                if(acc.Name  != null){
                    InsuranceCompany.add(new SelectOption(acc.Id,acc.name));
                }
            }               
        }        
        return InsuranceCompany;
    }
    
    
    public List<Representative_Information__c> getRepInfoFromDB()
    {
    
         if(pat != null)
         {
              return [SELECT id,
                             Name,
                             Date_Time__c,
                             Patient_Insurance__c, 
                             Reference_Number__c,
                             OwnerId,
                             IsDeleted
                             FROM Representative_Information__c 
                             WHERE  Patient_Insurance__c =:pat.id];            
         }        
        return new List<Representative_Information__c>();
    }
    
    
    public List<repInfoWrapper> getLstRepInfoWrp()
    {
        lstRepInfoWrp.clear();
        // repInfoDBMap.clear();
        if(lstRepInfo != NULL && lstRepInfo.size() > 0) {
            for (Integer i = 0; i < lstRepInfo.size(); i++) {
                lstRepInfoWrp.add(new repInfoWrapper(lstRepInfo[i],i));
                if(lstRepInfo[i].id != null) {
                    repInfoDBMap.put(lstRepInfo[i].id, lstRepInfo[i]);
                }
            }
        } else{
            lstRepInfoWrp.add(new repInfoWrapper(new Representative_Information__c(Patient_Insurance__c = pat.id), 0));
            lstRepInfo.add(new Representative_Information__c(Patient_Insurance__c = pat.id));
        }
        return lstRepInfoWrp;
    }
    
    public PageReference Cancel(){
        if(oppid!=null){
            PageReference page= new PageReference('/'+oppid);
            return page;
        } 
        return null;       
    }
   
    public pagereference Save(){
        //Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Representative_Information__c').getDescribe().fields.getMap();
        Boolean isUpdated = false;
        //Patient_Contact Object upsert.
        Map<String,Patient_Contact__c> patConWrpMap = new Map<String,Patient_Contact__c>();
        if(patConWrpList.size()>0){
            for(PatientContactsWrp pcWrp:patConWrpList){
                Patient_Contact__c pc =pcWrp.record;
                if(pc.Id!=null)
                    patConWrpMap.put(''+pc.Id,pc);
                else
                    patConWrpMap.put(''+pcWrp.UniqueNmbr,pc);
            }
            upsert patConWrpMap.values();
        }
        List<Representative_Information__c> repInfoToUpdate = new List<Representative_Information__c>();
        Representative_Information__c repInfoObj;
        
        // representative info
        if(lstRepInfoWrp.size() > 0 && !lstRepInfoWrp.isEmpty()) {
            repInfoDBMap = prepareRepInfoDbMap(getRepInfoFromDB());
            for(repInfoWrapper wrapperInstance : lstRepInfoWrp) {
	            if(wrapperInstance.repInfo.Id == null && wrapperInstance.repInfo.get('Name') != null) {
	                repInfoToUpdate.add(wrapperInstance.repInfo);
	            }else {
	                repInfoObj = new Representative_Information__c();
	                if(repInfoDBMap.containskey(wrapperInstance.repInfo.Id))
	                   repInfoObj = repInfoDBMap.get(wrapperInstance.repInfo.Id);
	                   if(wrapperInstance.repInfo.get('Name') != null) {
	                    if(wrapperInstance.repInfo.get('Date_Time__c') != null && repInfoObj.get('Date_Time__c') != wrapperInstance.repInfo.get('Date_Time__c')) {
	                       isUpdated = isUpdated || true;
	                    }
	                    if(wrapperInstance.repInfo.get('Reference_Number__c') != null && repInfoObj.get('Reference_Number__c') != wrapperInstance.repInfo.get('Reference_Number__c')) {
	                        isUpdated = isUpdated || true;
	                    }
	                    if(repInfoObj.get('Name') != wrapperInstance.repInfo.get('Name')) {
	                        isUpdated = isUpdated || true;
	                    }
	                   }
	                //}
	                if(isUpdated) {
	                    repInfoToUpdate.add(wrapperInstance.repInfo);
	                }
	            }
            }
        }
        if(!repInfoToUpdate.isEmpty()) {
            try {
                upsert repInfoToUpdate;
            }
            catch(Exception exObj) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, exObj.getMessage()));
            }
        }
        //Patient_Insurance Object insert.
        if(Selectedsubscriber!=null && Selectedsubscriber!=''){
            if(Selectedsubscriber.length()>=15 && Selectedsubscriber.startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){
                pat.Subscriber_is_Patient__c = true;
                pat.Subscriber__c = null;                   
            } else {
                if(patConWrpMap.containsKey(Selectedsubscriber)){
                    pat.Subscriber_is_Patient__c = false;
                    pat.Subscriber__c = patConWrpMap.get(Selectedsubscriber).Id;
                }
            }
        } else {
            pat.Subscriber_is_Patient__c = false;
            pat.Subscriber__c = null;
        }
                
        if(!IOIC){
            pat.Other_Insurance_Company__c = null;
        } 
        update pat;
        
        if(pat.id!=null && oppid!=null){
            PageReference page= new PageReference('/'+oppid);
            return page;
        } 
        return null;   
    }
    
    public List<SelectOption> getSubscriberName(){
        List<SelectOption> subscriberName = new List<SelectOption>();
        subscriberName.add(new SelectOption('','--None--'));
        if(opp!=null){          
            if(con==null || con.Id==null)
                conDetail();
            if(con!=null && con.Id!=null){   
                String conName;
                if(con.FirstName!=null)
                    conName = con.FirstName;
                conName = (conName==null) ? con.LastName : conName+' '+con.LastName;
                conName = conName+' (Patient)';
                subscriberName.add(new SelectOption(con.Id,conName));
            }
            String pConName;
            for(PatientContactsWrp patWrp:patConWrpList){
                Patient_Contact__c pCon = patWrp.record;
                pConName = '';
                if(pCon.First_Name__c!=null)
                    pConName = pCon.First_Name__c;
                if(pCon.Last_Name__c!=null)
                    pConName = (pConName==null) ? pCon.Last_Name__c : pConName+' '+pCon.Last_Name__c;
                
                if(pCon.Id!=null)
                    subscriberName.add(new SelectOption(''+pCon.Id,pConName));
                else
                    subscriberName.add(new SelectOption(''+patWrp.uniqueNmbr,pConName));
            }
        }
        return subscriberName;
    }
    
    public void SubscriberEmployer(){
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){           
            patconEmployer = '';
            pat.Subscriber_Employer__c = '';
            if(Selectedsubscriber.startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){
                pat.Subscriber_is_Patient__c = true;
            } else {
                pat.Subscriber_is_Patient__c = false;
                for(PatientContactsWrp pcw:patConWrpList){
                    if(pcw.UniqueNmbr+''==Selectedsubscriber){                  
                        patconEmployer = pcw.record.Employer__c;    
                        pat.Subscriber_Employer__c = pcw.record.Employer__c;                            
                    }else if(String.valueOf(pcw.record.Id) == Selectedsubscriber){
                        patconEmployer = pcw.record.Employer__c;    
                        pat.Subscriber_Employer__c = pcw.record.Employer__c;  
                    }
                }
            }
        } else {
            pat.Subscriber_Employer__c = '';
            patconEmployer = '';
            pat.Subscriber_is_Patient__c = false;
        }   
    }
    
       
    public void conDetail(){
        Integer age = 0;
        if(pat.Patient__c!= null && (pat.Patient__c+'').startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){            
            con=[Select Id, Age__c,FirstName,LastName,Birthdate,Social_Security_Number__c from contact where Id =: pat.Patient__c];
            if(con.Birthdate != null){
                age = calculateYears(con.Birthdate);                 
            }
            pat.Patient_Social_Security_Number__c  = con.Social_Security_Number__c;            
        } else {
            con = new Contact();
            age = 0;
        }
        if(age >0){
            conAge = age;   
        } else {
            conAge = 0; 
        }
    }
    
    //Calculate Age Method
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
        } else if(patientDOB > currentDate){ // birthday > today
            return null;
        //  birthday < today                    
        } else {
            monthsCal = patientDOB.monthsBetween(currentDate);          
            if (currentDate.day() < patientDOB.day()) monthsCal--;
            returnYears = monthsCal/12; 
        }
        //  will turn 26 years old in the current year
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
    
   
    
    //New Patient Contact
    public pagereference newPatientContact(){
        patcon = new Patient_Contact__c();
        patcon.Opportunity__c=opp.Id;
        patcon.Contact__c = opp.Contact__c;
        return page.EditPatContactPage;
    }
    
    //Add New Patient Contact 
    public Pagereference addNewPCObj(){
        PatientContactsWrp newRecord = new PatientContactsWrp();     
        newRecord.record = patcon; 
        newRecord.UniqueNmbr = patConWrpList.size();
        Selectedsubscriber = ''+newRecord.UniqueNmbr;
        patconEmployer = patcon.Employer__c;
        pat.Subscriber_Employer__c = patcon.Employer__c;
        pat.Subscriber_is_Patient__c = false;
        patConWrpList.add(newRecord); 
        return Page.EditPatientInsPage;
    } 
    
    public pagereference PatContactCancel(){
        return Page.EditPatientInsPage;
    } 
    
    public void OtherInsCom(){
        IOIC = false;
        if(pat.Insurance_Company__c != null){
            Account acct = [select id, Is_Other_Insurance_Company__c from Account WHERE Id =: pat.Insurance_Company__c];
            if(acct.Is_Other_Insurance_Company__c){
                IOIC = true;
            }
        }
    }
    
    // method to add new represnetative information
    public void addReprestativeInfoNew() {
        Representative_Information__c repInfoNew = new Representative_Information__c(Date_Time__c = System.Now(),
                                                                      Patient_Insurance__c = pat.id);
        lstRepInfo.add(repInfoNew);
        lstRepInfoWrp.add(new repInfoWrapper(repInfoNew, lstRepInfoWrp.size()));
    }
    
    // method to remove a represnetative information record
    public void deleteReprestativeInfo() {
        if(lstRepInfoWrp[repInfoTndexToRemove].repInfo.Id != null) {
            try {
                delete lstRepInfoWrp[repInfoTndexToRemove].repInfo;
            }
            catch(Exception exObj) {
                system.debug('>>> ex : '+exObj);
            }
        }
        lstRepInfo.remove(repInfoTndexToRemove);
        lstRepInfoWrp.remove(repInfoTndexToRemove);
        //re-indexing
         for(Integer i=0;i<lstRepInfoWrp.size();i++)
         {
            lstRepInfoWrp[i].repIndex = i;
         }
    } 
    
    // method to prepare a map to hold database records.
    public map<id, Representative_Information__c> prepareRepInfoDbMap(List<Representative_Information__c> pRepInfoList) {
        repInfoDBMap = new Map<id, Representative_Information__c>();
        for(Representative_Information__c repInfoInstance : pRepInfoList) {
            if(!repInfoDBMap.containsKey(repInfoInstance.Id)) {
                repInfoDBMap.put(repInfoInstance.Id, repInfoInstance);
            }
        }
        return repInfoDBMap;
    }
    
    //Wrapper class for Patient Contacts Object
    public class PatientContactsWrp{
        public Patient_Contact__c record;
        public Integer UniqueNmbr; 
        public PatientContactsWrp(){
            UniqueNmbr = 0;
            record = new Patient_Contact__c(); 
        }
    } 
    
    
     //Wrapper class for Refernce Information Object
    public class repInfoWrapper 
    {
        public Representative_Information__c repInfo                                     {get;set;}
        public Integer repIndex                                                          {get;set;}
       
        public repInfoWrapper (Representative_Information__c prepInfo, Integer prepIndex) 
        {
            repInfo = prepInfo;
            repIndex = prepIndex;
           
        }
    }
    
    public PageReference redirectIfLocked() {
        return RecordLockUtility.redirectIfLocked(oppid);
    }
}