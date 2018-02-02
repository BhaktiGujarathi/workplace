@isTest
public class BenefitsVOBStatus_test{
    static TestMethod void BenefitsVOBStatus_UnitTest(){ 
	
		contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
	
		RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Qualification',Probability = 10,LeadSource = 'Professional',OwnerId = UserInfo.getUserId(),CloseDate =  Date.today(),RecordTypeId = rc1.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes');
        insert opp1;
		
		Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp1.id, Contact__c = con.id, First_Name__c = 'test', Last_Name__c = 'test');
        insert pc;
		
		Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True,Subscriber__c=pc.Id);
        insert pi;		
		
		Account acc = new Account();
            acc.Name = 'test';
            insert acc;
		
		
		Insurance_Benefit__c ib = new Insurance_Benefit__c(Patient_Insurance__c=pi.id, Disposition__c = 'Benefits Available');
            insert ib;
		
		Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c = opp1.id, Insurance_Benefit__c=ib.id);
            insert paw;
		
        
        Test.startTest();
            BenefitsVOBStatus c = new BenefitsVOBStatus();
			BenefitsVOBStatus.VOBStatusCheck(opp1.id);
			BenefitsVOBStatus.VOBStageCheck(paw.id);
        Test.stopTest();
        
    }
		    
}