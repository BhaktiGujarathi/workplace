/*
	Author : Deepthi
	Create On: 18th Jun 2013
	Class Name: BankAccountWizard
	Description : Used for BankAccountWizardVF page
	Modified By : Vasu Takasi || 19th Jun 2013
*/
global with sharing class BankAccountWizard {
	public Bank_Account__c objBankAccount{get;set;}
	public Credit_Card__c objCreditCard{get;set;}	
	public Bank_Account__c objBankAccountSummary{get;set;}
	public Credit_Card__c objCreditCardSummary{get;set;}	
	public string accName{get;set;}
	public string BizAddress{get;set;}
	public string HomeAddress{get;set;}
	public boolean accInfoView{get;set;}
	public boolean cCView{get;set;}
	public boolean summaryView{get;set;}
	public boolean accView{get;set;}
	public list<Account> lstBanks{get;set;}
	public string ownerInfo{get;set;}
	string Accid;
	string key;
	public Account objAccount{get;set;}
	public string wizardType{get;set;}
	public string bankAccountNo;
	public string midAccountNo;
	
	
	public BankAccountWizard(){
		objBankAccount=new Bank_Account__c();
		objBankAccount.Year__c = string.valueOf(system.today().year());
		objBankAccountSummary=new Bank_Account__c();
		objAccount=new Account();
		objCreditCard = new Credit_Card__c();
		objCreditCard.Year__c = string.valueOf(system.today().year());
		objCreditCardSummary=new Credit_Card__c();
		
		ownerInfo='';
		BizAddress='';
		HomeAddress='';
		wizardType='';
		key='';
		accId='';
		accInfoView=true;
		cCView=false;
		summaryView=false;
		accView=true;
		if(Apexpages.currentpage().getParameters().get('key') !=null && Apexpages.currentpage().getParameters().get('key') != '')
			key=Apexpages.currentpage().getParameters().get('key');
		if(Apexpages.currentpage().getParameters().get('id') != null && Apexpages.currentpage().getParameters().get('id') != '')	
			accId=Apexpages.currentpage().getParameters().get('id');
				
				if(key == 'BankWizard'){
					accInfoView=true;
					cCView=false;
					summaryView=false;
					accView=true;
				}
				else if(key == 'CCWizard'){
					accInfoView=false;
					cCView=true;
					summaryView=false;
					accView=true;
				}
				else if(key == 'SummaryWizard'){
					accInfoView=false;
					cCView=false;
					summaryView=true;
					accView=false;
				}
				if( accId != Null && accId !=''){
					//objBankAccount.Bank_Name__c=accId;
					//objCreditCard.Processor_Name__c=accId;
					
					objBankAccount.Account__c = accId;//Changed Customer Account mapping to Account__c field on 26-08-2013 
					objCreditCard.Account__c = accId;//Changed Customer Account mapping to Account__c field on 26-08-2013
				}			
		//query all records from Banks__c 
		lstBanks=new list<account>();
		lstBanks=[select id,name from account where name != null and RecordType.Name = 'Merchant Processor/Bank' order by name limit 45000];//Added RecordType filter on 26-08-2013
			AccountDetails();
					
	}
	//function to change wizard type based on selection
	public void changeWizard(){
		if(wizardType == 'BankAccounts'){
			accInfoView=true;
			cCView=false;
			summaryView=false;
			accView=true;
		}
		else if(wizardType == 'creditCard'){
			accInfoView=false;
			cCView=true;
			summaryView=false;
			accView=true;
		}
		else if(wizardType == 'summary'){
			accInfoView=false;
			cCView=false;
			summaryView=true;
			accView=false;
		}
		lstBanks=new list<account>();
		lstBanks=[select id,name from account where name != null and RecordType.Name = 'Merchant Processor/Bank' order by name limit 45000];//Added RecordType filter on 26-08-2013
		
	}
	
	//function to get Account Details
	public void AccountDetails(){
			objAccount=new Account();
			if(Accid !=null && Accid !=''){
			try{
	    	 objAccount=[Select id,Name,BillingCity,BillingCountry,BillingState,BillingStreet,BillingPostalCode,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,
	    	             Owner_1_Name__c,Owner_2_name__c,Other_Owners__c,Legal_Name__c,Monthly_Bank_Deposit_Avg_All__c,Monthly_Bank_Depopsit_Avg_Last_2_Months__c,Number_Bank_Statements_Available__c,
	    	             Number_CC_Statements_Available__c,Monthly_CC_Avg_All__c,Monthly_CC_Avg_Last_2_Months__c,Monthly_CC_Avg_Non_Amex__c,Bank_Names__c,Processor_Names__c,
	    	             MIDs__c,Bank_Acct_Nums__c,NDBs_Avg__c,NSFs_Avg__c,CC_transactions_Monthly_Avg__c  from Account where id=:Accid];
			}
			catch(exception e){
				apexPages.addMessages(e);
			}
			BizAddress='';
			HomeAddress='';
			if(objAccount !=null){
				if( objAccount.Name != null )
					accname=objAccount.Name;
					
				if( objAccount.BillingStreet != null )
					BizAddress=objAccount.BillingStreet+', ';
					
				if( objAccount.BillingCity != null ) 
					BizAddress += objAccount.BillingCity+', ';
					
				if( objAccount.BillingState != null )
					BizAddress +=objAccount.BillingState+', ';
					
				if( objAccount.BillingPostalCode != null)
					BizAddress +=objAccount.BillingPostalCode+', ';
					
				if( objAccount.BillingCountry != null)
					BizAddress +=objAccount.BillingCountry;
					
					BizAddress=BizAddress.removeEnd(', ');
					
				if( objAccount.ShippingStreet != null )
					HomeAddress=objAccount.ShippingStreet+', ';
					
				if( objAccount.ShippingCity != null) 
					HomeAddress +=objAccount.ShippingCity+', ';
					
				if( objAccount.ShippingState != null )
					HomeAddress +=objAccount.ShippingState+', ';
					
				if (objAccount.ShippingPostalCode != null)
					HomeAddress +=objAccount.ShippingPostalCode+', ';
					
				if( objAccount.ShippingCountry != null )
					HomeAddress +=objAccount.ShippingCountry;
					
					HomeAddress=HomeAddress.removeEnd(', ');
					
				if( objAccount.Owner_1_Name__c != null )	
					ownerInfo = objAccount.Owner_1_Name__c+', ';
					
				if( objAccount.Owner_2_Name__c != null )	
						ownerInfo += objAccount.Owner_2_Name__c+', ';
						
				if( objAccount.Other_Owners__c != null )	
						ownerInfo += objAccount.Other_Owners__c;	
						
					ownerInfo=ownerInfo.removeEnd(', ');
			}	
		}
		
	}
	
	public void saveBankAccountRec(){
		
				try{
					summaryView=false;
					cCView=false;
					accInfoView=true;
					objBankAccount.Account__c = accId;
					//string accParamId=apexpages.currentpage().getparameters().get('thePg:theFm:theComp:theBankAccComp:thePb:theBankAccPBS:BankName_lkid');
					//if( accParamId != '')
						// Accid = accParamId;
					insert objBankAccount;
					
					if(objBankAccount.id != null){
						objBankAccountSummary=new Bank_Account__c();
						objBankAccountSummary=objBankAccount;
						accInfoView=false;
						summaryView=true;
						cCView=false;
						accView=false;
						AccountDetails();
					}
					objBankAccount = new Bank_Account__c();
				}
				catch(exception e){
					apexPages.addMessages(e);
				}	
			
	}
	public void saveAndNewBankAccount(){
		objBankAccountSummary.clear();
		try{
			summaryView=false;
			cCView=false;
			accInfoView=true;
			//string accParamId=apexpages.currentpage().getparameters().get('thePg:theFm:theComp:theBankAccComp:thePb:theBankAccPBS:BankName_lkid');
			//if( accParamId != '')
			//	Accid = accParamId;
			objBankAccount.Account__c = accId;			
			insert objBankAccount;
			objBankAccountSummary=objBankAccount.clone();
			
			if(objBankAccount.id != null){
				accInfoView=true;
				summaryView=false;
				cCView=false;
				AccountDetails();
				objBankAccount.clear();
				objBankAccount.Bank_Name__c=objBankAccountSummary.Bank_Name__c;
				objBankAccount.Year__c = objBankAccountSummary.Year__c;
				objBankAccount.Bank_Account_Number__c = objBankAccountSummary.Bank_Account_Number__c;
			}
			
		}
		catch(exception e)
		{		
			apexPages.addMessages(e);			
		}
	}
	
	public pagereference saveCC(){
		try
		{
			summaryView=false;
			cCView=true;
			accInfoView=false;
			//string accParamId=apexpages.currentpage().getparameters().get('thePg:theFm:theComp:theBankAccComp:thePb:theCCPBS:procName_lkid');
			//if( accParamId != '')
				//Accid = accParamId;
				objCreditCard.Account__c = accId;
			insert objCreditCard;
			if(objCreditCard.Id != null ){
				objCreditCardSummary=new Credit_Card__c();
				objCreditCardSummary=objCreditCard;
				summaryView=true;
				cCView=false;
				accInfoView=false;
				accView=false;
				AccountDetails();
			}
			objCreditCard=new Credit_Card__c();
			return null;
		}
		catch(exception e)
		{		
			apexPages.addMessages(e);		
			return null;	
		}
	}
	
	public void saveAndNewCC(){
		objCreditCardSummary.clear();
		try
		{
				summaryView=false;
			cCView=true;
			accInfoView=false;
			//string accParamId=apexpages.currentpage().getparameters().get('thePg:theFm:theComp:theBankAccComp:thePb:theCCPBS:procName_lkid');
			//if( accParamId != '')
			//	accParamId = accParamId;
				objCreditCard.Account__c = accId;
			insert objCreditCard;
			objCreditCardSummary=objCreditCard;
			//midAccountNo=objCreditCard.MID_Account_Number__c;
			if(objCreditCard.Id != null ){
				objCreditCardSummary=objCreditCard.clone();
				summaryView=false;
				cCView=true;
				accInfoView=false;
				
				AccountDetails();
				objCreditCard.clear();
				objCreditCard.Processor_Name__c = objCreditCardSummary.Processor_Name__c;
				objCreditCard.MID_Account_Number__c = objCreditCardSummary.MID_Account_Number__c;
				//objCreditCard.Month__c = objCreditCardSummary.Month__c;
				objCreditCard.Year__c = objCreditCardSummary.Year__c;
				
			}
		}
		catch(exception e){		
			apexPages.addMessages(e);			
		}
	}
	
	//method name previousMonthAccNo
	//Descrition :The bank account number should come up when the user enters the subsequent month.
	// (The bank account number from the previous month should come up/auto fill)
	@remoteAction
	Global static string previousMonthAccNo(string month,string year,string accId){
		list<Bank_Account__c> lstBankAccount = new list<Bank_Account__c>();
		
		string accNo;
		string prevMonth;
		//query bank account records 
		if(accId !=null && accId !=''){
			lstBankAccount=[select id,Bank_Name__c,Month__c,Year__c,Name from Bank_Account__c where Bank_Name__c=:accId];
		}	
		map<string,string> mapAccNO = new map<string,string>();
		for(Bank_Account__c obj : lstBankAccount){
			mapAccNO.put(obj.Month__c+'::'+obj.Year__c,obj.name);
		} 
		if(Month != null){
			if(Month=='January')
				prevMonth = 'December';
			else if(Month=='February')
				prevMonth = 'January';
			else if(Month=='March')
				prevMonth = 'February';
			else if(Month=='April')
				prevMonth = 'March';
			else if(Month=='May')
				prevMonth = 'April';
			else if(Month=='June')
				prevMonth = 'May';
			else if(Month=='July')
				prevMonth = 'June';
			else if(Month=='August')
				prevMonth = 'July';
			else if(Month=='September')
				prevMonth = 'August';
			else if(Month=='October')
				prevMonth = 'September';
			else if(Month=='November')
				prevMonth = 'October';
			else if(Month=='December')
				prevMonth = 'November';
		}
		if( prevMonth == 'December'){
			integer intYear= integer.valueOf(year)-1;
			year = string.valueOf(intYear);
		}	
		if(!mapAccNO.isEmpty()){
			accNo = mapAccNO.get(prevMonth+'::'+year);
		}
		return accNo;
	}
}