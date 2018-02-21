/* 
 *  Description - Handler for TransactionLineDebitTrigger
 *                Set the Transaction to Pending when the Transaction Line Debit is deleted
 * 
 *  Date - 15-05-2014
 *  
 *  Created by - Sneha P.
 *
 */
public with sharing class TansactionLineDebitHandler {
	
	public static final String STATUS_PENDING = 'Pending';
	
	public void onAfterDelete(list<Transaction_Line_Debit__c> lineItemList){
		
		set<Id> setTransactionId = new set<Id>();
 		list<Transaction__c> updatedTransactionList = new list<Transaction__c>();
 		
 		for(Transaction_Line_Debit__c lineDebit : lineItemList){
			if(lineDebit.Transaction__c != null)
				setTransactionId.add(lineDebit.Transaction__c);
		}
		
		//Query all the Transaction related to Line Debits
		map<Id,Transaction__c> mapTransaction = new map<Id,Transaction__c>([Select Id,Amount__c,Status__c 
												 							from Transaction__c 
												 							where Id IN: setTransactionId]);
		
		for(Transaction_Line_Debit__c lineDebit : lineItemList){
			Transaction__c objTransaction = new Transaction__c();
			
			if(lineDebit.Transaction__c != null && mapTransaction.size() > 0 
												&& mapTransaction.containsKey(lineDebit.Transaction__c)){
				
				objTransaction =  mapTransaction.get(lineDebit.Transaction__c);
				objTransaction.Status__c = STATUS_PENDING;										
				updatedTransactionList.add(objTransaction);
			}
		}
		
		try{
			if(updatedTransactionList.size() > 0)
				update updatedTransactionList;
		}catch(Exception e){
			system.debug('-----'+e.getMessage());
		}							 
	}
}