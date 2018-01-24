@isTest(SeeAllData = false)
public with sharing class EmailConfigTest {
    //To validate data if all the fields in custom settion are not checked.
    static testMethod void testValidateData() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        accInstance.Email__c = 'test@test.com';
        insert accInstance;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        contInstance.Email = 'test@test.com';
        insert contInstance;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = false;
        offersCustmStng.ISO_Sales_Rep__c = false;
        offersCustmStng.Merchant__c = false;
        insert offersCustmStng;
        
        Test.startTest();
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,oppInstance);
        Test.stopTest();
        System.assert(emailConfigInstance.isConfirmMsg == false,
            'EmailConfigTest.testValidateData - Custom setting is not configured isConfirmMsg should be false');
    }
    //To validate data if all the fields in custom settion are checked and email fields are specified.
    static testMethod void testCustomFieldsChecked() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        accInstance.Email__c = 'test@test.com';
        insert accInstance;
        Account accInstanceMerchant = GRIDTestDataFactory.getAccountRecord();
        accInstanceMerchant.Email__c = 'test@test.com';
        insert accInstanceMerchant;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        contInstance.Email = 'test@test.com';
        insert contInstance;
        Contact contInstanceOwner = GRIDTestDataFactory.getGRIDContactRecord(accInstanceMerchant.Id);
        contInstanceOwner.Email = 'test@test.com';
        insert contInstanceOwner;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        oppInstance.Owner_1__c = contInstanceOwner.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = true;
        offersCustmStng.ISO_Sales_Rep__c = true;
        offersCustmStng.Merchant__c = true;
        insert offersCustmStng;
        
        Test.startTest();
            Opportunity opportunity = [
                SELECT Id
                     , Name
                     , StageName
                     , AccountId
                     , Owner_1__c
                     , Owner_1__r.Email
                     , ISO__c
                     , ISO_Sales_Rep__c
                     , ISO__r.Email__c
                     , ISO_Sales_Rep__r.Email
                  FROM Opportunity
                 WHERE Id =: oppInstance.Id];
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,opportunity);
            emailConfigInstance.populateData(offersCustmStng,opportunity);
        Test.stopTest();
        /*System.assert(emailConfigInstance.isConfirmMsg == false,
            'EmailConfigTest.testCustomFieldsChecked - Custom setting is configured and all email address are specified, isConfirmMsg should be false');*/
        System.assert(emailConfigInstance.errorMsg == null,
            'EmailConfigTest.testCustomFieldsChecked - Custom setting is configured and all email address are specified, errorMsg should be null');
    }
    //To validate data if all the fields in custom settion are checked and email fields are not specified.
    static testMethod void testEmailNotSpecified() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        insert accInstance;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        insert contInstance;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = true;
        offersCustmStng.ISO_Sales_Rep__c = true;
        offersCustmStng.Merchant__c = true;
        insert offersCustmStng;
        
        Test.startTest();
            Opportunity opportunity = [
                SELECT Id
                     , Name
                     , StageName
                     , AccountId
                     , Owner_1__c
                     , Owner_1__r.Email
                     , ISO__c
                     , ISO_Sales_Rep__c
                     , ISO__r.Email__c
                     , ISO_Sales_Rep__r.Email
                  FROM Opportunity
                 WHERE Id =: oppInstance.Id];
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,opportunity);
            emailConfigInstance.populateData(offersCustmStng,opportunity);
        Test.stopTest();
        /*System.assert(emailConfigInstance.isConfirmMsg == false,
            'EmailConfigTest.testEmailNotSpecified - Custom setting is configured but none of the email are specified isConfirmMsg should be false');*/
    }
    //To validate data if all the fields in custom settion are checked and email fields are specified.
    static testMethod void testEmailSpecifiedISO_Sales_Rep() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        insert accInstance;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        contInstance.Email = 'test@test.com';
        insert contInstance;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = true;
        offersCustmStng.ISO_Sales_Rep__c = true;
        offersCustmStng.Merchant__c = true;
        insert offersCustmStng;
        
        Test.startTest();
            Opportunity opportunity = [
                SELECT Id
                     , Name
                     , StageName
                     , AccountId
                     , Owner_1__c
                     , Owner_1__r.Email
                     , ISO__c
                     , ISO_Sales_Rep__c
                     , ISO__r.Email__c
                     , ISO_Sales_Rep__r.Email
                  FROM Opportunity
                 WHERE Id =: oppInstance.Id];
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,opportunity);
            emailConfigInstance.populateData(offersCustmStng,opportunity);
        Test.stopTest();
        System.assert(emailConfigInstance.isConfirmMsg == true,
            'EmailConfigTest.testEmailSpecifiedISO_Sales_Rep - Custom setting is configured but only one email is specified isConfirmMsg should be true');
    }
    //To validate data if all the fields in custom settion are checked and email fields of ISO_Sales_Rep, ISO not specified.
    static testMethod void testErrorCountTwo() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        accInstance.Email__c = 'test@test.com';
        insert accInstance;
        Account accInstanceMerchant = GRIDTestDataFactory.getAccountRecord();
        insert accInstanceMerchant;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        insert contInstance;
        Contact contInstanceOwner = GRIDTestDataFactory.getGRIDContactRecord(accInstanceMerchant.Id);
        contInstanceOwner.Email = 'test@test.com';
        insert contInstanceOwner;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        oppInstance.Owner_1__c = contInstanceOwner.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = true;
        offersCustmStng.ISO_Sales_Rep__c = true;
        offersCustmStng.Merchant__c = true;
        insert offersCustmStng;
        
        Test.startTest();
            Opportunity opportunity = [
                SELECT Id
                     , Name
                     , StageName
                     , AccountId
                     , Owner_1__c
                     , Owner_1__r.Email
                     , ISO__c
                     , ISO_Sales_Rep__c
                     , ISO__r.Email__c
                     , ISO_Sales_Rep__r.Email
                  FROM Opportunity
                 WHERE Id =: oppInstance.Id];
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,opportunity);
            emailConfigInstance.populateData(offersCustmStng,opportunity);
        Test.stopTest();
        System.assert(emailConfigInstance.isConfirmMsg == true,
            'EmailConfigTest.testErrorCountTwo - Custom setting is configured but two email is specified isConfirmMsg should be true');
    }
    //To validate data if merchant fields of custom settion is unchecked and email fields are specified.
    static testMethod void testCustomFieldsMerchanUnChecked() {
        //Create data for test method
        Account accInstance = GRIDTestDataFactory.getAccountRecord();
        accInstance.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ISO').getRecordTypeId();
        accInstance.Email__c = 'test@test.com';
        insert accInstance;
        Account accInstanceMerchant = GRIDTestDataFactory.getAccountRecord();
        accInstanceMerchant.Email__c = 'test@test.com';
        insert accInstanceMerchant;
        
        Contact contInstance = GRIDTestDataFactory.getGRIDContactRecord(accInstance.Id);
        contInstance.Email = 'test@test.com';
        insert contInstance;
        Contact contInstanceOwner = GRIDTestDataFactory.getGRIDContactRecord(accInstanceMerchant.Id);
        contInstanceOwner.Email = 'test@test.com';
        insert contInstanceOwner;
        
        Opportunity oppInstance = GRIDTestDataFactory.getOpportunityRecord(accInstance.Id);
        oppInstance.ISO__c = accInstance.Id;
        oppInstance.ISO_Sales_Rep__c = contInstance.Id;
        oppInstance.Owner_1__c = contInstanceOwner.Id;
        insert oppInstance;
        
        //FO_Email_Settings__c offersCustmStng = FO_Email_Settings__c.getValues('Email Offers');
        FO_Email_Settings__c offersCustmStng = new FO_Email_Settings__c();
        offersCustmStng.Name = 'Email Offer';
        offersCustmStng.From_Address__c = 'test@test.com';
        offersCustmStng.ISO__c = true;
        offersCustmStng.ISO_Sales_Rep__c = true;
        offersCustmStng.Merchant__c = false;
        insert offersCustmStng;
        
        Test.startTest();
            Opportunity opportunity = [
                SELECT Id
                     , Name
                     , StageName
                     , AccountId
                     , Owner_1__c
                     , Owner_1__r.Email
                     , ISO__c
                     , ISO_Sales_Rep__c
                     , ISO__r.Email__c
                     , ISO_Sales_Rep__r.Email
                  FROM Opportunity
                 WHERE Id =: oppInstance.Id];
            EmailConfig emailConfigInstance = new EmailConfig();
            emailConfigInstance.validateData(offersCustmStng,opportunity);
            emailConfigInstance.populateData(offersCustmStng,opportunity);
        Test.stopTest();
        /*System.assert(emailConfigInstance.isConfirmMsg == false,
            'EmailConfigTest.testCustomFieldsMerchanUnChecked - Custom setting is configured and all email address are specified, isConfirmMsg should be false');*/
    }
}