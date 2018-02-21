@isTest
private class DeleteNextTransOnPauseTest {

    /*private static testMethod void deleteNextTransOnPauseTest() {
    	
    	Account account = new Account();
    	account.Name = 'Test Account';
    	insert account;
    	
    	Payment_Setting__c payment = new Payment_Setting__c();
    	payment.Payee_Account__c = account.Id;
    	payment.Intial_Repayment_Amount__c = 13423;
    	payment.Next_Hit_Date__c = Date.today();
    	payment.Payment_Amount__c = 134;
    	insert payment;
    	
    	Payment__c achTransaction = new Payment__c();
        achTransaction.Payment_Setting__c = payment.Id;
        achTransaction.Status__c = 'Settled';
        achTransaction.Effective_Date__c = Date.today().addDays(4);
    	insert achTransaction;
    	achTransaction.Status__c = 'Scheduled';
    	update achTransaction;
    	
    	payment.status__c = 'Pause';
    	payment.Intial_Repayment_Amount__c = 1342;
    	update payment;
    }*/
}