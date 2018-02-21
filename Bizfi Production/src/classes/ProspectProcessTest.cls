@isTest
public with sharing class ProspectProcessTest {

    private static final String ACTIVE_LEAD_TIMED_OUT = 'Active Lead Timed Out';

    public static testmethod void activeLeadTest() {

        Lead match = new Lead();

        match.FirstName = 'match'; 
        match.LastName  = 'lead';
        match.Company   = 'test';
        match.Phone     = '1234567890';
        match.status    = 'Open - Not Contacted';
        match.Open_Not_Contacted_Date_Time__c = Date.newInstance(1983, 1, 15);

        insert match;

        Test.startTest();

        
        Lead prospect = new Lead();
        prospect.LastName  = 'lead';
        prospect.Company   = 'test';
        prospect.Phone     = '1234567890';
        prospect.status    = 'Open - Not Contacted';
        prospect.Open_Not_Contacted_Date_Time__c = Date.newInstance(1983, 1, 15);

        insert prospect;

        match    = [select id, Duplicate_Reason__c, Phone, Lead_Status_Category__c, DupRefLeadId__c, DupRefLeadLink__c, DupRefLeadCampaign__c, DupRefLeadCompany__c from Lead where id =: match.Id limit 1][0];
        prospect = [select id, Duplicate_Reason__c, Phone, Lead_Status_Category__c, DupRefLeadId__c, DupRefLeadLink__c, DupRefLeadCampaign__c, DupRefLeadCompany__c from Lead where id =: prospect.Id limit 1][0];

        system.assertEquals(match.Phone,prospect.Phone);
        system.assertNotEquals(match.id,prospect.Id);
        system.assertEquals(match.Lead_Status_Category__c,'Active');

        // Prospect is supposed to win on this one.
/*
        system.assertEquals(match.Duplicate_Reason__c,ACTIVE_LEAD_TIMED_OUT);
        system.assertEquals(match.DupRefLeadId__c,prospect.Id);
        system.assertEquals(match.DupRefLeadLink__c,match.SalesforceInstance__c + prospect.Id);
        system.assertEquals(match.DupRefLeadCampaign__c,prospect.Original_Campaign__r.Name);
        system.assertEquals(match.DupRefLeadCompany__c,prospect.Company);
*/
        Test.stopTest();

    }


    public static testmethod void inactiveLeadTest() {

        Lead match = new Lead();

        match.FirstName                = 'match'; 
        match.LastName                 = 'lead';
        match.Company                  = 'test';
        match.Phone                    = '1234567890';
        match.status                   = 'Closed - Lost';
        match.Closed_Lost_Date_Time__c = Date.newInstance(1983, 1, 15);
        match.McaApp__Sub_Status__c    = 'Duplicate';

        insert match;

        Test.startTest();

        Lead prospect = match.clone();

        prospect.status  = 'Open - Not Contacted';

        insert prospect;

        system.assertEquals(match.Phone,prospect.Phone);

        match = [select id, Lead_Status_Category__c, Duplicate_Reason__c, DupRefLeadId__c, DupRefLeadLink__c, DupRefLeadCampaign__c, DupRefLeadCompany__c from Lead where id =: match.Id limit 1][0];

        system.assertEquals(match.Lead_Status_Category__c,'Inactive');

        // Prospect is supposed to win on this one.
/*
        system.assertEquals(match.Duplicate_Reason__c,ACTIVE_LEAD_TIMED_OUT);
        system.assertEquals(match.DupRefLeadId__c,prospect.Id);
        system.assertEquals(match.DupRefLeadLink__c,match.SalesforceInstance__c + prospect.Id);
        system.assertEquals(match.DupRefLeadCampaign__c,prospect.Original_Campaign__r.Name);
        system.assertEquals(match.DupRefLeadCompany__c,prospect.Company);
*/
        Test.stopTest();

    }
    
    
    
    public static testmethod void contractedOpportunityTest() {

        Lead prospect = new Lead();

        prospect.FirstName = 'match'; 
        prospect.LastName  = 'lead';
        prospect.Company   = 'test';
        prospect.Phone     = '1234567890';
        prospect.status    = 'Open - Not Contacted';
        prospect.Open_Not_Contacted_Date_Time__c = Date.newInstance(1983, 1, 15);

        
        Account matchingAccount = new Account();

        matchingAccount.Phone = '1234567890';

        matchingAccount.Name = 'Client';
        matchingAccount.Type = 'Prospect';
        matchingAccount.Industry = 'Banking';


        Opportunity matchingOpportunity = new Opportunity(Name = 'New Opportunity',
                                        StageName = 'Agreement Sent',
                                        CloseDate = date.today(),
                                        AccountId = matchingAccount.Id);



        Contact matchingContact = new Contact(FirstName = 'FirstName',
                                LastName = 'LastName',
                                AccountId = matchingAccount.Id);


        Test.startTest();

        
        insert matchingAccount;        

        insert matchingContact;

        insert matchingOpportunity;

        insert prospect;

//        prospect    = [select id, Duplicate_Reason__c, Phone, Lead_Status_Category__c, DupRefLeadId__c, DupRefLeadLink__c, DupRefLeadCampaign__c, DupRefLeadCompany__c from Account where id =: matchingAccount.Id limit 1][0];
        
//        system.assertEquals   (matchingAccount.Phone,prospect.Phone);        

        // Prospect is supposed to win on this one.
/*
        system.assertEquals(match.Duplicate_Reason__c,ACTIVE_LEAD_TIMED_OUT);
        system.assertEquals(match.DupRefLeadId__c,prospect.Id);
        system.assertEquals(match.DupRefLeadLink__c,match.SalesforceInstance__c + prospect.Id);
        system.assertEquals(match.DupRefLeadCampaign__c,prospect.Original_Campaign__r.Name);
        system.assertEquals(match.DupRefLeadCompany__c,prospect.Company);
*/
        Test.stopTest();

    }



}