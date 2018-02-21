@isTest
private class DedupeProspectAccountsProcessServiceTest{
    
    @isTest
    private static void ContactsWithSameNameTest(){
        
        Account matchingAccount = new Account(name='Test Account', phone='12345');
        insert  matchingAccount;

        Contact matchingContact = new Contact();
        matchingContact.FirstName = 'Test';
        matchingContact.LastName  = 'Contact';
        matchingContact.AccountId = matchingAccount.Id;

        insert matchingContact;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = matchingAccount.Id;
        opp.stageName='Application Sent';
        opp.CloseDate = System.Today().addDays(15);
        opp.Amt_Monthly_Bank_Deposits__c = 100;

        insert opp;

        Account prospectAccount = new Account(name='Prospect Account',phone='12345');
        insert prospectAccount;

        Contact prospectContact = new Contact();
        prospectContact.FirstName = 'Test';
        prospectContact.LastName  = 'Contact';
        prospectContact.AccountId = prospectAccount.Id;

        insert prospectContact;
            
        Opportunity prospectopp = new Opportunity();
        prospectopp.Name = 'Test Opportunity';
        prospectopp.AccountId = prospectAccount.Id;
        prospectopp.stageName = 'Underwriting';
        prospectopp.CloseDate = System.Today().addDays(15);
        prospectopp.Amt_Monthly_Bank_Deposits__c = 100;

        insert prospectopp;

        prospectopp.stageName = 'Application Sent';

        update prospectopp;
    }







    @isTest
    private static void differentContactsTest(){
        
        Account matchingAccount = new Account(name='Test Account', phone='12345');
        insert  matchingAccount;

        Contact matchingContact = new Contact();
        matchingContact.FirstName = 'Matching';
        matchingContact.LastName  = 'Contact';
        matchingContact.AccountId = matchingAccount.Id;

        insert matchingContact;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = matchingAccount.Id;
        opp.stageName='Application Sent';
        opp.CloseDate = System.Today().addDays(15);
        opp.Amt_Monthly_Bank_Deposits__c = 100;

        insert opp;

        Account prospectAccount = new Account(name='Prospect Account',phone='12345');
        insert prospectAccount;

        Contact prospectContact = new Contact();
        prospectContact.FirstName = 'Prospect';
        prospectContact.LastName  = 'Contact';
        prospectContact.AccountId = prospectAccount.Id;

        insert prospectContact;
            
        Opportunity prospectopp = new Opportunity();
        prospectopp.Name = 'Test Opportunity';
        prospectopp.AccountId = prospectAccount.Id;
        prospectopp.stageName = 'Underwriting';
        prospectopp.CloseDate = System.Today().addDays(15);
        prospectopp.Amt_Monthly_Bank_Deposits__c = 100;

        insert prospectopp;

        prospectopp.stageName = 'Application Sent';

        update prospectopp;
    }

}