@isTest
private class TaskTriggerBizfiTest {


	@testSetup
	static void testData() {
		
		List<Lead> leadList = new List<Lead>();
		List<String> stats = new List<String>{'Closed - Lost', 'Closed - Future Client', 'Closed - Unqualified', 'Open - Not Contacted'};
		
		for(Integer i = 0; i < 4; i++){
			Lead l = new Lead(
				LeadSource = 'Lead Partner',
				Campaign_Source__c = 'don\' matter',
				Company = 'Laz '+i,
				LastName = 'Surname-'+i,
				Email = 'surname-'+i+'@lazcompany.com',
				Phone = '(646) 604-8215',
				Status = stats[i]
				);

			if(i < 3) { l.McaApp__Sub_Status__c = 'Looking for Startup Capital'; }

			leadList.add(l);
		}

		insert leadList;

	}

	@isTest
	static void unqual() {
		// Given
		Id lostId = [SELECT Id FROM Lead WHERE Status = 'Closed - Unqualified' LIMIT 1].Id;

		List<Task> taskList = new List<Task>();

		for(Integer i = 0; i < 199; i++){
			Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

			taskList.add(t);
		}

		Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call - All - Radiance Call Center - (584) 387-2822',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

		taskList.add(t);

		// When
		test.startTest();
		insert taskList;

		Lead lost = [SELECT Id, Lazarus_ID__c FROM Lead WHERE Status = 'Closed - Unqualified' LIMIT 1];
		test.stopTest();

		// Then
		System.assertEquals(lost.Lazarus_ID__c, 'Radiance Call Center');
	}

	@isTest
	static void freebandzClient() {
		// Given
		Id lostId = [SELECT Id FROM Lead WHERE Status = 'Closed - Future Client' LIMIT 1].Id;

		List<Task> taskList = new List<Task>();

		for(Integer i = 0; i < 199; i++){
			Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

			taskList.add(t);
		}

		Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call - All - Radiance Call Center - (584) 387-2822',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

		taskList.add(t);

		// When
		test.startTest();
		insert taskList;

		Lead lost = [SELECT Id, Lazarus_ID__c FROM Lead WHERE Status = 'Closed - Future Client' LIMIT 1];
		test.stopTest();

		// Then
		System.assertEquals(lost.Lazarus_ID__c, 'Radiance Call Center');
	}

	@isTest
	static void negTest() {
		// Given
		Id lostId = [SELECT Id FROM Lead WHERE Status = 'Open - Not Contacted' LIMIT 1].Id;

		List<Task> taskList = new List<Task>();

		for(Integer i = 0; i < 199; i++){
			Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

			taskList.add(t);
		}

		Task t = new Task(
				WhoId = lostId,
				Subject = 'Inbound Call - All - Radiance Call Center - (584) 387-2822',
				isdc_inbound_number_dialed__c = '(717) 773-7887', 
				Status = 'Complete',
				Priority = 'Normal');

		taskList.add(t);

		// When
		test.startTest();
		insert taskList;

		Lead lost = [SELECT Id, Lazarus_ID__c FROM Lead WHERE Status = 'Open - Not Contacted' LIMIT 1];
		test.stopTest();

		// Then
		System.assert(String.isBlank(lost.Lazarus_ID__c));
	}


}