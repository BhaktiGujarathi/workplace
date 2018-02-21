/*
* Version       Date             Author         Description
*   1.1         04/06/2016       Ashwini S      For creating invoice line item from credit line item
*/
public with sharing class CreditlineTriggerHandler {
     public void onAfterInsert() {
         new CreditLineTriggerHandlerService().updateHarvestProject
                                               ((Map<Id,Credit_Line_Item__c>) trigger.newMap, null);
         new CreditLineTriggerHandlerService().createInvoiceLineItem
                                               ((Map<Id,Credit_Line_Item__c>) trigger.newMap, null);
    }
    
    public void onAfterUpdate() {
        new CreditLineTriggerHandlerService().updateHarvestProject
                                              ((Map<Id,Credit_Line_Item__c>) trigger.newMap,
                                              (Map<Id,Credit_Line_Item__c>) trigger.oldMap);
        new CreditLineTriggerHandlerService().createInvoiceLineItem
                                              ((Map<Id,Credit_Line_Item__c>) trigger.newMap,
                                              (Map<Id,Credit_Line_Item__c>) trigger.oldMap);
    }
    
    public void onAfterDelete() {
        new CreditLineTriggerHandlerService().updateHarvestProject
                                            (null, (Map<Id,Credit_Line_Item__c>) trigger.oldMap);
        new CreditLineTriggerHandlerService().deleteInvoiceLineItem
                                            ((Map<Id,Credit_Line_Item__c>) trigger.oldMap);
    }
    
     public void onBeforeInsert() {
          
         new CreditLineTriggerHandlerService().updateCreditLineItem
                                               ((list<Credit_Line_Item__c>) trigger.new);
        
    }
    
    public void onBeforeUpdate() {
        new CreditLineTriggerHandlerService().updateCreditLineItem
                                              ((list<Credit_Line_Item__c>) trigger.new);
    }
    
}