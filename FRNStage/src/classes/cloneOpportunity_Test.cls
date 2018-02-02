@isTest
public class cloneOpportunity_Test{
	
	 static testMethod void Test(){
		 Id x; 
		 Id y; 
		 Id z; 
		 Id a; 
		//String oppID = ApexPages.currentPage().getParameters().get('Id');
		
		Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
		
		Contact con = new Contact();
			con.LastName = 'test';
			insert con;
	
		Opportunity opp = new Opportunity();
			opp.Name = 'test';
			opp.RecordTypeId = OppRecId;
			opp.Contact__c = con.Id;
			opp.StageName = 'Benefits Submitted';
			opp.CloseDate = System.today();
			opp.Probability = 10;
			opp.AC_Assigned__c = u.Id;
			opp.RAM_Assigned__c = u.Id;
			opp.VOB_Assigned__c = u.Id;
			opp.LeadSource = 'Professional';
			opp.Lead_Source_is_FRN_Alumni__c = 'Yes';
			opp.Online_Search_Term__c = 'test';
			opp.Alumni_Referral_Source__c = 'Professional';
			opp.Referral_Source_Unknown_Details__c = 'test';
			opp.Brief_PPH__c = 'test';
			opp.Scratchpad__c = 'test';
			insert opp;
			
			Patient_Insurance__c pat = new Patient_Insurance__c();
				pat.Name = 'test';
				pat.Opportunity__c = opp.Id;
				insert pat;
			
		x = cloneOpportunity.cloneOpptyRecordType(opp.Id); 
		y = cloneOpportunity.UpdatePatientInOppty(pat.Id); 
		z = cloneOpportunity.cloneOutPatOppty(opp.Id); 
		a = cloneOpportunity.cloneOpptyResTreatType(opp.Id); 
	 }
}