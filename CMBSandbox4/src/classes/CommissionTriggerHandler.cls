public with sharing class CommissionTriggerHandler {
    public CommissionTriggerHandler(){}
    
    public void onAfterInsert(){
        new CommissionTriggerHandlerService().InvoiceRollup((map<Id, Commission__c>)trigger.newMap,
                                                            (map<Id, Commission__c>)trigger.oldMap);
         new CommissionTriggerHandlerService().OpportunityUpdate((map<Id, Commission__c>)trigger.newMap,
                                                            (map<Id, Commission__c>)trigger.oldMap);
    }
    
    public void onAfterUpdate(){
        new CommissionTriggerHandlerService().InvoiceRollup((map<Id, Commission__c>)trigger.newMap,
                                                            (map<Id, Commission__c>)trigger.oldMap);
        new CommissionTriggerHandlerService().OpportunityUpdate((map<Id, Commission__c>)trigger.newMap,
                                                            (map<Id, Commission__c>)trigger.oldMap);
    }
    
    public void onAfterDelete(){
        new CommissionTriggerHandlerService().InvoiceRollup((map<Id, Commission__c>)trigger.oldMap,
                                                            (map<Id, Commission__c>)trigger.NewMap);
        new CommissionTriggerHandlerService().OpportunityUpdate((map<Id, Commission__c>)trigger.newMap,
                                                            (map<Id, Commission__c>)trigger.oldMap);
    }

}