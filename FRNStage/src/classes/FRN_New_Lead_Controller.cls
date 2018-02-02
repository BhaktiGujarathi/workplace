public class FRN_New_Lead_Controller{
    public List<SelectOption> callInCodePicklist {get;set;}
    public String selectedCallInCode {get;set;}
    public Lead nLead {get;set;} 
    public Boolean rend1 {get;set;}
    public Boolean rend2 {get;set;}
    public Boolean rend3 {get;set;}
    public Boolean rend4 {get;set;}
     
	public Integer rowToRemove{get;set;}
	public Integer searchPosition{get;set;}
	public List<CampaignMemberWrapper> campMWrpList{get;set;}
	public String leadId;
	
    public FRN_New_Lead_Controller(ApexPages.StandardController controller) {
		campMWrpList = new List<CampaignMemberWrapper>();
		
        rend1 = false ;
        rend2 = false ;
        rend3 = false ;
        rend4 = false ;
        
        nLead = new Lead();
        callInCodePicklist = new List<SelectOption>();
        List<Call_in_Code__c> listCIC = [SELECT Id,Name FROM Call_in_Code__c ORDER BY Name ASC];
        for(Call_in_Code__c eachCIC : listCIC){
           callInCodePicklist.add(new SelectOption(eachCIC.Id, eachCIC.name));
        }
       
	   
	   if(campMWrpList.size()==0){
            addNewRow();
        }
	   
    }
    
    public void rendSection(){
        System.debug('...>>'+nLead.LeadSource );
        if(nLead.LeadSource == 'Online'){
            rend1 = true;
            rend2 = false;
            rend3 = false;
            rend4 = false;
        }
        else if(nLead.LeadSource == 'Professional'){
            rend1 = false;
            rend2 = true;
            rend3 = false;
            rend4 = false;
        }
        else if(nLead.LeadSource == 'Friend or Family Member'){
            rend1 = false;
            rend2 = false;
            rend3 = true;
            rend4 = false;
        }
        else if(nLead.LeadSource == 'Unknown'){
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
	
	public pagereference editLead(){
		return null;
	}
	public pagereference deleteLead(){
		return null;
	}
	public pagereference cloneLead(){
		return null;
	}
	public pagereference fdLead(){
		return null;
	}
	public pagereference crtLead(){
		return null;
	}
	public pagereference cotLead(){
		return null;
	}
	public pagereference crooLead(){
		return null;
	}
	
	
	// logic for campaignMember..
	public void selectedvalue(){
		System.debug('campMWrpList ::>'+campMWrpList);
		System.debug('searchPosition ::>'+searchPosition);
		if(campMWrpList.size()>searchPosition){
			Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();   
			String acckeyPrefix = r.getKeyPrefix();
			Schema.DescribeSObjectResult r1 = Contact.sObjectType.getDescribe();   
			String conkeyPrefix = r1.getKeyPrefix();
			
			CampaignMemberWrapper wrp = campMWrpList[searchPosition];
			wrp.referralSourceConList.clear();
			wrp.referralSourceList.clear();  
			System.debug('wrp ::>'+wrp);
			if(wrp.searchKeyWord != null && wrp.searchKeyWord!=''){	  
				String accName, accID;      
				if(String.valueOf(wrp.searchKeyWord).startsWith(acckeyPrefix)){			
					for(Contact con: [SELECT id,AccountId, Account.name, name FROM Contact WHERE AccountId = :wrp.searchKeyWord]){
						wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
					}
					for(Account acc: [SELECT id, name,RAM_Lookup__r.name FROM Account WHERE Id = :wrp.searchKeyWord]){
						wrp.referralSourceList.add(new SelectOption(acc.id, acc.name));
						if(acc.RAM_Lookup__r.name!=null)
							wrp.cmpM.RAM_Assigned_to_Referral_Source__c = acc.RAM_Lookup__r.name;
					}
				}
				if(String.valueOf(wrp.searchKeyWord).startsWith(conkeyPrefix)){
					for(Contact con: [SELECT id,AccountId, Account.name,Account.RAM_Lookup__r.name, name FROM Contact WHERE id = :wrp.searchKeyWord]){
						wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
						accName = con.Account.name;
						accID = con.AccountId;
						if(con.Account.RAM_Lookup__r.name!=null)
							wrp.cmpM.RAM_Assigned_to_Referral_Source__c = con.Account.RAM_Lookup__r.name;
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
        CampaignMemberWrapper newRecord = new CampaignMemberWrapper();
        newRecord.index = campMWrpList.size();
        newRecord.cmpM.LeadId = leadId;
        campMWrpList.add(newRecord);
    }
	
	public class SearchWrapperClass{
		String id,label;
		public SearchWrapperClass(String wrid, String name){
			this.label = name;
			this.id = wrid;
		}
	} 
	
	public class CampaignMemberWrapper{      
        public Integer index {get;set;}
        public CampaignMember cmpM {get;set;}
        public String searchKeyWord {get; set;}
        public String selectedKeyWrp {get; set;}
        public List<SelectOption> referralSourceList {get; set;}
        public List<SelectOption> referralSourceConList {get; set;}
        public CampaignMemberWrapper(){
			cmpM = new CampaignMember();
            referralSourceList = new List<SelectOption>();
            referralSourceConList = new List<SelectOption>();
        }
    }
	
	public void removeRow(){
        System.debug('PracticeProviderWrpList......'+campMWrpList);
        System.debug('rowToRemove  in removeRowFromPOSList......'+rowToRemove); 
        
        if(campMWrpList.size()>rowToRemove){
            campMWrpList.remove(rowToRemove);
            for(integer i=rowToRemove;i<campMWrpList.size();i++){
                campMWrpList[i].index = i;               
            }
        }                
    }


}