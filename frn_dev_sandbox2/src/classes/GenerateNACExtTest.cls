@isTest
public class GenerateNACExtTest{
    static testMethod void Test1(){   
        Contact con = new contact();
        con.LastName = 'Test';		
        insert con;	
		
		Opportunity opp = new Opportunity();
		opp.StageName = 'Prospecting';
		opp.Name = 'test';
		opp.CloseDate = System.today();
		opp.Contact__c = con.Id;
		opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
		insert opp;
		
		Patient_Contact__c pc = new Patient_Contact__c(First_Name__c = 'Test',Last_Name__c = 'TestL',Opportunity__c = opp.Id);
		insert pc;
		
		Patient_Contact__c pc1 = new Patient_Contact__c(Last_Name__c = 'TestL',Opportunity__c = opp.Id);
		insert pc1;
		
		ApexPages.currentPage().getParameters().put('id',''+opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController (opp);
        GenerateNACExt nc = new GenerateNACExt(sc);
        nc.generateNAC();
    } 
}