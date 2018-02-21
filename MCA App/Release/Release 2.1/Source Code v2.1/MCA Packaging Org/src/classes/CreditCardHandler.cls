public with sharing class CreditCardHandler {
	
	public static final String frmInsert = 'Insert';
	public static final String frmUpdate = 'Update';
	public static final String frmDelete = 'Delete';
	
	public void onBeforeInsert(list<Credit_Card__c> creditCardList){
		updateAccount(null, creditCardList, frmInsert);
	}
	
	public void onBeforeUpdate(map<Id,Credit_Card__c> oldCreditCardMap, list<Credit_Card__c> creditCardList){
		updateAccount(oldCreditCardMap, creditCardList, frmInsert);	
	}
	
	public void onAfterInsert(list<Credit_Card__c> creditCardList){
		this.updateNoOfCCStmt(null, creditCardList, frmInsert);		
	}
	
	public void onAfterUpdate(map<Id, Credit_Card__c> creditCardOldMap , list<Credit_Card__c> creditCardList){
		updateNoOfCCStmt(creditCardOldMap, creditCardList, frmUpdate);
	}
	
	public void onAfterDelete(list<Credit_Card__c> creditCardList){
		this.updateNoOfCCStmt(null, creditCardList, frmDelete);		
	}
	
	public void updateAccount(map<Id,Credit_Card__c > oldCreditCardMap, list<Credit_Card__c> creditCardList, String frmOperation ){
		set<Id> setOpportunity = new set<Id>();
		
		for(Credit_Card__c objCC: creditCardList){
			if(objCC.Opportunity__c != null && (frmOperation == frmInsert || 
													(frmOperation == frmUpdate && 
			                                	  	    (objCC.Opportunity__c != oldCreditCardMap.get(objCC.Id).Opportunity__c ||
			                                	  	   objCC.Account__c == null)
			                                	  	)
			                                	)){
				setOpportunity.add(objCC.Opportunity__c);
			}
		}
		
		map<Id,Opportunity> oppMap;
		if(!setOpportunity.isEmpty())
			oppMap = new map<Id, Opportunity>([Select AccountId from Opportunity where Id IN: setOpportunity]);
			
		for(Credit_Card__c objCC: creditCardList){
			if(objCC.Opportunity__c != null && (frmOperation == frmInsert || 
													(frmOperation == frmUpdate && 
													  (objCC.Opportunity__c != oldCreditCardMap.get(objCC.Id).Opportunity__c) ||
													   objCC.Account__c == null)
											    ) 
											&& oppMap!= null && !oppMap.isEmpty() 
											&& oppMap.containsKey(objCC.Opportunity__c) 
											&& objCC.Account__c == null){
				objCC.Account__c = oppMap.get(objCC.Opportunity__c).AccountId;
			}
		}	
	}
	
	public void updateNoOfCCStmt(map<Id, Credit_Card__c> creditCardOldMap, list<Credit_Card__c> creditCardList, String frmOperation){
		
		set<Id> setAccountId = new set<Id>();
		set<Id> setOldAccountId = new set<Id>();
		map<Id,Account> updatedAccMap = new map<Id,Account>();
		
		for(Credit_Card__c creditCard : creditCardList){
			
			//If insert or delete maintain a set of associated Accounts
			if(frmOperation != frmUpdate && creditCard.Account__c != null)
				setAccountId.add(creditCard.Account__c);	
			
			//If from Update and the Coount is changed
			if(frmOperation == frmUpdate && creditCardOldMap.get(creditCard.Id).Account__c != creditCard.Account__c ){
				
				// Maintain a set of new Account
				if(creditCard.Account__c != null)
					setAccountId.add(creditCard.Account__c);
				
				// Maintain a set of old Account		
				if(creditCardOldMap.get(creditCard.Id).Account__c != null)	
					setOldAccountId.add(creditCardOldMap.get(creditCard.Id).Account__c);
			}	
		}
		
		//Query all the Account new/old and maintain in a map
		Map<Id,Account> accountMap = new map<Id,Account>([Select Number_CC_Statements_Available__c
														  from Account 
														  where Id IN: setAccountId or 
															    Id IN : setOldAccountId]);
		
		Account acc; 
		
		for(Credit_Card__c creditCard : creditCardList){
			
			// Fetch the new account record which is to be updated  	
			if(creditCard.Account__c != null && accountMap.size() > 0 && accountMap.containsKey(creditCard.Account__c)){
				
			
				acc = ((updatedAccMap.size() > 0 &&
					    updatedAccMap.containsKey(creditCard.Account__c)) ?
			      			updatedAccMap.get(creditCard.Account__c)  : 
			      				new Account( Id = creditCard.Account__c, 
			      							Number_CC_Statements_Available__c = accountMap.get(creditCard.Account__c).Number_CC_Statements_Available__c ));
			
				if((frmOperation == frmInsert || 
								   (frmOperation == frmUpdate &&  creditCardOldMap.get(creditCard.Id).Account__c != creditCard.Account__c)
								   ))
					acc.Number_CC_Statements_Available__c = 1 + (acc.Number_CC_Statements_Available__c == null ? 0 : acc.Number_CC_Statements_Available__c ); 
				else if(frmOperation == frmDelete)
					acc.Number_CC_Statements_Available__c = (acc.Number_CC_Statements_Available__c == null ? 0 : acc.Number_CC_Statements_Available__c ) - 1; 

				updatedAccMap.put(acc.Id, acc);
			}
			
			// If it is an update operation, get the old Account and subtract the count from the previuos account	
			if(frmOperation == frmUpdate && creditCardOldMap.get(creditCard.Id).Account__c != creditCard.Account__c &&
											accountMap.size() > 0 && 
											creditCardOldMap.get(creditCard.Id).Account__c != null &&
											accountMap.containsKey(creditCardOldMap.get(creditCard.Id).Account__c)  ){
				
				//get the old Account
				Account account = ((updatedAccMap.size() > 0 && updatedAccMap.containsKey(creditCardOldMap.get(creditCard.Id).Account__c)) ?
			      					updatedAccMap.get(creditCardOldMap.get(creditCard.Id).Account__c)  : 
			      				new Account( Id = creditCardOldMap.get(creditCard.Id).Account__c , 
			      							Number_CC_Statements_Available__c = accountMap.get(creditCardOldMap.get(creditCard.Id).Account__c).Number_CC_Statements_Available__c ));
			
				account.Number_CC_Statements_Available__c = (account.Number_CC_Statements_Available__c == null ? 0 : account.Number_CC_Statements_Available__c ) - 1; 
				updatedAccMap.put(account.Id, account);
			}
		}
		
		if(updatedAccMap.size() > 0)
			update updatedAccMap.Values();
	}
}