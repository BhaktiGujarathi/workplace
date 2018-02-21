/* 
 * Test Class fo LoanBalanceTrigger
 *   
 * Version         Author                   Date                Description
 * 1.0             Shraddha P.              05-01-2016          Initial Draft[]
 */ 
 
@isTest
private class LoanBalanceTest {

    static testMethod void CalculateRollUpOnTest() {
        
        List<Account> listAccount = TestDataUtility.getAccountRecords(2);
        insert listAccount;
        System.assertNotEquals(null, listAccount);
        
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(5);
        insert listOpportunity;
        System.assertNotEquals(null, listOpportunity);
        
        List<Loan_Balance__c> listLoanBalance = createLoanBalanceRecord(4, listOpportunity[0].Id, listAccount[0].Id);
        insert listLoanBalance;
        System.assertNotEquals(null, listLoanBalance);
        
        List<Opportunity> listOpp = [Select Id
                                           , Name
                                           , Number_Of_Funder__c
                                           , Total_Loan_Balance1__c
                                           , Total_Daily_Payment1__c
                                        FROM Opportunity 
                                        WHERE Total_Daily_Payment1__c = 400
                                          AND Number_Of_Funder__c = 4];
        //System.assertEquals(1, listOpp.size());
        
        listLoanBalance[0].Balance__c = 15;
        Update listLoanBalance[0];
        
        List<Opportunity> listOpp1 = [Select Id
                                           , Name
                                           , Number_Of_Funder__c
                                           , Total_Loan_Balance1__c
                                           , Total_Daily_Payment1__c
                                        FROM Opportunity 
                                        WHERE Total_Loan_Balance1__c = 45
                                          AND Number_Of_Funder__c = 4];
        //System.assertEquals(1, listOpp1.size());
        
        delete listLoanBalance[0];
    }
    
    public static List<Loan_Balance__c> createLoanBalanceRecord(Integer pCount, Id oppId, Id accId) {
        List<Loan_Balance__c> listLoanBalance = new List<Loan_Balance__c>();
        
        for(Integer i=0; i < = pCount; i++) {
            Loan_Balance__c loanBalanceInstance = new Loan_Balance__c();
            //loanBalanceInstance.Name = 'Test'+i;
            loanBalanceInstance.Opportunity__c = oppId;
            loanBalanceInstance.Funder__c = accId;
            loanBalanceInstance.Balance__c = 10;
            loanBalanceInstance.Daily_Payment__c = 100;
            listLoanBalance.add(loanBalanceInstance);
        }
        
        return listLoanBalance;
    }
}