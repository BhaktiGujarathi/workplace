@isTest
public class InfectiousDiseaseHandler_Test{
	
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
		Infectious_Disease__c ids = new Infectious_Disease__c(Opportunity__c=opp.Id);
		insert ids;
		update ids;
		
		Abused_Substance__c abs = new Abused_Substance__c();
		insert abs;
		update abs;
		InfectiousDiseaseHandler IDH = new InfectiousDiseaseHandler();
		IDH.bulkAfter();
       
	}
	
	static testMethod void Test2(){
		
		Account a2 = new Account();
		a2.name ='test';
		insert a2;
		
		Contact con1 = new Contact();
		con1.LastName = 'testcon';
		insert con1;
		
		Opportunity opp1 = new Opportunity();
		opp1.Name = 'Test Opportunity';
		opp1.StageName = 'Stage 1 - Learn';
		opp1.CloseDate = date.newinstance(2013,1,31);
		opp1.Type = 'Renewal';
		opp1.accountId=a2.id;
		opp1.contact__c = con1.Id;
		insert opp1;
		
		
		Infectious_Disease__c ids1 = new Infectious_Disease__c(Opportunity__c=opp1.Id);
		insert ids1;	
		update ids1;	
		
	
		
	}
	
}