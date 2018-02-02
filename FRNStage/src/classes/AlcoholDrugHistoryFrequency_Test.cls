@isTest
public class AlcoholDrugHistoryFrequency_Test{
	
	static testMethod void Test1(){
		Account a1 = new Account();
		a1.name ='test';
		insert a1;
		
		Contact con = new Contact();
		con.LastName = 'testcon';
		insert con;
		
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Stage 1 - Learn';
		opp.CloseDate = date.newinstance(2013,1,31);
		opp.Type = 'Renewal';
		opp.accountId=a1.id;
		opp.contact__c = con.Id;
		insert opp;
		update opp;
		
		
		Clinical_Assessment__c Clinical = new Clinical_Assessment__c();
		Clinical.Caller_First_Name__c='test';
		Clinical.Opportunity__c = opp.Id;
		insert Clinical;
		update Clinical;
		
		
		
		Alcohol_Drug_History_Frequency__c ADH = new Alcohol_Drug_History_Frequency__c();
		ADH.Clinical_Assessment__c = Clinical.Id;
		ADH.Patient__c = con.Id;
		insert ADH;
		update ADH;
		
						
		 AlcoholDrugFreq ADF = new AlcoholDrugFreq();
		 
	}
}