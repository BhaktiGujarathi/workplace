public with sharing class TestUtilities {
	/*
    public static final String PORTAL_PROFILE_NAME = '%Customer%';

    public static Id PORTAL_PROFILE_ID { 
        private set; 
        get{
            if(PORTAL_PROFILE_ID==null){
                PORTAL_PROFILE_ID = [SELECT Id, Name  
                FROM Profile 
                WHERE userlicense.Name LIKE :PORTAL_PROFILE_NAME
                LIMIT 1].Id;
            }
            return PORTAL_PROFILE_ID;
        }       
    }
	*/
	
    /*
    @description Creates accounts for unit tets
    */
    /*
    public static List<Account> CreateAccounts(Id parentId, Id recordTypeId, Integer quantity, Boolean doInsert){
        List<Account> accounts = new List<Account>();
        for(Integer i = 1; i <= quantity; i++){ 

            accounts.add( new Account(Name = 'SFMTATEST_' + String.valueOf(i),
                recordTypeId                = recordTypeId,
                parentid                    = parentId,
                Industry                    = 'Other',
                Type                        = 'Prospect',
                NumberOfEmployees           = i,
                ShippingCountry             = 'United States',
                ShippingStreet              = '543453 Dallas St.',
                ShippingCity                = 'Houston',
                ShippingState               = 'TX',
                ShippingPostalCode          = '77002',
                BillingCountry              = 'United States',
                BillingStreet               = '1234 Dallas St.',
                BillingCity                 = 'Houston',
                BillingState                = 'TX',
                BillingPostalCode           = '77002',
                Phone 						= '5556667777'
                ));
        }

        if (doInsert){ 
            insert accounts;
        }

        return accounts;
    } 
    */

    /*
    @description Creates contacts for unit tets
    */
    public static List<Contact> CreateRandomContact(Id accId, Integer quantity, Boolean doInsert){
        String orgId        = UserInfo.getOrganizationId();

        List<Contact> contacts = new List<Contact>();
        for(Integer i = 1; i <= quantity; i++){ 
	        String dateString   = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	        Integer randomInt   = Integer.valueOf(math.rint(math.random()*(1000000+i)));
	        String uniqueName   = orgId + dateString + randomInt;  

	        Contact tempContact = new Contact();
	        tempContact.FirstName                   = uniqueName.substring(0,10) + '_FN' + randomInt;
	        tempContact.LastName                    = uniqueName.substring(10,20) + '_LN' + randomInt;
	        tempContact.Email                       = uniqueName.substring(0,30) + '@SFMTATEST.org';
	        tempContact.Title                       = 'TestTitle';
	        tempContact.Phone                       = '5557778989';
	        tempContact.MobilePhone                 = '5556667878';
	        tempContact.MailingStreet               = '1234 Dallas St.';
	        tempContact.MailingCity                 = 'Houston';
	        tempContact.MailingState                = 'TX';
	        tempContact.MailingCountry              = 'USA';
	        tempContact.MailingPostalCode           = '77002';
	        tempContact.AccountId                   = accId;       
	        contacts.add(tempContact);
        } 

        if (doInsert){ 
            insert contacts;
        }

        return contacts;
    }    

    /*
    @description Creates portal users for unit tets
    */
	/*    
	public static List<User> CreatePortalUsers (List<Contact> contacts, Boolean doInsert) {
    	String orgId = UserInfo.getOrganizationId();

        List<User> partnerUsers = new List<User>();

        for(Integer i=0; i < contacts.size(); i++){     
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*(1000000+i)));
            String uniqueName = orgId + dateString + randomInt;       

            User u              = new User();
            u.Alias             = 'Alias';
            u.CommunityNickName = uniqueName.substring(0,30) + '@SFMTATEST.org';
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

            partnerUsers.add(u);
        }

        if (doInsert){ 
            insert partnerUsers;
        }

        return partnerUsers;
    }    
	*/

    /*
    @description Creates portal users for unit tets
    */
    public static List<Case> CreateCases (Id parentId, Integer quantity, Boolean doInsert) {

        Map<String, RecordType> rtypes = new Map<String, RecordType>();
        for(RecordType rt :[Select Name, Id From RecordType where sObjectType='Case' and isActive=true]){
            rtypes.put(rt.Name, rt);
        }

        List<Case> cases = new List<Case>();

        for(Integer i = 0; i <= quantity; i++){ 
	        Case newCase 		= new Case();
            newCase.ContactId   = parentId;
	        newCase.Subject 	= 'Unit Test Case_' + (i+1);
	        newCase.Description = 'Unit Test Case';
	        newCase.Origin 		= 'Email';

            if(i==0){
                newCase.Type = 'Sidewalk Bicycle Rack';
                if(rtypes.containsKey('Bike Parking')){
                   newCase.RecordTypeId = rtypes.get('Bike Parking').Id;
                }
            }
            else if(i==1){
                newCase.Type = 'Red Curb Color';
                if(rtypes.containsKey('Color Curbs')){
                    newCase.RecordTypeId = rtypes.get('Color Curbs').Id;
                }
            }
            else if(i==2){
                newCase.Type = 'Block Party';
                if(rtypes.containsKey('Block Party')){
                    newCase.RecordTypeId = rtypes.get('Block Party').Id;
                }
            }
            else if(i==3){
                newCase.Type = 'Street Fair';
                if(rtypes.containsKey('Special Events Read-Only')){
                    newCase.RecordTypeId = rtypes.get('Special Events Read-Only').Id;
                }
            }
            else if(i==4){
                newCase.Type = 'Street Fair';
                if(rtypes.containsKey('Temporary Signs')){
                    newCase.RecordTypeId = rtypes.get('Temporary Signs').Id;
                }
            }
	        
            newCase.I_affirm_the_statements_above__c        = true;
            newCase.I_agree_with_the_terms_stated_above__c  = true;

            cases.add(newCase);
        }

        if (doInsert){ 
            try{
                insert cases;
            }
            catch(DmlException dmle){
                system.debug('DmlException: ' + dmle.getMessage());
            }
        }

        return cases;
    }  
}