/* Handler Class to calculate the Roll-up of Amount of Recivables on Opportunity
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/04/2014                              Initial Draft
 */ 

public with sharing class PayableTriggerHandler {
    
    public void OnAfterInsert(map<Id,Payable__c> pOldPayableMap ,list<Payable__c> pNewPayableList){
        
        CalculatePayableRollup objCalculatePayableRollup = new CalculatePayableRollup();
        objCalculatePayableRollup.CalculateTotalCommissionsPayable(pOldPayableMap,pNewPayableList);
    }
    
    public void OnAfterUpdate(list<Payable__c> pOldPayableList ,list<Payable__c> pNewPayableList){
        
        CalculatePayableRollup objCalculatePayableRollup = new CalculatePayableRollup();
        objCalculatePayableRollup.CalculateTotalPayableOnUpdate(pOldPayableList,pNewPayableList);  
    }
    
    public void OnAfterDelete(list<Payable__c> pOldPayableList ,list<Payable__c> pNewPayableList){
        
        CalculatePayableRollup objCalculatePayableRollup = new CalculatePayableRollup();
        objCalculatePayableRollup.CalculateTotalPayableOnDelete(pOldPayableList,pNewPayableList); 
    }
}