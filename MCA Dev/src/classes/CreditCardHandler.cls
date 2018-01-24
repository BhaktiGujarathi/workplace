/**
 *
 * Description :
 *  1.Used to make a call to the business logic that implents the trigger functionality
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0      Ashwini Singh          27/10/2015            To make a call to the business logic
 *
 **/
public without sharing class CreditCardHandler {

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
        
       /* new CreditCardHandlerServiceAfter().accountRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);
        new CreditCardHandlerServiceAfter().opportunityRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);*/
                                                            
         new CreditCardHandlerServiceAfter().opportunityRollUpCreditCard((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);                                                   
    }

    public void onAfterUpdate(){
        
        /*new CreditCardHandlerServiceAfter().accountRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);
        new CreditCardHandlerServiceAfter().opportunityRollup((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);*/
        
        new CreditCardHandlerServiceAfter().opportunityRollUpCreditCard((map<Id, Credit_Card__c>)trigger.newMap,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);                                                     
    }

    public void onAfterDelete(){
        /*new CreditCardHandlerServiceAfter().accountRollup(Null,(map<Id, Credit_Card__c>)trigger.oldMap);
        new CreditCardHandlerServiceAfter().opportunityRollup(Null,(map<Id, Credit_Card__c>)trigger.oldMap);*/
        
        new CreditCardHandlerServiceAfter().opportunityRollUpCreditCard(NULL,
                                                            (map<Id, Credit_Card__c>)trigger.oldMap);  
    }

    public void onAfterUndelete() {
       /* new CreditCardHandlerServiceAfter().accountRollup((map<Id, Credit_Card__c>)trigger.newMap, null);
        new CreditCardHandlerServiceAfter().opportunityRollup((map<Id, Credit_Card__c>)trigger.newMap, null);*/
        
        new CreditCardHandlerServiceAfter().opportunityRollUpCreditCard((map<Id, Credit_Card__c>)trigger.newMap,
                                                                           NULL);  
    }
}