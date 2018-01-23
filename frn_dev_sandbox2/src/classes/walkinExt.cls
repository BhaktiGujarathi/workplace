public class walkinExt{
    
    public List<TreatmentHistoryWrp> TreatmentHistoryWrpList {get;set;}    
    public List<SelectOption> callInCodePicklist {get;set;}
    public String selectedCallInCode {get;set;} 
    public String selectedOrigin {get;set;} 
    public Contact con{get;set;}
    public String refRecId;
    public Lead le{get;set;}
    public list<Lead> leadlist{get;set;}
    public Integer searchPosition{get;set;}
    public Integer rowToRemove{get;set;}
    public Map<Id,Call_in_Code__c> listCIC;    
    public List<ReferralWrapper> ReferWrpList{get;set;}    
    public Abused_Substance__c sub{get;set;}
    public List<AbusedSubstanceWrp> AbusedSubstanceWrpList {get;set;}   
    public String recordTypeName{get;set;}   
    public boolean redBoolead{get;set;}
    public Integer rowToEdit {get;set;}    
    public Boolean rend1 {get;set;}
    public Boolean rend2 {get;set;}
    public Boolean rend3 {get;set;}
    public Boolean rend4 {get;set;}
   
    //Below for Patient Contact
    public Patient_Contact__c patcon {get;set;}
    public List<PatientContactsWrp> patConWrpList;     
    public boolean recordForEdit{get;set;}
    public Patient_Insurance__c patIns {get;set;}
    public List<PatientInsuranceWrp> PatientInsuranceWrpList {get;set;}
    public String patconEmployer{get;set;}   
    public string Selectedsubscriber{get;set;}
    public Integer conAge {get;set;}
    public Set<String> resCrtdPatConIds;
    public boolean IOIC{get;set;}
	
    public walkinExt(ApexPages.StandardController controller){
        conAge = 0;
        redBoolead = false;
		IOIC = false;
        ReferWrpList = new List<ReferralWrapper>();
        PatientInsuranceWrpList = new List<PatientInsuranceWrp>();
        TreatmentHistoryWrpList = new List<TreatmentHistoryWrp>();
        AbusedSubstanceWrpList = new List<AbusedSubstanceWrp>();
        patConWrpList = new List<PatientContactsWrp>();
        leadlist = new list<Lead>();
        le = new Lead();
        con = new Contact();
        sub = new Abused_Substance__c();
        patIns = new Patient_Insurance__c();
        patcon = new Patient_Contact__c();
        resCrtdPatConIds = new Set<String>();
        callInCodePicklist = new List<SelectOption>();
        listCIC = new Map<Id,Call_in_Code__c>([SELECT Id,Name FROM Call_in_Code__c ORDER BY Name ASC]);
        for(Call_in_Code__c eachCIC : listCIC.values()){
           callInCodePicklist.add(new SelectOption(eachCIC.Id, eachCIC.name));
           System.debug('callInCodePicklist---'+callInCodePicklist);
        }
        refRecId = Schema.Sobjecttype.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        System.debug('refRecId....>'+refRecId);
        if(ReferWrpList.size()==0){
            addNewRow();
        } 
        
        if(TreatmentHistoryWrpList.size()==0){
            addNewTreatmentHistoryObj();
        }        
        
        patconEmployer = '';
     
        RecordType rcTyp = [SELECT Name FROM RecordType WHERE SobjectType =: 'Lead'];
        recordTypeName = rcTyp.Name;
        System.debug('RecordType_________________________'+recordTypeName);
        
        if(ReferWrpList.size()>0){
            referlist();
        }

        If(le.ownerId =='' || le.ownerId == null){
            le.ownerId = UserInfo.getUserId();
        }
        System.debug('OwnerId____________________________ '+le.ownerId);        
    }
    
    /***Who told you about ONLINE search()?????*/  
    public String abtValue{get;set;}    
    public String searchTerm{get;set;}  
    public void toldYouAbout() {
        searchTerm = '';
        abtValue = System.currentPageReference().getParameters().get('about');
        System.debug('abtValue___________________________________'+abtValue);
        
        if(abtValue != null && abtValue != '') {
            //string tempInput = '%' + abtValue + '%';
            List<Online_Search_Term__c> srch = new List<Online_Search_Term__c>();
            srch = [SELECT Id, Name FROM Online_Search_Term__c WHERE Name =: abtValue LIMIT 1];
                System.debug('SIZE___ '+srch.size()+'  srch___________ '+srch);
                if(srch.size() > 0){
                    for(Online_Search_Term__c O: srch){
                        searchTerm = O.Name;                            
                    }
                    System.debug('searchTerm_____________________'+searchTerm);
                    
                }   else { System.debug('showSearch_Value_is_not_Valid');}
                
        } else if(abtValue == null && abtValue == '') { searchTerm = ''; System.debug('Not_Getting_the_showSearch_Value');}
            
    }
    
    public void rendSection(){
        searchTerm = '';
        le.Online_Search_Term__c = '';       
        if(le.LeadSource == 'Online'){
            rend1 = true;
            rend2 = false;
            rend3 = false;
            rend4 = false;
        } else if(le.LeadSource == 'Professional'){
            rend1 = false;
            rend2 = true;
            rend3 = false;
            rend4 = false;
        } else if(le.LeadSource == 'Alumni'){
            rend1 = false;
            rend2 = false;
            rend3 = true;
            rend4 = false;           
        } else if(le.LeadSource == 'Unknown'){
            rend1 = false;
            rend2 = false;
            rend3 = false;
            rend4 = true;
        } else {
            rend1 = false ;
            rend2 = false ;
            rend3 = false ;
            rend4 = false ;
        }        
    }     
    
    public List<SelectOption> getOriginPicklist(){
        List<SelectOption> OriginPicklist  = new List<SelectOption>();
        //OriginPicklist.add(new SelectOption('Walk In','Walk In'));    
        Schema.DescribeFieldResult fieldResult = Lead.Origin__c.getDescribe();  
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
           OriginPicklist.add(new SelectOption(p.getValue(), p.getValue()));        
        return OriginPicklist;
    }
    
    public void selectedvalue(){        
        System.debug('ReferWrpList ::>'+ReferWrpList);
        System.debug('searchPosition ::>'+searchPosition);
        if(ReferWrpList.size()>searchPosition){
            Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();   
            String acckeyPrefix = r.getKeyPrefix();
            Schema.DescribeSObjectResult r1 = Contact.sObjectType.getDescribe();   
            String conkeyPrefix = r1.getKeyPrefix();
            
            ReferralWrapper wrp = ReferWrpList[searchPosition];
            wrp.referralSourceConList.clear();
            wrp.referralSourceList.clear(); 
            System.debug('wrp ::>'+wrp);
            if(wrp.searchKeyWord != null && wrp.searchKeyWord!=''){   
                String accName, accID;      
                if(String.valueOf(wrp.searchKeyWord).startsWith(acckeyPrefix)){         
                    for(Contact con: [SELECT id,AccountId, Account.name, name FROM Contact WHERE AccountId = :wrp.searchKeyWord]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                    }
                    for(Account acc: [SELECT id, name,RAM_Lookup__c, RAM_Lookup__r.Name FROM Account WHERE Id = :wrp.searchKeyWord]){
                        wrp.referralSourceList.add(new SelectOption(acc.id, acc.name));
                        if(acc.RAM_Lookup__c!=null)
                            wrp.RAMName = acc.RAM_Lookup__r.Name;
                     }
                }
                if(String.valueOf(wrp.searchKeyWord).startsWith(conkeyPrefix)){
                    for(Contact con: [SELECT id,AccountId,Account.name,Account.RAM_Lookup__c,Account.RAM_Lookup__r.name, name FROM Contact WHERE id = :wrp.searchKeyWord]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                        accName = con.Account.name;
                        accID = con.AccountId;
                        if(con.Account.RAM_Lookup__c !=null)
                            wrp.RAMName = con.Account.RAM_Lookup__r.Name;
                    }
                    if(accName != '' && accName != null){
                        wrp.referralSourceList.add(new SelectOption(accID,accName));
                    }
                }
                System.debug('wrp ::>'+wrp);
            }
        }           
    }
    
    @RemoteAction
    public static List<SearchWrapperClass> getSearchResult(String keyTerm){ 
        System.debug('keyTerm ::>'+keyTerm);
        List<SearchWrapperClass> wrpList = new List<SearchWrapperClass>();
        
        if(keyTerm!= null && keyTerm.trim()!=''){
            keyTerm = '%'+keyTerm.trim()+'%';
            wrpList.add(new SearchWrapperClass('', 'Referral Source'));
            List<Account> accList = [Select id, Name from Account where name like :keyTerm];
            if(accList!=null && accList.size()>0){
                for(Account acc:accList){
                    wrpList.add(new SearchWrapperClass(String.valueof(acc.id), acc.name));
                }
            } else {
                wrpList.add(new SearchWrapperClass('', '--No Matches--'));
            }
            System.debug('wrpList ::>'+wrpList);
            wrpList.add(new SearchWrapperClass('', 'Referral Source Contact'));
            List<Contact> conList = [Select id, name from Contact where FirstName like :keyTerm or LastName like:keyTerm ];
            if(conList!=null && conList.size()>0){
                for(Contact con: conList){
                    wrpList.add(new SearchWrapperClass(String.valueof(con.id), con.name));
                }
            } else {
                wrpList.add(new SearchWrapperClass('', '--No Matches--'));
            }   
            System.debug('wrpList ::>'+wrpList);            
        }
        System.debug('wrpList ::>'+wrpList);
        return wrpList;
    }
    
    public void addNewRow(){
        ReferralWrapper newRecord = new ReferralWrapper();
        newRecord.index = ReferWrpList.size();
        ReferWrpList.add(newRecord);        
        referlist();        
    }
    
    public class SearchWrapperClass{
        String id,label;
        public SearchWrapperClass(String wrid, String name){
            this.label = name;
            this.id = wrid;
        }
    } 
    
    public class ReferralWrapper{      
        public Integer index {get;set;}
        public Referral__c cmpM {get;set;}
        public String RAMName {get;set;}
        public String searchKeyWord {get; set;}
        public String selectedKeyWrp {get; set;}
        public List<SelectOption> referralSourceList {get; set;}
        public List<SelectOption> referralSourceConList {get; set;}
        public List<SelectOption> refOrders {get; set;}
        public ReferralWrapper(){
            cmpM = new Referral__c();
            referralSourceList = new List<SelectOption>();
            referralSourceConList = new List<SelectOption>();
            refOrders =  new List<SelectOption>();
        }
    }
    
    public void removeRow(){
        System.debug('PracticeProviderWrpList......'+ReferWrpList);
        System.debug('rowToRemove  in removeRowFromPOSList......'+rowToRemove); 
        
        if(ReferWrpList.size()>rowToRemove){
            ReferWrpList.remove(rowToRemove);
            for(integer i=rowToRemove;i<ReferWrpList.size();i++){
                ReferWrpList[i].index = i;               
            }
        }
        referlist();        
    }
    
    public void referlist(){
        String refer = '';
        for(ReferralWrapper c: ReferWrpList){
            refer += ' '+c.cmpM.Referral_Rank__c;
        }
        
        System.debug('current Referral_Rank...... '+refer); 
        Schema.DescribeFieldResult fieldResult = Referral__c.Referral_Rank__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for(ReferralWrapper c: ReferWrpList){
            c.refOrders =  new List<SelectOption>();
            for( Schema.PicklistEntry f : ple){
                if(!refer.contains(f.getValue()) || f.getValue() == c.cmpM.Referral_Rank__c)
                c.refOrders.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
    }
    
    public PageReference SaveAndClose(){
        if(le.LastName == null || le.LastName ==''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Last Name: You must enter a value');
            apexpages.addmessage(msg); 
            return null;
        }
                                                    // if (le.FirstName == null || le.FirstName == '') { apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'First Name: You must enter a value'); apexpages.addmessage(msg); return null
    if(le.LeadSource=='Online'){
      le.Referral_Source_Unknown_Details__c = null;
      le.Alumni_Name__c = null;
      le.Alumni_FRN_Facility__c = null;      
    } else if(le.LeadSource=='Unknown'){
      le.Online_Search_Term__c = null;        
      le.Alumni_Name__c = null;
      le.Alumni_FRN_Facility__c = null;
    } else if(le.LeadSource == 'Alumni'){
      le.Online_Search_Term__c = null;  
      le.Referral_Source_Unknown_Details__c = null;
    } else if(le.LeadSource == 'Professional') {
      le.Referral_Source_Unknown_Details__c = null;
      le.Alumni_Name__c = null;
      le.Alumni_FRN_Facility__c = null;
      le.Online_Search_Term__c = null;        
    }
    
        le.Opportunity_RecordType__c = 'Outpatient Treatment';
        insert le;
    
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(le.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        System.debug('lcr---'+lcr);
        
        //List<Contact> conrList = new List<Contact>();
        Id AccId = lcr.getAccountId();
        System.debug('AccId---'+AccId);
        Id ConId = lcr.getContactId();
        System.debug('ConId---'+ConId);
        Id LeadID = lcr.getLeadID();
        System.debug('LeadID---'+LeadID);
        
        if(le.Alumni_Referral_Source__c == 'Professional' && LeadID!=null){            
            Referral__c ref = new Referral__c();
            ref.Account__c = AccId;
            insert ref;
            System.debug('ref---'+ref);
        }
        
        if(ConId != null){            
            Contact convertedCon = new Contact();
            convertedCon.id = ConId;
            System.debug('Conlist---'+convertedCon);
            convertedCon.Birthdate = con.Birthdate;
            update convertedCon;
        }
                
        System.debug('lcr.isSuccess()...>> '+lcr.isSuccess());
        if(lcr.isSuccess()){
            Opportunity opp = [Select Id from opportunity where Id=:lcr.getOpportunityId()];
            String oppRecTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
            
            //System.debug('opp.RecordTypeId..> '+opp.RecordTypeId);
            System.debug('oppRecTypeId...>> '+oppRecTypeId);
            if(oppRecTypeId != null){
                opp.RecordTypeId = oppRecTypeId;
                System.debug('opp.RecordTypeId..> '+opp.RecordTypeId);
                if(Test.isRunningTest() || opp != null){
                    //update opp;
                    System.debug('opp...>> '+opp);
                }
            }           
            
      if(le.LeadSource == 'Professional') {
        List<Referral__c> refList = new List<Referral__c>();
        Referral__c rf ;
        
        for(ReferralWrapper cmpWrp:ReferWrpList){
          rf = new Referral__c();
          String patientName = '';
          if(cmpWrp.cmpM.Account__c!=null){
            if(cmpWrp.cmpM.id== null){
              rf.Opportunity__c = opp.Id;
              rf.Account__c = cmpWrp.cmpM.Account__c;
              
              if(cmpWrp.cmpM.Consentor__c!=null){
                rf.Consentor__c = cmpWrp.cmpM.Consentor__c;
              }
              if(cmpWrp.cmpM.Referral_Rank__c!=null){
                rf.Referral_Rank__c = cmpWrp.cmpM.Referral_Rank__c;
              }
              //rf.Call_In_Code__c = listCIC.get(le.Call_In_Code__c).Name;
              if(le.FirstName!=null){
                patientName = le.FirstName +' ';
              }
              if(le.MiddleName!=null){
                patientName += le.MiddleName +' ';
              }
              patientName += le.LastName;
              rf.Patient_Name__c = patientName;
              rf.RecordTypeId = refRecId;
              rf.Referral_Stage__c = 'Open';
              
              refList.add(rf);
              System.debug('refList....>'+refList);
            }
          }
        }              
        if(refList.size()>0){
          insert refList;
        }
      }
            //Patient_Contact Object upsert.
            Map<String,Patient_Contact__c> PatientContactMap = new Map<String,Patient_Contact__c>();
            if(patConWrpList.size()>0){
                for(PatientContactsWrp sd:patConWrpList){
                    Patient_Contact__c ad =sd.record;
                    ad.Opportunity__c = opp.Id;
                    ad.Contact__c = ConId;
                    PatientContactMap.put(sd.UniqueNmbr+'',ad);
                }
                upsert PatientContactMap.values();
            }
        
            List<Patient_Insurance__c> PatientInsuranceList = new list<Patient_Insurance__c>();
            if(PatientInsuranceWrpList.size()>0){
                for(PatientInsuranceWrp pIs:PatientInsuranceWrpList){
                    Patient_Insurance__c pisw = pIs.record;
                    pisw.Opportunity__c = opp.Id;
                    pisw.Patient__c = ConId;
                    if(pIs.patConUniqueNo!=null && pIs.patConUniqueNo!=''){                            
                        if(PatientContactMap.containsKey(''+pIs.patConUniqueNo)){
                            pisw.Subscriber__c = PatientContactMap.get(pIs.patConUniqueNo).Id;
                            pisw.Subscriber_is_Patient__c = false;                          
                        } else {
                            pisw.Subscriber__c = null;
                            pisw.Subscriber_is_Patient__c = true;
                        }
                    }
                    PatientInsuranceList.add(pisw);
                }
                insert PatientInsuranceList;
            }            
            
            List<Abused_Substance__c> AbusedSubstanceList = new list<Abused_Substance__c>();
            if(AbusedSubstanceWrpList.size()>0){
                for(AbusedSubstanceWrp abusub:AbusedSubstanceWrpList){
                    Abused_Substance__c abusedsub = abusub.record;
          if(abusedsub.Overdosed_on_this_Substance__c==null || abusedsub.Overdosed_on_this_Substance__c!='Yes'){
            abusedsub.Hospitalized_for_Overdose__c = null;
            abusedsub.Number_Times_Overdosed_on_this_Substance__c = null;
            abusedsub.Were_Any_Overdoses_Intentional__c = null;
            abusedsub.Most_Recent_Overdosed_Date__c = null;
            abusedsub.Explanation_of_Intentional_Overdose__c = null;
          }
                    abusedsub.Opportunity__c = opp.Id;
                    AbusedSubstanceList.add(abusedsub);
                }
                insert AbusedSubstanceList;
            }            
            
            List<Treatment_History__c> TreatmentHistoryList = new list<Treatment_History__c>();
            if(TreatmentHistoryWrpList.size()>0){
                for(TreatmentHistoryWrp tHs:TreatmentHistoryWrpList){
                    Treatment_History__c thw = tHs.record;
                    if(thw.Other_Facility__c==null && thw.Level_of_Care__c==null && thw.Was_Treatment_Involuntary__c==null && thw.Admit_Date__c==null && thw.Discharge_Date__c==null)
                        continue;
                    thw.Opportunity__c = opp.Id;
                    TreatmentHistoryList.add(thw);
                }
                insert TreatmentHistoryList;
            }            
            
            
            PageReference page = new PageReference('/'+opp.id);
            page.setRedirect(true);
            return page;
        }
        return null;
    }
    
    public pagereference cancel(){
        PageReference demoPage = new pagereference('/home/home.jsp');
        demoPage.setRedirect(true);
        return demoPage;
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
        } else if(patientDOB > currentDate){ 
            // birthday > today
            System.debug('patientDOB > currentDate');
            return null;
            //  birthday < today                    
        } else {
            monthsCal = patientDOB.monthsBetween(currentDate);          
            if (currentDate.day() < patientDOB.day()) monthsCal--;
            returnYears = monthsCal/12; 
            System.debug('patientDOB < currentDate');                       
        }
        //  will turn 26 years old in the current year
        if(returnYears == 25){
            if(pMnth > cMnth){
                redBoolead = true;
            } else if(pMnth == cMnth && pDate >= cDate){
                redBoolead = true;
            }                   
        } else { redBoolead = false; }                      
        System.debug('redBoolead__________________________'+redBoolead);  
        
        if(returnYears > 0){
            return returnYears;
            system.debug('returnYears__________________________'+returnYears);                  
        }      
        return null;
    } 
    
    //Wrapper class for Treatment history
    public class TreatmentHistoryWrp{
        public Integer index {get;set;}
        public Treatment_History__c record {get;set;}
        public TreatmentHistoryWrp(){
            record = new Treatment_History__c(); 
        }
    }  
    
    //Add New row to the Treatment_History__c related list
    public void addNewTreatmentHistoryObj(){
        TreatmentHistoryWrp newRecord = new TreatmentHistoryWrp();
        Treatment_History__c newTreatmentHistory = new Treatment_History__c();        
        newRecord.record = newTreatmentHistory;
        newRecord.index = TreatmentHistoryWrpList.size()-1;
        if(newRecord.index>=0){
            Treatment_History__c oldLORecord = TreatmentHistoryWrpList[newRecord.index].record;
            if(oldLORecord.Other_Facility__c==null && oldLORecord.Level_of_Care__c==null && oldLORecord.Was_Treatment_Involuntary__c==null && oldLORecord.Admit_Date__c==null && oldLORecord.Discharge_Date__c==null)
                 return;                
            /* newRecord.record.RecordTypeId = oldLORecord.RecordTypeId;           
            newRecord.record.Level_of_Care__c = oldLORecord.Level_of_Care__c;             
            newRecord.record.Other_Facility__c = oldLORecord.Other_Facility__c;           
            newRecord.record.Was_Treatment_Involuntary__c = oldLORecord.Was_Treatment_Involuntary__c;           
            newRecord.record.Admit_Date__c = oldLORecord.Admit_Date__c;
            newRecord.record.Discharge_Date__c = oldLORecord.Discharge_Date__c;   */         
        }
        TreatmentHistoryWrpList.add(newRecord);
    }
    
    //Wrapper class for Abustance Substance
    public class AbusedSubstanceWrp{
        public Integer index {get;set;}
        public Abused_Substance__c record {get;set;}
        public AbusedSubstanceWrp(){
            record = new Abused_Substance__c(); 
        }
    }
    
    //Open New Abused Substance object Page
    public pagereference openNewAbusedSubstancePage(){
        sub = new Abused_Substance__c();
        recordForEdit = false;
        return page.NewAbusedSubstancePage;
    }  
    
    // Edit Abused Substance Record from related list
    public pagereference abuseSubEdit(){
        sub = new Abused_Substance__c();
        sub =  AbusedSubstanceWrpList[rowToEdit].record;
        recordForEdit = true;
        return page.NewAbusedSubstancePage;
    }

    /***SAVEANDNEW Abused_Substance */
     public pagereference saveNewAbusedSubstanceObj(){
        AbusedSubstanceWrp newRecord = new AbusedSubstanceWrp();
        Abused_Substance__c newAbusedSubstance = new Abused_Substance__c();        
        newRecord.record = sub;
        newRecord.index = AbusedSubstanceWrpList.size();        
        AbusedSubstanceWrpList.add(newRecord);
        newRecord = new AbusedSubstanceWrp();
        sub = new Abused_Substance__c();
        return page.NewAbusedSubstancePage;
    }
    
    /***SAVEANDNEW Abused_Substance on EDIT*/
    public pagereference saveNewAbSubstanceOnEdit(){
        recordForEdit = false;
        sub = new Abused_Substance__c();
        //sub = AbusedSubstanceWrpList[rowToEdit].record;
        return page.NewAbusedSubstancePage;
    }
    //Add New row to the Abused_Substance__c related list
     public pagereference addNewAbusedSubstanceObj(){
        AbusedSubstanceWrp newRecord = new AbusedSubstanceWrp();
        Abused_Substance__c newAbusedSubstance = new Abused_Substance__c();        
        newRecord.record = sub;
        newRecord.index = AbusedSubstanceWrpList.size();        
        AbusedSubstanceWrpList.add(newRecord);
        return page.WalkInPage;
    } 
    
    //Cancel from Abused Subatcnce
    public pagereference cancel1(){
        return Page.WalkinPage;
    }
    
    //Delete one row from the Patient_Insurance__c Related List
    public void removeRowToPatientInsuranceList(){
        Patient_Insurance__c objpiDel = PatientInsuranceWrpList[rowToRemove].record;         
        if(objpiDel.id!=null){
            delete objpiDel;
        }
        PatientInsuranceWrpList.remove(rowToRemove);          
    }
    
    //Delete one row from the Abused_Substance__c Related List
    public void removeRowToAbusedSubstanceList(){
        Abused_Substance__c objpiDel1 = AbusedSubstanceWrpList[rowToRemove].record;       
        if(objpiDel1.id!=null){
            delete objpiDel1;
        }
        AbusedSubstanceWrpList.remove(rowToRemove); 
    }   
        
    //Delete one row from the Treatment_History__c Related List
    public void removeRowToTreatmentHistoryList(){
        Treatment_History__c objpiDel2 = TreatmentHistoryWrpList[rowToRemove].record;
        if(TreatmentHistoryWrpList.size()-1 == rowToRemove){
            if(TreatmentHistoryWrpList.size() == 1){
                if(objpiDel2.id!=null){ 
                    objpiDel2 = new Treatment_History__c(); 
                    objpiDel2.Id = TreatmentHistoryWrpList[rowToRemove].record.Id;
                } else{
                    objpiDel2 = new Treatment_History__c(); 
                } 
                TreatmentHistoryWrp newRecord = new TreatmentHistoryWrp(); 
                newRecord.record = objpiDel2; 
                TreatmentHistoryWrpList[rowToRemove] = newRecord;
            }else{
                if(objpiDel2.id!=null){
                    delete objpiDel2;
                }
                TreatmentHistoryWrpList.remove(rowToRemove);                 
            }            
        } else{ 
            if(objpiDel2.id!=null){
                delete objpiDel2;
            }
            TreatmentHistoryWrpList.remove(rowToRemove);  
        }
    }
       
    public List<SelectOption> getInsuranceCompany(){
       List<SelectOption> InsuranceCompany  = new List<SelectOption>();
        String name ;        
        InsuranceCompany.add(new SelectOption('','--None--'));
        for(Account acc:[SELECT Id,  Name FROM Account where RecordType.Name = 'Insurance Company' ORDER BY Name ASC]){          
            if(acc.Name  != null){
                InsuranceCompany.add(new SelectOption(acc.Id,acc.name));
            }
        }               
        return InsuranceCompany;
    }

    public List<SelectOption> getSubscriberName(){
          
        List<SelectOption> subscriberName  = new List<SelectOption>(); 
        subscriberName.add(new SelectOption('','--None--'));        
        String name = ''; 
        if(le.FirstName !=null && le.FirstName !=''){
            name = le.FirstName +' ';
        }
        if(le.LastName !=null && le.LastName !=''){
            name = name + (le.LastName+' (Patient)');
        }
        if(name!='')
            subscriberName.add(new SelectOption('conId', name));
        
        if(patConWrpList!=null && patConWrpList.size()>0){
            for(PatientContactsWrp pcWrp:patConWrpList){
                name='';                  
                if(pcWrp.record.First_Name__c !=null && pcWrp.record.First_Name__c !=''){
                    name = pcWrp.record.First_Name__c +' ';
                }
                if(pcWrp.record.Last_Name__c !=null && pcWrp.record.Last_Name__c !=''){
                    name = name + (pcWrp.record.Last_Name__c);
                }
                System.debug('name___________________________ '+name);  
                if(name !=''){
                    subscriberName.add(new SelectOption(''+pcWrp.UniqueNmbr, name));                  
                }     
            }
        }       
        return subscriberName;      
    }   
    
    public void SubscriberEmployer(){
    //if(!recordForEdit){
      System.debug('SubscriberEmployer__Called' + Selectedsubscriber);
      if(Selectedsubscriber !=null && Selectedsubscriber != ''){
        //patconEmployer = '';
        patIns.Subscriber_Employer__c='';
        if(Selectedsubscriber.equals('conId')){
          patIns.Subscriber_is_Patient__c = true;
        } else {
          patIns.Subscriber_is_Patient__c = false;
          for(PatientContactsWrp pcw:patConWrpList){
            if(pcw.UniqueNmbr+''==Selectedsubscriber){                  
              //patconEmployer = pcw.record.Employer__c;                        
              patIns.Subscriber_Employer__c = pcw.record.Employer__c;                        
            }
          }
        }
        
      } else {
        patIns.Subscriber_is_Patient__c = false;
        //patconEmployer = '';
        patIns.Subscriber_Employer__c = '';
        System.debug('patconEmployer_____________________ '+patIns.Subscriber_Employer__c);            
      } 
    //}
    }
    
    /** Patient Insurance New button START ****/
    //Wrapper class for Patient Insurance Object
    public class PatientInsuranceWrp{
        public Integer index {get;set;}
        public Patient_Insurance__c record {get;set;}
        public String patConUniqueNo;
        public String patConName {get;set;}     
        public String patientEmployer {get;set;}     
        public PatientInsuranceWrp(){
            patConName = '';
            patientEmployer = '';
            record = new Patient_Insurance__c(); 
        }
    } 
    
    //New Patient Insurance Page
    public pagereference openNewPatientInsPage(){
        patIns = new Patient_Insurance__c();
        recordForEdit = false;
		IOIC = false;
        patIns.Policy_Effective_Date__c = Date.newInstance((System.Today()).year(), 1, 1);
        patIns.Renewal_Date__c = Date.newInstance((System.Today().addYears(1)).year(), 1, 1);
        patIns.Term_Date__c = Date.newInstance((System.Today()).year(), 12, 31);
        if(con.Birthdate != null){
            Integer age = calculateYears(con.Birthdate);
            if(age >0){
                conAge = age;   
            } else {
                conAge = 0; 
            }   
        }
        return Page.NewPatientInsurancePage;
    }
    
    //Add New row to the Patient_Insurance__c related list
    public pagereference addNewPatientInsuranceObj(){
        PatientInsuranceWrp newRecord = updatedPatient();         
        newRecord.index = PatientInsuranceWrpList.size();        
        PatientInsuranceWrpList.add(newRecord);
        Selectedsubscriber = null;
        patconEmployer = null;
        recordForEdit = false;
        resCrtdPatConIds.clear();
        return page.WalkInPage;
    } 
    
    //Edit Patient Insurance from related list
    public pagereference patientInsEdit(){
        patIns = new Patient_Insurance__c();
        patIns =  PatientInsuranceWrpList[rowToEdit].record;
        Selectedsubscriber = PatientInsuranceWrpList[rowToEdit].patConUniqueNo;
        if(Selectedsubscriber!=null && Selectedsubscriber!='')
            //patconEmployer = PatientInsuranceWrpList[rowToEdit].patientEmployer;       
            patIns.Subscriber_Employer__c = PatientInsuranceWrpList[rowToEdit].patientEmployer;       
        recordForEdit = true;
        return page.NewPatientInsurancePage;
    }   
    
    //Save Updated Patient Insurance record.
    public pagereference updatePatientIontactObj(){
        if(resCrtdPatConIds.size()>0){ 
            for(String uniqueNo:new List<String>(resCrtdPatConIds)){
                for(integer i=0;i<patConWrpList.size();i++){
                    if(uniqueNo==''+(patConWrpList[i].UniqueNmbr)){
                        patConWrpList.remove(i);
                        break;
                    }
                }
            } 
            resCrtdPatConIds.clear();
        } 
        if(recordForEdit){
            PatientInsuranceWrpList[rowToEdit] = updatedPatient();          
        }
		if(!IOIC){
				patIns.Other_Insurance_Company__c = null;
			} 
        recordForEdit = false;       
        return page.WalkinPage;
    }
    
    public PatientInsuranceWrp updatedPatient(){
        PatientInsuranceWrp newRecord = new PatientInsuranceWrp();         
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){
            
            if(Selectedsubscriber.equals('conId')){
                patIns.Subscriber__c = null;                
                patIns.Subscriber_is_Patient__c = true;
                newRecord.patConName = '';
            } else {
                String name = '';
                for(PatientContactsWrp pcw:patConWrpList){
                    if(pcw.UniqueNmbr+''==Selectedsubscriber){
                        if(pcw.record.First_Name__c !=null && pcw.record.First_Name__c !=''){
                            name = pcw.record.First_Name__c +' ';
                        }
                        if(pcw.record.Last_Name__c !=null && pcw.record.Last_Name__c !=''){
                            name = name + pcw.record.Last_Name__c +' ';
                        }
                        newRecord.patConName = name;                                      
                        //newRecord.patientEmployer = pcw.record.Employer__c; 
                        newRecord.patientEmployer = patIns.Subscriber_Employer__c; 
                        break;
                    }
                }
            }
			
			if(!IOIC){
				patIns.Other_Insurance_Company__c = null;
			} 
            newRecord.patConUniqueNo = Selectedsubscriber;  
        }
			
        newRecord.record = patIns; 
        return newRecord;
    }
    
    //Wrapper class for Patient Contacts Object
    public class PatientContactsWrp{
        public Patient_Contact__c record {get;set;}
        public Integer UniqueNmbr; 
        public PatientContactsWrp(){
            UniqueNmbr = 0;
            record = new Patient_Contact__c(); 
        }
    } 
    
    //New Patient Contact
    public pagereference newPatientContact(){
        patcon = new Patient_Contact__c();
        return Page.NewPatContactForWalkinAddNew;
    }
        
    //New Patient Contacts from Patient Insurance
    public Pagereference addNewPCObjInPI(){        
        PatientContactsWrp newRecord = new PatientContactsWrp();     
        newRecord.record = patcon;
        newRecord.UniqueNmbr = patConWrpList.size();
        recordForEdit = false;
        patConWrpList.add(newRecord);
        Selectedsubscriber = ''+newRecord.UniqueNmbr;
        //patconEmployer = patcon.Employer__c;
        patIns.Subscriber_Employer__c = patcon.Employer__c;
        resCrtdPatConIds.add(''+newRecord.UniqueNmbr);
        patIns.Subscriber_is_Patient__c = false;
        return Page.NewPatientInsurancePage;
    } 
    
    public pagereference PatContactCancel(){
        return Page.NewPatientInsurancePage;
    }
	
	public void OtherInsCom(){
		IOIC = false;
		if(patIns.Insurance_Company__c != null){
			Account acct = [select id, Is_Other_Insurance_Company__c from Account WHERE Id =: patIns.Insurance_Company__c];
			if(acct.Is_Other_Insurance_Company__c){
				IOIC = true;
			}
		}
	}
}