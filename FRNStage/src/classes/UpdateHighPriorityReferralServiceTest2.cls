@isTest
private class UpdateHighPriorityReferralServiceTest2 {
	@testSetup static void setupTestData() {

		Lead objLead = new Lead();
		objLead.LastName = ' test Lead';
		objLead.Status = 'Open';
		// objLead.Owner = UserInfo.getUserId();
		objLead.Referral_Instruction__c = '';
		insert objLead;

		Opportunity objOpp = new Opportunity();
		objOpp.Name = 'Test Opportunity';
		objOpp.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
		objOpp.Referral_Instruction__c = '';
		objOpp.stageName = 'In Process';
        objOpp.CloseDate = system.Today().addMonths(5);
		insert objOpp;

		Account accountObj = new Account();
        accountObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Account', 'Referral Source');
        accountObj.Name = 'Test referral';
        accountObj.Phone = '9865321471';
        accountObj.Type = 'Active';
        accountObj.Master_Referral_Type__c = 'Lawyer';
        accountObj.Special_Instructions__c = 'Special Instructions to be followed while treating the patients referred by this Account:';
        insert accountObj;

		Document__c objDoc = new Document__c();
		objDoc.Account__c = accountObj.id;
		objDoc.Category__c = 'Referral Documents';
		objDoc.Opportunity__c = NULL;
		insert objDoc;

		Attachment objAttach = new Attachment();
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	objAttach.body=bodyBlob;
		objAttach.Name = 'Test doc';
		objAttach.ParentId = objDoc.id;
		insert objAttach;

		Opportunity objOppForAccount = new Opportunity();
		objOppForAccount.Account = accountObj;
		objOppForAccount.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
		objOppForAccount.Name = 'Test Opportunity 2';
		objOppForAccount.stageName = 'In Process';
        objOppForAccount.CloseDate = system.Today().addMonths(5);
		insert objOppForAccount;

		Document__c objDocument = new Document__c();
		objDocument.Opportunity__c = objOppForAccount.id;
		objDocument.Category__c = 'Referral Documents';
		objDocument.Linked_Document__c = objDoc.id;
		insert objDocument;


	}

	@isTest static void checkLeadForHighPriorityCheckBoxForTrue() {
		Lead leadObj = [SELECT id,
                                Referral_Instruction__c
                        FROM Lead
                        LIMIT 1];
		Lead leadToAssert = new Lead();
		Test.startTest();
            leadToAssert = UpdateHighPriorityReferralService.updateLeadHighPriorityCheckBox(leadObj);
        Test.stopTest();

        System.assertEquals(leadToAssert.High_Priority__c, false);

	}

	@isTest static void checkLeadForHighPriorityCheckBoxForFalse() {
		Lead leadObj = [SELECT id,
                                Referral_Instruction__c
                        FROM Lead
                        LIMIT 1];
		leadObj.Referral_Instruction__c = 'Special Instructions to be followed while treating the patients.';
	    update leadObj;

		Lead leadToAssert = new Lead();
		Test.startTest();
            leadToAssert = UpdateHighPriorityReferralService.updateLeadHighPriorityCheckBox(leadObj);
        Test.stopTest();

        System.assertEquals(leadToAssert.High_Priority__c, true);

	}

	@isTest static void test_method_one() {
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
	    }

	static testMethod void checkForClonedDocumentsTest() {
		Account objAccount = [SELECT id FROM Account LIMIT 1];

		Opportunity opportunityObj = [SELECT id,
                                             Name
                                        FROM Opportunity
										WHERE name = 'Test Opportunity 2'
                                       LIMIT 1];

		Test.startTest();
		UpdateHighPriorityReferralService.getReferralDocsOnOpportunity(objAccount.id, opportunityObj.id);
		Test.stopTest();

		// System.assert();
	}


}