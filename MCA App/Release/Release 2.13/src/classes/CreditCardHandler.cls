/**
 *
 * Description :
 *  1.Used to make a call to the business logic that implents the trigger functionality
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0      Ashwini Singh          27/10/2015            To make a call to the business logic
 *
 **/
public with sharing class CreditCardHandler {
    
    public static final String frmInsert = 'Insert';
    public static final String frmUpdate = 'Update';
    public static final String frmDelete = 'Delete';
    
    public void onBeforeInsert(){
        new CreditCardHandlerServiceBefore().updateAccount(null, (List<Credit_Card__c>)trigger.new, frmInsert);
    }
    
    public void onBeforeUpdate(){
        new CreditCardHandlerServiceBefore().updateAccount((map<Id, Credit_Card__c>)trigger.oldMap, (List<Credit_Card__c>)trigger.new, frmUpdate );  
    }
    
    public void onAfterInsert(){
        //new CreditCardHandlerServiceAfter().updateNoOfCCStmt(null, (List<Credit_Card__c>)trigger.new, frmInsert);
        new CreditCardHandlerServiceAfter().accountRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);
    }
    
    public void onAfterUpdate(){
        //new CreditCardHandlerServiceAfter().updateNoOfCCStmt((map<Id, Credit_Card__c>)trigger.oldMap, (List<Credit_Card__c>)trigger.new, frmUpdate);
        new CreditCardHandlerServiceAfter().accountRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);
    }
    
    public void onAfterDelete(){
        //new CreditCardHandlerServiceAfter().updateNoOfCCStmt((map<Id, Credit_Card__c>)trigger.oldMap, Null, frmDelete);
        new CreditCardHandlerServiceAfter().accountRollup(Null,(map<Id, Credit_Card__c>)trigger.oldMap);
    }
    
    public void onAfterUndelete() {
        new CreditCardHandlerServiceAfter().accountRollup(Null,(map<Id, Credit_Card__c>)trigger.oldMap);
    }
}