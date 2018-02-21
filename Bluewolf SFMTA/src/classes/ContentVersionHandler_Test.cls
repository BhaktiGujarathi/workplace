/*******************************
* Author: Pike Pullen
* Purpose : Unit Tests for ContentVersionHandler.
* Version           Date
* ------------------------------------------------
* 1.0                14 Nov 2016
 CHANGE HISTORY
* =============================================================================
* Date         Name                  Description
* 2016-11-14   Pike - BW-IBM         Unit Tests added
* =============================================================================
*/
@isTest(seeallData = false)
public with sharing class ContentVersionHandler_Test {

	//static Id orgAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private or Community-Based Organization').getRecordTypeId();
	static User builderUser, currentUser;
	//static List<Account> accounts;
	static List<Contact> contacts;
	static List<Case> cases;

	@testSetup 
    static void userSetup(){
        /*
    	Profile adminProfile 	= [SELECT Id, Name FROM Profile WHERE Name LIKE '%System Administrator%' LIMIT 1];
        UserRole adminRole      = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Administrator%' LIMIT 1];
        
        User currentUser_setup 	= [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        User builderUser_setup;

        System.runAs(currentUser_setup) { 
            builderUser_setup = new User(
                    ProfileId 			= adminProfile.Id,
                    UserRoleId 			= adminRole.Id,
                    Username 			= 'admin' + System.now().millisecond() + '@SFMTATEST.com',
                    Alias 				= 'admin',
                    Email 				= 'admin@SFMTATEST.com',
                    EmailEncodingKey 	= 'UTF-8',
                    Firstname 			= 'Adam',
                    Lastname 			= 'Min',
                    LanguageLocaleKey 	= 'en_US',
                    LocaleSidKey 		= 'en_US',
                    TimeZoneSidKey 		= 'America/Chicago',
                    Phone 				= '6665557777',
                    MobilePhone 		= '6667778888',
                    Street 				= 'AnyStreet',
                    City 				= 'AnyCity',
                    State 				= 'TX',
                    PostalCode 			= '77002',
                    Country 			= 'USA',
                    Title 				= 'Lead Administrator',
                    isActive 			= true
            );
            insert builderUser_setup;
        }

        System.runAs(builderUser_setup) { 
            List<Account> accounts_Setup 	= TestUtilities.CreateAccounts(null, orgAccountRT, 1, true);
            List<Contact> contacts_Setup 	= TestUtilities.CreateRandomContact(accounts_Setup[0].Id, 1, true);
            List<Case> cases_Setup 			= TestUtilities.CreateCases(contacts_Setup[0].Id,  1, true);

            system.debug('accounts_Setup: ' + accounts_Setup);
            system.debug('contacts_Setup: ' + contacts_Setup);
            system.debug('cases_Setup: ' + cases_Setup);
        }
        */
        List<Contact> contacts_Setup    = TestUtilities.CreateRandomContact(null, 1, true);
        List<Case> cases_Setup          = TestUtilities.CreateCases(contacts_Setup[0].Id,  1, true);        
	}

    static void setUp(){
        /*
    	builderUser     = [SELECT Id FROM User WHERE Email = 'admin@SFMTATEST.com' LIMIT 1];
    	currentUser     = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

    	System.runAs(builderUser) { 
	    	accounts = [SELECT Id, Name, RecordTypeId, ParentId, INdustry, Type, NumberOfEmployees, 
	        ShippingCountry, ShippingStreet, ShippingState, ShippingPostalCode, 
	        BillingCountry, BillingStreet, BillingState, BillingPostalCode 
	        FROM Account 
	        WHERE Name LIKE '%SFMTATEST%'];

	        system.debug('accounts: ' + accounts);

	        contacts = [SELECT Id, AccountId, FirstName, LastName, Email,  Title, Phone, MobilePhone, 
	        MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
	    	FROM Contact];

	    	system.debug('contacts: ' + contacts);

	    	cases = [SELECT Subject, Description, Type, Origin 
	    	FROM Case 
	    	WHERE contactId =: contacts[0].Id];

	    	system.debug('cases: ' + cases);
    	}
        */

        contacts = [SELECT Id, AccountId, FirstName, LastName, Email,  Title, Phone, MobilePhone, 
        MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
        FROM Contact];

        system.debug('contacts: ' + contacts);

        cases = [SELECT Subject, Description, Type, Origin 
        FROM Case 
        WHERE contactId =: contacts[0].Id];

        system.debug('cases: ' + cases);        
    }

    @isTest
    static void ContentVersionHandler_AttachmentInsert_Valid(){
        setUp();
        //Test.startTest();
        //    System.RunAs(builderUser){
				ContentVersion cvToInsert 	= new ContentVersion();
				cvToInsert.Title 			= 'Test';
				cvToInsert.VersionData 		= blob.valueOf('Test Content');
				cvToInsert.PathOnClient 	= 'test.jpg';
				//cvToInsert.ContentURL 		= 'http://www.google.com/';
				insert cvToInsert;

				ContentVersion cv 	= [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvToInsert.Id LIMIT 1];
				ContentDocument cd 	= [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :cv.ContentDocumentId];

				ContentDocumentLink cdl = new ContentDocumentLink();
				cdl.ContentDocumentId 	= cd.Id;
				cdl.LinkedEntityId 		= cases[0].Id;
				cdl.ShareType 			= 'V';
				insert cdl;
        //	}
        //Test.stopTest();

		Case testCase = [SELECT Attachment_Uploaded__c
    	FROM Case 
    	WHERE contactId =: contacts[0].Id LIMIT 1];
    	system.assertEquals(true, testCase.Attachment_Uploaded__c);
    }    
}