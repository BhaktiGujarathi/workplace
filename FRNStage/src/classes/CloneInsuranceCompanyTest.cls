@isTest
private class CloneInsuranceCompanyTest {
	
	@testSetup static void setupTestData() {
        // account
        Account accountObj = new Account();
        accountObj = FRNOrgTestDataFactory.createInsComapnyAccountRecord(accountObj);
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Insurance Company');
        insert accountObj;
        system.assertNotEquals(accountObj.Id, null);

        //facility programs
        Facility_Program__c fcltyPrgrm = new Facility_Program__c();
        fcltyPrgrm = FRNOrgTestDataFactory.createFcltyPrgrmRecord(fcltyPrgrm,1);
        fcltyPrgrm.FRN_Facility__c = accountObj.Id;
        insert fcltyPrgrm;
        system.assertNotEquals(fcltyPrgrm.Id, null);

        Clone_Insurance_Related_Objects_To_Clone__c setting = new Clone_Insurance_Related_Objects_To_Clone__c();
        setting.Name = 'Facility Programs';
        setting.Insurance_Company_Relationship_API_Name__c = 'Facility_Programs__r';
        insert setting;
    }

    static testMethod void validTriggerInsurnaceCompanyCloneTest() {
        Id clonedAccountId;

        Test.startTest();
            Account accountObj = [SELECT Id,
                                         RecordTypeId,
                                         (SELECT id 
                                          FROM Facility_Programs__r) 
                                    FROM Account 
                                    LIMIT 1];
            clonedAccountId = CloneInsuranceCompany.triggerInsurnaceCompanyClone(accountObj.Id, 'Clone Insurance Company');
        
        Test.stopTest();
        Account accountToAssert = [SELECT id,
                                          Name,
                                          RecordTypeId,
                                          (SELECT Id
                                             FROM Facility_Programs__r)
                                    FROM Account
                                   WHERE Name = 'Clone Insurance Company'];
        System.assertNotEquals(accountToAssert, null);
        System.assertEquals(accountToAssert.Facility_Programs__r.Size(), accountObj.Facility_Programs__r.Size());
    }

    static testMethod void invalidTriggerInsurnaceCompanyCloneTest() {
        Id clonedAccountId;

        Test.startTest();
            Account accountObj = new Account(Name = 'Test Account');
            try{
                clonedAccountId = CloneInsuranceCompany.triggerInsurnaceCompanyClone(accountObj.Id, 'Clone Insurance Company');    
            }
            catch(exception exobj) {                
            }
            
        
        Test.stopTest();
        List<Account> accountToAssert = [SELECT id,
                                          Name,
                                          RecordTypeId,
                                          (SELECT Id
                                             FROM Facility_Programs__r)
                                    FROM Account
                                   WHERE Name = 'Clone Insurance Company'];
        System.assertEquals(accountToAssert.Size(), 0);
    }
}