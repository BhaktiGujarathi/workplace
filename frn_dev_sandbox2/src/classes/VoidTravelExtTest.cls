@isTest
private class VoidTravelExtTest{
       static testMethod void test1 () {
		      Account acc = new Account();  
				acc.Name = 'tesst';  
				insert acc;  
			Contact con = new Contact();
			con.Lastname = 'test';
			insert con;
            Opportunity opp = new Opportunity();
            opp.StageName = 'In Progress';
            opp.Name = 'test'; 
			opp.Contact__c = con.id;
            opp.CloseDate = System.today();
            opp.AccountId = acc.id;
			
            insert opp; 
			 
			 Quote est = new Quote();
			 est.Name = 'test quote';
			 est.OpportunityId = opp.Id;
			 est.Status__c = 'Open';
			 insert est;
		 
            
            VoidTravelExt Controller = new VoidTravelExt();
			
            VoidTravelExt.request(opp.id,'','');
            
        
       }
}