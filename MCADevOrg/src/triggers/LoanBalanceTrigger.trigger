/*  *
    Revision History:
 *   
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           12-01-2016           Initial Draft
 */ 

trigger LoanBalanceTrigger on Loan_Balance__c (after insert, after update, after delete, after undelete) {
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            new LoanBalanceHandler().onAfterInsert();            
        } else if(trigger.isUpdate) {
            new LoanBalanceHandler().onAfterUpdate();            
        } else if(trigger.isDelete) {
            new LoanBalanceHandler().onAfterDelete();
        } else if(trigger.isundelete) {
            new LoanBalanceHandler().onAfterUndelete();
        }
    }
}