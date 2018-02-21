@isTest
Public Class ATTestDataUtility
{


    public static User generateTestUser(String userName,Profile  profile,String alias,String email)
    {

        return new User(Alias = alias,
                        Email= email,
                        EmailEncodingKey='UTF-8',
                        LastName='Testing',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        ProfileId = profile.Id,
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName= userName,
                        Generate_Sales_Rep_Scorecard__c = true);

    }

    public static Lead generateTestLead()
    {

        return  new Lead(LastName = 'Last',
                            FirstName = 'first',
                            Status = 'Open',
                            Phone = '12345678',
                            Business_Main_Phone__c = '1234567890',
                            Business_Email__c = 'test@testmail.com',
                            Company = 'Company');

    }

    public static Task generateTestTaskOpportunity(String whatID)
    {

        return new Task(WhatId = whatID,
                        CallType ='Outbound',
                        Type = 'Call',
                        Subject = 'Test',
                        Description = 'Description',
                        Priority='Normal',
                        status='Completed');
    }

    public static Task generateTestTaskLead(String whoID)
    {
        return new Task(WhoId = whoID,
                        CallType ='Outbound',
                        Type = 'Call',
                        Subject = 'Test3123',
                        Description = 'Description',
                        Priority='Normal',
                        status='Completed');


    }


    public static Opportunity generateTestOpportunity()
    {
        return new Opportunity(Name = 'Test Opportunity',
                                StageName = 'Prospecting',
                                CloseDate = system.today());

    }

    public static Audit_trail__c generateTestAuditTrailForStatusChange(String objectName,
                                                                     String newStatus,
                                                                     String currentStatus,
                                                                     String type,
                                                                     Opportunity tempOpp,
                                                                     Lead tempLead,
                                                                     User userInstance,
                                                                     DateTime dtTime)
    {
        return new Audit_trail__c(Object__c = objectName,
                                  New_Status_Stage_value__c = newStatus,
                                  Current_Stage__c = currentStatus,
                                  Type__c = type,
                                  Opportunity__c = tempOpp.id,
                                  Current_owner__c = userInstance.id,
                                  Date_Time_change_was_made__c = dtTime);

    }

    public static List<Account> generateAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'TestAccount' + i
            ));
        }
        return accounts;
    }

    public static List<Opportunity> generateOpportunities(Integer count, Id accountId) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < count; i++) {
            opps.add(new Opportunity(
                Name = 'TestOpp' + i,
                AccountId = accountId,
                StageName = 'Prospecting',
                CloseDate = Date.today()
            ));
        }
        return opps;
    }

    public static List<McaApp__Receivable__c> generateReceivables(Integer count, Id oppId) {
        return generateReceivables(count, oppId, null);
    }

    public static List<McaApp__Receivable__c> generateReceivables(Integer count, Id oppId, Id receivableId) {
        List<McaApp__Receivable__c> receivables = new List<McaApp__Receivable__c>();
        for(Integer i = 0; i < count; i++) {
            McaApp__Receivable__c receivable = new McaApp__Receivable__c(
                McaApp__Opportunity__c = oppId
            );
            if(receivableId != null) {
                receivable.IsAdjustment__c = true;
                receivable.Adjustment_To__c = receivableId;
                receivable.McaApp__Amount__c = 5000;
            }
            receivables.add(receivable);
        }
        return receivables;
    }

    public static List<McaApp__Payable__c> generatePayables(Integer count, Id oppId, Id receivableId) {
        return generatePayables(count, oppId, receivableId, null);
    }

    public static List<McaApp__Payable__c> generatePayables(Integer count, Id oppId, Id receivableId, Id payableId) {
        List<McaApp__Payable__c> payables = new List<McaApp__Payable__c>();
        for(Integer i = 0; i < count; i++) {
            McaApp__Payable__c payable = new McaApp__Payable__c(
                McaApp__Opportunity__c = oppId,
                McaApp__Receivable_Dependency__c = receivableId,
                McaApp__Percentage__c = 10,
                McaApp__Payback_Funded__c = 'Commission Revenue'
            );
            if(payableId != null) {
                payable.IsAdjustment__c = true;
                payable.Adjustment_To__c = payableId;
            }
            payables.add(payable);
        }
        return payables;
    }

}