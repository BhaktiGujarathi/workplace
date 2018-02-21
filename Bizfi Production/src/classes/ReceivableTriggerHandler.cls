/**
 * @description Trigger Handler for McaApp__Receivable__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion.
 * Ideally, business logic should not be included in this class. Trigger handlers are used to control recursion and order of execution and should delegate other work to service classes.
 *
 * @group Trigger Handlers
 *
 */
public with sharing class ReceivableTriggerHandler {

    /**
     * @description Method to process McaApp__Receivable__c records on Before Insert
     * @param receivables List of new McaApp__Receivable__c records to be processed
     */
    public static void onBeforeInsert(List<McaApp__Receivable__c> receivables) {}

    /**
     * @description Method to process McaApp__Receivable__c records on Before Update
     * @param receivables - List of new McaApp__Receivable__c records to be processed
     * @param oldMap - Map of old McaApp__Receivable__c records by Id
     */
    public static void onBeforeUpdate(List<McaApp__Receivable__c> receivables, Map<Id, McaApp__Receivable__c> oldMap) {}

    /**
     * @description Method to process McaApp__Receivable__c records on Before Delete
     * @param receivables List of new McaApp__Receivable__c records to be processed
     */
    public static void onBeforeDelete(List<McaApp__Receivable__c> receivables) {}

    /**
     * @description Method to process McaApp__Receivable__c records on After Insert
     * @param receivables List of new McaApp__Receivable__c records to be processed
     */
    public static void onAfterInsert(List<McaApp__Receivable__c> receivables) {
        ReceivableService.createPayableAdjustments(ReceivableService.filterReceivableAdjustments(receivables));
    }

    /**
     * @description Method to process McaApp__Receivable__c records on After Update
     * @param receivables - List of new McaApp__Receivable__c records to be processed
     * @param oldMap - Map of old McaApp__Receivable__c records by Id
     */
    public static void onAfterUpdate(List<McaApp__Receivable__c> receivables, Map<Id, McaApp__Receivable__c> oldMap) {}

    /**
     * @description Method to process McaApp__Receivable__c records on After Delete
     * @param receivables List of new McaApp__Receivable__c records to be processed
     */
    public static void onAfterDelete(List<McaApp__Receivable__c> receivables) {}

    /**
     * @description Method to process McaApp__Receivable__c records on After Undelete
     * @param receivables List of new McaApp__Receivable__c records to be processed
     */
    public static void onAfterUndelete(List<McaApp__Receivable__c> receivables) {}

}