@isTest
public class BenefitHandler_Test{
	 static testMethod void Test1(){
		 Contact con = new Contact();
		 con.lastName='test';
		 con.Birthdate=System.today().addYears(-20);
		 insert con;
		 
		 Patient_Insurance__c PI = new Patient_Insurance__c();
		 PI.Name = 'Test';
		 PI.Patient__c = con.Id;
		 insert PI;
		 
		// RecordType rc = [select id from  RecordType where SobjectType='Insurance_Benefit__c' AND Name='In Network'];
		 
		 Insurance_Benefit__c IB = new Insurance_Benefit__c();
		 //RecordTypeId = rc.id;
		 IB.Patient_Insurance__c = PI.id;
		 IB.LOC_Benefits_are_the_Same__c=true;
		 IB.PHP_Covered__c='Yes';
		 insert IB;
		 
		 Insurance_Benefit__c Ins = new Insurance_Benefit__c();
		 Ins.Patient_Insurance__c= PI.id;
		 Ins.LOC_Benefits_are_the_Same__c=true;
		 Ins.PHP_Covered__c=ins.Detox_Covered__c;
		 insert Ins;
		 update Ins;
	     //delete IB;
		// undelete IB;
		
		 
		
		 
	 }
}