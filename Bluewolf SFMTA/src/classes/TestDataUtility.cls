/**
* Utility class for test data creation to be used in test classes
*/

@isTest
public class TestDataUtility {
    // Static variables
    public static final String  STR_API_SPECIFICATION_ACKNOWLEDGMENT    = 'API Specification Acknowledgment';
    public static final String  STR_CHP_INSPECTION_FORM                 = 'CHP Inspection Form';
    public static final String  STR_COMPLIANCE_PLAN                     = 'Compliance Plan';
    public static final String  STR_CPUC_INSURANCE_COMPLIANCE           = 'CPUC Insurance Compliance';
    public static final String  STR_CPUC_VERIFICATION                   = 'CPUC Verification';
    public static final String  STR_DRIVER_SAFE_STREETS_CERTIFICATION   = 'Driver Safe Streets Certification';
    public static final String  STR_PER_TERMS_ACKNOWLEDGEMENT           = 'Per Terms Acknowledgement';
    public static final String  STR_SERVICE_DISRUPTION_PREVENTION_PLAN  = 'Service Disruption Prevention Plan';
    public static final String  STR_ASSIGNED                            = 'Assigned';
    public static final String  STR_USERNAME                            = 'probablynotauser@example.com';

    // public static final String PORTAL_PROFILE_NAME = '%Customer%';

    // get portal profile id
    public static Id PORTAL_PROFILE_ID {
        private set;
        get{
            if( PORTAL_PROFILE_ID==null ) {
                PORTAL_PROFILE_ID = [SELECT Id, Name
                FROM Profile
                WHERE Name = 'Customer Community Login 2'
                LIMIT 1].Id;
            }
            return PORTAL_PROFILE_ID;
        }
    }

    /*
    @description Creates portal users for unit tets
    */
	public static List<User> CreatePortalUsers ( List<Contact> contacts  ) {
    	String orgId = UserInfo.getOrganizationId();

        List<User> partnerUsers = new List<User>();

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

        for( Integer i=0; i < contacts.size(); i++ ) {
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*(1000000+i)));
            String uniqueName = orgId + dateString + randomInt;

            User u              = new User();
            u.Alias             = 'Alias';
            u.CommunityNickName = 'testUser123';
            u.ContactId         = contacts[i].Id;
            u.Email             = contacts[i].Email;
            u.EmailEncodingKey  = 'UTF-8';
            u.FirstName         = contacts[i].FirstName;
            u.IsActive          = true;
            u.LanguageLocaleKey = 'en_US';
            u.LastName          = contacts[i].LastName;
            u.LocaleSidKey      = 'en_US';
            u.ProfileId         = PORTAL_PROFILE_ID;
            u.PortalRole        = 'Worker';
            u.TimeZoneSidKey    = 'GMT';
            u.UserName          = uniqueName + '@test' + orgId + '.org';
            // u.UserRoleId          = portalRole.Id;

            partnerUsers.add(u);
        }

        // if ( doInsert ){
            insert partnerUsers;
        // }

        return partnerUsers;
    }

    // Create test user
    public static User createTestUser( Boolean doInsert ) {
        //Create portal account owner
         UserRole portalRole = [Select Id From UserRole Where Name = 'System Administrator' Limit 1];
         Id profile = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
         List<User> userAdmin = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
         User user = new User(alias = 'hasrole',
                         UserRoleId = portalRole.Id,
                         email='kramer@gmail.com',
                         emailencodingkey='UTF-8',
                         lastname='kramer',
                         languagelocalekey='en_US',
                         localesidkey='en_US',
                         profileid = profile,
                         timezonesidkey='America/Los_Angeles',
                         username= STR_USERNAME);

        if( doInsert )  {
            System.runAs(userAdmin[0]) {
                insert user;
            }
        }
        return user;
    }

    // Method to create account record
    public static List<Account> createAccounts( Integer countStart, Integer countEnd, Boolean isInsert ) {
        List<Account> lstAccount = new List<Account> ();
		
        for ( Integer i = countStart; i < countEnd; i++ ) {
            lstAccount.add(
                new Account(
                    Name = 'Test Account ' + i,
                    BillingCountry = 'United States' + i,
                    BillingStreet = (1078 + i) + ' WEST AVE' + i,
                    BillingCity = 'KENT' + i,
                    BillingPostalCode = '4211' + i,
                    BillingState = 'Ohio'+i,
                    Phone = '123456' + i,
                    Website = 'www.testaccount' + i + '.com',
					STL_Customer_ID__c = '01'
                )
            );
        }

        if ( isInsert ) {
            insert lstAccount;
        }

        return lstAccount;
    }


    // Method to create contact record
    public static List<Contact> createContacts( Integer count, Boolean isInsert,Id acctId ) {
        List<Contact> lstContact = new List<Contact> ();

        for ( Integer i = 0; i < count; i++ ) {
            lstContact.add(
                new Contact(
                    LastName = 'TestContact'+i,
                    Email = 'test@gmail.com',
                    AccountId = acctId
                )
            );
        }

        if ( isInsert ) {
            insert lstContact;
        }

        return lstContact;
    }

    // Method to create Application record
    public static List<Application__c> createApplications( Integer count
                                                      , Boolean isInsert
                                                      , List<Account> lstAccount ) {
        List<Application__c> lstApplication = new List<Application__c> ();

        for( Account objAccount : lstAccount ) {
            for ( Integer i = 0; i < count; i++ ) {
                lstApplication.add(
                    new Application__c(
                        Name = 'Test Application ' + i,
    					Account__c = objAccount.Id,
                        Status__c = 'Submitted - Pending Approval',
                        STL_Vehicle_Registration__c = true,
                        STL_No_Outstanding_Citations__c = true,
                        STL_Contact_Info__c = true,
                        STL_No_Outstanding_Invoices__c = true,
                        STL_Tech_Contractor__c = true,
                        STL_Routing__c = true,
                        STL_Documentation__c = true,
                        STL_Monthly_Average_Travel_Data__c = true
                    )
                );
            }
        }

        if ( isInsert ) {
            insert lstApplication;
        }

        return lstApplication;
    }

    // Method to create Vehicle record
    public static List<Vehicle__c> createVehicles( Integer count
                                              , Boolean isInsert
                                              , List<Account> lstAccount
                                              , String strLicensePlate ) {
        List<Vehicle__c> lstVehicle = new List<Vehicle__c> ();
        for ( Integer i = 0; i < count; i++ ) {
            lstVehicle.add(
                new Vehicle__c(
                    Account__c = lstAccount[i].Id,
                    Length_ft__c = 54,
					//Active__c = true,
                    Status__c = 'Active',
					Registration_Expiration_Date__c = Date.Today().addDays(120),
					Vehicle_Model__c = 'Van',
					Vehicle_Make__c = 'Honda',
					Vehicle_Year__c = '2017',
					License_Plate__c = strLicensePlate + lstAccount[i].Id + i
                )
            );
        }

        if ( isInsert ) {
            insert lstVehicle;
        }

        return lstVehicle;
    }

    // Method to create Sticker record
    public static List<Sticker__c> createStickers( Integer count, Boolean isInsert , Id accId ) {
        List<Sticker__c> lstSticker = new List<Sticker__c> ();

        for ( Integer i = 0; i < count; i++ ) {
            lstSticker.add(
                new Sticker__c(
                    Name = 'test',
                    Account_Name__c = accId
                )
            );
        }

        if ( isInsert ) {
            insert lstSticker;
        }

        return lstSticker;
    }

    // Method to create Document record
    public static List<Document__c> createDocuments( Integer count, Boolean isInsert ) {
        List<Document__c> lstDocument = new List<Document__c> ();

        for ( Integer i = 0; i < count; i++ ) {
            lstDocument.add(
                new Document__c(
                    Document_Type__c = 'Accessibility Plan',
					Status__c = Utility.STR_APPROVED
                )
            );
        }

        if ( isInsert ) {
            insert lstDocument;
        }

        return lstDocument;
    }
    // Method to create Application Attachment record
    public static List<Application_Attachment__c> createApplicationAttachments( Boolean isInsert
                                                                           , List<Application__c> lstApplication
                                                                           , List<Document__c> lstDocument ) {
        List<Application_Attachment__c> lstApplicationAttachment = new List<Application_Attachment__c> ();

        for( Application__c objApplication : lstApplication ) {
            for( Document__c objDoc : lstDocument ) {
                Application_Attachment__c objAppAttachment = new Application_Attachment__c();
                objAppAttachment.Name = 'Test Application Attachment' + objDoc.Document_Type__c;
                objAppAttachment.Document__c = objDoc.Id;
                objAppAttachment.Application__c = objApplication.Id;
                lstApplicationAttachment.add(objAppAttachment);
            }
        }
        if ( isInsert ) {
            insert lstApplicationAttachment;
        }

        return lstApplicationAttachment;
    }

    // common method to create Document with Application Attachment and vehicle
    public static void createDocAppAttachment( List<Application__c> lstApplication
                                             , List<Account> lstAccount
                                             , Integer intVehicleCount ) {
        // Create the Document Record.
        List<Document__c> lstDocument = TestDataUtility.createDocuments( 9, false  );
        lstDocument[1].Document_Type__c = TestDataUtility.STR_API_SPECIFICATION_ACKNOWLEDGMENT;
        lstDocument[2].Document_Type__c = TestDataUtility.STR_CHP_INSPECTION_FORM;
        lstDocument[3].Document_Type__c = TestDataUtility.STR_COMPLIANCE_PLAN;
        lstDocument[4].Document_Type__c = TestDataUtility.STR_CPUC_INSURANCE_COMPLIANCE;
        lstDocument[5].Document_Type__c = TestDataUtility.STR_CPUC_VERIFICATION;
        lstDocument[6].Document_Type__c = TestDataUtility.STR_DRIVER_SAFE_STREETS_CERTIFICATION;
        lstDocument[7].Document_Type__c = TestDataUtility.STR_PER_TERMS_ACKNOWLEDGEMENT;
        lstDocument[8].Document_Type__c = TestDataUtility.STR_SERVICE_DISRUPTION_PREVENTION_PLAN;
        insert lstDocument;

        // Create the Application Attachment Record.
        List<Application_Attachment__c> lstApplicationAttachment = TestDataUtility.createApplicationAttachments( true
                                                                                                             , lstApplication
                                                                                                             , lstDocument);
        // Create the Vehicle Record.
        List<Vehicle__c> lstVehicle = TestDataUtility.createVehicles( intVehicleCount , true , lstAccount , 'VWX432' );
    }

    // Get the test internal user by using a SOQL query
    public static User getInternalUser() {
        // Get the test internal user by using a SOQL query
        return [ SELECT Id FROM User where username =: TestDataUtility.STR_USERNAME ];
    }

    // Get the test Account by using a SOQL query
    public static List<Account> getAccountRecord() {
        // Get the test Account by using a SOQL query
        return [ Select id from Account ];
    }

    // Get the test Contact by using a SOQL query
    public static List<Contact> getContactRecord() {
        // Get the test Contact by using a SOQL query
        return [ Select id ,Email,FirstName,LastName from Contact ];
    }

    // Get the test Application by using a SOQL query
    public static List<Application__c> getApplicationRecord() {
        // Get the test Application by using a SOQL query
        return [ Select id from Application__c ];
    }

    // Get the test Vehicle by using a SOQL query
    public static List<Vehicle__c> getVehicleRecord() {
        // Get the test Vehicle by using a SOQL query
        return [ Select id from Vehicle__c ];
    }
    
    // Get the test Sticker by using a SOQL query
    public static List<Sticker__c> getStickerRecord( List<Account> lstAccount
                                                   , List<Vehicle__c> lstVehicle ) {
        // Get the test Sticker by using a SOQL query
        return  [Select Id
    			      , Name
    				  , Account_Name__c
    				  , Vehicle__c
                      , Vehicle__r.Length_ft__c
                      , Account_Name__r.STL_Customer_ID__c
    			   from Sticker__c
    			  where Account_Name__c IN: lstAccount
    			    AND Vehicle__c IN: lstVehicle
    				AND Status__c =: TestDataUtility.STR_ASSIGNED
               ORDER BY Name ];
    }

}// end of main class