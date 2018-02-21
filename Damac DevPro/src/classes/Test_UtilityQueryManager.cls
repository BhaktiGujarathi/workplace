/**************************************************************************************************
* Name               : Test_UtilityQueryManager                                               
* Description        : An apex page controller for UtilityQueryManager                                        
* Created Date       : NSI - Diana                                                                        
* Created By         : 03/01/2017                                                               
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          03/01/2017                                                          
**************************************************************************************************/
@isTest
public class Test_UtilityQueryManager {
/*
    private static Contact adminContact;
    private static User portalUser;
    private static Account adminAccount;
    private static User portalOnlyAgent;
    private static Notification__c notification;
    private static Property__c property;
    private static Address__c address;
    private static Announcement__c futureannouncement;
    
    static void init(){

        adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        system.debug('--adminAccount--'+adminAccount.Agency_Tier__c);
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        Contact agentContact = InitialiseTestData.getAgentContact('Test Agent', adminAccount.Id);
        insert agentContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');
        portalOnlyAgent = InitialiseTestData.getPortalUser('test1@test.com', agentContact.Id, 'Agent');
        
        System.runAs(portalUser){
          notification =  InitialiseTestData.createNotification(adminAccount.Id,adminContact.Id);
          futureannouncement = InitialiseTestData.createAnnouncement(System.now().Date(),System.now().Date().addDays(30),true,
                                                                  'PLATINUM','All');
          insert futureannouncement;
          
          Assigned_Agent__c assignedAgents =  InitialiseTestData.assignCampaignsToAgents(System.now().Date().addDays(5),System.now().Date(),portalUser.Id);
          insert assignedAgents;
          
          property = InitialiseTestData.insertProperties();
          InitialiseTestData.createInventoryUser(property); 
            
          address = InitialiseTestData.getAddressDetails(123);
          insert address;

          Case__c cases = InitialiseTestData.createCases();
          insert cases;

        }
        
    }
    
    @isTest static void notifications(){
        
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            String condition = 'Contact__r.id =\''+adminContact.Id+'\' AND Active__c  =true'+ 
                                ' ORDER BY Read__c,CreatedDate DESC';
            
            UtilityQueryManager.getNotifications(condition);
            UtilityQueryManager.getNotificationDescription(notification.ID);
            UtilityQueryManager.markNotificationAsRead(notification.Id);
        }  
        Test.stopTest();
    }
    
    @isTest static void getInformation(){
        Test.startTest();
        init();
        System.runAs(portalUser){
            UtilityQueryManager.getContactInformation();
            UtilityQueryManager.getAccountId();
            UtilityQueryManager.getAccountInformation(adminAccount.Id);
            UtilityQueryManager.getAllContacts(adminAccount.Id);
            UtilityQueryManager.getCompanyProfileDetail(adminAccount.Id);
            UtilityQueryManager.getProfileName();
            UtilityQueryManager.getAllUsers(adminAccount.Id);
        }
        Test.stopTest();
    }
    
    @isTest static void announcement(){
        Test.startTest();
        init();
        adminAccount = [SELECT Agency_Tier__c,Id from Account where Id=:adminAccount.Id limit 1];
        system.debug('--agency tier'+adminAccount.Agency_Tier__c);
       
        System.runAs(portalUser){
            UtilityQueryManager.getLatestAnnouncement(adminAccount);
            UtilityQueryManager.getAllAnnouncements(adminAccount);
        }
        Test.stopTest();
    }
    
    @isTest static void campaigns(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            UtilityQueryManager.getLatestCampaign();
            UtilityQueryManager.getAllCampaigns();
        }
        Test.stopTest();
    }
    
    @isTest static void projects(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            UtilityQueryManager.getAllProjectTypes();
            Set<Id> propertyId = new Set<Id>();
            propertyId.add(property.Id);
            UtilityQueryManager.getProjectLists(propertyId);
            Set<Id> inventoryIds  = UtilityQueryManager.getInventoryIDs('SELECT Id,Inventory__c FROM Inventory_User__c');
            UtilityQueryManager.getPropertyIDs(inventoryIds);
            UtilityQueryManager.getAllCities();
            UtilityQueryManager.getAddressLocation(propertyId, inventoryIds);
            UtilityQueryManager.getAllBedRooms();
            UtilityQueryManager.getInventoryList('Id,Property_Name_2__c FROM Inventory__c',inventoryIds);
            UtilityQueryManager.getPriceRange();
            String condition = 'SELECT Id from Inventory__c where Status__c=\'RELEASED\' AND Unit_Location__c != null'+
                                ' AND Address__c != null AND Is_Assigned__c = false';
            UtilityQueryManager.getAllGeneralInventories(condition);
            UtilityQueryManager.getMinMaxPrice(property.Id);
        }
        Test.stopTest();
    }
    
    @isTest static void processFlow(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Update_Page_Flow_Name);
        }
        Test.stopTest();
    }
    
    @isTest static void CILS(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            
              Inquiry__c CIL = InitialiseTestData.getInquiryDetails(DAMAC_Constants.CIL_RT,1);
              insert CIL;
            Id inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.CIL_RT).getRecordTypeId();
            String condition =  ' AND CreatedById =\''+portalUser.Id+'\'';
            UtilityQueryManager.getCILs(condition, inquiryRecordTypeId, null);
        }
    }
    
    @isTest static void Cases(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
             String condition =  ' CreatedById =\''+portalUser.Id+'\'';
             UtilityQueryManager.getCases(condition,null);
        }
        Test.stopTest();
    }
    
    @isTest static void announcementRequest(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            Announcement_Request__c announcementRequest = new Announcement_Request__c();
            announcementRequest.Footer__c = 'test footer';
            announcementRequest.Announcement__c = futureannouncement.Id;
            announcementRequest.Agency__c = adminAccount.Id;
            insert announcementRequest;
            UtilityQueryManager.getAnnouncementRequest(futureannouncement.Id, adminAccount.Id); 
            UtilityQueryManager.getAnnouncementDetail(futureannouncement.Id);
        }
        Test.stopTest();
    }

    @isTest static void getCommission(){
        Test.startTest();
        init();

        System.runAs(portalUser){
            Agent_Commission__c agentCommission = InitialiseTestData.createAgentCommission(adminAccount.Id,System.now().Date(),System.now().Date());
            insert agentCommission;

            UtilityQueryManager.getCommission(adminAccount.Id);

        }
        Test.stopTest();
    }
    
    */
    
}