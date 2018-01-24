/* Handler Class to calculate the Roll-up of Amount of Recivables on Opportunity
 *
 *
 * Revision History:
 *
 * Version      Author                      Date(mm/dd/yyyy)    Description
 * 1.0          Nachiket R. Deshpande       11/03/2014          Initial Draft
 * 2.0          Ajinkya Hingne              01/06/2017          Added undelete event for rollup
 */


public class ReceivableTriggerHandler {

    public void OnAfterInsert(Map<Id,Receivable__c> pOldReceivableMap,
            List<Receivable__c> pNewReceivableList ,
            Map<Id,Receivable__c> pNewReceivableMap
    ) {
        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalCommissionsReceivable(pOldReceivableMap,pNewReceivableList,pNewReceivableMap);
    }//End OnAfterInsert

    public void OnAfterUpdate(List<Receivable__c> pOldReceivableList, List<Receivable__c> pNewReceivableList ,
                              Map<Id,Receivable__c> pNewReceivableMap,Map<Id,Receivable__c> pOldReceivableMap){

        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalReceivableOnUpdate(pOldReceivableList,pNewReceivableList,pNewReceivableMap,pOldReceivableMap);
    }//End OnAfterUpdate

    public void OnAfterDelete(List<Receivable__c> pOldReceivableList, List<Receivable__c> pNewReceivableList ,
                              Map<Id,Receivable__c> pNewReceivableMap,Map<Id,Receivable__c> pOldReceivableMap){

        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalReceivableOnDelete(pOldReceivableList,pNewReceivableList,pNewReceivableMap,pOldReceivableMap);
    }//End OnAfterDelete

    public void onAfterUndelete(List<Receivable__c> pNewReceivableList, Map<Id,Receivable__c> pNewReceivableMap) {
        CalculateReceivableRollup objCalculateReceivableRollup = new CalculateReceivableRollup();
        objCalculateReceivableRollup.CalculateTotalCommissionsReceivable(null, pNewReceivableList, pNewReceivableMap);
    }
}//End ReceivableTriggerHandler