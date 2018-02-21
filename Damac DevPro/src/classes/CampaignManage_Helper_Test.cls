/**************************************************************************************************
* Covered Class      : CampaignManage_Helper  
* Test class         : CampaignManage_Helper_Test                                  
* Created Date       : NSI - Sivasankar                                                                        
* Created By         : 18/Apr/2017                                                                 
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Sivasankar          18/Apr/2017                                                               
***************************************************************************************************/
@isTest
public class CampaignManage_Helper_Test {
    testMethod static void campainhelperTest(){
        
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
            TimeZoneSidKey='America/Los_Angeles', UserName='admin@damactest.com');
        
        System.runAs(u2) {
            
            
            Campaign__c camp = new Campaign__c();
            camp.RecordTypeId = RSRecordTypeId;
            camp.Campaign_Name__c='Test Campaign';
            camp.start_date__c = System.today();
            camp.end_date__c = System.Today().addDays(30);
            camp.Marketing_start_date__c = System.today();
            camp.Marketing_end_date__c = System.Today().addDays(30);
            insert camp;
            
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
            
            ApexPages.currentPage().getParameters().put('id', camp.Id);
            
            CampaignManage_Helper helper = new CampaignManage_Helper('SELECT ID,Name From Campaign__c');
            System.debug('existingusers = '+helper.existingusers);
            System.debug('existingusers = '+helper.existingInventories);
            System.debug('existingusers = '+helper.existingAgencies);
            System.debug('existingusers = '+helper.controller);
            
            System.debug('existingusers = '+helper.hasNext);
            System.debug('existingusers = '+helper.hasPrevious);
            System.debug('existingusers = '+helper.pageNumber);
            System.debug('existingusers = '+helper.existingusers);
            
            CampaignManage_Helper.existingRecordIds('Assigned_PC__c');
            CampaignManage_Helper.existingRecordIds('Assigned_Agent__c');
            CampaignManage_Helper.existingRecordIds('Campaign_Inventory__c');
            
            CampaignManage_Helper.searchResultWrapper searchw = new CampaignManage_Helper.searchResultWrapper();
            System.debug(searchw.checked);
            System.debug(searchw.obj);
            System.debug(searchw.assignedPC);
            System.debug(helper.searchText);
            System.debug(helper.selectedText);
            System.debug(helper.isSaved);
            System.debug(helper.lstSearchResult);
        }
    }    
}