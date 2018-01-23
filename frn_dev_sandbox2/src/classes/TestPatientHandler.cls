@isTest 
private class TestPatientHandler{
    private static TestMethod  void TestPatientHandler_UnitTest(){
    
	Contact con = new Contact();
	
	RecordType rec = [SELECT Id, Name from RecordType where sObjectType ='Contact' And IsActive = true And Name='Referral Source Contact'];
	
	con.LastName = 'test';
	insert con;
	
    opportunity opp = new opportunity();
	
	RecordType rec1 = [SELECT Id, Name from RecordType where sObjectType ='opportunity' And IsActive = true And Name='Outpatient Treatment'];
	
        opp.name = 'test';
        opp.StageName = 'Prospecting';
        opp.Probability = 100;
        opp.CloseDate  = System.today();
        opp.Contact__c = con.Id;
        insert opp;
		
		Medical_Equipment__c med = new Medical_Equipment__c();
		med.Opportunity__c = opp.Id;
		med.Patient__c = con.Id;
		insert med;
        update med;
    }
}