@isTest
private class ReferralRequesteExtTest{
       static testMethod void test1 () {
			
			Opportunity opp = new Opportunity();
            opp.StageName = 'Referral Requested';
            opp.Name = 'test';
			opp.Probability =10.0;
            opp.CloseDate = System.today();
            insert opp;
	   
	   
            Opportunity opp1 = new Opportunity();
            opp1.StageName = 'Referral Requested';
			opp1.Id = opp.Id;
            opp1.Name = 'test';
			opp1.Probability =10.0;
            opp1.CloseDate = System.today();
            update opp1;
			
			Pay_Agreement_Worksheet__c paw=new Pay_Agreement_Worksheet__c();
			paw.Status__c='Cancelled';
			paw.Opportunity__c=opp1.id;
			insert paw;
			update paw;
			
            Quote quo = new Quote();
            quo.Name = 'test';
            quo.opportunityId = opp1.Id;
            quo.Status__c='Cancelled';
            insert quo;
            update quo;
                      
             
            ReferralRequesteExt Controller = new ReferralRequesteExt();
			
            ReferralRequesteExt.request(opp.id,'Referral Requested','FRN - Admissions Coordinator','Residential Treatment');
            
        
       }static testMethod void test2 () {
			id rec = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
			id recopp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
			contact con = new Contact();
			con.RecordTypeId = rec;
			con.LastName = 'test';
			insert con;
			
			Opportunity opp = new Opportunity();
            opp.StageName = 'Referral Requested';
            opp.Name = 'test';
            opp.Contact__c = con.id;
            opp.RecordTypeId = recopp;
			opp.Probability =10.0;
            opp.CloseDate = System.today();
            insert opp;
	   
	   
            Opportunity opp1 = new Opportunity();
            opp1.StageName = 'Referral Requested';
			opp1.Id = opp.Id;
            opp1.Name = 'test';
			opp1.Probability =10.0;
            opp1.CloseDate = System.today();
            update opp1;
			
			Pay_Agreement_Worksheet__c paw=new Pay_Agreement_Worksheet__c();
			paw.Status__c='Cancelled';
			paw.Opportunity__c=opp1.id;
			insert paw;
			update paw;
			
            Quote quo = new Quote();
            quo.Name = 'test';
            quo.opportunityId = opp1.Id;
            quo.Status__c='Cancelled';
            insert quo;
            update quo;
                      
             
            ReferralRequesteExt Controller = new ReferralRequesteExt();
			
            ReferralRequesteExt.request(opp.id,'Referral Requested','FRN - Admissions Coordinator','Refer Out Only');
            
        
       }
}