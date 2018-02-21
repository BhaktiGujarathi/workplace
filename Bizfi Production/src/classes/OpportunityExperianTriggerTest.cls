@isTest
private class OpportunityExperianTriggerTest {
	
	@testSetup
	static void dataSetup(){
		// Create user and scorecard
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Agent - Opener'];
	    User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
	    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
	    LocaleSidKey='en_US', ProfileId = p.Id, IsActive=true,
	    TimeZoneSidKey='America/Los_Angeles', UserName='bizfistandarduser@bizfitestorg.com');
		// User u = OpportunityExperianTestData.testUser();
		// OpportunityExperianTestData.scoreCard(u);

		// List for Opportunities, Contacts and Contact Roles
		List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
		List<Contact> inConList = new List<Contact>();
		List<Opportunity> oList = new List<Opportunity>();

		// Create Account, Opportunities and Contacts as user
		System.runAs(u) {
			// Account for Opportunity and Contact
			Account a = new Account(Name = 'Exp Acc', RecordTypeId = RecordTypesUtility.recId('Account', 'Merchant'));
			insert a;
				
			for(Integer i = 0; i < 10; i++){
				Opportunity o = new Opportunity(
					Name = 'Test opp' + i,
					RecordTypeId = RecordTypesUtility.recId('Opportunity', 'MCA App Default'), 
					Type = 'New Deal', 
					McaApp__Amount_Requested__c = 15000.00,
					AccountId = a.Id,
					CloseDate = Date.today() + 30,
					StageName = 'Application Sent'
				);
				oList.add(o);
			}
			insert oList;

			// Create 2 contacts per opportunity
			for (Integer i = 2, j = oList.size()+2; i < j; i++) {
				Contact auth = new Contact(AccountId = a.Id, LastName = i+'LastName', Authorize_Run_Credit__c = true);
				Contact unauth = new Contact(AccountId = a.Id, LastName = 'LastName'+i, Authorize_Run_Credit__c = false);
				inConList.add(auth);
				inConList.add(unauth);
			}
			insert inConList;

			// Get contacts
			List<Contact> cList = [SELECT Id FROM Contact];

			// Split into check and unchecked contacts
			for(Integer i = 0, j = oList.size(); i < j; i++){	
				OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = cList[i*2].Id, OpportunityId = oList[i].Id);
				OpportunityContactRole ocr2 = new OpportunityContactRole(ContactId = cList[(i*2)+1].Id, OpportunityId = oList[i].Id);
				ocrList.add(ocr1);
				ocrList.add(ocr2);	
			}
			insert ocrList;
		}
	}

	@isTest
	static void positiveBulkTest(){
		// Get user for test run
		User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
		// Create collections to hold data
		Set<Id> conIds = new Set<Id>();
		Map<Id, Opportunity> oppIdMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);
		// Update opportunity values as user
		System.runAs(u) {
			for(Opportunity o : oppIdMap.values()) {
				o.Send_to_Experian__c = true;
			}
		
			test.starttest();
			update oppIdMap.values();
			test.stoptest();
		}

		// Get contacts that we can run credit for
		List<OpportunityContactRole> cRoleList = [SELECT ContactId, Contact.Authorize_Run_Credit__c 
												  FROM OpportunityContactRole 
												  WHERE Contact.Authorize_Run_Credit__c = true AND OpportunityId IN :oppIdMap.keySet()];

		for(OpportunityContactRole cr : cRoleList) {
			conIds.add(cr.ContactId);
		}

		List<Contact> conList = [SELECT Opportunity_Id__c, Authorize_Run_Credit__c FROM Contact WHERE Id IN :conIds];

		// Check if opportunity Id on contacts is populated
		for(Contact c : conList){
			System.assertNotEquals(c.Opportunity_Id__c, null);
		}
	}

	@isTest
	static void negativeBulkTest(){
		// Create user for test run
		User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
		// Create collections to hold data
		Set<Id> conIds = new Set<Id>();
		Map<Id, Opportunity> oppIdMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);
		// Update opportunity values as user
		System.runAs(u) {
			for(Opportunity o : oppIdMap.values()) {
				o.Send_to_Experian__c = true;
			}
		
			test.starttest();
			update oppIdMap.values();
			test.stoptest();
		}


		// Get contacts that we cannot run credit for
		List<OpportunityContactRole> cRoleList = [SELECT ContactId, Contact.Authorize_Run_Credit__c 
												  FROM OpportunityContactRole 
												  WHERE Contact.Authorize_Run_Credit__c = false AND OpportunityId IN :oppIdMap.keySet()];

		for(OpportunityContactRole cr : cRoleList) {
			conIds.add(cr.ContactId);
		}

		List<Contact> conList = [SELECT Opportunity_Id__c, Authorize_Run_Credit__c FROM Contact WHERE Id IN :conIds];

		// Check that opportunity id is null
		for(Contact c : conList){
			System.assertEquals(c.Opportunity_Id__c, null);
		}
	}

}