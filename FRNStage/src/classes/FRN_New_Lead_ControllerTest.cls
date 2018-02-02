@isTest
public class FRN_New_Lead_ControllerTest{
    static testMethod void test1(){
		 Account testAccount = new Account();
            testAccount.Name= 'Test Account'; 
            testAccount.Phone = '(012)-345-6769'; 
            insert testAccount; 	
			
		Contact con = new Contact();
			con.LastName = 'test';
			con.AccountId = testAccount.Id;
			insert con;
			
        lead newLead = new lead();
			newLead.FirstName = 'test';
			newLead.LastName = 'test';
			newLead.Company = 'test';
			newLead.Status = 'Converted';
			newLead.Opportunity_RecordType__c = 'Refer Out Only';        
			insert newLead;
			
		 ApexPages.StandardController sc = new ApexPages.standardController(newLead);
		 FRN_New_Lead_Controller FNLC = new FRN_New_Lead_Controller(sc);
		 FRN_New_Lead_Controller.CampaignMemberWrapper crw = new FRN_New_Lead_Controller.CampaignMemberWrapper();
		 crw.searchKeyWord= testAccount.Id;
		 crw.selectedKeyWrp= 'test';
		 FNLC.campMWrpList.add(crw);
		 FRN_New_Lead_Controller.getSearchResult('test');
		 FNLC.rendSection();
		 FNLC.editLead();
		 FNLC.deleteLead();
		 FNLC.cloneLead();
		 FNLC.fdLead();
		 FNLC.crtLead();
		 FNLC.cotLead();
		 FNLC.crooLead();
		 FNLC.searchPosition=1;
		 FNLC.selectedvalue();
		 FNLC.removeRow();
		 newLead.LeadSource ='Online';
		 FNLC.nLead=newLead;
		 FNLC.rendSection();
		 newLead.LeadSource ='Professional';
		 FNLC.nLead=newLead;
		 FNLC.rendSection();
		 newLead.LeadSource ='Friend or Family Member';
		 FNLC.nLead=newLead;
		 FNLC.rendSection();
		 newLead.LeadSource ='Unknown';
		 FNLC.nLead=newLead;
		 FNLC.rendSection();
     }
	static testMethod void test2(){
		 Account testAccount = new Account();
            testAccount.Name= 'Test Account'; 
            testAccount.Phone = '(012)-345-6769'; 
            insert testAccount; 	
			
		Contact con = new Contact();
			con.LastName = 'test';
			con.AccountId = testAccount.Id;
			insert con;
			
        lead newLead = new lead();
			newLead.FirstName = 'test';
			newLead.LastName = 'test';
			newLead.Company = 'test';
			newLead.Status = 'Converted';
			newLead.Opportunity_RecordType__c = 'Refer Out Only';        
			insert newLead;
			
		 ApexPages.StandardController sc = new ApexPages.standardController(newLead);
		 FRN_New_Lead_Controller FNLC = new FRN_New_Lead_Controller(sc);
		 FRN_New_Lead_Controller.CampaignMemberWrapper crw = new FRN_New_Lead_Controller.CampaignMemberWrapper();
		 crw.searchKeyWord= con.Id;
		 crw.selectedKeyWrp= 'test';
		 FNLC.campMWrpList.add(crw);
		 FRN_New_Lead_Controller.getSearchResult('test');
		 FNLC.rendSection();
		 FNLC.editLead();
		 FNLC.deleteLead();
		 FNLC.cloneLead();
		 FNLC.fdLead();
		 FNLC.crtLead();
		 FNLC.cotLead();
		 FNLC.crooLead();
		 FNLC.searchPosition=1;
		 FNLC.selectedvalue();
		 FNLC.removeRow();
     }
}