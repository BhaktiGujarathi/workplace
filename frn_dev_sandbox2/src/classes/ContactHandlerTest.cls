@isTest
public class ContactHandlerTest{
    static testMethod void Test1(){   
        Contact con = new contact();
        con.LastName = 'Test';		
        insert con;
		
		List<Opportunity> oppList = new List<Opportunity>();
		
		Opportunity opp = new Opportunity();
		opp.StageName = 'Prospecting';
		opp.Name = 'test';
		opp.CloseDate = System.today();
		opp.Contact__c = con.Id;
		opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
		oppList.add(opp);
		
		Opportunity opp1 = new Opportunity();
		opp1.StageName = 'Prospecting';
		opp1.Name = 'test';
		opp1.CloseDate = System.today();
		opp1.Contact__c = con.Id;
		opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
		oppList.add(opp1);

		Opportunity opp2 = new Opportunity();
		opp2.StageName = 'Prospecting';
		opp2.Name = 'test';
		opp2.CloseDate = System.today();
		opp2.Contact__c = con.Id;
		opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
		oppList.add(opp2);
		
		insert oppList;
		con.FirstName = 'Test';
		update con;
    } 
}