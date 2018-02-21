@isTest
private class submit2QuickbridgeTest {
/*

    @testSetup
    static void dataSetup() {

        // Quickbridge settings
        QBF_Connect_Settings__c qbSet = new QBF_Connect_Settings__c();
        qbSet.APIKey__c = 'rVradpcZk0yfTQhfHi/fQw==';
        qbSet.ClientSecret__c = 'NTo0NDU5OTpyVnJhZHBjWmsweWZUUWhmSGkvZlF3PT0=';
        qbSet.EndPoint__c  ='https://connect.quickbridgefunding.com/QBFConnectDev/QBFConnectRest.svc';
        insert qbSet;
        
        // Lists to hold data values
        List<Account> acctList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        List<String> recNames = new List<String>{'Bank', 'Bank', 'ISO'};

        // Banks and ISO
        for(Integer n = 0; n < 3; n++) {
            Account a = new Account(
                McaApp__Active__c = 'Yes',
                Phone = '(999) 888-777'+n,
                RecordTypeId = RecordTypesUtility.recId('Account', recNames[n]),
                Test_Complete__c = true,
                McaApp__Email__c = 'test' + n + '@dataSetup.com');

            if(n == 0) { a.Name = 'Quickbridge'; }
            else { a.Name = 'Biz Account ' + n; }

            if(n == 2) { a.Type = 'Internal'; }

            acctList.add(a);
        }

        // Merchant Account
        Account merch = new Account();
        merch.Test_Complete__c = true;
        merch.Name = 'Merchant'; 
        merch.Phone = '(414) 525-6336'; 
        merch.AnnualRevenue = 1000000; 
        merch.BillingStreet = '7915 Bustleton Ave';  
        merch.BillingCity = 'Philadelphia'; 
        merch.BillingState = 'PA';  
        merch.BillingPostalCode = '19152'; 
        merch.Website = 'business.com';  
        merch.Industry = 'Business'; 
        merch.McaApp__Legal_Name__c = 'Merchant LLC'; 
        merch.McaApp__Type_of_Entity__c = 'Limited Liability Company'; 
        merch.McaApp__Federal_Tax_ID_No__c = '11-2233440';  
        merch.McaApp__Date_Business_Established__c = Date.newInstance(2008, 6, 15); 
        merch.McaApp__Years_in_Business__c = 8; 

        acctList.add(merch);
        insert acctList;

        Account[] accts = [SELECT Id, Name FROM Account ORDER BY Name];

        for(Integer i = 0; i < 2; i++){
            Opportunity o = new Opportunity(
                Name = 'Opp Test',
                AccountId = accts[2].Id,
                MCACE__ISO_1_Lead_Source__c = accts[1].Id,
                Amount = 200000,
                StageName = 'Underwriting',
                CloseDate = Date.newInstance(2008, 8, 15),
                Test_Complete__c = true,
                McaApp__NSFs_avg__c = 1,
                McaApp__Use_of_Proceeds__c = 'working capital/inventory',
                McaApp__Amount_Requested__c = 200000,
                Amt_Monthly_Bank_Deposits__c = 32,
                McaApp__Avg_Number_Bank_Deposits__c = 6);

            oppList.add(o);
        }

        insert oppList;

        Contact c = new Contact();
        c.FirstName = 'Given';
        c.LastName = 'Sur';
        c.Email = 'given@sur.com';
        c.MobilePhone = '(222) 333-4444';
        c.MailingStreet = '760 Rogers Avenue';
        c.MailingCity = 'Brooklyn';
        c.MailingState = 'NY';
        c.MailingPostalCode = '11226';
        c.McaApp__Social_Security_Number1__c = '333-66-9999';
        c.McaApp__Of_Ownership__c = 100;

        insert c;

        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 2];
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;

        for(Integer i = 0; i < 2; i++) {
            OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = opps[i].Id,
                ContactId = conId);

            ocrList.add(ocr);
        }

        insert ocrList;

    }


    @isTest
    static void negTest() {

        McaApp__Submission__c[] submissions = new McaApp__Submission__c[]{};

        Account funder = [SELECT Id FROM Account WHERE Name = 'Biz Account 1' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        for(Integer i = 0; i < 4; i++) {
            McaApp__Submission__c sub = new McaApp__Submission__c(
                McaApp__Funder__c = funder.Id,
                McaApp__Opportunity__c = opp.Id,
                McaApp__Status__c = 'Underwriting',
                McaApp__Status_Date__c = Date.newInstance(2008, 6, 15),
                McaApp__Date_Submitted__c = datetime.now());

            submissions.add(sub);
        }

        test.startTest();
        insert submissions;
        test.stopTest();

        McaApp__Submission__c[] updatedSubs = [SELECT External_Id__c FROM McaApp__Submission__c];

        for(McaApp__Submission__c s : updatedSubs) {
            System.assert(String.isBlank(s.External_Id__c));
        }

    }

    @isTest
    static void posTest() {

        McaApp__Submission__c[] submissions = new McaApp__Submission__c[]{};

        Id bank = RecordTypesUtility.recId('Account', 'Bank');
        Account[] funder = [SELECT Id, Name FROM Account WHERE RecordTypeId = :bank ORDER BY Name];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        for(Integer i = 0; i < 4; i++) {
            McaApp__Submission__c sub = new McaApp__Submission__c(
                McaApp__Opportunity__c = opp.Id,
                McaApp__Status__c = 'Underwriting',
                McaApp__Status_Date__c = Date.newInstance(2008, 6, 15),
                McaApp__Date_Submitted__c = datetime.now());

            sub.McaApp__Funder__c = (i == 0) ? funder[0].Id : funder[1].Id;

            submissions.add(sub);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        insert submissions;
        test.stopTest();

        McaApp__Submission__c[] updatedSubs = [SELECT External_Id__c, Funder_Name__c FROM McaApp__Submission__c WHERE Funder_Name__c = 'QUICKBRIDGE'];

        for(McaApp__Submission__c s : updatedSubs) {
            System.assert(String.isNotBlank(s.External_Id__c));
        }

    }

*/    
}