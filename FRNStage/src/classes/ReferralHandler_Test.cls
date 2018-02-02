@isTest
private class ReferralHandler_Test {
    static testMethod void validateTestReferralBeforeInsert() {
	
        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
		 
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
		
        Account testAccount = new Account();
            testAccount.Name= 'Test Account'; 
            testAccount.Phone = '(012)-345-6769'; 
            testAccount.RAM_Lookup__c = u.Id; 
            insert testAccount; 
        String rtId =   Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
		
		Opportunity opp = new Opportunity();
		opp.RecordTypeId = rc.id;
		opp.Probability= 10.0;
		opp.StageName='Prospecting';
		opp.Name = 'test';
		opp.CloseDate= System.today();
		opp.RAM_Assigned__c = u.Id;
		insert opp;
		
/*** Insert Referral */
        Referral__c r = new Referral__c(Referral_Rank__c='Primary',RecordTypeId = rtId, Account__c=testAccount.Id, Opportunity__c = opp.id);
        insert r;
		
		opportunity opp1 = new opportunity();
		opp1.Probability= 10.0;
		opp1.StageName='Prospecting';
		opp1.Name = 'test1';
		opp1.CloseDate= System.today();
        opp1.id= r.Opportunity__c;
	    update opp1;
    }
}