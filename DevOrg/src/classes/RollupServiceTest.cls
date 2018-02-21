/* Test class to calculate the Roll-up 
 * 
 * Revision History:
 *   
 * Version         Author                         Date                                     Description
 * 1.0             Shraddha P.                    28th Jan 2016                            Initial Draft
 */ 
 
@isTest
private class RollupServiceTest {
    static testMethod void calculateRollUpValidTest() {
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;
        System.assertNotEquals(null, objAcc.Id);
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opportunity';
        objOpp.StageName = 'Closed';
        objOpp.CloseDate = system.Today();
        insert objOpp;
        System.assertNotEquals(null, objOpp.Id);
        
        Loan_Balance__c objLoanBalance1 = createLoanBalanceRecord(objOpp.Id, objAcc.Id, 10);
        insert objLoanBalance1;
        System.assertNotEquals(null, objLoanBalance1.Id);
        
        Loan_Balance__c objLoanBalance2 = createLoanBalanceRecord(objOpp.Id, objAcc.Id, 20);
        insert objLoanBalance2;
        System.assertNotEquals(null, objLoanBalance2.Id);
        
        
    }
    
    public static Loan_Balance__c createLoanBalanceRecord(Id oppId, Id accId, decimal payment) {
        Loan_Balance__c objLoanBalance = new Loan_Balance__c();
        objLoanBalance.Opportunity__c = oppId;
        objLoanBalance.Daily_Payment__c = payment;
        objLoanBalance.Funder__c = accId;
        return objLoanBalance;
    }
}