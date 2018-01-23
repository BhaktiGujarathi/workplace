@isTest
private class LeadHandlerTest 
{
 
    Static testMethod void LeadHandler_Test()
    {   OpportunityEstimatedCloseDays__c opcd = new OpportunityEstimatedCloseDays__c();
        opcd.Name = 'EstimatedCloseDays';
        opcd.Number__c = 30;
        insert opcd;
        
        Profile p = [Select id from Profile where Name = 'System Administrator'];
        
        User u = new User(
          Alias = 'testu',
          Email = 'test@example.com',
          EmailEncodingKey = 'UTF-8',
          LastName = 'Test',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          TimeZoneSidKey='America/Los_Angeles',
          ProfileId = p.Id,
          UserName='test12123vb@example1.com'
        );

        INSERT u;
        
        RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='FRN Facility'];
        Account Acc = new Account();
        acc.Name = 'test';
        insert Acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
     
        lead newLead = new lead();
        newLead.FirstName = 'test';
        newLead.MiddleName = 'test';
        newLead.LastName = 'test';
        newLead.Company = 'test';
        newLead.Status = 'Converted';
        newLead.Opportunity_RecordType__c = 'Residential Treatment';
        newLead.Opportunity_RecordType__c = 'Outpatient Treatment';
        newLead.Opportunity_RecordType__c = 'Refer Out Only';        
        insert newLead;
        update newLead;
       
         
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Scratchpad__c= newLead.Id;
        insert opp;
        update opp;
       
        
        Referral__c ref = new Referral__c();
        ref.Account__c = acc.Id;
        ref.Lead__c = newLead.Id;
        ref.Opportunity__c = opp.Id;
        insert ref;
        update ref;
        
        
        Treatment_History__c treatment = new Treatment_History__c();
        treatment.Lead__c = newLead.Id;
        treatment.Opportunity__c= opp.Id;
        insert treatment;
        update treatment;
        
        
        
        Database.LeadConvert lco = new database.LeadConvert();
          lco.setLeadId(newLead.Id);
          lco.isDoNotCreateOpportunity();
          //lco.setDoNotCreateOpportunity(true);
          LeadStatus convertStatuso = [Select Id, MasterLabel from LeadStatus where MasterLabel='Qualified' AND IsConverted=true limit 1];
          lco.setConvertedStatus(convertStatuso.MasterLabel);
          Database.LeadConvertResult lcro = Database.convertLead(lco); 
        
    }  
}