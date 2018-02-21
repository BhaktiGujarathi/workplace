@isTest
private class StorageAccountReassignTest {

	@testSetup
	static void dataSetup(){
		Account[] acctList = new Account[]{};

		for(Integer i = 0; i < 4; i++){
			Account acct = new Account();
			acct.Industry = 'Banking';
			acct.Test_Complete__c = true;

			if(math.mod(i,2) == 0) {
				acct.Funded_Opp__c = false;
				acct.Name = 'no money'+i;
			} else {
				acct.Funded_Opp__c = true;
				acct.Name = 'funded'+i;
			}

			acctList.add(acct);
		}

		insert acctList;

		Account[] accts = [SELECT Id, Funded_Opp__c FROM Account];
		Opportunity[] oppList = new Opportunity[]{};

		for(Account a : accts){
			for(Integer i = 0; i < 2; i++){
				Opportunity o = new Opportunity();
				o.Name = 'test opp'+i;
				o.AccountId = a.Id;
				o.CloseDate = date.today()+30;

				if(math.mod(i,2) == 0) {
					o.StageName = 'Application In';
				} else {
					o.StageName = 'Application Sent';
				}
				
				oppList.add(o);
			}
		}

		insert oppList;

	}

	@isTest
	static void posTest(){
		Map<Id, Account> accts = new Map<Id, Account>([SELECT Id, Opportunity_Stage_Category__c 
													   FROM Account 
						     						   WHERE Name LIKE 'funded']);

		test.startTest();
		for(Account a : accts.values()){
			a.Opportunity_Stage_Category__c = 'Duplicate Opp';
		}

		update accts.values();
		test.stopTest();
		// When
		Set<Id> acctIds = accts.keySet();

		Opportunity[] oppList = [SELECT Owner.LastName 
								 FROM Opportunity
								 WHERE AccountId IN :acctIds];

		for(Opportunity o : oppList){
			System.assertNotEquals(o.Owner.LastName, 'Storage Account');
		}
	}

	@isTest
	static void negTest(){
		Map<Id, Account> accts = new Map<Id, Account>([SELECT Id, Opportunity_Stage_Category__c 
													   FROM Account 
						     						   WHERE Name LIKE 'no money']);

		test.startTest();
		for(Account a : accts.values()){
			a.Opportunity_Stage_Category__c = 'Duplicate Opp';
		}

		update accts.values();
		test.stopTest();
		// When
		Set<Id> acctIds = accts.keySet();

		Opportunity[] oppList = [SELECT Owner.LastName 
								 FROM Opportunity
								 WHERE AccountId IN :acctIds];

		for(Opportunity o : oppList){
			System.assertEquals(o.Owner.LastName, 'Storage Account');
		}
	}

}