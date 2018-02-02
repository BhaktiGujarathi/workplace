@isTest
public class NewLeadController_Test{
    static testMethod void Test1(){   
        RecordType rc = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
        Account acc = new Account();
        acc.Name= 'test';
        acc.RecordTypeId=rc.Id;
		//acc.RAM_Lookup__c = Userinfo.getUserId();
        insert acc;
		
		        
        Lead nLead = new Lead();
        nLead.company =  'New Household';
        nLead.LastName =  'test';
        nLead.Status =  'Open';
        insert nLead;
        
        Contact con = new contact();
        con.LastName = 'Test';
		con.AccountId = acc.Id;
        insert con;
		
		/* Treatment_History__c th = new Treatment_History__c(Opportunity__c = opp1.id, Lead__c = nLead.id, Patient__c = con.id, Level_of_Care__c = 'Psych stabilization');
		insert th; */
        
        rc = [select id from  RecordType where SobjectType='Referral__c' AND Name='Inbound Referral'];
        Referral__c re = new Referral__c();
        re.Account__c=acc.Id;
        re.Lead__c=nLead.Id;
        re.RecordTypeId=rc.Id;
        insert re;
        
        ApexPages.currentPage().getParameters().put('about','Test');
         ApexPages.StandardController sc = new ApexPages.StandardController (nLead);
        NewLeadController nc = new NewLeadController(sc);
        nc.rendSection();
        
        nLead.LeadSource = 'Professional';
        
        Update nLead;
        sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nc.rowToRemove=0;
        nc.rendTreatmentHistoryInfo();
        nc.leadCallingFor();
        nc.toldYouAbout();
        nc.removeRow();
        nc.addNewTreatmentHistoryObj();
		nc.rowToRemove = 0;
        nc.removeRowToTreatmentHistoryList();
        nLead.LeadSource = 'Unknown';
        Update nLead;
		
		sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nc.rowToRemove=0;
        nc.rendTreatmentHistoryInfo();
        nc.leadCallingFor();
        nc.toldYouAbout();
        nc.removeRow();
        nc.addNewTreatmentHistoryObj();
		nc.rowToRemove = 0;
        nc.removeRowToTreatmentHistoryList();
        nLead.LeadSource = 'Professional';
        Update nLead;
		
        sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nLead.LeadSource = 'Friend or Family Member';
        Update nLead;
        sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nLead.LeadSource = 'Online';
		Update nLead;
        
        sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nc.leadCallingFor();
        nc.searchPosition= 0;
		nc.campMWrpList[0].searchKeyWord = acc.Id;
        nc.selectedvalue();		
        NewLeadController.getSearchResult('Test');
		nc.searchPosition= 0;
		nc.campMWrpList[0].searchKeyWord = con.Id;
		nc.campMWrpList[0].cmpM.Account__c = acc.Id;
        nc.selectedvalue();
		nc.nLead.LeadSource = 'Professional';
		nc.nLead.Prior_Treatment__c='Yes';
        nc.saveAndNewLead();
		nc.nLead.Prior_Treatment__c='Yes';
		nc.nLead.LeadSource = 'Unknown';
        nc.saveLeadData();
        nc.saveLead();
        nc.saveAndContinue();
        nc.cancel();
        nc.hideMessage();
        nc.rendLeadSourceisFRNAlumniInfo();
		sc = new ApexPages.StandardController (nLead);
        nc = new NewLeadController(sc);
        nc.rendSection();
        nc.leadCallingFor();
        nc.searchPosition= 0;
		nc.campMWrpList[0].searchKeyWord = acc.Id;
        nc.selectedvalue();		
        NewLeadController.getSearchResult('Test');
		nc.searchPosition= 0;
		nc.campMWrpList[0].searchKeyWord = con.Id;
		nc.campMWrpList[0].cmpM.Account__c = acc.Id;
        nc.selectedvalue();
		nc.nLead.LeadSource = 'Professional';
		nc.nLead.Prior_Treatment__c='Yes';
        nc.saveAndNewLead();
		nc.nLead.Prior_Treatment__c='Yes';
		nc.nLead.LeadSource = 'Alumni';
        nc.saveLeadData();
        nc.saveLead();
        nc.saveAndContinue();
        nc.cancel();
        nc.hideMessage();
        nc.rendLeadSourceisFRNAlumniInfo();
		
 
    } 

	
	 static testMethod void Test2(){
		 
		 RecordType rc = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
        Account acc = new Account();
        acc.Name= 'test';
        acc.RecordTypeId=rc.Id;
		//acc.RAM_Lookup__c = Userinfo.getUserId();
        insert acc;
		 
		        
        Lead nLead = new Lead();
        nLead.company =  'New Household';
        nLead.LastName =  'test';
        nLead.Status =  'Open';
        insert nLead;
        
        Contact con = new contact();
        con.LastName = 'Test';
		con.AccountId = acc.Id;
        insert con;
		
		Treatment_History__c th = new Treatment_History__c(Lead__c = nLead.id, Patient__c = con.id, Level_of_Care__c = 'Psych stabilization');
		insert th;
		
		
		
		ApexPages.currentPage().getParameters().put('id',nLead.id);
         ApexPages.StandardController sc = new ApexPages.StandardController (nLead);
        NewLeadController nc = new NewLeadController(sc);
		
		
        nc.rendSection();
        nc.rowToRemove=0;
        nc.rendTreatmentHistoryInfo();
        nc.leadCallingFor();
        nc.toldYouAbout();
        nc.removeRow();
        nc.addNewTreatmentHistoryObj();
		nc.rowToRemove = 0;
        nc.removeRowToTreatmentHistoryList();
        
	 }
    
    
    static testMethod void Lead_assign_highpriority_referral_information(){ 
    	RecordType rc = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
        Account acc = new Account();
        acc.Name= 'test';
        acc.RecordTypeId=rc.Id;
        acc.Special_Instructions__c = 'Treat the patient in a special way';
        acc.High_Priority__c = true;
		insert acc;
		
        Lead nLead = new Lead();
        nLead.company =  'New Household';
        nLead.LastName =  'test';
        nLead.Status =  'Open';
        insert nLead;
        
        Contact con = new contact();
        con.LastName = 'Test';
		con.AccountId = acc.Id;
        insert con;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController (nLead);
        NewLeadController leadController = new NewLeadController(standardController);
        
        NewLeadController.getSearchResult('Test');
		leadController.searchPosition= 0;
		leadController.campMWrpList[0].searchKeyWord = con.Id;
		leadController.campMWrpList[0].cmpM.Account__c = acc.Id;
        leadController.selectedvalue();
        
        leadController.saveLead();
        System.assertEquals(  [SELECT Referral_Instruction__c FROM Lead WHERE Id = :nLead.Id].Referral_Instruction__c
                             , acc.Special_Instructions__c 
                             , 'Special instructions not pulled from high priority referral to lead.'
                           );  
    }
}