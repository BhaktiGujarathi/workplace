@isTest
private class MerchantPaymentTest {

    static testMethod void CalculateRollUpOnTest() {
        List<Account> listAccount = TestDataUtility.getAccountRecords(2);
        insert listAccount;        
        
        List<Opportunity> listOpportunity = TestDataUtility.getOpportunityRecords(5);
        insert listOpportunity;        
        
        List<Merchant_Payment__c> listMerchantPayment = TestDataUtility.getMerchantPaymentRecords(4, listOpportunity[0].Id);
        insert listMerchantPayment;
        
        if(listMerchantPayment.size()>0)
            delete listMerchantPayment;
    }
}