@isTest
public class UpdateHighPriorityReferralServiceTest {
	/*@testSetup static void setupTestData() {
		Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Referral Source');
        accountObj.Name = 'Test referral';
        accountObj.Phone = '9865321471';
        accountObj.Type = 'Active';
        accountObj.Master_Referral_Type__c = 'Lawyer';
        accountObj.Special_Instructions__c = 'Special Instructions to be followed while treating the patients referred by this Account:';

        insert accountObj;


        Contact contactObj = new Contact();
        contactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Referral Source Contact');
        contactObj.AccountId = accountObj.Id;
        contactObj.LastName = 'Test Ref Contact';

        insert contactObj;

        Contact patientContactObj = new Contact();
        patientContactObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Contact', 'Patient');
        patientContactObj.LastName = 'Patientcontact';

        insert patientContactObj;


        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        opportunityObj.Contact__c = patientContactObj.Id;
        opportunityObj.LeadSource = 'Alumni';
        opportunityObj.stageName = 'In Process';
        opportunityObj.CloseDate = system.Today().addMonths(5);
        opportunityObj.Name = 'Test Opportunity';

        insert opportunityObj;
	}

    static testMethod void updateReferralHighPriorityCheckBoxValidTest() {
        Account accountObj = [SELECT id,
                                     Special_Instructions__c
                                FROM Account
                               LIMIT 1];
        System.assertNotEquals(accountObj, null);
        Account accountToAssert = new Account();
        Test.startTest();
            accountToAssert = UpdateHighPriorityReferralService.updateReferralHighPriorityCheckBox(accountObj);
        Test.stopTest();

        System.assertEquals(accountToAssert.High_Priority__c, true);
    }

    static testMethod void updateReferralHighPriorityCheckBoxInvalidTest() {
        Account accountObj = [SELECT id,
                                     Special_Instructions__c
                                FROM Account
                               LIMIT 1];
        System.assertNotEquals(accountObj, null);
        accountObj.Special_Instructions__c = '';
        update accountObj;

        Account accountToAssert = new Account();
        Test.startTest();
            accountToAssert = UpdateHighPriorityReferralService.updateReferralHighPriorityCheckBox(accountObj);
        Test.stopTest();

        System.assertEquals(accountToAssert.High_Priority__c, false);
    }

    static testMethod void updateOpportunityHighPriorityCheckBoxInvalidTest() {
        Opportunity opportunityObj = [SELECT id,
                                             Referral_Instruction__c
                                        FROM Opportunity
                                       LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        Opportunity opportunityToAssert = new Opportunity();
        Test.startTest();
            opportunityToAssert = UpdateHighPriorityReferralService.updateOpportunityHighPriorityCheckBox(opportunityObj);
        Test.stopTest();

        System.assertEquals(opportunityToAssert.High_Priority__c, false);
    }

    static testMethod void updateOpportunityHighPriorityCheckBoxValidTest() {
        Opportunity opportunityObj = [SELECT id,
                                             Referral_Instruction__c
                                        FROM Opportunity
                                       LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        opportunityObj.Referral_Instruction__c = 'Special Instructions to be followed while treating the patients.';
        update opportunityObj;


        Opportunity opportunityToAssert = new Opportunity();
        Test.startTest();
            opportunityToAssert = UpdateHighPriorityReferralService.updateOpportunityHighPriorityCheckBox(opportunityObj);
        Test.stopTest();

        System.assertEquals(opportunityToAssert.High_Priority__c, true);
    }*/
}