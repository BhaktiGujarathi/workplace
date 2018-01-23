@isTest
private class RecordLockUtilityTest {
    static testMethod void validTest(){
        Account testAccount = new Account();
        testAccount.Name= 'Test Account'; 
        testAccount.Phone = '(012)-345-6769'; 
        testAccount.Facility_Type__c = 'Hospital'; 
        insert testAccount;
        
        Test.startTest();
            RecordLockUtility.verifyIfLocked(testAccount.Id);
            Approval.lock(testAccount.Id);           
            RecordLockUtility.redirectIfLocked(testAccount.Id);
            PageReference pageRef = Page.RecordLockedError;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('returnId','');
            new RecordLockUtility().returnBack();
            
        Test.stopTest();
    }
    
    static testMethod void invalidTest(){
        Account testAccount = new Account();
        testAccount.Name= 'Test Account'; 
        testAccount.Phone = '(012)-345-6769'; 
        testAccount.Facility_Type__c = 'Hospital'; 
        insert testAccount;
        
        Test.startTest();
            RecordLockUtility.verifyIfLocked(testAccount.Id);      
            RecordLockUtility.redirectIfLocked(testAccount.Id);
            PageReference pageRef = Page.RecordLockedError;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('returnId',testAccount.id);
            new RecordLockUtility().returnBack();
            
        Test.stopTest();
    }
}