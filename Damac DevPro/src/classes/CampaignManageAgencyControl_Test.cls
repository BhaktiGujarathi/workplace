/**************************************************************************************************
* Class Name            : CampaignManageAgencyControl
* Test Class			: CampaignManageAgencyControl_Test
***************************************************************************************************/
@isTest
public class CampaignManageAgencyControl_Test {
    
    testmethod static void testMethodForController(){
        
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Id CorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
        ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
        ID adminProfileID = [ Select id,UserType from Profile where name = 'System Administrator'].id;
        ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String milli = String.valueOf(System.now().millisecond());
        User u1 = new User(Alias = 'standt1', UserName='testUser'+milli+'@damac.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles');
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+milli+'@damac.com');
        
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
            
            User u4 = new User( email='test-user5@fakeemail.com', contactid = c1.id, profileid = profileID, 
                      UserName='test-user4@fakeemail.com', alias='tuser1', CommunityNickName='tuser5', isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
            insert u4;
    
            User u3 = new User( email='test-user3@fakeemail.com', profileid = consultantId, 
                      UserName='test-user3@fakeemail.com', alias='tuser3',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test213', LastName = 'User213');
            insert u3;
            
            Agency_PC__c AGPC = new Agency_PC__c();
            AGPC.Agency__c = a1.id;
            AGPC.User__c = u3.Id;
            insert AGPC;
            
            Assigned_PC__c apc = new Assigned_PC__c();
            apc.Campaign__c = camp.Id;
            apc.user__c = u3.id;
            insert apc;
            
            Assigned_Agent__c agent = new Assigned_Agent__c();
            agent.Agency__c = a1.id;
            agent.Contact__c = c1.id;
            agent.User__c = u3.Id;
            agent.Campaign__c = camp.Id;
            insert agent;
            
            Campaign_Inventory__c cInv = new Campaign_Inventory__c();
            cInv.Inventory__c = inv.Id;
            cInv.Campaign__c = camp.Id;
            insert cInv;
            
            
            Group gp = new Group();
            gp.name = 'DAMAC Team';
            gp.Type = 'Regular';
            insert gp;
            
            GroupMember gm = new GroupMember();
            gm.UserOrGroupId = u3.Id;
            gm.GroupId = gp.Id;
            insert gm;
            
            delete cInv;
            
            delete agent;
            
            delete apc;
            
            PageReference pageRef = Page.CampaignManageAgency;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id', camp.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            CampaignManageAgencyControl obj = new CampaignManageAgencyControl(sc);
            
            System.debug('=== '+obj.strengthOfAgency);
            System.debug('=== '+obj.campaignID);
            System.debug('=== '+CampaignManageAgencyControl.existingAgencies);
            System.debug('=== '+obj.campainRecords);
            System.debug('=== '+obj.controller);
            
            System.debug('=== '+obj.hasNext);
            System.debug('=== '+obj.hasPrevious);
            System.debug('=== '+obj.pageNumber);
            System.debug('=== '+obj.manageHelper);
            System.debug('=== '+obj.isSaved);
            
            
            obj.getlstAgencies();
            
            obj.searchAgency();
            
            CampaignManageAgencyControl.getAgencies('Test',camp.id,'Name');
            CampaignManageAgencyControl.getAgencies('Test',camp.id,'BillingCity');
            CampaignManageAgencyControl.getAgencies('Test',camp.id,'BillingCountry');
            
            obj.searchSection.agencyName = 'Test Accoun';
            obj.searchSection.city = '';
            obj.searchSection.country ='';
            obj.searchSection.typeofAccount = '';
            obj.searchSection.strength = '';
            obj.searchSection.tier = '';
            obj.searchAgency();
            
            obj.doCancel();
            obj.cancel();
            obj.next();
            obj.last();
            obj.previous();
            obj.first();
            
            obj.assignAgents();
        }
    }
}