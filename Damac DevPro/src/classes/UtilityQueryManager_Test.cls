@isTest
private class UtilityQueryManager_Test {

    static testMethod void myUnitTest() {
    	Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    	ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
    	User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
				            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				            LocaleSidKey='en_US', ProfileId = p2.Id, 
				            TimeZoneSidKey='America/Los_Angeles', UserName='admin0@testorg.com');
		insert u2;
		User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p2.Id, ManagerID = u2.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser0@damactest.com');
        insert u1;
        System.runAs(u2) {
	        Campaign__c thisCampaign = InitialiseTestData.createCampaign();
	        insert thisCampaign;
	        Campaign__c thisCampaign1 = InitialiseTestData.createCampaign();
	        insert thisCampaign1;
	        UtilityQueryManager.getUsersCampaignDetails(new set<ID>{thisCampaign.id});
	        
	        UtilityQueryManager.getObjectRecord('Campaign__c',new set<ID>{thisCampaign.id,thisCampaign1.id});
	        UtilityQueryManager.getSharingRecord('Campaign__c',new set<String>{thisCampaign.id,thisCampaign1.id});
	        UtilityQueryManager.getUserChildDetails(new Set<ID>{u2.id});
	        UtilityQueryManager.getUserManagerDetails(new Set<Id> {u1.id});
	        UtilityQueryManager.getUserShareMap(new Set<Id> {u1.id});
	        Notification__c notifycation = InitialiseTestData.createNotification(null,null);
	        //insert notifycation;
	        UtilityQueryManager.getNotifications('Active__c = true');
	        UtilityQueryManager.getNotificationDescription(notifycation.id);
	        UtilityQueryManager.markNotificationAsRead(notifycation.id);
	        UtilityQueryManager.markNotificationAsRead(null);
	        UtilityQueryManager.getContactInformation();
	        UtilityQueryManager.getAccountId();
	        Account acc = InitialiseTestData.getBlacklistedAccount('test');
	        //acc.Agency_Tier__c = 'All';
	        insert acc;
	        UtilityQueryManager.getAccountInformation(acc.id);
	        Announcement__c announcement = InitialiseTestData.createAnnouncement(Date.today(),Date.today().addDays(2),true,'All','All');
	        //announcement.Agency__c = acc.id;
	        insert announcement;
	        UtilityQueryManager.getLatestAnnouncement(acc);
	        UtilityQueryManager.getAllAnnouncements(acc);
	        UtilityQueryManager.getLatestCampaign();
	        Assigned_Agent__c agent = InitialiseTestData.assignCampaignsToAgents(Date.today().addDays(2),Date.today(),u2.id);
	        UtilityQueryManager.getLatestCampaign();
	        Property__c pro = InitialiseTestData.insertProperties();
	        InitialiseTestData.createInventoryUser(pro);
	        UtilityQueryManager.getAllProjectTypes();
	        UtilityQueryManager.getProjectLists(new Set<ID>{pro.id});
	        UtilityQueryManager.getAllFields(Campaign__c.SObjectType.getDescribe());
	        UtilityQueryManager.getInventoryIDs('Select Id,Inventory__c from Inventory_User__c');
	        UtilityQueryManager.getPropertyIDs(new Set<Id> {pro.id});
	        UtilityQueryManager.getAllCities();
	        map<ID,inventory__c> mapin = new Map<ID,Inventory__c>([select id, name from Inventory__c]);
	        UtilityQueryManager.getAddressLocation(new Set<Id> {pro.id},mapin.keySet());
	        
	        List<Group> lstGroups = InitialiseTestData.createGroupRecords(new List<Group> {new Group()});
	        GroupMember gm = new GroupMember(UserOrGroupId = u1.id,GroupId = lstGroups[0].id);
	        insert gm;
	        UtilityQueryManager.getUserIdsFromGroups(new Set<Id> {lstGroups[0].id});
	        Page_Flow__c  pf= InitialiseTestData.createPageFlow();
	        insert pf;
	        UtilityQueryManager.getProcessFlowId(pf.id);
	        UtilityQueryManager.getAllContacts(acc.id);
	        UtilityQueryManager.getCompanyProfileDetail(acc.id);
	        UtilityQueryManager.getProfileName();
	        Id InquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get('Inquiry').getRecordTypeId();
	        UtilityQueryManager.getCILs('',InquiryRecordTypeId,new Set<Id> {u2.id});
	        
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
            ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
            ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
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
	        
	        UtilityQueryManager.getAllUsers(A1.id);
	        
	        Attachment att = new Attachment(body=blob.valueOf('test'),Name='test',parentID = A1.id);
	        insert att;
	        UtilityQueryManager.getTheAttachmentCount(A1.id);
	        
	        Case__c cas = InitialiseTestData.createCases();
	        insert cas;
	        UtilityQueryManager.getCases( 'Status__c = \'New\'',new Set<Id> ());
	        
	        UtilityQueryManager.getAllBedRooms();
	        UtilityQueryManager.getInventoryList('Name From Inventory__c ',new Set<ID>());
	        UtilityQueryManager.getAnnouncementRequest(announcement.id,acc.id);
	        UtilityQueryManager.getPriceRange();
	        UtilityQueryManager.getAnnouncementDetail(announcement.id);
	        UtilityQueryManager.getAllUsersOfAccounts(new List<Id> {A1.id,acc.id});
	        UtilityQueryManager.checkPendingSR(acc.id);
	        UtilityQueryManager.getAllGeneralInventories('Select Id,Name from Inventory__c');
	        UtilityQueryManager.getMinMaxPrice(pro.id);
	        UtilityQueryManager.getCommission(A1.id);
		}
    }
}