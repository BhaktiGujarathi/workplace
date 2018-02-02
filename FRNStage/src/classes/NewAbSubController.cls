public class NewAbSubController {
    public Patient_Insurance__c pat{get;set;}
    public Patient_Contact__c patcon{get;set;}
    public Date StartYear = System.Today();
    public Date NextYear = System.Today().addYears(1);
    public Date startDate = System.Today();
    public String stYear{get;set;}
    public String stYear1{get;set;}
    public String stYear2{get;set;}
    public Contact con{get;set;}
    public String patconEmployer{get;set;}   
    public string Selectedsubscriber{get;set;}
    public Patient_Contact__c patcon1{get;set;}
    public boolean opptyForQue {get;set;}
    string oppid;
    string patconid;
    string retpg;
    
    public NewAbSubController(ApexPages.StandardController controller){
        opptyForQue = false;
        patconEmployer = '';
        oppid = apexpages.currentpage().getparameters().get('id');
        patconid = apexpages.currentpage().getparameters().get('patc');
        System.debug('patconid__________________________'+patconid);        
        retpg = apexpages.currentpage().getparameters().get('retpg');
        
        pat = new Patient_Insurance__c();
        patcon1 = new Patient_Contact__c();
        con = new Contact();
        pat.Policy_Effective_Date__c = Date.newInstance(StartYear.year(), 1, 1);
        pat.Renewal_Date__c = Date.newInstance(NextYear.year(), 1, 1);
        pat.Term_Date__c = Date.newInstance(StartYear.year(), 12, 31);
        stYear=String.valueof('1/1/'+startDate.year());
        stYear1='1/1/'+String.valueof(startDate.year()+1);
        stYear2=String.valueof('12/31/'+startDate.year());       
        patcon = new Patient_Contact__c();
    
        if(oppid != null && oppid != ''){
            pat.Opportunity__c=oppid;
            Opportunity opp  = [SELECT Contact__c,Contact__r.Social_Security_Number__c FROM Opportunity where Id =: oppId];
            patcon.Opportunity__c=oppid;
            patcon.Contact__c = opp.Contact__c;
        
            if(opp.contact__c != null){
                pat.Patient__c  = opp.contact__c;
                //pat.Subscriber_is_Patient__c = true;
                System.debug('autoPopulated_Patient__________________________'+pat.Patient__c);
                conDetail();
            }else{
        		//pat.Subscriber_is_Patient__c = false;
            }
            if(opp.Contact__r.Social_Security_Number__c != null ){
                pat.Patient_Social_Security_Number__c  = opp.Contact__r.Social_Security_Number__c;
                System.debug('PatientSocialSecurityNumber__________________________'+pat.Patient_Social_Security_Number__c);
                
            }
            
        }
        if(patconid != null && patconid != ''){
                Selectedsubscriber = patconid;
        }
        SubscriberEmployer();
    }
 
    public List<SelectOption> getInsuranceCompany(){
       List<SelectOption> InsuranceCompany  = new List<SelectOption>();
        string name ;
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
   
    public PageReference patientcontact() {
        if(oppid!=null){
            PageReference MyPageReference = new PageReference('/apex/NewPatContactPage?id='+ oppid);
            return MyPageReference;
        }
    if(pat.Opportunity__c != null){
     PageReference MyPageReference = new PageReference('/apex/NewPatContactPage?id='+pat.Opportunity__c);
            MyPageReference.setRedirect(true);
      return MyPageReference;  
    }
        return null;
    }
   
    public pagereference Cancel(){
        if(oppid!=null){
            system.debug('debug if');
            pageReference page= new pageReference('/'+oppid);
           return page;
        } else if(oppid == null && patconid == null && retpg != null){
                system.debug('debug else if');
                pageReference pagep= new pageReference('/apex/'+retpg);
                pagep.setRedirect(true);
                return pagep;
        } else {
                system.debug('debug else');
                pageReference pagep= page.NewPatientInsPage;
                return pagep;
        }
        return null;
        
    }
   
    public pagereference Save(){

        if(Selectedsubscriber !=null){
        	if(!Selectedsubscriber.trim().startsWith('006')) {
            	pat.subscriber__c = Selectedsubscriber;
        	} else {
        		
        	}

        }
        insert pat;
        
        if(pat.id!=null && oppid!=null){
            pageReference page= new pageReference('/'+oppid);
            return page;
        } else if(retpg != null){
      		pageReference pagep= new pageReference('/apex/'+retpg);
      		pagep.setRedirect(true);
            return pagep;
    }
        return null;
    
    }

    public List<SelectOption> getsubscriberName(){
        System.debug('pat.Opportunity___________________________ '+pat.Opportunity__c);     
        System.debug('opptyForQue___________________________ '+opptyForQue);        
        List<SelectOption> subscriberName  = new List<SelectOption>();  
       
        String OptyId = '';
        if(opptyForQue = false && oppid!=null){
            OptyId = oppid;
        } else if(opptyForQue = true){
            OptyId = pat.Opportunity__c;
        }
        System.debug('OptyId___________________________ '+OptyId);      
        
        if(OptyId!=null){
            subscriberName.add(new SelectOption('','--None--'));
            Integer counter = 0;
            for(Patient_Contact__c opp : [SELECT Id, Opportunity__c, First_Name__c,Last_Name__c,Employer__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM Patient_Contact__c where Opportunity__c =:OptyId]){
                  String name = '';
                  	if(counter == 0) {
	                    if(opp.Contact__c != null){
	                        if(opp.Contact__r.FirstName !=null && opp.Contact__r.FirstName !=''){
	                            name = opp.Contact__r.FirstName +' ';
	                        }
	                        name = name + (opp.Contact__r.LastName+' (Patient)');
	                        System.debug('name___________________________ '+name);              
	                        subscriberName.add(new SelectOption(opp.Opportunity__c, name));
	                    }
                  	}
	                        if(opp.First_Name__c !=null && opp.First_Name__c !=''){
	                            name = opp.First_Name__c +' ';
	                        }
	                        name = name + (opp.Last_Name__c);
	                        System.debug('name___________________________ '+name);              
	                        subscriberName.add(new SelectOption(opp.Id, name));
                  	
                  	counter = counter + 1;
            }   
                
        }
        System.debug('subscriberName___________________________ '+subscriberName);          
        return subscriberName;      
        
    }   
    
    public void SubscriberEmployer(){
        system.debug('SubscriberEmployer__Called' + Selectedsubscriber);
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){
    /***Set Subscriber_is_Patient == true */            
            List<Patient_Contact__c> patConList = [SELECT Id, Employer__c, Contact__c FROM Patient_Contact__c where Id =:Selectedsubscriber Order by CreatedDate DESC];
            system.debug('patConList_____________________ '+ patConList.size());
            
            if(patConList!=null && patConList.size()>0){
                patcon1 = patConList[0];
                if(patcon1.Employer__c != null) {
                    patconEmployer = patcon1.Employer__c;
                } else {
                	patconEmployer = '';
                }
                pat.Subscriber_is_Patient__c = false;
            } else {
            	pat.Subscriber_is_Patient__c = true;
            }
            system.debug('patconEmployer_____________________ '+patconEmployer);
            
        } else {
            patconEmployer = '';
            system.debug('patconEmployer_____________________ '+patconEmployer);
            
        }   
    }
 
    public pagereference SaveandNew(){
        if(pat.Patient__c == null){
            if(Selectedsubscriber !=null){
                pat.subscriber__c = Selectedsubscriber;
            }
        } else {
            //pat.Subscriber_is_Patient__c = true;
        }
        insert pat;
      
        if(oppid!=null && pat.id!=null){ 
            pat = new Patient_Insurance__c();
            pat.Opportunity__c = oppId;
            populateFromOpp();  
            pat.Policy_Effective_Date__c = Date.newInstance(StartYear.year(), 1, 1);
            pat.Renewal_Date__c = Date.newInstance(NextYear.year(), 1, 1);
            pat.Term_Date__c = Date.newInstance(StartYear.year(), 12, 31);
            
            pageReference page= new pageReference('/apex/NewPatientInsPage');
            page.setRedirect(true);
        } else if(pat.id!=null && oppid == null){       
                    pat = new Patient_Insurance__c(); 
                    pat.Policy_Effective_Date__c = Date.newInstance(StartYear.year(), 1, 1);
                    pat.Renewal_Date__c = Date.newInstance(NextYear.year(), 1, 1);
                    pat.Term_Date__c = Date.newInstance(StartYear.year(), 12, 31);                  
                    pageReference page = new pageReference('/apex/NewPatientInsPage');
                    page.setRedirect(true);     
        }       
        return null;
    }
    
    public pagereference PatContactCancel(){
        if(oppid != null && oppid != ''){
            pageReference page= new pageReference('/apex/NewPatientInsPage?id='+oppid);
            return page;            

        } else {
            pageReference page= new pageReference('/apex/WalkInPage');
            return page;            

        }
        return null;
    }
    
    public pagereference Save1(){
          
        insert patcon;
        if(patcon.id!=null){
            pageReference page= new pageReference('/apex/NewPatientInsPage?id='+patcon.Opportunity__c+'&patc='+patcon.id);
            page.setRedirect(true);
            return page;     
        }
        return null;
    
    }
    
    public pagereference SaveandNew1(){
        insert patcon;
        if(patcon.id!=null){ 
            patcon = new Patient_Contact__c();
            if(oppid!=null){
                pageReference page= new pageReference('/apex/NewPatContactPage?id='+oppid);
                page.setRedirect(true);
                return page; 
            }
        } 
        return null;
    }
    
    public void conDetail(){
        if(pat.Patient__c!= null){
            
            con=[Select Id, Age__c,Birthdate from contact where Id =: pat.Patient__c];
        }
    }

    
    public void populateFromOpp(){
        System.debug('Pat.Opportunity___________________________ '+pat.Opportunity__c);
        if(pat.Opportunity__c != null){
            opptyForQue = true;
            getsubscriberName();
            getInsuranceCompany();
        }   
        if(pat.Opportunity__c != null){
            Opportunity opp  = [SELECT Contact__c,Contact__r.Social_Security_Number__c FROM Opportunity where Id =: pat.Opportunity__c];
            patcon.Opportunity__c=pat.Opportunity__c;
            patcon.Contact__c = opp.Contact__c;
        
            if(opp.contact__c != null){
                pat.Patient__c  = opp.contact__c;
                //pat.Subscriber_is_Patient__c = true;
                System.debug('autoPopulated_Patient__________________________'+pat.Patient__c);
                conDetail();
            }else{
                //pat.Subscriber_is_Patient__c = false;
            }
            if(opp.Contact__r.Social_Security_Number__c != null ){
                pat.Patient_Social_Security_Number__c  = opp.Contact__r.Social_Security_Number__c;
                System.debug('PatientSocialSecurityNumber__________________________'+pat.Patient_Social_Security_Number__c);
                
            }
            
        }
        
        
    }
 

}