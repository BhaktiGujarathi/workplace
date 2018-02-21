/* 
 * Call in LoanBalance trigger to calculate RollUp on Opportunity
 *   
 * Version         Author                   Date                Description
 * 1.0             Shraddha P.              05-01-2016          Initial Draft[]
 */ 

public with sharing class LoanBalanceHandler {
    public LoanBalanceHandler() {
        
    }
    
    public void onAfterInsert() {       
      if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'LoanBalanceRollUpTrigger'].IsActivate__c){
        list<RollupService.fieldDefinition> fieldDefinitions_dailypayment = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Daily_Payment__c', 
            'Total_Daily_Payments__c')
            };
        RollupService.rollUpTrigger(fieldDefinitions_dailypayment, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');

        list<RollupService.fieldDefinition> fieldDefinitions_Balance = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Balance__c', 
            'Total_Loan_Balances__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_Balance, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
        
        list<RollupService.fieldDefinition> fieldDefinitions_funders = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT', 'Id', 
            'Number_of_Funders__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_funders, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
      }
    }
    
    public void onAfterUpdate() {       
      if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'LoanBalanceRollUpTrigger'].IsActivate__c){
        list<RollupService.fieldDefinition> fieldDefinitions_dailypayment = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Daily_Payment__c', 
            'Total_Daily_Payments__c')
            };
        RollupService.rollUpTrigger(fieldDefinitions_dailypayment, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');

        list<RollupService.fieldDefinition> fieldDefinitions_Balance = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Balance__c', 
            'Total_Loan_Balances__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_Balance, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
        
        list<RollupService.fieldDefinition> fieldDefinitions_funders = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT', 'Id', 
            'Number_of_Funders__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_funders, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
      }
    }
    
    public void onAfterUndelete(){
      if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'LoanBalanceRollUpTrigger'].IsActivate__c){
        list<RollupService.fieldDefinition> fieldDefinitions_dailypayment = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Daily_Payment__c', 
            'Total_Daily_Payments__c')
            };
        RollupService.rollUpTrigger(fieldDefinitions_dailypayment, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');

        list<RollupService.fieldDefinition> fieldDefinitions_Balance = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Balance__c', 
            'Total_Loan_Balances__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_Balance, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
        
        list<RollupService.fieldDefinition> fieldDefinitions_funders = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT', 'Id', 
            'Number_of_Funders__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_funders, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
      }
    }
    
    public void onAfterDelete() {        
      if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'LoanBalanceRollUpTrigger'].IsActivate__c){
        list<RollupService.fieldDefinition> fieldDefinitions_dailypayment = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Daily_Payment__c', 
            'Total_Daily_Payments__c')
            };
        RollupService.rollUpTrigger(fieldDefinitions_dailypayment, trigger.old, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');

        list<RollupService.fieldDefinition> fieldDefinitions_Balance = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM', 'Balance__c', 
            'Total_Loan_Balances__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_Balance, trigger.old, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
        
        list<RollupService.fieldDefinition> fieldDefinitions_funders = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT', 'Id', 
            'Number_of_Funders__c')
             };
         RollupService.rollUpTrigger(fieldDefinitions_funders, trigger.old, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');
      }
    }   
   
}