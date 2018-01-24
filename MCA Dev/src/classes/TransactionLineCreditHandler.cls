/* 
 *  Description - Handler for TransactionLineCreditTrigger
 *                Set the Transaction to Pending when the Transaction Line Credit is deleted
 * 
 *  Date - 15-05-2014
 *  
 *  Created by - Sneha P.
 *
 */
public with sharing class TransactionLineCreditHandler {
	
	public static final String STATUS_PENDING = 'Pending';
	
	//Function called on After Delete of Transaction line credit
	public void onAfterDelete(list<Transaction_Line_Credit__c> lineItemList){
		
		set<Id> setTransactionId = new set<Id>();
		set<Id> setReceivableId = new set<Id>();
		map<Id,Receivable__c> mapUpdatedReceivable = new map<Id,Receivable__c>();
		
		map<Id,Transaction__c> updatedTransactionMap = new map<Id,Transaction__c>();
		
		for(Transaction_Line_Credit__c lineItem : lineItemList){
			
			if(lineItem.Transaction__c != null){
				if(lineItem.Transaction__c != null)
					setTransactionId.add(lineItem.Transaction__c);
				if(lineItem.Receivable__c != null)
					setReceivableId.add(lineItem.Receivable__c);
			}
		}
		
		//Query all the Transaction related to Line Debits
		map<Id,Transaction__c> mapTransaction = new map<Id,Transaction__c>([Select Id,Amount__c,Status__c 
												 							from Transaction__c 
												 							where Id IN: setTransactionId]);
		
		map<Id,Receivable__c> mapReceivable = new map<Id,Receivable__c> ([Select Id,Receivable_Amount_Paid__c
																		  from Receivable__c 
																		  where Id IN: setReceivableId]);
		
		for(Transaction_Line_Credit__c lineItem : lineItemList){
			Transaction__c objTransaction = new Transaction__c();
			
			if(lineItem.Transaction__c != null && mapTransaction.size() > 0 
												&& mapTransaction.containsKey(lineItem.Transaction__c)){
				
				objTransaction =  (updatedTransactionMap.size() > 0 && updatedTransactionMap.containsKey(lineItem.Transaction__c) ) 
										?  updatedTransactionMap.get(lineItem.Transaction__c)
										 	: mapTransaction.get(lineItem.Transaction__c);
				objTransaction.Status__c = STATUS_PENDING;										
				updatedTransactionMap.put(objTransaction.Id,objTransaction );
			}
			
			Receivable__c objReceivable = new Receivable__c();
			if(lineItem.Receivable__c != null && mapReceivable.size() > 0 && 
										         mapReceivable.containsKey(lineItem.Receivable__c)){
				
				objReceivable = (mapUpdatedReceivable.size() > 0 && mapUpdatedReceivable.containsKey(lineItem.Receivable__c))
									? mapUpdatedReceivable.get(lineItem.Receivable__c)
										: mapReceivable.get(lineItem.Receivable__c);
				
				if( lineItem.Amount__c != null && objReceivable.Receivable_Amount_Paid__c != null &&
											      objReceivable.Receivable_Amount_Paid__c != 0){
					system.debug('*****objReceivable.Receivable_Amount_Paid__c**'+objReceivable.Receivable_Amount_Paid__c);
					system.debug('*****lineItem.Amount__c**'+lineItem.Amount__c);
					objReceivable.Receivable_Amount_Paid__c -=  lineItem.Amount__c ; 
					
					system.debug('*****lineItem.Amount__c after**'+lineItem.Amount__c);
					system.debug('*****objReceivable.Receivable_Amount_Paid__c after**'+objReceivable.Receivable_Amount_Paid__c); 
				}
				mapUpdatedReceivable.put(objReceivable.Id, objReceivable);										         	
			}
		}	
		
		try{
			if(updatedTransactionMap.size() > 0)
				update updatedTransactionMap.values();
			if(mapUpdatedReceivable.size() > 0)
				update mapUpdatedReceivable.values();
		}catch(Exception e){
			system.debug('-----'+e.getMessage());
		}											 							
	}
}