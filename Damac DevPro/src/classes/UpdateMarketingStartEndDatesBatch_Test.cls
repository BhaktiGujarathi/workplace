/*
Test class for UpdateMarketingStartEndDatesBatch
*/
@isTest
private class UpdateMarketingStartEndDatesBatch_Test {

    static testMethod void myUnitTest() {
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Id CorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
        ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
        ID adminProfileID = [ Select id,UserType from Profile where name = 'System Administrator'].id;
        ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='admin'+ String.valueOf(system.now().millisecond())+'@damactest.com');
        
        System.runAs(u2) {
            Campaign__c camp = new Campaign__c();
            camp.RecordTypeId = RSRecordTypeId;
            camp.Campaign_Name__c='Test Campaign';
            camp.start_date__c = System.today();
            camp.end_date__c = System.Today().addDays(30);
            camp.Marketing_start_date__c = System.today();
            camp.Marketing_end_date__c = System.Today().addDays(30);
            insert camp;
            
            Address__c addressobj1 = new Address__c();
            addressobj1.Address_ID__c = 987654;
            addressobj1.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj1.ADDRESS_LINE2__c='Cluster E';
            addressobj1.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj1.City__c = 'Dubai';
            addressobj1.Country__c = 'AE';
            insert addressobj1;
            
            Address__c addressobj2 = new Address__c();
            addressobj2.Address_ID__c = 12345;
            addressobj2.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj2.ADDRESS_LINE2__c='Cluster E';
            addressobj2.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj2.City__c = 'Dubai';
            addressobj2.Country__c = 'LB';
            insert addressobj2;
            
            Address__c addressobj3 = new Address__c();
            addressobj3.Address_ID__c = 12346;
            addressobj3.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj3.ADDRESS_LINE2__c='Cluster E';
            addressobj3.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj3.City__c = 'Dubai';
            addressObj3.State__c = 'Dubai';
            addressobj3.Country__c = 'QA';
            insert addressobj3;
            
            addressobj3.Latitude__c = '';
            update addressobj3;
            
            Address__c addressobj4 = new Address__c();
            addressobj4.Address_ID__c = 12347;
            addressobj4.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj4.ADDRESS_LINE2__c='Cluster E';
            addressobj4.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj4.City__c = 'Dubai';
            addressobj4.Country__c = 'JO';
            insert addressobj4;
            
            Address__c addressobj5 = new Address__c();
            addressobj5.Address_ID__c = 12348;
            addressobj5.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj5.ADDRESS_LINE2__c='Cluster E';
            addressobj5.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj5.City__c = 'Riyadh';
            addressobj5.Country__c = 'SA';
            insert addressobj5;
            
            Property__c prop = new Property__c();
            prop.Property_Name__c='Discovery gardens';
            prop.Property_ID__c = 12345;
            prop.Active_Property__c = true;
            insert prop;
            
            Location__c loc1 = new Location__c();
            loc1.Name = 'DGB56';
            loc1.Building_Name__c = 'Discovery Gardens';
            loc1.Address_ID__c = '987654';
            loc1.Location_ID__c = '0001';
            loc1.Property_ID__c = '12345';
            loc1.location_type__c = 'Building';
            insert loc1;
            
            Location__c loc2 = new Location__c();
            loc2.Name = 'DGB562';
            loc2.Building_Name__c = 'Discovery Gardens';
            loc2.Address_ID__c = '987654';
            loc2.Location_ID__c = '0002';
            loc2.Property_ID__c = '12345';
            loc2.location_type__c = 'Floor';
            loc2.Parent_id__c = loc1.Location_ID__c;
            insert loc2;
            
            Location__c loc3 = new Location__c();
            loc3.Name = 'DGB562214';
            loc3.Building_Name__c = 'Discovery Gardens';
            loc3.Address_ID__c = '987654';
            loc3.Location_ID__c = '0003';
            loc3.Property_ID__c = '12345';
            loc3.location_type__c = 'Unit';
            loc3.Parent_id__c = loc2.Location_ID__c;
            insert loc3;
            
            Inventory_Release__c ir = new Inventory_Release__c();
            ir.Property_ID__c = '12345';
            ir.Floor_ID__c = '0002';
            ir.Building_ID__c = '0001';
            ir.Unit_ID__c = '0003';
            ir.Release_ID__c = '12345';
            insert ir;
            
            Inventory__c inv = new Inventory__c();
            inv.Inventory_ID__c = '0003';
            inv.Address_Id__c = '987654';
            inv.Building_ID__c = '0001';
            inv.Floor_ID__c = '0002';
            inv.Unit_ID__c = '0003';
            inv.Property_ID__c = '12345';
            inv.Release_ID__c='12345';
            inv.IPMS_Bedrooms__c='RELEASED';
            insert inv;
            
            
            
            Account A1 = new Account(Name = 'Test Account',RecordTypeID = CorRecordTypeId,BillingCity='TestCity',Strength_of_Agency__c = 2,BillingCountry='TestCountry', Agency_Type__c = 'Corporate');
            insert A1;
            
            Account A2 = new Account(Name = 'Damac Account',RecordTypeID = CorRecordTypeId,BillingCity='City',Strength_of_Agency__c = 3,BillingCountry='TestCountry', Agency_Type__c = 'Corporate');
            insert A2;
        
            Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User1', 
            email = 'test-user@fakeemail.com' );
            insert C1; 
            
            Contact C2 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User2', 
            email = 'test-user1@fakeemail.com' );
            insert C2;
            
            Contact C3 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User3', 
            email = 'test-user2@fakeemail.com' );
            insert C3;
            
            User u4 = new User( email='test-user5@fakeemail.com',contactid = c1.id, profileid = profileID, 
                      UserName='test-user4@fakeemail.com', alias='tuser1', CommunityNickName='tuser5', isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
            insert u4;
            
            User u5 = new User( email='test-user7@fakeemail.com',contactid = c2.id, profileid = profileID, 
                      UserName='test-user7@fakeemail.com', alias='tuser1', CommunityNickName='tuser7', isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
            insert u5;
    
            User u3 = new User( email='test-user3@fakeemail.com', profileid = consultantId, 
                      UserName='test-user3@fakeemail.com', alias='tuser3',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test213', LastName = 'User213');
            insert u3;
            
            User u6 = new User( email='test-user23@fakeemail.com', profileid = consultantId, 
                      UserName='test-user23@fakeemail.com', alias='tuser23',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test213', LastName = 'User213');
            insert u6;
            
            Campaign_Inventory__c campInv = new Campaign_Inventory__c(Campaign__c = camp.id,Inventory__c = inv.id,Start_Date__c = camp.Start_Date__c,End_Date__c = camp.End_Date__c);
            insert campInv;
            
            Agency_PC__c AGPC = new Agency_PC__c();
            AGPC.Agency__c = a1.id;
            AGPC.User__c = u3.Id;
            insert AGPC;
            
            Assigned_PC__c apc = new Assigned_PC__c();
            apc.Campaign__c = camp.Id;
            apc.user__c = u3.id;
            insert apc;
            
            Assigned_PC__c apc1 = new Assigned_PC__c();
            apc1.Campaign__c = camp.Id;
            apc1.user__c = u6.id;
            insert apc1;
            
            Assigned_Agent__c agent = new Assigned_Agent__c();
            agent.Agency__c = a1.id;
            agent.Contact__c = c1.id;
            agent.User__c = u4.Id;
            agent.Campaign__c = camp.Id;
            insert agent;
            
            Assigned_Agent__c agent1 = new Assigned_Agent__c();
            agent1.Agency__c = a1.id;
            agent1.Contact__c = c2.id;
            agent1.User__c = u5.Id;
            agent1.Campaign__c = camp.Id;
            insert agent1;
            
            Inventory_User__c inventoryUser = new Inventory_User__c(Campaign__c = camp.Id,Start_Date__c = camp.Marketing_Start_Date__c,End_Date__c = camp.Marketing_End_Date__c,Inventory__c = inv.id,Unique_Key__c = u4.Id+'###'+inv.id,User__c = u4.id);
            insert inventoryUser;
            
            camp.Marketing_end_date__c = System.Today().addDays(20);
            camp.End_date__c = System.Today().addDays(20);
            update camp;
            Test.startTest();
                SchUpdateMarketingStartEndDatesBatch ascsObject = new SchUpdateMarketingStartEndDatesBatch();
                String sch = '0 0 23 * * ?'; 
                system.schedule('Test Account Sales Calculator Check', sch, ascsObject); 
                UpdateMarketingStartEndDatesBatch updateObjects = new UpdateMarketingStartEndDatesBatch(new Set<ID>{camp.id});
                Database.executeBatch(updateObjects,1);
            Test.stopTest();
        }
    }
}