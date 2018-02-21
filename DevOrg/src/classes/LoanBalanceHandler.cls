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
        new LoanBalanceRollupFieldsService().rollUpTotalDailyPaymentSum((List<Loan_Balance__c>) trigger.new);
    }
    
    public void onAfterUpdate() {
        List<Loan_Balance__c> listToUpdateLoanBalance = updateOpportunityRollUp();
        new LoanBalanceRollupFieldsService().rollUpTotalDailyPaymentSum(listToUpdateLoanBalance);
    }
    
    public void onAfterDelete() {
        new LoanBalanceRollupFieldsService().rollUpTotalDailyPaymentSum((List<Loan_Balance__c>) trigger.old);
    }
    
    public List<Loan_Balance__c> updateOpportunityRollUp() {
        List<Loan_Balance__c> listLoanBalance = new List<Loan_Balance__c>();
        
        for(Loan_Balance__c objNewLoanBalance :(List<Loan_Balance__c>) trigger.new) {
            if(((Map<Id, Loan_Balance__c>)trigger.oldMap).containsKey(objNewLoanBalance.Id)) {
                Loan_Balance__c objOldLoanBalance = ((Map<Id, Loan_Balance__c>)trigger.oldMap).get(objNewLoanBalance.Id);
                
                if((objNewLoanBalance.Opportunity__c != objOldLoanBalance.Opportunity__c) 
                || objNewLoanBalance.Daily_Payment__c != objOldLoanBalance.Daily_Payment__c
                || objNewLoanBalance.Balance__c != objOldLoanBalance.Balance__c) {
                    listLoanBalance.add(objNewLoanBalance);
                }
            }
        }
        
        System.debug('---listLoanBalance--->'+listLoanBalance);
        return listLoanBalance;
    }
    
}