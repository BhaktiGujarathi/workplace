@isTest
public class NewPatInsControllerTest {


    private static TestMethod  void NewPatInsController_UnitTest(){
		
		
		RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='Insurance Company'];
		Account Acc = new Account();
        acc.recordtypeid = rc1.id;
		acc.Name = 'test';
        insert Acc;
		
		Contact con = new Contact();
		con.FirstName = 'test';
		con.LastName = 'test';
		con.Birthdate = System.Today();
		con.Social_Security_Number__c = 'test';
		insert con;
		
		Opportunity opp= new Opportunity();
		opp.Contact__c = con.Id;
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;
		
	    Patient_Contact__c patcon = new Patient_Contact__c();
		patcon.Opportunity__c = opp.id;
		patcon.First_Name__c = 'test';
		patcon.Last_Name__c='test';
		insert patcon;		
		
        Patient_Insurance__c pins = new Patient_Insurance__c();
		pins.Opportunity__c=opp.id;
		pins.Patient__c= opp.Contact__c;
		pins.Patient_Social_Security_Number__c = 'test';
		pins.Subscriber_is_Patient__c =True;
		pins.Subscriber__c =patcon.id;
		insert pins;
	   

	   
		
		ApexPages.currentPage().getParameters().put('id',opp.Id);
		ApexPages.currentPage().getParameters().put('patc',patcon.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		
		NewPatInsController patins = new NewPatInsController(sc);
        //patins.populateFromOpp();
		//patins.SaveandNew1();
		//patins.Save1();
		patins.getLstRepInfoWrp();
		patins.PatContactCancel();
		patins.SaveandNew();
		patins.SubscriberEmployer();
		patins.Save();
		patins.Cancel();
		//patins.patientcontact();
		patins.getInsuranceCompany();
		patins.getSubscriberName();
		patins.newPatientContact();
		patins.addNewPCObj();
		patins.conDetail();
		patins.calculateYears(System.Today().addYears(-25));
		patins.calculateYears(System.Today().addYears(5));
		patins.calculateYears(System.Today());
		
	}  

	   private static TestMethod  void NewPatInsController_UnitTest2(){
		   
		   Account acc = new Account();
            acc.Name = 'test';
            insert acc;
            
		
		Contact con = new Contact();
		con.FirstName = 'test';
		con.LastName = 'test';
		con.Social_Security_Number__c ='test123';
		insert con;
		
		Opportunity opp= new Opportunity();
		opp.Contact__c = con.Id;
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;

        Patient_Contact__c patcon = new Patient_Contact__c();
		patcon.Opportunity__c = opp.id;
		patcon.First_Name__c = 'test';
		patcon.Last_Name__c='test';
		insert patcon;

		//Quote q = new Quote(name = 'Test Quote', opportunityId = opp.id);
        //insert q;
		
		// Quote q = new Quote();
            // q.Name = 'test';
            // q.opportunityId = opp.Id;
            // q.FRN_Facility__c = acc.Id;
            // q.Insurance_Company__c = acc.Id;
            // q.Insurance_Company_Contract_Type__c = 'In Network';
            // insert q;

		ApexPages.currentPage().getParameters().put('retpg','QuoteExtPage');
		//ApexPages.currentPage().getParameters().put('retUrl','q.id');

		Patient_Insurance__c pins = new Patient_Insurance__c(Opportunity__c = opp.Id);

		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		
		NewPatInsController patins = new NewPatInsController(sc);
  		patins.pat = pins;
  		patins.Selectedsubscriber = patcon.Id;
  		//patins.patientcontact();
		patins.Cancel();
		//patins.SaveandNew();
	}
	
	private static TestMethod  void saveReprestativeInfoTestCase() {
	    
	    Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'test';
        con.Social_Security_Number__c ='test123';
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.Contact__c = con.Id;
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        insert opp;

        Patient_Contact__c patcon = new Patient_Contact__c();
        patcon.Opportunity__c = opp.id;
        patcon.First_Name__c = 'test';
        patcon.Last_Name__c='test';
        insert patcon;
        
        ApexPages.currentPage().getParameters().put('id',opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        
        NewPatInsController cntrller = new NewPatInsController(sc);
        Test.startTest();
            cntrller.getRepInfoFromDB();
            cntrller.getLstRepInfoWrp();
            cntrller.Selectedsubscriber = (cntrller.getSubscriberName())[0].getValue();
            cntrller.addReprestativeInfoNew();
            cntrller.lstRepInfoWrp[0].repInfo.Name = 'Test';
            cntrller.lstRepInfoWrp[1].repInfo.Name = 'Test1';
            cntrller.save();
            cntrller.OtherInsCom();
            cntrller.repInfoTndexToRemove = 0;
            cntrller.deleteReprestativeInfo();
        Test.stopTest();
	}
	
}