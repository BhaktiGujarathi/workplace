@isTest
public class EditPatInsControllerTest {
	static testMethod void Test(){
        
        Contact con = new Contact(Lastname = 'Test', FirstName= 'test',Social_Security_Number__c='12345',Birthdate=System.today().addYears(-25));
        insert con;
                
        Account acc = new Account(Name='test',Phone='12345',Type='TV',Master_Referral_Type__c='Judge');
        
        Opportunity opp = new Opportunity (Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting',Contact__c = con.id);
        insert opp; 

        Patient_Contact__c pc = new Patient_Contact__c(First_Name__c='test',Last_Name__c='test',Employer__c='test',Opportunity__c = opp.Id,Contact__c = con.Id);
        insert pc;
            
        Patient_Insurance__c pat = new Patient_Insurance__c (Name = 'test',Patient__c= con.Id,Patient_Social_Security_Number__c = '123',Opportunity__c= opp.Id,Subscriber_is_Patient__c= true,Benefits_Check__c=true,Insurance_Plan__c='PPO',Insurance_Company__c=acc.Id,Provider_Services_Phone__c='12345',Member_ID__c='test',Behavioral_Health_Phone__c= '12345',Group_Number__c='12345',Type_Order__c='Termed',Policy_Effective_Date__c= system.today(),COB_Completed__c='No',Renewal_Date__c=system.today(),COB_Needed__c='No',Term_Date__c=system.today(),State_of_Origination__c='Hawaii',Claims_Billing_Address__c='test',PreCert_Required__c='Yes',Accreditation__c='State',Vendor__c='test',Free_Standing_RTC_Facility__c='No',PreCert_Phone__c='12345',Free_Standing_Facility__c='No',PreCert_Penalty_Description__c='test',Travel_Out_of_State_for_Non_Emergent_Tx__c='Yes',Accepts_Assignment_of_Benefits__c='Yes',Prior_Auth_Before_Travel__c='Yes',Referral_Needed__c='Yes',Pharmacy_Coverage__c='No',Rx_Vendor__c='test',Rx_Phone__c='12345',ACA_Policy__c='No',ACA_Policy_Paid_Through_Date__c= system.today(),COBRA_Account__c='Yes',Subscriber_Employer__c='test',COBRA_Effective_Date__c= system.today(),COBRA_Paid_Through_Date__c=system.today());
        insert pat;
        apexpages.currentpage().getparameters().put('id',pat.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        EditPatInsController epit = new EditPatInsController(sc);
        epit.SubscriberEmployer();
        epit.Cancel();      
        epit.addNewPCObj();
        epit.getInsuranceCompany();
        epit.Selectedsubscriber = pat.Patient__c;
        epit.getSubscriberName();
        epit.PatContactCancel();
        epit.conDetail();
        epit.calculateYears(con.Birthdate);
        epit.getRepInfoFromDB();
        epit.getLstRepInfoWrp();
        epit.Save();
               
    }
        
    static testMethod void Test1(){
        
        Contact con = new Contact(Lastname = 'Test', FirstName= 'test',Social_Security_Number__c='12345',Birthdate=System.today());
        insert con;
                
        Account acc = new Account(Name='test',Phone='12345',Type='TV',Master_Referral_Type__c='Judge');
        
        Opportunity opp = new Opportunity (Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting',Contact__c = con.id);
        insert opp; 

        Patient_Contact__c pc = new Patient_Contact__c(First_Name__c='test',Last_Name__c='test',Employer__c='test',Opportunity__c = opp.Id,Contact__c = con.Id);
        insert pc;
            
        Patient_Insurance__c pat = new Patient_Insurance__c (Name = 'test',Patient__c= con.Id,Patient_Social_Security_Number__c = '123',Opportunity__c= opp.Id,Subscriber_is_Patient__c= false,Subscriber__c= pc.Id,Benefits_Check__c=true,Insurance_Plan__c='PPO',Insurance_Company__c=acc.Id,Provider_Services_Phone__c='12345',Member_ID__c='test',Behavioral_Health_Phone__c= '12345',Group_Number__c='12345',Type_Order__c='Termed',Policy_Effective_Date__c= system.today(),COB_Completed__c='No',Renewal_Date__c=system.today(),COB_Needed__c='No',Term_Date__c=system.today(),State_of_Origination__c='Hawaii',Claims_Billing_Address__c='test',PreCert_Required__c='Yes',Accreditation__c='State',Vendor__c='test',Free_Standing_RTC_Facility__c='No',PreCert_Phone__c='12345',Free_Standing_Facility__c='No',PreCert_Penalty_Description__c='test',Travel_Out_of_State_for_Non_Emergent_Tx__c='Yes',Accepts_Assignment_of_Benefits__c='Yes',Prior_Auth_Before_Travel__c='Yes',Referral_Needed__c='Yes',Pharmacy_Coverage__c='No',Rx_Vendor__c='test',Is_this_Medicare_Medicaid__c = 'Yes',Rx_Phone__c='12345',ACA_Policy__c='No',ACA_Policy_Paid_Through_Date__c= system.today(),COBRA_Account__c='Yes',Subscriber_Employer__c='test',COBRA_Effective_Date__c= system.today(),COBRA_Paid_Through_Date__c=system.today());
        insert pat;
        apexpages.currentpage().getparameters().put('id',pat.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        EditPatInsController epit = new EditPatInsController(sc);
        epit.SubscriberEmployer();
        epit.Cancel();      
        epit.addNewPCObj();
        epit.getInsuranceCompany();
        epit.Selectedsubscriber = pat.Patient__c;
        epit.getSubscriberName();
        epit.PatContactCancel();
        epit.conDetail();
        epit.newPatientContact();
        epit.calculateYears(con.Birthdate);
        epit.getRepInfoFromDB();
        epit.getLstRepInfoWrp();
        epit.Save();
               
    }       
	
	static testMethod void Test2(){
		RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Qualification',Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp1;
		
		contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
		
		Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True);
        insert pi;
        update pi;
		
		
		Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp1.id, Contact__c = con.id);
        insert pc;
		
		
		ApexPages.StandardController sc = new ApexPages.StandardController (opp1);
		EditPatInsController epc = new EditPatInsController(sc);
		epc.Cancel();
		epc.getInsuranceCompany();
		epc.getSubscriberName();
		epc.SubscriberEmployer();
		epc.OtherInsCom();
		epc.getRepInfoFromDB();
        epc.getLstRepInfoWrp();
		epc.addReprestativeInfoNew();
		epc.repInfoTndexToRemove = 0;
		epc.deleteReprestativeInfo();
		epc.conDetail();
	}
}