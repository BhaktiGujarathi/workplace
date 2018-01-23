@isTest
public class NewAbSubControllerTest{
 testMethod static void test1(){
	 contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test1';
        con.Social_Security_Number__c = 'Test';
        insert con;
		
		
		Id oppRTId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
		opp.RecordTypeId = oppRTId2;
        opp.StageName='Prospecting';
        opp.Contact__c = con.Id;
        opp.Probability = 10;
        insert opp;
		
         Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
         Id accRTId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance Company').getRecordTypeId();
		 
        Account acc = new Account();
        acc.Name = 'Test';
		acc.RecordTypeId = accRTId1;
        acc.Phone = '(123) 456-7890';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.RecordTypeId = accRTId;
        acc1.Phone = '(123) 456-7890';
        acc1.FRN_Facility_Type__c ='Residential Treatment';
        insert acc1;
        
        Patient_Insurance__c pins = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1),Term_Date__c = System.Today());
        insert pins;
       
        Insurance_Company_Rate_Adjustment__c icra = new Insurance_Company_Rate_Adjustment__c();
        icra.Insurance_Company__c = acc.Id;
        icra.FRN_Facility__c = acc1.Id;
        icra.In_Network_Rate_Adjustment__c = 10;
        icra.Out_of_Network_Rate_Adjustment__c = 10;
        insert icra;
        
        Patient_Contact__c patcon = new Patient_Contact__c();
        patcon.Opportunity__c = opp.id;
        patcon.First_Name__c = 'test';
        patcon.Last_Name__c='test1';
        insert patcon;
		
		Patient_Insurance__c pins1 = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(),subscriber__c= patcon.id, Renewal_Date__c = System.Today().addYears(1),Term_Date__c = System.Today());
        insert pins1;
		
        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c();
        paw.Patient_Insurance__c = pins.Id;
        paw.Num_Days_Detox_DTX__c = 1;
        paw.Num_Days_Residential_Treatment_RTC__c = 1;
        paw.FRN_Facility__c = acc1.Id;
        paw.Num_Days_Partial_Hospitalization_PHP__c = 1;
        paw.Num_Days_Intensive_Outpatient_IOP__c = 1;
        insert paw;
		
		ApexPages.CurrentPage().getparameters().put('id',opp.id);
		ApexPages.CurrentPage().getparameters().put('patc',pins.id);
		ApexPages.CurrentPage().getparameters().put('patc',patcon.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		// //From Pay_Agreement_Worksheet__c 
        PageReference pageRef = Page.NewPatientInsPage;
        pageRef.getParameters().put('id', opp.id);
        pageRef.getParameters().put('retURL', '/'+opp.id);
        Test.setCurrentPage(pageRef);
		NewAbSubController obj = new NewAbSubController(sc);
		obj.getInsuranceCompany();
		obj.patientcontact();
		obj.Cancel();
		obj.SaveandNew1();
		obj.getsubscriberName();
		obj.SubscriberEmployer();
		obj.PatContactCancel();
		obj.Save1();
		obj.SaveandNew();		
		obj.populateFromOpp();
		obj.patientcontact();
		obj.conDetail();
		obj.Save();
       
        
	}
	

}