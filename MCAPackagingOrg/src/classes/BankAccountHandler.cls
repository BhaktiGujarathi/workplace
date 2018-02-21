/**
 *
 * Description :
 *  1.Used to make a call to the business logic that implents the trigger functionality
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0      Ashwini Singh          26/10/2015            To make a call to the business logic
 *
 **/
 
public without sharing class BankAccountHandler {
    
    public BankAccountHandler(){}
    
    public static final String frmInsert = 'Insert';
    public static final String frmUpdate = 'Update';    
    public static final String frmDelete = 'Delete';
    
    public void onBeforeInsert(){
        new BankAccountHandlerServiceBefore().updateAccount(null,(list<Bank_Account__c>) trigger.new, frmInsert);
    }
    
    public void onBeforeUpdate(){
        new BankAccountHandlerServiceBefore().updateAccount((map<Id,Bank_Account__c >) trigger.oldMap,
                                                    (list<Bank_Account__c>) trigger.new, frmUpdate);
    }
    
    public void onAfterInsert(){
       /* new BankAccountHandlerServiceAfter().updateNoOfBankAcc(null,(list<Bank_Account__c>) trigger.new,frmInsert);*/
        new BankAccounthandlerServiceAfter().accountRollup((map<Id, Bank_Account__c>)trigger.newMap,
                                                            (map<Id, Bank_Account__c>)trigger.oldMap);
        new BankAccounthandlerServiceAfter().opportunityRollup((map<Id, Bank_Account__c>)trigger.newMap,
                                                            (map<Id, Bank_Account__c>)trigger.oldMap);
    }
    
    public void onAfterUpdate(){
     /*  new BankAccountHandlerServiceAfter().updateNoOfBankAcc((map<Id,Bank_Account__c >) trigger.oldMap,
                                                    (list<Bank_Account__c>) trigger.new, frmUpdate);*/
        new BankAccounthandlerServiceAfter().accountRollup((map<Id, Bank_Account__c>)trigger.newMap,
                                                            (map<Id, Bank_Account__c>)trigger.oldMap);
        new BankAccounthandlerServiceAfter().opportunityRollup((map<Id, Bank_Account__c>)trigger.newMap,
                                                            (map<Id, Bank_Account__c>)trigger.oldMap);
    }
    
    public void onAfterDelete(){
    /*    new BankAccountHandlerServiceAfter().updateNoOfBankAcc(null,(list<Bank_Account__c>) trigger.old,frmDelete);*/
        new BankAccounthandlerServiceAfter().accountRollup(Null,(map<Id, Bank_Account__c>)trigger.oldMap);
        new BankAccounthandlerServiceAfter().opportunityRollup(Null,(map<Id, Bank_Account__c>)trigger.oldMap);
    }
    
    public void onAfterUndelete() {
        new BankAccounthandlerServiceAfter().accountRollup(Null,(map<Id, Bank_Account__c>)trigger.oldMap);
        new BankAccounthandlerServiceAfter().opportunityRollup(Null,(map<Id, Bank_Account__c>)trigger.oldMap);
    }
}