@isTest 
private class SendToOndeckControllerTest { 
    
    static testMethod void TestEmptyOwnerEmail() {
        Opportunity opportunity = createTestData();
        Account account = [SELECT McaApp__Email__c, Id FROM Account WHERE Id =: opportunity.AccountId];
        Contact owner1 = [SELECT Email, Id FROM Contact WHERE Id = :opportunity.McaApp__Owner_1__c];
        owner1.Email = null;
        update owner1;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        Test.stopTest();
        
        System.assert(stoControl.businessData.owner1.email == account.McaApp__Email__c);
        System.assert('test2@email.test'.Equals(stoControl.businessData.owner2.email));

    }
    
    static testMethod void TestEmptyOpportunity() {
        createTestData();
        Opportunity opportunity = null;
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        stoControl.submitToOnDeck();
        
    }
    
    static testMethod void doPreQualTest() {
        Opportunity opportunity = createTestData();
        
        Account account = [SELECT Id, McaApp__Federal_Tax_ID_No__c FROM Account WHERE Id = :opportunity.accountId];
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        System.assertEquals(Apexpages.currentPage().getParameters().get('id'), opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        Test.stopTest();
        
        opportunity = getOpportunity(opportunity.Id);
        
        /////////////////ASSERTIONS/////////////////////
        System.assertEquals(opportunity.OnDeck_Business_ID__c, stoControl.businessData.businessID);
        //System.assertEquals(stoControl.businessData.taxID, opportunity.Account.McaApp__Federal_Tax_ID_No__c);
        
        System.assertEquals(stoControl.businessData.prequalified, 'true');
        System.assert(stoControl.enableSubmit);
        
         
    }
    
    static testMethod void showSubmitLoaderTest() {
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.showSubmitLoader();
        System.assert(stoControl.showLoader);
    }
    
    static testMethod void submitToOnDeckNoBusinessIDTest() {
        
        Opportunity opportunity = createTestData();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Account account = getAccount(opportunity.accountId);
        account.AccountNumber = '41234';
        update account;

        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        
        stoControl.businessData.businessID = '1234';
        stoControl.businessData.errorCodes.clear();
        stoControl.businessData.errorCodes.add('1000');

        stoControl.doPrequal();
        Test.stopTest();
        
        opportunity = getOpportunity(opportunity.Id);
        
    }
    
    static testMethod void checkPreQualErrors(){
        
        TestUtils.createSettings();
        OnDeckClient odc = new OnDeckClient();
        OnDeckClient.BusinessData bd = TestUtils.createBusinessData();
        
        OnDeckClient.ResponseData response = odc.sendPrequal(bd);
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.StageName = 'Funded';
        opportunity.CloseDate = Date.today();
        insert opportunity;
        
        opportunity = getOpportunity(opportunity.Id);
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        Test.stopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean legalName = false;
        boolean billingCity = false;
        boolean billingState = false;
        boolean taxId = false;
        boolean boolOwner = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Account Legal Name cannot be empty')) { 
                legalName = true;
            }
            if (msg.getDetail().contains('Account Billing City cannot be empty')) { 
                billingCity = true;
            }
            if (msg.getDetail().contains('Account Billing State/Province cannot be empty and must be exactly two character in length')) { 
                billingState = true;
            }
            if (msg.getDetail().contains('Account Federal Tax ID# cannot be empty and must be a numeric string of length 9')) { 
                taxId = true;
            }
            if (msg.getDetail().contains('Owner cannot be empty')) { 
                boolOwner = true;
            }
        }
        system.assert(legalName);
        system.assert(billingCity);
        system.assert(billingState);
        system.assert(taxId);
        system.assert(boolOwner);
    }
    
    static testMethod void checkPreQualErrorsOwner(){
        Account account = createAccount();
        Contact owner = new Contact();
        owner.LastName = 'test';
        insert owner;
        Opportunity opportunity = new Opportunity ();
        opportunity.AccountId = account.Id;
        
        opportunity.Account = account;
        opportunity.Name = 'test';
        opportunity.McaApp__Owner_1__c = owner.Id;
        opportunity.StageName = 'Funded';
        opportunity.CloseDate = Date.today();
        opportunity.OnDeck_Business_ID__c = '234';
        insert opportunity;
        
        
        opportunity = getOpportunity(opportunity.Id);
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        opportunity = [SELECT Id FROM Opportunity WHERE Id = :opportunity.Id];
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        Test.stopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean ownerMailingCity = false;
        boolean ownerMailingState = false;
        boolean ownerHomePhone = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Owner Mailing City cannot be empty')) { 
                ownerMailingCity = true;
            }
            if (msg.getDetail().contains('Owner Mailing State/Province cannot be empty and must be exactly two character in length')) { 
                ownerMailingState = true;
            }
            if (msg.getDetail().contains('Owner Home Phone cannot be empty')) { 
                ownerHomePhone = true;
            }
        }
        
        system.assert(ownerMailingCity);
        system.assert(ownerMailingState);
        system.assert(ownerHomePhone);
    }
    
    static testMethod void checkSubmitError(){
        TestUtils.createSettings();
        OnDeckClient odc = new OnDeckClient();
        OnDeckClient.BusinessData bd = TestUtils.createBusinessData();
        
        OnDeckClient.ResponseData response = odc.sendPrequal(bd);
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.StageName = 'Funded';
        opportunity.CloseDate = Date.today();
        insert opportunity;
        
        opportunity = getOpportunity(opportunity.Id);
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.enableSubmit = true;
        stoControl.submitToOnDeck(); 
        Test.stopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean legalName = false;
        boolean billingStreet = false;
        boolean billingCity = false;
        boolean billingState = false;
        boolean taxId = false;
        boolean boolOwner = false;
        boolean billingZip = false;
        boolean businessPhone = false;
        boolean annualRevenue = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Account Legal Name cannot be empty')) { 
                legalName = true;
            }
            if (msg.getDetail().contains('Account Billing Street cannot be empty')) { 
                billingStreet = true;
            }
            if (msg.getDetail().contains('Account Billing City cannot be empty')) { 
                billingCity = true;
            }
            if (msg.getDetail().contains('Account Billing State/Province cannot be empty and must be exactly two character in length')) { 
                billingState = true;
            }
            if (msg.getDetail().contains('Account Billing Zip/Postal Code cannot be empty')) { 
                billingZip = true;
            }
            if (msg.getDetail().contains('Account Phone cannot be empty')) { 
                businessPhone = true;
            }
            if (msg.getDetail().contains('Account Annual Revenue cannot be empty')) { 
                annualRevenue = true;
            }
            if (msg.getDetail().contains('Owner cannot be empty')) { 
                boolOwner = true;
            }
        }
        system.assert(legalName);
        system.assert(billingCity);
        system.assert(billingState);
        system.assert(billingStreet);
        system.assert(billingZip);
        system.assert(businessPhone);
        system.assert(annualRevenue);
        system.assert(boolOwner);
    }
    
    static testMethod void submitToOnDeckNoTaxIDTest() {
        
        Opportunity opportunity = createTestData();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Account account = [SELECT McaApp__Federal_Tax_ID_No__c, Id FROM Account WHERE Id =: opportunity.AccountId];
        account.McaApp__Federal_Tax_ID_No__c = null;
        update account;
        
        opportunity.AccountId = account.Id;
        update opportunity;
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal();
        Test.stopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Account Federal Tax ID# cannot be empty and must be a numeric string of length 9')) { 
              b = true;
            }
        }
        system.assert(b);
    }
    
    static testMethod void submitToOnDeckTest() {
        Opportunity opportunity = createTestData();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Test.startTest();
        SendToOndeckController stoControl = new SendToOndeckController();
        stoControl.doPrequal(); 
        stoControl.submitToOnDeck();
        Test.stopTest();
        
        /////////////////ASSERTIONS/////////////////////
        
        opportunity = getOpportunity(opportunity.Id);
        
        McaApp__Submission__c s = getSubmission(stoControl.businessData.applicationNumber, opportunity.Id);
        //System.assert(s.McaApp__Status__c == 'UW');
        //System.assert(s.McaApp__Channel__c == 'API');
        //System.assert(s.McaApp__Application_Number__c == stoControl.businessData.applicationNumber);
        //System.assert(s.McaApp__Status_Date__c == System.today());
        //System.assert(s.Date_Submitted__c == System.today());
        
        Bank_API_Settings__c settings = Bank_API_Settings__c.getInstance('OnDeck');
        System.assert(s.McaApp__Funder__c == settings.Funder_Account__c);
        //System.assert(s.McaApp__Opportunity__c == opportunity.Id);
        McaApp__Offer__c o = getOffer(s, opportunity.Id, s.Id);
        //System.assert(o.McaApp__Amount__c == Decimal.valueOf(stoControl.businessData.prequalAmount));
        //System.assert(o.McaApp__Funder__c == s.McaApp__Funder__c);
        //System.assert(o.McaApp__Term_Months__c == Decimal.valueOf(stoControl.businessData.prequalTerm));
        //System.assert(o.McaApp__Status__c == 'Prequal');
        //System.assert(o.McaApp__Opportunity__c == opportunity.Id);
        //System.assert(o.McaApp__Submission__c == s.Id);      
        
        //System.assertEquals('Underwriting', opportunity.StageName);
        
    }
    
    static testMethod void Failure() {
        
        SendToOndeckController stoControl = new SendToOndeckController();
        try{
            stoControl.doPrequal(); 
        }catch (Exception e){
            System.assertEquals(e.getMessage(), '');
        }
    }
    
    private static Account createAccount(){
        Account account = new Account();
        account.McaApp__Federal_Tax_ID_No__c = '78-1478589';
        account.Name = 'test';
        account.McaApp__Legal_Name__c = 'test';
        account.Industry = 'test';
        account.McaApp__Date_Business_Established__c = Date.today();
        account.BillingStreet = 'test';
        account.BillingCity = 'test';
        account.BillingState = 'tt';
        account.BillingPostalCode = 'test';
        account.Phone = '1234567890';
        account.AnnualRevenue = 200000;
        account.McaApp__Monthly_Bank_Deposit_Avg_All__c = 2;
        account.McaApp__Monthly_CC_Avg_All__c = 2;
        account.McaApp__Email__c = 'accountMail@test.test';
        insert account;
        
        return account;
    }
    
    private static Contact createOwner(String ownerNumber){
        Contact owner = new Contact();
        owner.McaApp__Social_Security_Number__c = 'ssnTest' + ownerNumber;
        owner.Email = 'test' + ownerNumber + '@email.test';
        owner.Phone = '1234567890';
        owner.HomePhone = '1234567890';
        owner.Birthdate = Date.today().addYears(-25);
        owner.MailingStreet = 'streetTest' + ownerNumber;
        owner.MailingCity = 'cityTest' + ownerNumber;
        owner.MailingState = 'Tt';
        owner.MailingPostalCode = 'zipTest' + ownerNumber;
        owner.LastName = 'test' + ownerNumber;
        insert owner;
        return owner;
    }
    
    private static Opportunity createOpportunity(){
        
        Account account = createAccount();
        
        Contact owner1 = createOwner('1');
        Contact owner2 = createOwner('2');
        Opportunity opportunity = new Opportunity ();
        opportunity.AccountId = account.Id;
        
        opportunity.Account = account;
        opportunity.Name = 'test';
        opportunity.McaApp__Owner_1_Ownership__c = 50;
        opportunity.McaApp__Owner_2_Ownership__c = 50;
        opportunity.McaApp__Owner_1__c = owner1.Id;
        opportunity.McaApp__Owner_2__c = owner2.Id;
        opportunity.StageName = 'Founded';
        opportunity.CloseDate = Date.today();
        opportunity.OnDeck_Business_ID__c = '234';
        insert opportunity;
        return opportunity;
        
    }
    
    private static Opportunity createTestData(){
        TestUtils.createSettings();
        OnDeckClient odc = new OnDeckClient();
        OnDeckClient.BusinessData bd = TestUtils.createBusinessData();
        
        OnDeckClient.ResponseData response = odc.sendPrequal(bd);
        
        Opportunity opportunity = createOpportunity();
        
        return opportunity;
    }
    
    private static Opportunity getOpportunity(Id id){
        Opportunity opportunity = [select OnDeck_Business_ID__c, Account.McaApp__Federal_Tax_ID_No__c, StageName,
                                   McaApp__Owner_1__c from Opportunity where Id = :id];
        return opportunity;
    }
    
    private static Account getAccount(Id accountId){
        Account account = [SELECT Id, AccountNumber FROM Account WHERE Id = :accountId];
        return account;
    }
    
    private static McaApp__Submission__c getSubmission(String applicationNumber, Id opportunityId) {
        for (McaApp__Submission__c s : [select Id, McaApp__Status__c, McaApp__Channel__c, McaApp__Application_Number__c, McaApp__Status_Date__c,
                                                McaApp__Date_Submitted__c, McaApp__Funder__c, McaApp__Opportunity__c
                                 from McaApp__Submission__c
                                 where McaApp__Opportunity__c = :opportunityId
                                   and McaApp__Application_Number__c = :applicationNumber]) {
            return s;
        }
        return new McaApp__Submission__c();
    }
    
    private static McaApp__Offer__c getOffer(McaApp__Submission__c s, Id opportunityId, Id submissionId) {
        for (McaApp__Offer__c o : [select Id, McaApp__Amount__c, McaApp__Funder__c, McaApp__Term_Months__c, McaApp__Opportunity__c, McaApp__Submission__c, McaApp__Status__c from McaApp__Offer__c
                            where McaApp__Submission__c = :submissionId
                              and McaApp__Opportunity__c = :opportunityId]) {
            return o;
        }
        return new McaApp__Offer__c();
    }  
}