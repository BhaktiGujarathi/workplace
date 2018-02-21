/**
 * @description Service Class for McaApp__Receivable__c. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 *
 * @group Services
 *
 */
public with sharing class ReceivableService {

    /**
     * @description Method to filter a list of receivables for adjustments
     * @param receivables - List of McaApp__Receivable__c record to be filtered
     * @return List containing only receivable adjustments
     */
    public static List<McaApp__Receivable__c> filterReceivableAdjustments(List<McaApp__Receivable__c> receivables) {
        List<McaApp__Receivable__c> adjustments = new List<McaApp__Receivable__c>();
        for(McaApp__Receivable__c receivable : receivables) {
            if(isAdjustment(receivable)) adjustments.add(receivable);
        }
        return adjustments;
    }

    /**
     * @description Method to determine if receivable is an adjustment
     * @param receivable - McaApp__Receivable__c record to be checked
     * @return Boolean signifying whether or not receivable is an adjustment
     */
    public static Boolean isAdjustment(McaApp__Receivable__c receivable) {
        return (receivable.IsAdjustment__c && receivable.Adjustment_To__c != null && receivable.McaApp__Amount_Due__c != null);
    }

    /**
     * @description Method to create Payable Adjustments for receivables
     * @param receivables - List of McaApp__Receivable__c adjustment records for which to create related payable adjustments
     */
    public static void createPayableAdjustments(List<McaApp__Receivable__c> receivableAdjustments) {
        Set<Id> originalReceivableIds = new Set<Id>();
        for(McaApp__Receivable__c receivableAdjustment : receivableAdjustments) {
            originalReceivableIds.add(receivableAdjustment.Adjustment_To__c);
        }

        Map<Id, List<McaApp__Payable__c>> payablesByReceivableId = new Map<Id, List<McaApp__Payable__c>>();
        for(McaApp__Payable__c payable : getPayablesToAdjust(originalReceivableIds)) {
            if(!payablesByReceivableId.containsKey(payable.McaApp__Receivable_Dependency__c)) {
                payablesByReceivableId.put(payable.McaApp__Receivable_Dependency__c, new List<McaApp__Payable__c>());
            }
            payablesByReceivableId.get(payable.McaApp__Receivable_Dependency__c).add(payable);
        }

        List<McaApp__Payable__c> payableAdjustments = new List<McaApp__Payable__c>();

        for(McaApp__Receivable__c receivableAdjustment : receivableAdjustments) {
            if(!payablesByReceivableId.containsKey(receivableAdjustment.Adjustment_To__c)) continue;

            for(McaApp__Payable__c payable : payablesByReceivableId.get(receivableAdjustment.Adjustment_To__c)) {
                payableAdjustments.add(getPayableAdjustment(payable, receivableAdjustment));
            }
        }

        insert payableAdjustments;
    }

    private static McaApp__Payable__c getPayableAdjustment(McaApp__Payable__c originalPayable, McaApp__Receivable__c receivableAdjustment) {
        McaApp__Payable__c adjustment = new McaApp__Payable__c();
        adjustment.McaApp__Opportunity__c = originalPayable.McaApp__Opportunity__c;
        adjustment.McaApp__Status__c = 'Open - Needs Review';
        adjustment.IsAdjustment__c = true;
        adjustment.Adjustment_To__c = originalPayable.Id;
        adjustment.McaApp__Payable_Date__c = Date.today();
        adjustment.McaApp__Account__c = originalPayable.McaApp__Account__c;
        adjustment.McaApp__Amount_Due__c = receivableAdjustment.McaApp__Amount_Due__c * (originalPayable.McaApp__Percentage__c / 100);
        adjustment.McaApp__Payback_Funded__c = originalPayable.McaApp__Payback_Funded__c;
        adjustment.McaApp__Payee_Type__c = originalPayable.McaApp__Payee_Type__c;
        adjustment.McaApp__Due_Date__c = Date.today();
        adjustment.McaApp__Percentage__c = originalPayable.McaApp__Percentage__c;
        adjustment.OwnerId = receivableAdjustment.OwnerId;
        adjustment.McaApp__Receivable_Dependency__c = receivableAdjustment.Id;
        adjustment.McaApp__Type__c = originalPayable.McaApp__Type__c;
        return adjustment;
    }


    private static List<McaApp__Payable__c> getPayablesToAdjust(Set<Id> receivableIds) {
        Set<String> fundedValues = new Set<String> {'Commission Revenue', 'Net Commission Revenue', 'Origination Fee', 'Net Origination Fee'};
        return [SELECT Id, McaApp__Opportunity__c, McaApp__Account__c, McaApp__Percentage__c, McaApp__Payback_Funded__c, McaApp__Type__c, McaApp__Payee_Type__c, McaApp__Receivable_Dependency__c
                FROM McaApp__Payable__c WHERE McaApp__Receivable_Dependency__c IN :receivableIds AND McaApp__Percentage__c != null AND McaApp__Payback_Funded__c IN :fundedValues LIMIT 50000];
    }

}