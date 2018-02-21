/*  *
    Revision History:
 *   
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           12-01-2016           Initial Draft
 */ 

trigger LoanBalanceTrigger on Loan_Balance__c (after insert, after update, after delete) {
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){

        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('MAX', 'Daily_Payment__c', 
            'Total_Daily_Payment1__c')
             };

        RollupService.rollUpTrigger(fieldDefinitions, trigger.new, 
        'Loan_Balance__c', 'Opportunity__c', 'Opportunity', '');

    }
    /*if(trigger.isAfter) {
        if(trigger.isInsert) {
            new LoanBalanceHandler().onAfterInsert();
            
        } else if(trigger.isUpdate) {
            new LoanBalanceHandler().onAfterUpdate();
            System.debug('---Update trigger--->');
        } else if(trigger.isDelete) {
            new LoanBalanceHandler().onAfterDelete();
        }
    }*/
}