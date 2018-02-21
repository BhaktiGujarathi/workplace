/* Handler Class to calculate the Roll-up of Amount of Recivables on Opportunity
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/03/2014                              Initial Draft
 */ 


public  class ReceivableTriggerHandler {
    
    public void OnAfterInsert(map<Id,Receivable__c> pOldReceivableMap ,list<Receivable__c> pNewReceivableList ,
                              map<Id,Receivable__c> pNewReceivableMap)
    {
        
        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalCommissionsReceivable(pOldReceivableMap,pNewReceivableList,pNewReceivableMap);
    }
    
    public void OnAfterUpdate(list<Receivable__c> pOldReceivableList ,list<Receivable__c> pNewReceivableList , 
                              map<Id,Receivable__c> pNewReceivableMap,map<Id,Receivable__c> pOldReceivableMap)
    {
        
        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalReceivableOnUpdate(pOldReceivableList,pNewReceivableList,pNewReceivableMap,pOldReceivableMap);  
    }
    
    public void OnAfterDelete(list<Receivable__c> pOldReceivableList ,list<Receivable__c> pNewReceivableList ,
                              map<Id,Receivable__c> pNewReceivableMap,map<Id,Receivable__c> pOldReceivableMap)
    {
        
        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalReceivableOnDelete(pOldReceivableList,pNewReceivableList,pNewReceivableMap,pOldReceivableMap); 
    }
}