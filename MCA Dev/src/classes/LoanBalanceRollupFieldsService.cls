/* 
 *
    Revision History:
 *   
 * Version         Author                   Date                Description
 * 1.0             Shraddha P.              05-01-2016          Initial Draft[]
 */ 

public with sharing class LoanBalanceRollupFieldsService {
    public LoanBalanceRollupFieldsService() {
        
    }
    
    public void rollUpTotalDailyPaymentSum(List<Loan_Balance__c> listNewLoanBalance) {
        
        List<Opportunity> listToUpdateOpportunity = new List<Opportunity>();
        Set<Id> setOppId = new Set<Id>();
        
        //Itterate over list of loan, while inserting or updating list trigger is fire
        for(Loan_Balance__c objLoanBalance :listNewLoanBalance) {
           setOppId.add(objLoanBalance.Opportunity__c);
           system.debug('---Set--->'+setOppId);
        }
        
        //Query on opportunity and its child record
        List<Opportunity> listOpportunity =[
                                           SELECT Id
                                                , Name
                                                , Total_Daily_Payments__c
                                                , Total_Loan_Balances__c
                                                , Number_Of_Funders__c
                                                , (SELECT Opportunity__c
                                                        , Daily_Payment__c
                                                        , Balance__c 
                                                     FROM Loan_Balances__r)
                                             FROM Opportunity 
                                            WHERE Id IN :setOppId
        ];
        
        //Itterate over list of opportunity to calculate rollup on opportunity from Loan Balance 
        for(Opportunity objOpportunity :listOpportunity) {
            decimal sumChildPayment = 0;
            decimal sumChildBalance = 0;
            //decimal count;
            for(Loan_Balance__c objLoanBalance :objOpportunity.Loan_Balances__r) {
                if(objLoanBalance.Daily_Payment__c != null) {
                    sumChildPayment = sumChildPayment + objLoanBalance.Daily_Payment__c;
                }
                
                if(objLoanBalance.Balance__c != null) {
                    sumChildBalance = sumChildBalance + objLoanBalance.Balance__c;
                }
                //count++;
            } 
            if(sumChildPayment != null) {
                objOpportunity.Total_Daily_Payments__c = sumChildPayment;
            }
            
            if(sumChildBalance != null) {
                objOpportunity.Total_Loan_Balances__c = sumChildBalance;
            }
             if(objOpportunity.Loan_Balances__r.size() > 0) {
                 objOpportunity.Number_Of_Funders__c = objOpportunity.Loan_Balances__r.size();
             }
            
            listToUpdateOpportunity.add(objOpportunity);
            System.debug('---list b4 insert--->'+listToUpdateOpportunity);
            
        }
        
        if(!listToUpdateOpportunity.isEmpty()) {
            update listToUpdateOpportunity;
            system.debug('---Update List--->'+listToUpdateOpportunity);
        }
    }
}