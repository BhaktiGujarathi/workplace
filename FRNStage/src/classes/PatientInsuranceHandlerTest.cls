@isTest
public class PatientInsuranceHandlerTest {
  
	private static testMethod  void PatientInsuranceHandler_test(){
		
		Account acc = new Account();
		acc.Name = 'test';
		insert acc;
		update acc;
		
		contact con = new contact();
		con.FirstName = 'Test';
		con.LastName = 'Name';
		insert con;
		update con;
		
		Patient_Insurance__c pi = new Patient_Insurance__c();
		pi.Patient__c = con.Id;
		pi.Insurance_Company__c = acc.Id;
		pi.Name = 'Test';
		pi.Member_ID__c = 'Test';
		insert pi;
		update pi;
	
	}    
}