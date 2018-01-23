@isTest
public class convertLeadTest{
	
	static testmethod void test1(){
		OpportunityEstimatedCloseDays__c opcd = new OpportunityEstimatedCloseDays__c();
			opcd.Name = 'EstimatedCloseDays';
			opcd.Number__c = 30;
			insert opcd;
			
		Lead lead = new Lead(LastName='Test',FirstName='JTest',Company='Test',Status='Inquiry',Caller_Last_Name__c ='test',Caller_First_Name__c='test1',Caller_Phone__c='test',StateCode = 'DE',City = 'testcity',Relationship_to_Patient__c = 'Self');
			insert lead;   
			
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

		User u = new User(Alias = 'stan1t', Email='standarduser@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='TestingU1', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='standarduserU1@testorg.com'); 
			insert u;
			
		Contact con= new Contact();
			con.LastName= 'test';
			insert con;
					
		Opportunity opp = new Opportunity(	Name = 'Test', StageName = 'Prospecting',Probability = 10.00,CloseDate = system.today(),Contact__c  = con.id);
			insert opp;
			
			
		convertLead cL = new convertLead();
		convertLead.convertLeadtoAcc(lead.Id);
	}
static testmethod void test2(){
		OpportunityEstimatedCloseDays__c opcd = new OpportunityEstimatedCloseDays__c();
			opcd.Name = 'EstimatedCloseDays';
			opcd.Number__c = 30;
			insert opcd;
			
		Lead lead = new Lead(LastName='test',FirstName='',Company='',Status='',Caller_Last_Name__c ='',Caller_First_Name__c='',Caller_Phone__c='',StateCode = '',City = '',Relationship_to_Patient__c = '');
			insert lead;   
			
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

		User u = new User(Alias = 'stan1t', Email='standarduser@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='TestingU1', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='standarduserU1@testorg.com'); 
			insert u;
			
		Contact con= new Contact();
			con.LastName= 'test';
			insert con;
					
		Opportunity opp = new Opportunity(	Name = 'Test', StageName = 'Prospecting',Probability = 10.00,CloseDate = system.today(),Contact__c  = con.id);
			insert opp;
			
			
		convertLead cL = new convertLead();
		convertLead.convertLeadtoAcc(lead.Id);
	}	
	
 }