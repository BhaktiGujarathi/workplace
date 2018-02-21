/* 
 *  Apex controller class call from ManageRenewal page to display all opportunity which are moving to renewal.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Neena Tiwari           26/3/2014            Initial Draft 
 *  1.1				  Sneha Patil			 16/04/2014           -Displayed Thankyou Page on Create Of Opportunities
 *  1.2				  Neena Tiwari			 22/05/2014			   Changing the filter criteria to display renewals
 */
public with sharing class MovingRenewalController {
    
    //Variables
    private map<Id, Decimal> mapBankWithCount;
    private map<Id, Decimal> mapBankWithBalanceAmount;
    private map<Id,Account> mapAllBankIdWithName;
    private static final string BANK_NAME = 'Bank';
    private static final string OPPRENEWALCLOSEDLOST = 'Closed Lost';
    private static final string OPPRenewalDeclined = 'Declined';
    private static final string ContractClosedRenewed = 'Closed/Renewed';
  
    //Properties
    public list<RenewalWrapper> RenewalWrapperLst     {get;set;}
    public list<PieWedgeData> pieDataBankWithCount    {get;set;}
    public list<PieWedgeData> pieDataBankWithBalance  {get;set;}
    public list<Contract> contractLst                 {get;set;}
    public Contract Cont                              {get;set;}
    public boolean displayPopup                       {get;set;}
    public string DelayTime                           {get;set;}
    public string bankName                            {get;set;}    
    public boolean showThankyouPage					  {get;set;}
    public list<Opportunity> newOppLst 				  {get;set;}
    public list<Task> taskLst 						  {get;set;}
    public Integer cnt = 0;
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    
    public String sortExpression
    {
         get { return sortExp; }
         set
         {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
        }
    }
    
     public String getSortDirection()
     {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     } 
    
    
    //Controller
    public MovingRenewalController(){ 
    	this.init();
        
    }//controller ends
    
    public void init(){
        //Initializing all parameters
        RenewalWrapperLst = new list<RenewalWrapper>();
        mapBankWithCount = new map<Id, Decimal>();
        mapBankWithBalanceAmount = new map<Id, Decimal>();
        pieDataBankWithBalance  = new list<PieWedgeData>(); 
        pieDataBankWithCount = new list<PieWedgeData>();
        cont = new Contract();
        displayPopup = false;
        bankName = '';
		showThankyouPage = false;
		newOppLst = new list<Opportunity>(); 
		taskLst = new list<Task>();
		string sortFullExp = sortExpression  + ' ' + sortDirection;
    	Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Contract.fields.getMap();
        string fieldnames = ' ';
        String query ;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            fieldnames += s + ',';
        }
         fieldnames = fieldnames.substring(0,fieldnames.length()-1);
         query ='Select'+fieldnames+ ' ,Opportunity__r.Date_Funded__c, Opportunity__r.OwnerId,Bank__r.Name,Opportunity__r.Funding_Amount__c, Opportunity__r.Payback_Amount__c, Opportunity__r.Term_Months__c from '+
                 SObjectType.Contract.Name + ' where '+ 
	        	                SObjectType.Contract.fields.Opportunity__c.Name+' <> null AND '+ 
	        	              	'( '+ SObjectType.Contract.fields.Opportunity_Renewal__c.Name+' = null OR '+
	                  			' Opportunity_Renewal__r.StageName = \''+OPPRENEWALCLOSEDLOST+
	                  			'\' OR Opportunity_Renewal__r.StageName = \''+OPPRenewalDeclined+ '\') AND '+  
	               				SObjectType.Contract.fields.Opportunity__c.Name+' <> null AND '+ SObjectType.Contract.fields.Stage__c.Name+' != \''+ContractClosedRenewed+'\''+
	               				' order by '+sortFullExp;
        system.debug('***Query***'+query);
        contractLst = Database.query(query);
        mapAllBankIdWithName = new map<Id,Account>([select Name,Id 
                                                    from Account 
                                                    where RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().
                                                                         get(BANK_NAME).getRecordTypeId()]); 
        Decimal countOfBank = 0;
        Decimal balanceAmount = 0;
       
        //Passing value to wrapper list to display all renewals on page 
        for(Contract contract : contractLst){
        	if(contract.Bank__c <> null && contract.Bank__r.Name != '' ){
        		if(mapBankWithCount.containsKey(contract.Bank__c)){
        			countOfBank = mapBankWithCount.get(contract.Bank__c) + 1;
        			balanceAmount = mapBankWithBalanceAmount.get(contract.Bank__c);
        			mapBankWithCount.put(contract.Bank__c, countOfBank);
        			mapBankWithBalanceAmount.put(contract.Bank__c, (contract.Current_Balance_Amt__c <> null ?
        															balanceAmount +  contract.Current_Balance_Amt__c : 
        															balanceAmount));
        		}//End if
        		else{
        			mapBankWithCount.put(contract.Bank__c, 1);
        			
        			mapBankWithBalanceAmount.put(contract.Bank__c, contract.Current_Balance_Amt__c <> null ?
        			                                               contract.Current_Balance_Amt__c : 0);
        		}//End else
        	}//End if
        	
            RenewalWrapperLst.add(new RenewalWrapper(contract,false));  
        }//End for 
        
        for(Id bankIds :  mapBankWithCount.keyset()){
        	if(mapAllBankIdWithName.get(bankIds) <> null)
        		pieDataBankWithCount.add(new PieWedgeData(mapAllBankIdWithName.get(bankIds).Name,
        	                                          	  mapBankWithCount.get(bankIds)));
        	
			if(mapAllBankIdWithName.get(bankIds) <> null)		                                        
        		pieDataBankWithBalance.add(new PieWedgeData(mapAllBankIdWithName.get(bankIds).Name,
        	                                            	mapBankWithBalanceAmount.get(bankIds)));   
        }//End for
    }//End init method.	
    
    public void getContractsAfterFilter(){
    	string sortFullExp = sortExpression  + ' ' + sortDirection;
        string q;
    	Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Contract.fields.getMap();
        string fieldnames = ' ';
        String query ;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            fieldnames += s + ',';
        }
         fieldnames = fieldnames.substring(0,fieldnames.length()-1);
         query ='Select'+fieldnames+ ' ,Opportunity__r.Date_Funded__c,Opportunity__r.OwnerId, Bank__r.Name,Opportunity__r.Funding_Amount__c, Opportunity__r.Payback_Amount__c, Opportunity__r.Term_Months__c from '+
                 SObjectType.Contract.Name;

        if((Cont.Current_Balance_Date__c != null || 
            Cont.Renewal_Eligibility_Percent__c != null || 
            Cont.Anticipated_Renewal_Date__c != null ||
            Cont.Renewal_Eligibility_Days_from_funding__c != null ||
            Cont.Current_Balance_Amt__c != null ||
            Cont.Funded_Date__c != '--None--' ||
            bankName != '')){
        	
        	string dateString;
            cnt++;
            query += ' Where ';
            if(Cont.Current_Balance_Date__c != null){
            	dateString = string.valueOf(Cont.Current_Balance_Date__c);
                query += SObjectType.Contract.fields.Current_Balance_Date__c.Name+'<= ' + dateString; 
            }
            if(Cont.Renewal_Eligibility_Percent__c != null){
            	if(query.substring(query.length() - 8).contains('Where')){
		        	query += SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name +' >= '+ Cont.Renewal_Eligibility_Percent__c;
				}
				else{
					query += ' AND ' + SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name+' >= '+ Cont.Renewal_Eligibility_Percent__c; 
				}
            }
            if(Cont.Anticipated_Renewal_Date__c != null){
            	dateString = string.valueOf(Cont.Anticipated_Renewal_Date__c);
            	if(query.substring(query.length() - 8).contains('Where')){
		        	 query +=SObjectType.Contract.fields.Anticipated_Renewal_Date__c.Name+' <= ' + dateString;  
				}//End if.
				else{
					query += ' AND '+ SObjectType.Contract.fields.Anticipated_Renewal_Date__c.Name+' <= ' + dateString; 
				}//End else.
            }//End if.
            if(Cont.Funded_Date__c != null){
            	String objdate;
            	String dateTimeFormat = DateTime.now().format('yyyy-MM-dd');
            	
            	if(Cont.Funded_Date__c.equalsIgnoreCase('Last 2 Months'))
            		objdate = DateTime.now().addMonths(-2).format('yyyy-MM-dd');
            	else if(Cont.Funded_Date__c.equalsIgnoreCase('Last 4 Months'))
            		objdate = DateTime.now().addMonths(-4).format('yyyy-MM-dd');
            	else if(Cont.Funded_Date__c.equalsIgnoreCase('Last 6 Months'))
            		objdate = DateTime.now().addMonths(-6).format('yyyy-MM-dd');
            	else if(Cont.Funded_Date__c.equalsIgnoreCase('Last 12 Months'))
            		objdate = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
            		
            	if(query.substring(query.length() - 8).contains('Where')){
		        	//Modified by sneha 23-05
		        	query += 'Opportunity__r.Date_Funded__c <= '+ dateTimeFormat+' AND Opportunity__r.Date_Funded__c >= '+objdate;
				}//End if.
				else{
					query += ' AND Opportunity__r.Date_Funded__c <= '+dateTimeFormat+' AND Opportunity__r.Date_Funded__c >= '+objdate;
				}
            }//End if.

            if(Cont.Bank__c != null){
            	if(query.substring(query.length() - 8).contains('Where')){
		        	query += 'Bank__r.Name like \'%' + String.escapeSingleQuotes(String.ValueOf(mapAllBankIdWithName.get(Cont.Bank__c).Name))+'%\'';
				}//End if.
				else{
					query += ' AND Bank__r.Name like \'%' + String.escapeSingleQuotes(String.ValueOf(mapAllBankIdWithName.get(Cont.Bank__c).Name))+'%\'';
				}
            }//End if.
        }//End if.
        if(query.substring(query.length() - 8).contains('Where')){
        	this.init();
        }
        else{
        	query += ' AND ( '+ SObjectType.Contract.fields.Opportunity_Renewal__c.Name+' = null OR '+
                              ' Opportunity_Renewal__r.StageName = \''+OPPRENEWALCLOSEDLOST+
                             '\' OR Opportunity_Renewal__r.StageName = \''+OPPRenewalDeclined+ '\') AND '+  
        	                 SObjectType.Contract.fields.Opportunity__c.Name+' <> null '+'order by '+sortFullExp;
        	
        	RenewalWrapperLst.clear();
	        for(Contract Contracts : Database.query(query)){
	        	RenewalWrapperLst.add(new RenewalWrapper(Contracts,false));
	        } 
        }
    }//End getContractsAfterFilter method
    
    //Call Save method which will save changes of selected contract.
    public void save(){
        contractLst = new list<Contract>();
        list<RenewalWrapper> tempRenewalWrapperLst = new list<RenewalWrapper>();
        for(RenewalWrapper ContractWrap : RenewalWrapperLst){
            contractLst.add(ContractWrap.contract);
           
        }
        try{
            if(contractLst != null && contractLst.size()>0){
                update contractLst;
           		
           		apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                											 System.Label.MovingRenewal_SaveSuccessful);
                apexpages.addmessage(msg);  
                init();
                this.getContractsAfterFilter();
            }//End if
        }//End try
        Catch(Exception e){
            ApexPages.addMessages(e);
        }//End Catch
    }//End save method.
    
    //This method calls from Email Bank button.
    public void callEmailBank(){
    }
    
    //This method call from "Create Opportunites" which will change all selected contract to new opportunity.
    public PageReference createOpportunities(){
        contractLst = new list<Contract>();
        set<Id> insertedOppIds = new set<Id>();
        list<Opportunity> insertOppLst = new list<Opportunity>();
        map<String,Id> oppNumberMap = new map<String,Id>(); 
        for(RenewalWrapper createOppWrap : RenewalWrapperLst){
            if(createOppWrap.isSelected){
                cnt++;
                Opportunity theOpp = new Opportunity();
                theOpp.AccountId = createOppWrap.contract.AccountId;
                //theOpp.Name = 'Renewal Opp ' + createOppWrap.contract.Name;
                list<Account> accName= [select Name from Account where Id =: createOppWrap.contract.AccountId];
                theOpp.Name = 'Renewal Opp ' + accName[0].Name + ' - ' +system.today().format();
                theOpp.StageName = system.label.MovingRenewal_CreatedOppStage;
                theOpp.Contract_Auto_number_value__c = createOppWrap.contract.ContractNumber; 
                theOpp.CloseDate = system.today();
                theOpp.NextStep = system.label.MovingRenewal_CreatedOppNextStep;
                newOppLst.add(theOpp);
            }
        }
        
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
            //To bind the inserted opportunities in individual selected contracts.
            if(newOppLst != null && newOppLst.size() > 0){
                insert(newOppLst);
                
                insertOppLst = [Select Id,Contract_Auto_number_value__c from Opportunity 
                                where Contract_Auto_number_value__c <> null];
                                
                if(newOppLst != null && newOppLst.size() > 0){
                    for(Opportunity opp : newOppLst){
                        oppNumberMap.put(opp.Contract_Auto_number_value__c, opp.Id);
                    }
                }
                for(RenewalWrapper createOppWrap : RenewalWrapperLst){
                    createOppWrap.contract.Opportunity_Renewal__c = oppNumberMap.get(createOppWrap.contract.ContractNumber);
                    contractLst.add(createOppWrap.contract);
                }
                if(contractLst != null && contractLst.size() > 0){
                    update contractLst;
                	showThankyouPage = true;	
                }
            }
        }
        catch(Exception e){
            return null;
        }
    	return null;
    }
    
    // To open Javascript pop-up for adding delay eligibility time in renewal date.
    public void displayDelayEligibility(){
        for(RenewalWrapper PopupWrap : RenewalWrapperLst){
            if(PopupWrap.isSelected){
                cnt++;
                displayPopup = true;
            }
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
    }
    
    //to close the popup window
    public void ClosePopup(){
        displayPopup = false; 
    }
    //Balnk method used to refrence in actionsupport method
    public void autoPopulate1(){
    	
    }
    
    //The method will delay time to 'Renewal Date' i.e Anticipated Renewal Date.
    public void delayTime() {
    	contractLst = new list<Contract>();
        if(!DelayTime.equalsIgnoreCase('0')){
        	integer noOFDays = Integer.valueOf(DelayTime) * 7;
        	
	        for(RenewalWrapper wrapper: RenewalWrapperLst){
	        	if(wrapper.isSelected){
	         		wrapper.contract.Anticipated_Renewal_Date__c = (wrapper.contract.Anticipated_Renewal_Date__c <> null) ? 
	         		                                               (wrapper.contract.Anticipated_Renewal_Date__c.addDays(noOFDays)) :
	         		                                               (system.today().addDays(noOFDays));
	         		contractLst.add(wrapper.contract);
	         	}//End if
	        }//End for
	        
	        try{
            if(contractLst != null && contractLst.size()>0){
                upsert contractLst;
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                											 System.Label.MovingRenewal_SaveSuccessful);
                apexpages.addmessage(msg);  
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        }//End if
        displayPopup = false;
    }//End Delay Time method
    
    public PageReference createFollowupTask(){
        
        for(RenewalWrapper followupTaskWrap : RenewalWrapperLst){
            if(followupTaskWrap.isSelected){
                cnt++;
                Task followupTask = new Task();
                followupTask.WhatId = followupTaskWrap.contract.Id;  
                followupTask.IsReminderSet = true;
                followupTask.ReminderDateTime = system.now();
                followupTask.OwnerId = followupTaskWrap.contract.Opportunity__r.OwnerId;
                followupTask.Subject = 'Call';
                followupTask.Status = 'In Progress';
                followupTask.ActivityDate = system.today();
                taskLst.add(followupTask);
            }
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
            if(taskLst != null && taskLst.size() > 0){
                insert taskLst;
                //return new PageReference('/' + taskLst[0].Id);
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                											  system.label.MovingRenewal_FollowupTasksCreated);
                apexpages.addmessage(msg);  
            }
        }
        catch(Exception e){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
            apexpages.addmessage(msg);
        }
        return null;
    }
    
    //Wrapper Class contains Contract Object and isSelected to keep track of which Contract is selected 
    public class RenewalWrapper{
        
        public Contract contract          {get;set;}
        public boolean isSelected         {get; set;}

        public RenewalWrapper(Contract pcontract,Boolean pIsSelected){
            
            contract = pcontract;
            isSelected = pIsSelected;
        }
        
    }
    
    //Wrapper class to display bar chart statistics of all contracts and 
    //current balance amount associated to a bank. 
    public class PieWedgeData{  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        
        public PieWedgeData(String pName, Decimal pData){  
            this.name = pName;  
            this.data = pData;  
        }  
   }  
   
   public PageReference ViewSortedData_Contract() {
   	getContractsAfterFilter();
   		return null;
   }
}