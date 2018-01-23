@isTest
private class CampaignMemberHandlerTest{
	
   Static testMethod void Test1(){
	    RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='Referral Source'];
		Account acc = new Account();
		   acc.Name = 'test';
		   acc.RecordTypeid = rc1.id;
		insert acc;
		
		Contact con = New Contact();
		con.LastName='test';
		insert con;
		
		Campaign cam = new Campaign(Name = 'test', Referral_Source__c= acc.Id);
		insert cam;
		
		Lead ld = new Lead(LastName = 'Test',Company = 'Test',Status = 'Open');
		insert ld;
		
		CampaignMember cm =  new CampaignMember(Status = 'Sent', CampaignId = cam.Id, LeadId = ld.Id,Referral_Source__c= acc.Id, Referral_Source_Contact__c=Con.id);
		insert cm;
        update cm;
        delete cm;
      
    }
}