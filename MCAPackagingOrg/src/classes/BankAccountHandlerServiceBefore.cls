/*
* Version       Date             Author         Description
*   1.0         23/10/2015       Ashwini S      Updating Account field on bank Account object.
*/
public without sharing class BankAccountHandlerServiceBefore {

public BankAccountHandlerServiceBefore(){}
// Updating account  if  account is not selected by user on  Bankstatements currently called on Before Update and Before insert.
public void updateAccount(map<Id,Bank_Account__c > oldBankAccMap, list<Bank_Account__c> BankAccountList, String frmOperation ){
        set<Id> setOpportunity = new set<Id>();
        
        for(Bank_Account__c objBA: BankAccountList){
            if( objBA.Opportunity__c != null && (frmOperation == BankAccountHandler.frmInsert || (frmOperation == BankAccountHandler.frmUpdate && 
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
            if((frmOperation == BankAccountHandler.frmInsert || (frmOperation == BankAccountHandler.frmUpdate && 
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
}