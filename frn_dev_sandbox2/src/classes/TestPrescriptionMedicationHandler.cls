@isTest 
private class TestPrescriptionMedicationHandler{
    private static TestMethod  void TestPrescriptionMedicationHandler_UnitTest(){
    
	Contact con = new Contact();
		con.LastName = 'test';
		insert con;
	
    opportunity opp = new opportunity();
	    opp.name = 'test';
        opp.StageName = 'Prospecting';
        opp.Probability = 100;
        opp.CloseDate  = System.today();
        opp.Contact__c = con.Id;
        insert opp;
	 
	Medication__c med = new Medication__c();
	    med.Name = 'test';
		insert med;
		
	Prescription_Medication__c pre = new Prescription_Medication__c();
	    pre.Opportunity__c = opp.Id;
		pre.Patient__c = con.Id;
		pre.Medication__c = med.Id;
		pre.Currently_Abusing_Substance__c = 'Yes';
		pre.Amount_Abused__c = 'test';
		insert pre;	
        update pre;
        delete pre;
        undelete pre;
    }	
}