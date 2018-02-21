@isTest
public with sharing class TestCountEstimatedHoursforProject {

	static testMethod void testEstimateHours() {
		
		Account objAccount = new Account(Name='Test', Type='Analyst', Sub_Type__c='Test', Industry='Energy');
		insert objAccount;
		
		Opportunity objOpp = new Opportunity(Name='Opp1', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
		insert objOpp; 
		
		HarvestProject__c objProject1 = new HarvestProject__c(Name='TestProject1',Account__c=objAccount.Id, Budget__c='No Budget', SyncStatus__c='Status Unknown', InvoiceMethod__c='This project is not billable' );
		insert objProject1;
		
		HarvestProject__c objProject2 = new HarvestProject__c(Name='TestProject2',Account__c=objAccount.Id, Budget__c='No Budget', SyncStatus__c='Status Unknown', InvoiceMethod__c='This project is not billable', Estimated_Hours__c=0 );
		insert objProject2;	
		
		HarvestProject__c objProject3 = new HarvestProject__c(Name='TestProject2',Account__c=objAccount.Id, Budget__c='No Budget', SyncStatus__c='Status Unknown', InvoiceMethod__c='This project is not billable', Estimated_Hours__c=0 );
		insert objProject3;		
				
		list<Estimates__c> listEstimates = new list<Estimates__c>{new Estimates__c(Name='TestEstimate1', Opportunity__c=objOpp.Id, Estimates_Hours__c=100, Estimated_Hrs_Developer__c=10, Harvest_Projects__c=objProject1.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=false )
																, new Estimates__c(Name='TestEstimate2', Opportunity__c=objOpp.Id, Estimates_Hours__c=150, Estimated_Hrs_Developer__c=20, Harvest_Projects__c=objProject1.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=false )
																, new Estimates__c(Name='TestEstimate3', Opportunity__c=objOpp.Id, Estimates_Hours__c=200, Estimated_Hrs_Developer__c=30, Harvest_Projects__c=objProject1.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=false )
																, new Estimates__c(Name='TestEstimate4', Opportunity__c=objOpp.Id, Estimates_Hours__c=250, Estimated_Hrs_Developer__c=40, Harvest_Projects__c=objProject2.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=true )
																, new Estimates__c(Name='TestEstimate5', Opportunity__c=objOpp.Id, Estimates_Hours__c=300, Estimated_Hrs_Developer__c=50, Harvest_Projects__c=objProject2.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=true )
																, new Estimates__c(Name='TestEstimate6', Opportunity__c=objOpp.Id, Harvest_Projects__c=objProject3.Id, Status__c='Open - Not Sent Yet', Include_in_Rollup__c=true )
																};
																
		insert listEstimates;		
		
		Test.startTest();
		list<HarvestProject__c> estimatehrs = [Select h.Estimated_Hours__c,h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject2.Id];
		System.assertEquals(550,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(90,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		list<Estimates__c> estimatehours = [Select h.Name,Estimates_Hours__c, Estimated_Hrs_Developer__c From Estimates__c h where Id=:listEstimates[5].Id];
		System.assertEquals(null,estimatehours[0].Estimates_Hours__c);
		System.assertEquals(null,estimatehours[0].Estimated_Hrs_Developer__c);
		
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject3.Id];
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(0,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		estimatehrs = [Select h.Estimated_Hours__c From HarvestProject__c h where Id=:objProject1.Id];
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		
		
		listEstimates[4].Estimates_Hours__c = 50;
		listEstimates[4].Estimated_Hrs_Developer__c=55;
		update listEstimates[4];
		
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject2.Id];		
		System.assertEquals(300,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(95,estimatehrs[0].Total_Estimated_Hrs_Developer__c);		
		//
				
		delete listEstimates[2];
		estimatehrs = [Select h.Estimated_Hours__c From HarvestProject__c h where Id=:objProject1.Id];
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		
		listEstimates[1].Include_in_Rollup__c = true;
		update listEstimates[1];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject1.Id];
		System.assertEquals(150,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(20,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		delete listEstimates[1];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject1.Id];
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(0,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		listEstimates[0].Include_in_Rollup__c = true;
		listEstimates[0].Harvest_Projects__c = objProject2.Id;
		update listEstimates[0];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject2.Id];		
		System.assertEquals(400,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(105,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		listEstimates[5].Include_in_Rollup__c = true;
		listEstimates[5].Harvest_Projects__c = objProject1.Id;
		update listEstimates[5];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject1.Id];		
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		
		listEstimates[5].Estimates_Hours__c = 50;
		listEstimates[5].Estimated_Hrs_Developer__c=55;
		update listEstimates[5];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject1.Id];		
		System.assertEquals(50,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(55,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		listEstimates[5].Include_in_Rollup__c = false;
		listEstimates[5].Harvest_Projects__c = objProject3.Id;
		update listEstimates[5];
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject1.Id];		
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(0,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		
		estimatehrs = [Select h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c From HarvestProject__c h where Id=:objProject3.Id];		
		System.assertEquals(0,estimatehrs[0].Estimated_Hours__c);
		System.assertEquals(0,estimatehrs[0].Total_Estimated_Hrs_Developer__c);
		Test.stopTest();
	}
}