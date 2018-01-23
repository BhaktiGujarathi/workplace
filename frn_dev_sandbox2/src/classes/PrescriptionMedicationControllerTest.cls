@isTest 
public class PrescriptionMedicationControllerTest {
	static testMethod void testMethod1() {
		
		Account Acc = new Account();
        acc.Name = 'test';
        insert Acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        con.Social_Security_Number__c = 'test#';
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.contact__c= con.id;
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
		
		Prescription_Medication__c pm = New Prescription_Medication__c(Opportunity__c = opp.id, Patient__c = con.id);
		insert pm;
		
		ApexPages.CurrentPage().getparameters().put('retUrl',opp.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(con);
        PrescriptionMedicationController pmc = new PrescriptionMedicationController(sc);
		
		pmc.saveNew();
		pmc.save();
		pmc.cancel();
	}
}