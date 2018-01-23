@isTest
private class SObjectCloneTest {
    // method to setup test data for the test class
    @testSetup static void setupTestData() {
        // account
        Account accountObj = new Account();
        accountObj = FRNOrgTestDataFactory.createInsComapnyAccountRecord(accountObj);
        insert accountObj;
        system.assertNotEquals(accountObj.Id, null);

        //facility programs
        Facility_Program__c fcltyPrgrm = new Facility_Program__c();
        fcltyPrgrm = FRNOrgTestDataFactory.createFcltyPrgrmRecord(fcltyPrgrm,1);
        fcltyPrgrm.FRN_Facility__c = accountObj.Id;
        insert fcltyPrgrm;
        system.assertNotEquals(fcltyPrgrm.Id, null);
    }

    // method to test SObjectClone()
    static testMethod void SObjectCloneTest() {
        Test.startTest();
            SObjectClone cloneCls = new SObjectClone(Account.sObjectType);
        Test.stopTest();

        System.AssertEquals(cloneCls.objectType, Account.sObjectType);
    }
    
    // method to test SObjectClone()
    static testMethod void setFieldSetTest() {
        Test.startTest();
            SObjectClone cloneCls = new SObjectClone(Account.sObjectType)
                                        .setFieldSet(SObjectType.Account.FieldSets.Clone_Insurance_Fields_to_Clone);
        Test.stopTest();

        //System.AssertEquals(cloneCls.fieldSet, SObjectType.Account.FieldSets.Clone_Insurance_Fields_to_Clone);
    }

    // method to test SObjectClone()
    static testMethod void setTargetRecordTypeIdTest() {
        Test.startTest();
            SObjectClone cloneCls = new SObjectClone(Account.sObjectType)
                                        .setTargetRecordTypeId('Insurance_Company');
        Test.stopTest();

        //System.AssertEquals(cloneCls.fieldSet, SObjectType.Account.FieldSets.Clone_Insurance_Fields_to_Clone);
    }

    // method to test SObjectClone()
    static testMethod void setCloneConfigTest() {

        Test.startTest();
            //SObjectClone cloneCls = new SObjectClone(Account.sObjectType);
            SObjectClone.CloneConfig configCls = new SObjectClone.CloneConfig();
            configCls.preserveId                 = true;
            configCls.isDeepClone                = true;
            configCls.preserveReadonlyTimestamps = true;
            configCls.preserveAutonumber         = true;
            SObjectClone cloneCls = new SObjectClone(Account.sObjectType);
            cloneCls = cloneCls.setCloneConfig(configCls);
        Test.stopTest();

        System.AssertEquals(cloneCls.config.preserveId, true);
        System.AssertEquals(cloneCls.config.isDeepClone, true);
        System.AssertEquals(cloneCls.config.preserveReadonlyTimestamps, true);
        System.AssertEquals(cloneCls.config.preserveAutonumber, true);
    }

    // method to test setRelationshipNameSet()
    static testMethod void setRelationshipNameSetTest() {
        Test.startTest();
            Set<String> relationShipSet = new Set<String>{'Facility_Programs__r'};
            SObjectClone cloneCls = new SObjectClone(Account.sObjectType)
                                        .setRelationshipNameSet(relationShipSet);
        Test.stopTest();

        System.AssertEquals(cloneCls.relationshipNameSet.size(), relationShipSet.size());
    }

    // method to test SObjectClone()
    static testMethod void cloneTest() {
        Test.startTest();
            Account accountObj = [SELECT Id,
                                         (SELECT id 
                                          FROM Facility_Programs__r) 
                                    FROM Account 
                                    LIMIT 1];
            Set<String> relationShipSet = new Set<String>{'Facility_Programs__r'};
            InitializerTestCls initCls = new InitializerTestCls();
            initCls.accountName = 'Clone Insurance Company';
            SObjectClone.CloneConfig configCls = new SObjectClone.CloneConfig();
            configCls.preserveId                 = false;
            configCls.isDeepClone                = true;
            configCls.preserveReadonlyTimestamps = true;
            configCls.preserveAutonumber         = true;
            Account cloneAccount = (Account)new SObjectClone(Account.sObjectType)
                                        .setInitializer(initCls)
                                        .setRelationshipNameSet(relationShipSet)
                                        .setCloneConfig(configCls)
                                        .setFieldSet(SObjectType.Account.FieldSets.Clone_Insurance_Fields_to_Clone)
                                        .setTargetRecordTypeId('Insurance_Company')
                                        .clone(accountObj.Id);
        
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

    // cloned account initializer
    public class InitializerTestCls implements CloneInitializer{
        public String accountName = '';
        public SObject initialize(Id parentId, SObject clonedRecord){
            Account clonedAccount = (Account)clonedRecord;
            clonedAccount.Name = accountName;

            return clonedAccount;
        }
    }
}