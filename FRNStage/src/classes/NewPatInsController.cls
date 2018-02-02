public class NewPatInsController {
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
    public Patient_Contact__c patcon {get;set;}
    public List<repInfoWrapper> lstRepInfoWrp;
    public List<Representative_Information__c> lstRepInfo                               {get; set;}
    public Integer repInfoTndexToRemove                                                 {get; set;}
    public Map<Id, Representative_Information__c> repInfoDBMap;
    
    public NewPatInsController(ApexPages.StandardController controller){
        patconEmployer = '';
        conAge = 0;
        redBoolead = false;
        IOIC = false;
        oppid = apexpages.currentpage().getparameters().get('id');
        
        pat = new Patient_Insurance__c();
        con = new Contact();
        pat.Policy_Effective_Date__c = Date.newInstance((System.Today()).year(), 1, 1);
        pat.Renewal_Date__c = Date.newInstance((System.Today().addYears(1)).year(), 1, 1);
        pat.Term_Date__c = Date.newInstance((System.Today()).year(), 12, 31);   
           
        patcon = new Patient_Contact__c();
        patConWrpList = new List<PatientContactsWrp>();
        
        if(oppid != null && oppid != ''){
            pat.Opportunity__c=oppid;
            opp  = [SELECT Contact__c, Contact__r.FirstName, Contact__r.LastName ,Contact__r.Social_Security_Number__c FROM Opportunity where Id =: oppId];
                    
            if(opp.contact__c != null){
                pat.Patient__c  = opp.contact__c;
                conDetail();
            }
            
            if(opp.Contact__r.Social_Security_Number__c != null ){
                pat.Patient_Social_Security_Number__c  = opp.Contact__r.Social_Security_Number__c;
            }
            
            PatientContactsWrp patConWrp;
            for(Patient_Contact__c pCon:[Select Id,First_Name__c,Last_Name__c,Employer__c FROM Patient_Contact__c Where Opportunity__c=:oppid AND (First_Name__c!=null OR Last_Name__c!=null) Order by CreatedDate DESC]){
                patConWrp = new PatientContactsWrp();
                patConWrp.record = pCon;
                patConWrp.uniqueNmbr = patConWrpList.size();
                patConWrpList.add(patConWrp);
            }
            repInfoDBMap = new Map<Id, Representative_Information__c>();
            // Retrive of RepInfo Logic
            lstRepInfo = getRepInfoFromDB();
        }
    }
 
    public List<SelectOption> getInsuranceCompany(){
        List<SelectOption> InsuranceCompany  = new List<SelectOption>();
        String name ;
        if(oppid!=null || pat.Opportunity__c != null){
            InsuranceCompany.add(new SelectOption('','--None--'));
            for(Account acc:[SELECT Id, Is_Other_Insurance_Company__c, Name FROM Account where RecordType.Name = 'Insurance Company' ORDER BY Name ASC]){    if(acc.Name  != null){
                    InsuranceCompany.add(new SelectOption(acc.Id,acc.name));
                }
            }               
        }        
        return InsuranceCompany;
    }
    // get related representative information from db
    public List<Representative_Information__c> getRepInfoFromDB()
    {
        return new List<Representative_Information__c>();
    }
    
    public List<repInfoWrapper> getLstRepInfoWrp()
    {
             lstRepInfoWrp = new List<repInfoWrapper>();
              if(lstRepInfo != NULL && lstRepInfo.size() > 0)
              {
                 //lstRepInfoWrp = new List<repInfoWrapper>();
                  for (Integer i = 0; i < lstRepInfo.size(); i++) 
                    {
                        lstRepInfoWrp.add(new repInfoWrapper(lstRepInfo[i],i));
                        if(lstRepInfo[i].id != null) {
                            repInfoDBMap.put(lstRepInfo[i].id, lstRepInfo[i]);
                        }
                    }
                 //return lstRepInfoWrp;
              }
              else {
                  lstRepInfo.add(new Representative_Information__c(Patient_Insurance__c = pat.id));
                  lstRepInfoWrp.add(new repInfoWrapper(new Representative_Information__c(Patient_Insurance__c = pat.id), 0));
              }
           system.debug('>>> repInfoDBMap : '+repInfoDBMap);
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
		
        //Patient_Contact Object upsert.
        Map<String,Patient_Contact__c> patConWrpMap = new Map<String,Patient_Contact__c>();
        if(patConWrpList.size()>0){
            for(PatientContactsWrp pcWrp:patConWrpList){
                Patient_Contact__c pc =pcWrp.record;
                patConWrpMap.put(''+pcWrp.UniqueNmbr,pc);
            }
            upsert patConWrpMap.values();
        }
        
        //Patient_Insurance Object insert.
        pat.Opportunity__c = opp.Id;
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
        } 
		if(!IOIC){
			pat.Other_Insurance_Company__c = null;
		}
        insert pat;
        
        List<Representative_Information__c> repInfoToUpdate = new List<Representative_Information__c>();
        
        // representative info
        if(lstRepInfoWrp.size() > 0 && !lstRepInfoWrp.isEmpty() && pat.Id != null) {
            for(repInfoWrapper wrapperInstance : lstRepInfoWrp) {
                if(wrapperInstance.repInfo.Id == null && wrapperInstance.repInfo.get('Name') != null) {
                    wrapperInstance.repInfo.Patient_Insurance__c = pat.Id;
                    repInfoToUpdate.add(wrapperInstance.repInfo);
                }
            }
        }
        system.debug('>>> repInfoToUpdate : '+repInfoToUpdate);
        if(!repInfoToUpdate.isEmpty()) {
            try {
                upsert repInfoToUpdate;
            }
            catch(Exception exObj) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, exObj.getMessage()));
            }
        }
        
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
        System.debug('subscriberName ::>'+subscriberName);
        return subscriberName;
    }
    
    public void SubscriberEmployer(){
        System.debug('SubscriberEmployer__Called' + Selectedsubscriber);
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){           
            //patconEmployer = '';
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
            System.debug('Subscriber_Employer__c '+pat.Subscriber_Employer__c);
            System.debug('patIns ::>'+pat);
            
        } else {
            pat.Subscriber_Employer__c = '';
            pat.Subscriber_is_Patient__c = false;
            System.debug('patconEmployer_____________________ '+pat.Subscriber_Employer__c);            
        }   
    }
    
    public Pagereference SaveandNew(){
        //Patient_Contact Object upsert.
        Map<String,Patient_Contact__c> patConWrpMap = new Map<String,Patient_Contact__c>();
        if(patConWrpList.size()>0){
            for(PatientContactsWrp pcWrp:patConWrpList){
                Patient_Contact__c pc =pcWrp.record;
                
                patConWrpMap.put(''+pcWrp.UniqueNmbr,pc);
            }
            upsert patConWrpMap.values();
        }
        
        //Patient_Insurance Object insert.
        pat.Opportunity__c = opp.Id;
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
        } 
		if(!IOIC){
			pat.Other_Insurance_Company__c = null;
		}
        insert pat;
      
        if(oppid!=null && pat.id!=null){ 
            pat = new Patient_Insurance__c();
            pat.Opportunity__c = oppId;
           // populateFromOpp();  
            pat.Policy_Effective_Date__c = Date.newInstance((System.Today()).year(), 1, 1);
            pat.Renewal_Date__c = Date.newInstance((System.Today().addYears(1)).year(), 1, 1);
            pat.Term_Date__c = Date.newInstance((System.Today()).year(), 12, 31);            
            Pagereference page= new Pagereference('/apex/NewPatientInsPage?id='+oppId);
            page.setRedirect(true);
            return page;
        }     
        return null;
    }
       
    public void OtherInsCom(){
		if(pat.Insurance_Company__c != null){
			Account acct = [select id, Is_Other_Insurance_Company__c from Account WHERE Id =: pat.Insurance_Company__c];
			if(acct.Is_Other_Insurance_Company__c){
				IOIC = true;
			}else{
				IOIC=false;
			}
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
        System.debug(pMnth+'  '+pDate+'  '+pYear);      
        date currentDate = system.today();
        System.debug('patientDOB______________currentDate'+patientDOB+'______________'+currentDate);                        
        //  birthdate = today        
        if(patientDOB == currentDate){         
            monthsCal = 0;             
            returnYears = 0; 
            System.debug('patientDOB = currentDate');                   
        } else if(patientDOB > currentDate){ // birthday > today
            System.debug('patientDOB > currentDate');
            return null;
        //  birthday < today                    
        } else {
            monthsCal = patientDOB.monthsBetween(currentDate);          
            if (currentDate.day() < patientDOB.day()) monthsCal--;
            returnYears = monthsCal/12; 
            system.debug('patientDOB < currentDate');                       
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
        System.debug('redBoolead__________________________'+redBoolead);                             
        if(returnYears > 0){
            return returnYears;
            System.debug('returnYears__________________________'+returnYears);                  
        }      
        return null;
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
    
    //New Patient Contact
    public pagereference newPatientContact(){
        patcon = new Patient_Contact__c();
        patcon.Opportunity__c=opp.Id;
        patcon.Contact__c = opp.Contact__c;
        return page.NewPatContactPage;
    }
    
    //Add New Patient Contact 
    public Pagereference addNewPCObj(){
        PatientContactsWrp newRecord = new PatientContactsWrp();     
        newRecord.record = patcon; 
        newRecord.UniqueNmbr = patConWrpList.size();
        Selectedsubscriber = ''+newRecord.UniqueNmbr;
        patconEmployer = patcon.Employer__c;
		pat.Subscriber_Employer__c= patcon.Employer__c;
        pat.Subscriber_is_Patient__c = false;
        patConWrpList.add(newRecord); 
        return Page.NewPatientInsPage;
    } 
    
    public pagereference PatContactCancel(){
        return Page.NewPatientInsPage;
    }
    
        // method to add new represnetative information
    public void addReprestativeInfoNew() {
        Representative_Information__c repInfoNew = new Representative_Information__c(Date_Time__c = System.Now(),
                                                                      Patient_Insurance__c = pat.id);
        lstRepInfoWrp.add(new repInfoWrapper(repInfoNew, lstRepInfoWrp.size()));
        lstRepInfo.add(repInfoNew);
    }
    
    // method to remove a represnetative information record
    public void deleteReprestativeInfo() {
        if(lstRepInfoWrp[repInfoTndexToRemove].repInfo.Id != null) {
            try {
                delete lstRepInfoWrp[repInfoTndexToRemove].repInfo;
            }
            catch(Exception exObj) {
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
    
    // method to redirect to error page if record is locked
    public PageReference redirectIfLocked() {
        if(oppid != null) {
            return RecordLockUtility.redirectIfLocked(oppid);
        }
        else {
            return null;
        }
    }
}