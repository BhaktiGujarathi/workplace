/*
* Version       Date             Author         Description
*   1.0         05/10/2015       Ashwini S      For Roll up on Account from Invoice  
*/

public with sharing class InvoiceTriggerHandler {
    
    public InvoiceTriggerHandler(){}

    public void onafterInsert(){        
        new InvoiceAccountUpdate().accountRollup((map<Id, Invoice__c>)trigger.newMap,
                                                            (map<Id, Invoice__c>)trigger.oldMap);
        new CommissionUpdateService().updateCommissions((map<Id, Invoice__c>)trigger.newMap,
                                                            (map<Id, Invoice__c>)trigger.oldMap);
    }
    
    public void onafterUpdate(){ 
       new InvoiceAccountUpdate().accountRollup((map<Id, Invoice__c>)trigger.newMap,
                                                            (map<Id, Invoice__c>)trigger.oldMap);
       new CommissionUpdateService().updateCommissions((map<Id, Invoice__c>)trigger.newMap,
                                                            (map<Id, Invoice__c>)trigger.oldMap);
    }
    
    public void onafterDelete(){
        new InvoiceAccountUpdate().accountRollup((map<Id, Invoice__c>)trigger.newMap,
                                                            (map<Id, Invoice__c>)trigger.oldMap);
    }
}