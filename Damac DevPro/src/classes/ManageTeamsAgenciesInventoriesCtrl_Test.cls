/**************************************************************************************************
* Test Class for        : ManageTeamsAgenciesInventoriesController    
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 30/Jan/2017 
* ----------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         30/Jan/2017      Initial development
* CH02              3.0         NSI - Sivasankar K         05/March/2017    Initial development
**************************************************************************************************/
@isTest
public class ManageTeamsAgenciesInventoriesCtrl_Test {
    
    @testSetup static void manageTeamsAgenciesInventoriesTestData() {
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
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser21@testorg.com');
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='admin12@testorg.com');
        User pcUser1 = InitialiseTestData.getPropertyConsultantUsers('pcUser1@testPC.com');
        pcUser1.ProfileID = p1.id;
        User pcUser2 = InitialiseTestData.getPropertyConsultantUsers('pcUser2@testPC.com');
        pcUser2.ProfileID = p1.id;
        List<User> pcUsers = new List<User>();
        pcUsers.add(pcUser1);
        pcUsers.add(pcUser2);
        insert pcUsers;
        
        System.runAs(u2) {
            Campaign__c camp = InitialiseTestData.getCampaignDetails();
            insert camp;

            List<Address__c> addresslist = new List<Address__c>();
            Address__c addressobj1 =  InitialiseTestData.getAddressDetails(123);
            addresslist.add(addressobj1);

            Address__c addressobj2 =  InitialiseTestData.getAddressDetails(1234);
            addressobj2.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj2.ADDRESS_LINE2__c='Cluster H';
            addressobj2.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj2.City__c = 'Dubai';
            addressobj2.Country__c = 'LB';
            //addresslist.add(addressobj2);

            Address__c addressobj3 =  InitialiseTestData.getAddressDetails(1235);
            addressobj3.ADDRESS_LINE1__c='Saba Tower 3';
            addressobj3.ADDRESS_LINE2__c='Cluster E';
            addressobj3.ADDRESS_LINE3__c='JLT';
            addressobj3.City__c = 'Dubai';
            addressObj3.State__c = 'Dubai';
            addressobj3.Country__c = 'QA';
            addresslist.add(addressobj3);

            Address__c addressobj4 =  InitialiseTestData.getAddressDetails(1236);
            addressobj4.ADDRESS_LINE1__c='Saba Tower 2';
            addressobj4.ADDRESS_LINE2__c='Cluster G';
            addressobj4.ADDRESS_LINE3__c='Dubai Internet City';
            addressobj4.City__c = 'Dubai';
            addressobj4.Country__c = 'JO';
            addresslist.add(addressobj4);

            Address__c addressobj5 =  InitialiseTestData.getAddressDetails(1237);
            addressobj5.ADDRESS_LINE1__c='Saba Tower 4';
            addressobj5.ADDRESS_LINE2__c='Cluster I';
            addressobj5.ADDRESS_LINE3__c='Damac Heights';
            addressobj5.City__c = 'Riyadh';
            addressobj5.Country__c = 'SA';
            addresslist.add(addressobj5);

            System.debug('addresslist = '+addresslist);
            insert addresslist;

            List<Property__c> lstProperty = new List<Property__c>();

            Property__c damacPropertyStreet1 = InitialiseTestData.getPropertyDetails(123);
            damacPropertyStreet1.Property_Name__c = 'Damac Property 1';
            lstProperty.add(damacPropertyStreet1);
            Property__c damacPropertyStreet2 = InitialiseTestData.getPropertyDetails(1234);
            damacPropertyStreet2.Property_Name__c    = 'Damac Heights' ;
            lstProperty.add(damacPropertyStreet2);

            Property__c damacPropertyStreet3 = InitialiseTestData.getPropertyDetails(1235);
            damacPropertyStreet3.Property_Name__c    = 'Damac Heights1' ;
            lstProperty.add(damacPropertyStreet3);

            insert lstProperty;

            List<Location__c> lstLocations = new List<Location__c>();
            Location__c damacLocations = InitialiseTestData.getLocationDetails('123','Building');
            damacLocations.Name = 'DGB56';
            damacLocations.Building_Name__c = 'Discovery Gardens';
            damacLocations.Address_ID__c = '123';
            damacLocations.Property_ID__c = '123';
            damacLocations.Property_Name__c = damacPropertyStreet1.id;

            Location__c damacLocations3 = InitialiseTestData.getLocationDetails('126','Building');
            damacLocations3.Name = 'DGB56';
            damacLocations3.Building_Name__c = 'Discovery Gardens 3';
            damacLocations3.Address_ID__c = '1234';
            damacLocations3.Property_ID__c = '123';
            damacLocations3.Property_Name__c = damacPropertyStreet1.id;
            
            lstLocations.add(damacLocations);

            Location__c damacLocations1 = InitialiseTestData.getLocationDetails('124','Building');
            damacLocations.Name = 'DGB57';
            damacLocations1.Building_Name__c = 'Discovery Gardens2';
            damacLocations1.Address_ID__c = '1235';
            damacLocations1.Property_ID__c = '1234';
            damacLocations1.Property_Name__c = damacPropertyStreet2.id;
            
            lstLocations.add(damacLocations1);

            Location__c damacLocations2 = InitialiseTestData.getLocationDetails('125','Building');
            damacLocations2.Name = 'DGB58';
            damacLocations2.Building_Name__c = 'Discovery Gardens1';
            damacLocations2.Address_ID__c = '1236';
            damacLocations2.Property_ID__c = '1235';
            damacLocations2.Property_Name__c = damacPropertyStreet3.id;
            
            lstLocations.add(damacLocations2);

            insert lstLocations;
            
            List<Inventory__c> lstInventory = new List<Inventory__c>();

            Inventory__c inventory1 = InitialiseTestData.getInventoryDetails('123','123','1',123,123);
            inventory1.Status__c = 'Released';
            inventory1.Building_Location__c = damacLocations.id;
            lstInventory.add(inventory1);

            Inventory__c inventory4 = InitialiseTestData.getInventoryDetails('126','126','1',1234,123);
            inventory4.Status__c = 'Released';
            inventory4.Building_Location__c = damacLocations3.id;
            lstInventory.add(inventory4);

            Inventory__c inventory2 = InitialiseTestData.getInventoryDetails('124','124','1',1234,1234);
            inventory2.Status__c = 'Released';
            inventory1.Building_Location__c = damacLocations1.id;
            lstInventory.add(inventory2);

            Inventory__c inventory3 = InitialiseTestData.getInventoryDetails('125','125','1',1235,1235);
            inventory3.Status__c = 'Released';
            inventory1.Building_Location__c = damacLocations2.id;
            lstInventory.add(inventory3);

            insert lstInventory;

            //Insert Team records
            List<Group> lstGroups = new List<Group>();
            for(Integer i=0;i<5;i++){
                Group gr = new Group(Name='Test'+i+'_DAMAC_TEAM');
                lstGroups.add(gr);
            }
            lstGroups = InitialiseTestData.createGroupRecords(lstGroups);

            Team_Building__c teamBuilding = InitialiseTestData.createTeamBuilding((String)damacLocations1.id,(String)damacPropertyStreet1.id,(String)lstGroups[0].id);
            insert teamBuilding;
            List<Account> lst  = new List<Account>();
            //Insert Agency records
            Account A1 = new Account(Name = 'Test Account',RecordTypeID = CorRecordTypeId,BillingCity='TestCity',Strength_of_Agency__c = 2,BillingCountry='TestCountry', Agency_Type__c = 'Corporate');
            lst.add(A1);
            
            Account A2 = new Account(Name = 'Damac Account',RecordTypeID = CorRecordTypeId,BillingCity='City',Strength_of_Agency__c = 3,BillingCountry='TestCountry', Agency_Type__c = 'Corporate');
            lst.add(A2);
            
            insert lst;
            
            Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User1', 
            email = 'test-user@fakeemail.com' );
            insert C1; 
            
            Contact C2 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User2', 
            email = 'test-user1@fakeemail.com' );
            insert C2;
            
            Contact C3 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User3', 
            email = 'test-user2@fakeemail.com' );
            insert C3;
            
            Agency_PC__c agencyPC1 = new Agency_PC__c(User__c = pcUser1.id,Agency__c =A1.id);
            Agency_PC__c agencyPC2 = new Agency_PC__c(User__c = pcUser2.id,Agency__c =A1.id);
            Agency_PC__c agencyPC3 = new Agency_PC__c(User__c = pcUser1.id,Agency__c =A2.id);
            Agency_PC__c agencyPC4 = new Agency_PC__c(User__c = pcUser2.id,Agency__c =A2.id);
            List<Agency_PC__c> lstagencies = new List<Agency_PC__c>();
            lstagencies.add(agencyPC1);
            lstagencies.add(agencyPC2);
            lstagencies.add(agencyPC3);
            lstagencies.add(agencyPC4);
            insert lstagencies;
            User u4 = new User( email='test-user5@fakeemail.com', contactid = c1.id, profileid = profileID, 
                      UserName='test-user42@fakeemail.com', alias='tuser1', CommunityNickName='tuser5', isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
            insert u4;
            User u3 = new User( email='test-user3@fakeemail.com', profileid = consultantId, 
                      UserName='test-user31@fakeemail.com', alias='tuser3',  isActive = true,
                      TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                      LanguageLocaleKey='en_US', FirstName = 'Test213', LastName = 'User213');
            insert u3;

            Team_Building__c teamBuilding1 = InitialiseTestData.createTeamBuilding((String)damacLocations1.id,(String)damacPropertyStreet1.id,(String)A1.id);
            insert teamBuilding1;
            
        }
        
    }

    testmethod static void testConstructMethod(){
        
        PageReference pageRef = Page.ManageTeamsAgenciesInventories;
        Test.setCurrentPage(pageRef);
        
        ManageTeamsAgenciesInventoriesCtrl manageTeams = new ManageTeamsAgenciesInventoriesCtrl();
        manageTeams.noOfRecToDisplay = 5;
        System.debug('==>'+manageTeams.removeBuildingfor);
        System.debug('==>'+manageTeams.removeBuildingIndex);
        System.debug('==>'+manageTeams.noOfRecToDisplay);
        System.debug('==>'+manageTeams.buildingsOfProperty);
        System.debug('==>'+manageTeams.buildingsIndexMap);
        System.debug('==>'+manageTeams.addedBuildingsUniqueKeyValues);

        for(ManageTeamsAgenciesInventoriesCtrl.SelectWrapper selWrapper : manageTeams.lstGroupsAgency){
            selWrapper.selected = true;
        }
        manageTeams.getteamBuildingsRecs();
        manageTeams.getPropertyNames();
        System.debug('manageTeams.allPropertyNames ='+manageTeams.allPropertyNames);
        for(SelectOption selOp : manageTeams.allPropertyNames){
             manageTeams.selectedProperty.add(selOp.getValue());
        }
        manageTeams.getBuildingNames();
        manageTeams.addRow();
        manageTeams.addteambuilding.Start_Date__c = Date.today();
        manageTeams.addteambuilding.End_Date__c = Date.today().addDays(2);
        manageTeams.addRow();
        manageTeams.removeBuildingfor = manageTeams.allPropertyNames[0].getValue();
        manageTeams.removeBuildingIndex = 0;
        manageTeams.saveBuildingAllocation();
        manageTeams.removeRow();
        
        manageTeams.selTeamAgency = 'Agencies';
        manageTeams.onRadioChange();

        for(ManageTeamsAgenciesInventoriesCtrl.SelectWrapper selWrapper : manageTeams.lstGroupsAgency){
            selWrapper.selected = true;
        }
        manageTeams.getteamBuildingsRecs();
        manageTeams.getPropertyNames();
        System.debug('manageTeams.allPropertyNames ='+manageTeams.allPropertyNames);
        for(SelectOption selOp : manageTeams.allPropertyNames){
             manageTeams.selectedProperty.add(selOp.getValue());
        }
        manageTeams.getBuildingNames();
        manageTeams.addRow();
        manageTeams.addteambuilding.Start_Date__c = Date.today();
        manageTeams.addteambuilding.End_Date__c = Date.today().addDays(2);
        manageTeams.addRow();
        manageTeams.removeBuildingfor = manageTeams.allPropertyNames[0].getValue();
        manageTeams.removeBuildingIndex = 0;
        manageTeams.saveBuildingAllocation();

        manageTeams.removeRow();
        manageTeams.goToHomePage();
        manageTeams.goToNextPage();
        manageTeams.updatePage();
        manageTeams.Firstbtn();
        manageTeams.prvbtn();
        manageTeams.Nxtbtn();
        manageTeams.lstbtn();
        manageTeams.gethasNext();
        manageTeams.gethasPrevious();
    }
}