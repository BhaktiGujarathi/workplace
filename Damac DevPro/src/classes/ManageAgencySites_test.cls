/*
 * Test Class for ManageAgencySites.
 */
@isTest
private class ManageAgencySites_test {
    @testSetup static void setupData() {
        Account a = new Account();
            a.Name = 'Test Account';
            insert a;   
    }
    
    @isTest static void test_method_1() {
        Test.startTest();
        Account acc = [select id,name from account limit 1];
        ManageAgencySites.insertAgencySites('KSA;UAE', acc.id);
        ManageAgencySites.UpdateAgencySites('KSA', acc.id);
        ManageAgencySites.UpdateAgencySites('KSA', acc.id);
        ManageAgencySites.UpdateAgencySites('KSA;UAE', acc.id);
        Test.stopTest();    
            
    }
    
     @isTest static void test_method_2() {
        Test.startTest();
        Account acc = [select id,name from account limit 1];
        ManageAgencySites.UpdateAgencySites('KSA;Russia', acc.id);
        Test.stopTest();    
            
    }
}