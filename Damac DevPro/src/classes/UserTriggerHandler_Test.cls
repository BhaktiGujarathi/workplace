@isTest
public class UserTriggerHandler_Test {
    
    static testmethod void m1(){
        
        Id AgencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        
        ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
        ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
        ID adminProfileID = [ Select id,UserType from Profile where name = 'System Administrator'].id;
        ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
        
        User u = new User( email='test-user1@fakeemail.com', profileid = adminProfileID, UserRoleId = adminRoleId,
                  UserName='test-user@fakeemail.com', alias='tuser2', CommunityNickName='tuser1', isActive = true,
                  TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                  LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
        insert u;
        
        System.runAs(u){
            UserTriggerHandler userE = new UserTriggerHandler();
            System.debug(userE.portalUserIDs);
            System.debug(userE.inActiveUserIDs);
            
            Account A1 = new Account(Name = 'Test Account', Agency_Type__c = 'Corporate');
            insert A1;
        
            Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User1', 
            email = 'test-user@fakeemail.com' );
            insert C1; 
            
            Contact C2 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User2', 
            email = 'test-user1@fakeemail.com' );
            insert C2;
            
            Contact C3 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User3', 
            email = 'test-user2@fakeemail.com' );
            insert C3;
            
            User u1 = new User( email='test-user@fakeemail.com', contactid = c1.id, profileid = profileID, 
                      UserName='test-user4@fakeemail.com', alias='tuser1', CommunityNickName='tuser5', isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
            insert u1;
    
            User u3 = new User( email='test-user3@fakeemail.com', profileid = consultantId, 
                      UserName='test-user3@fakeemail.com', alias='tuser3',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test213', LastName = 'User213');
            insert u3;
            
            Agency_PC__c AGPC = new Agency_PC__c();
            AGPC.Agency__c = a1.id;
            AGPC.User__c = u3.Id;
            insert AGPC;
            
            
            Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
            Campaign__c camp = new Campaign__c();
            camp.RecordTypeId = RSRecordTypeId;
            camp.Campaign_Name__c='Test Campaign';
            camp.start_date__c = System.today();
            camp.end_date__c = System.Today().addDays(30);
            camp.Marketing_start_date__c = System.today();
            camp.Marketing_end_date__c = System.Today().addDays(30);
            insert camp;
            
            
            
            Property__c prop = new Property__c();
            prop.Property_Name__c='Discovery gardens';
            prop.Property_ID__c = 12345;
            prop.Active_Property__c = true;
            insert prop;
            
            Location__c loc1 = new Location__c();
            loc1.Name = 'DGB56';
            loc1.Building_Name__c = 'Discovery Gardens';
            loc1.Location_ID__c = '0001';
            loc1.Property_ID__c = '12345';
            loc1.location_type__c = 'Building';
            insert loc1;
            
            Location__c loc2 = new Location__c();
            loc2.Name = 'DGB562';
            loc2.Building_Name__c = 'Discovery Gardens';
            loc2.Location_ID__c = '0002';
            loc2.Property_ID__c = '12345';
            loc2.location_type__c = 'Floor';
            loc2.Parent_id__c = loc1.Location_ID__c;
            insert loc2;
            
            Location__c loc3 = new Location__c();
            loc3.Name = 'DGB562214';
            loc3.Building_Name__c = 'Discovery Gardens';
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
            inv.Building_ID__c = '0001';
            inv.Floor_ID__c = '0002';
            inv.Unit_ID__c = '0003';
            inv.Property_ID__c = '12345';
            inv.Release_ID__c='12345';
            inv.IPMS_Bedrooms__c='RELEASED';
            insert inv;
            
            Assigned_PC__c apc = new Assigned_PC__c();
            apc.Campaign__c = camp.Id;
            apc.user__c = u3.id;
            insert apc;
            
            Assigned_Agent__c agent = new Assigned_Agent__c();
            agent.Agency__c = a1.id;
            agent.Contact__c = c1.id;
            agent.User__c = u1.Id;
            insert agent;
            
            
            
            Inventory_User__c user = new Inventory_User__c();
            user.Inventory__c = inv.id;
            user.user__c = u1.id;
            insert user;
            
            
            Inventory__c inv1 = new Inventory__c();
            inv1.Inventory_ID__c = '00023';
            inv1.Building_ID__c = '0001';
            inv1.Floor_ID__c = '0002';
            inv1.Unit_ID__c = '0026';
            inv1.Property_ID__c = '12345';
            inv1.Release_ID__c='12345';
            inv1.IPMS_Bedrooms__c='RELEASED';
            insert inv1;
            
            
            Team_Building__c tem = InitialiseTestData.createTeamBuilding(loc3.id,prop.id,A1.id);
            insert tem;
            
            Inventory_User__c user1 = new Inventory_User__c();
            user1.Inventory__c = inv1.id;
            user1.user__c = u1.id;
            user1.Team_Building__c = tem.id;
            insert user1;
            
            User u2 = new User( email='test-user2@fakeemail.com', contactid = c2.id, profileid = profileID, 
                      UserName='test-user5@fakeemail.com', alias='tuser2', CommunityNickName='tuser2',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test21', LastName = 'User21');
            insert u2;
            
            u2.isActive = false;
            update u2;
            
            u2.isActive = true;
            update u2;
            
            User u4 = new User( email='test-user7@fakeemail.com', contactid = c3.id, profileid = profileID, 
                      UserName='test-user37@fakeemail.com', alias='tuser7', CommunityNickName='tuser7',  isActive = false,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test11', LastName = 'User11');
            insert u4;
            
        }
        
    }
    
}