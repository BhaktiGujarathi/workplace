/****************************************************************************************************************
* Name                  : AgentToPCMappingController_Test                                                            *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 19/Apr/2017                                                                           *   
* ------------------------------------------------------------------------------------------------------------  */
@isTest
private class AgentToPCMappingController_Test {

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
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com'+math.random());
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='admin1@testorg.com'+math.random());
        System.runAs(u2) {
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
            
            PageReference pageRef = Page.AgentsToPCMapping;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id', A1.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(A1);
            AgentToPCMappingController agentsMapping = new AgentToPCMappingController(controller);
            System.debug('agencyID '+agentsMapping.agencyID);
            System.debug('agencyID '+agentsMapping.existingPCs);
            System.debug('agencyID '+agentsMapping.existingPCIDS);
            System.debug('agencyID '+agentsMapping.userIDs);
            System.debug('agencyID '+agentsMapping.conditionsString);
            System.debug('agencyID '+agentsMapping.totalRecs);
            System.debug('agencyID '+agentsMapping.offsetVal);
            System.debug('agencyID '+agentsMapping.LimitSize);
            System.debug('noOfRecToDisplay '+agentsMapping.noOfRecToDisplay);
            agentsMapping.existingPCUsers();
            agentsMapping.getallPCUsers();
            agentsMapping.Firstbtn();
            agentsMapping.prvbtn();
            agentsMapping.Nxtbtn();
            agentsMapping.lstbtn();
            agentsMapping.gethasNext();
            agentsMapping.gethasPrevious();
            agentsMapping.getTotalRecords();
            agentsMapping.updatePage();
            agentsMapping.selSM = u4.id;
            agentsMapping.searchUsers();
            agentsMapping.addPCsToAgency();
            agentsMapping.selHOS = u3.id;
            agentsMapping.searchUsers();
            
        }
    }
}