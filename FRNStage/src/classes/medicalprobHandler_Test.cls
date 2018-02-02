@isTest
private class medicalprobHandler_Test
{

    static testMethod void test1() 
    {
		Contact con = new Contact();
		con.LastName = 'test';
		insert con;
		
		opportunity opp = new opportunity();
		opp.Name = 'test';
		opp.CloseDate = System.today();
		opp.StageName = 'Prospecting';
		opp.Contact__c = con.Id;
		insert opp;
		
		Medical_Problem_Symptom__c med = new Medical_Problem_Symptom__c();
		med.Opportunity__c = opp.Id;
		med.Patient__c = con.Id;
		insert med;
		update med;
        delete med;
        undelete med;
	}
 }