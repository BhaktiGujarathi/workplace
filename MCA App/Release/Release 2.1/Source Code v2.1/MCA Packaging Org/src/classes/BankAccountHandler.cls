public with sharing class BankAccountHandler {
	
	public static final String frmInsert = 'Insert';
	public static final String frmUpdate = 'Update';	
	public static final String frmDelete = 'Delete';
	
	public void onBeforeInsert(list<Bank_Account__c> BankAccountList){
		updateAccount(null, BankAccountList, frmInsert);
	}
	
	public void onBeforeUpdate(map<Id,Bank_Account__c > bankAccountOldMap,list<Bank_Account__c> BankAccountList){
		updateAccount(bankAccountOldMap, BankAccountList, frmUpdate);
	}
	

	public void onAfterInsert(list<Bank_Account__c> BankAccountList){
		updateNoOfBankAcc(null,BankAccountList,frmInsert);
	}
	
	public void onAfterUpdate(map<Id, Bank_Account__c> bankAccountOldMap , list<Bank_Account__c> BankAccountList){
		updateNoOfBankAcc(bankAccountOldMap, BankAccountList, frmUpdate);
	}
	
	public void onAfterDelete(list<Bank_Account__c> BankAccountList){
		updateNoOfBankAcc(null,BankAccountList,frmDelete);
	}
	
	//Function used to update Account on Bank Statements to Acc of opportunity
	public void updateAccount(map<Id,Bank_Account__c > oldBankAccMap, list<Bank_Account__c> BankAccountList, String frmOperation ){
		set<Id> setOpportunity = new set<Id>();
		
		for(Bank_Account__c objBA: BankAccountList){
			if( objBA.Opportunity__c != null && (frmOperation == frmInsert || (frmOperation == frmUpdate && 
			                                        (objBA.Opportunity__c != oldBankAccMap.get(objBA.Id).Opportunity__c || 
			                                         objBA.Account__c == null)
			                                     ))){
				setOpportunity.add(objBA.Opportunity__c);
			}
		}
		
		map<Id,Opportunity> oppMap;
		
		if(!setOpportunity.isEmpty())
			oppMap = new map<Id, Opportunity>([Select AccountId from Opportunity where Id IN: setOpportunity]);
		
		for(Bank_Account__c objBA: BankAccountList){
			if((frmOperation == frmInsert || (frmOperation == frmUpdate && 
			                                   (objBA.Opportunity__c != oldBankAccMap.get(objBA.Id).Opportunity__c || 
			                                    objBA.Account__c == null)
			                                  )) 
	                                && objBA.Opportunity__c != null && oppMap != null && !oppMap.isEmpty() 
								    && oppMap.containsKey(objBA.Opportunity__c)
								    && objBA.Account__c == null){
				objBA.Account__c = oppMap.get(objBA.Opportunity__c).AccountId;
			}
		}
	}
	
	public void updateNoOfBankAcc(map<Id, Bank_Account__c> bankAccountOldMap, list<Bank_Account__c> BankAccountList, String frmOperation){
		set<Id> setAccountId = new set<Id>();
		set<Id> setOldAccountId = new set<Id>();
		map<Id,Account> updatedAccMap = new map<Id,Account>();
		
		// Loop through all the newly created records
		for(Bank_Account__c bankAcc: BankAccountList){
			//If the lookup filed is not empty
			if(frmOperation != frmUpdate && bankAcc.Account__c != null){
				//maintain a set of  IDs
				setAccountId.add(bankAcc.Account__c);
			}
			
			//If from Update and the Coount is changed
			if(frmOperation == frmUpdate && bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c ){
				
				// Maintain a set of new Account
				if(bankAcc.Account__c != null)
					setAccountId.add(bankAcc.Account__c);
				
				// Maintain a set of old Account		
				if(bankAccountOldMap.get(bankAcc.Id).Account__c != null)	
					setOldAccountId.add(bankAccountOldMap.get(bankAcc.Id).Account__c);
			}	
		}
		
		//Query all the Opportunities
		Map<Id,Account> accountMap = new map<Id,Account>([Select Number_Bank_Statements_Available__c 
																	   from Account  
																	   where Id IN: setAccountId or 
															    			 Id IN : setOldAccountId]);
		
		Account acc; 
		
		for(Bank_Account__c bankAcc: BankAccountList){
			//If the lookup field is not empty
			if(bankAcc.Account__c != null && accountMap.size() > 0 && accountMap.containsKey(bankAcc.Account__c)){
				
				acc = ( (updatedAccMap.size() > 0 && accountMap.containsKey(bankAcc.Account__c)) ?
				      			updatedAccMap.get(bankAcc.Account__c )  : 
				      				new Account( Id = bankAcc.Account__c, 
				      							 Number_Bank_Statements_Available__c = accountMap.get(bankAcc.Account__c).Number_Bank_Statements_Available__c));
				
				if((frmOperation == frmInsert || 
								   (frmOperation == frmUpdate &&  bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c)
								   ))
					acc.Number_Bank_Statements_Available__c = 1+ (acc.Number_Bank_Statements_Available__c == null ? 0 : acc.Number_Bank_Statements_Available__c ); 
				else if(frmOperation == frmDelete)
					acc.Number_Bank_Statements_Available__c = (acc.Number_Bank_Statements_Available__c == null ? 0 : acc.Number_Bank_Statements_Available__c ) - 1; 
				updatedAccMap.put(acc.Id, acc);
			}
			
			// If it is an update operation, get the old Account and subtract the count from the previuos account	
			if(frmOperation == frmUpdate && bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c &&
											accountMap.size() > 0 && 
											bankAccountOldMap.get(bankAcc.Id).Account__c != null &&
											accountMap.containsKey(bankAccountOldMap.get(bankAcc.Id).Account__c)  ){
				
				//get the old Account
				Account account = ((updatedAccMap.size() > 0 && updatedAccMap.containsKey(bankAccountOldMap.get(bankAcc.Id).Account__c)) ?
			      					updatedAccMap.get(bankAccountOldMap.get(bankAcc.Id).Account__c)  : 
			      				new Account( Id = bankAccountOldMap.get(bankAcc.Id).Account__c , 
			      							Number_Bank_Statements_Available__c = accountMap.get(bankAccountOldMap.get(bankAcc.Id).Account__c).Number_Bank_Statements_Available__c ));
			
				account.Number_Bank_Statements_Available__c = (account.Number_Bank_Statements_Available__c == null ? 0 : account.Number_Bank_Statements_Available__c ) - 1; 
				updatedAccMap.put(account.Id, account);
			}
		}
		if(updatedAccMap.size() > 0)
			update updatedAccMap.Values();
	}
}