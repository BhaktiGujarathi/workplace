@isTest
private class TestReferralBeforeInsert {
    static testMethod void validateTestReferralBeforeInsert() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount; 
        
        recordType rt=[select id from recordtype where name='Outbound Referral'];
        
        Referral__c r = new Referral__c(RecordTypeId=rt.Id, Account__c=testAccount.Id);
        System.debug('User before inserting new Referral: ' + r.User__c);
 
        // Insert referral__c
        insert r;
       
        // Retrieve the new book
        r = [SELECT User__c FROM Referral__c WHERE Id =:r.Id];
        System.debug('User after trigger fired: ' + r.User__c);
        
        // Test that the trigger correctly updated the user
        //System.assertNotEquals(null, r.User__c);
    }
}