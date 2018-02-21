@isTest
public class AvailableUnitsControllerTest {
    Static ID RID;
    public static testmethod void AvailableUnitsControllerTest_testMethod1() {
        
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Agency_Short_Name__c = 'testShrName';
        insert a;
        
        //Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get(rectypeName).getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
       
            sr.NSIBPM__Customer__c = a.id;
            sr.Agency__c = a.id;
            sr.Eligible_to_Sell_in_Dubai__c = true;
            sr.Agency_Type__c = 'Individual';
            sr.ID_Type__c = 'Passport';
            sr.Agency__c = a.id;
            sr.Agency_Email_2__c = 'test2@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
            sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
            
            insert sr;
            
        
        UtilityWrapperManager  um = new UtilityWrapperManager ();
        um.dealRecord = sr;
            
        AvailableUnitsController auc = new AvailableUnitsController();
        
        auc.availableInventoryList = um;
                
        auc.getCampaignList();
        //auc.getPromotionList();
        auc.getProjectList();
        auc.getBuildingList();
        auc.getBedroomTypeList();
        //auc.getPriceList();
        auc.refreshthePropertyFilters();
        auc.refreshtheBuildingFilters();
        auc.refreshtheBedroomFilters();
        auc.getSpaMethods();
        auc.getProperties();
        auc.getRelatedInventories();
        auc.showNextRecords();
        auc.getAgencyRelatedInventories();
        
        //auc.selectInventory();
        auc.getAssociatedCampaigns();
        //auc.getTeamRelatedInventories();
        auc.getGeneralInventories();
        AvailableUnitsController.getCampaignRelatedInventories();
        AvailableUnitsController.getTeamUsers();
        auc.sortToggle();
        auc.getSortedList();
        AvailableUnitsController.getRelatedCampaign();
        
        
    }
    
    public static testmethod void AvailableUnitsControllerTest_testMethod2() {
        
        test.startTest();
        		        Account a = new Account();
        a.Name = 'Test Account';
        a.Agency_Short_Name__c = 'testShrName';
        
        insert a;
        
        Contact con = new Contact();
        con.LastName = 'testlnme';
        con.AccountId = a.Id ;
        insert con;
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        
        profile p= [select Id from Profile where name='Customer Community - Admin'];
        User portalUser = new User(alias = 'test456', email='testusr1@test.com',
                emailencodingkey='UTF-8', lastname='User 456', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.id, country='United Arab Emirates',IsActive =true,
                ContactId = con.Id,timezonesidkey='America/Los_Angeles', username='testusr1@test.com');
                insert portalUser;
        
        //Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get(rectypeName).getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
       
            sr.NSIBPM__Customer__c = a.id;
            sr.Agency__c = a.id;
            sr.Eligible_to_Sell_in_Dubai__c = true;
            sr.Agency_Type__c = 'Individual';
            sr.ID_Type__c = 'Passport';
            sr.Agency__c = a.id;
            sr.Agency_Email_2__c = 'test2@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
            sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
            
            insert sr;
            
        Location__c loc = new Location__c();
        loc.Location_Code__c =  'test';
        loc.Location_ID__c = 'testloc2010';
        insert loc;
        
        
        Inventory__c  inv = new Inventory__c ();
        inv.Unit_Location__c = loc.id;
        inv.Property_Country__c = 'UAE';
        inv.Is_Assigned__c = true;
        inv.Status__c = 'Released';
        
        insert inv;
        
        UtilityWrapperManager.InventoryBuyerWrapper umi = new UtilityWrapperManager.InventoryBuyerWrapper(true, false,false, 100, 100, 'test', 'test', 'test','test', 2, inv, null, null,null);
        
        list<UtilityWrapperManager.InventoryBuyerWrapper> listumi = new list<UtilityWrapperManager.InventoryBuyerWrapper>();
        listumi.add(umi);
        
        AvailableUnitsController.FilterWrapper fw = new AvailableUnitsController.FilterWrapper('GeneralInventories', 'test', 'test', 'test', 'test', 'test','', 100, 100);
        
        Campaign__c camp = new Campaign__c ();
        camp.Campaign_Name__c= 'test';
        camp.Start_Date__c = system.today()-1;
        camp.End_Date__c = system.today() + 1;
        camp.Marketing_Start_Date__c = system.today()-1;
        camp.Marketing_End_Date__c = system.today() + 1;
        
        
        insert camp;
        
        
        Campaign_Inventory__c  cinv = new Campaign_Inventory__c();
        cinv.Campaign__c = camp.id;
        cinv.Inventory__c = inv.id;
        cinv.Start_Date__c = system.today()-1;
        cinv.End_Date__c = system.today()+1;
        
        insert cinv;
        
        
        Map<Id, String> inventoryCampaignIdsMap = new Map<Id, String>();    
        inventoryCampaignIdsMap.put(cinv.Inventory__c , cinv.Campaign__c);
        
        
        List<Id> campaignIdsList = new List<Id>();
        campaignIdsList.add(camp.id);
        
        Inventory_User__c iu = new Inventory_User__c ();
        iu.Inventory__c = inv.id;
        iu.user__c = portalUser.id;
        iu.Start_Date__c = system.today() - 1;
        iu.End_Date__c = system.today() + 1;
        
        insert iu;
        
        Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> mp_um = new Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>();
        mp_um.put(camp.id, umi);
        
        
        UtilityWrapperManager  um = new UtilityWrapperManager ();
        um.dealRecord = sr;
        um.ibwList = listumi;
        
        Map<String, Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>> mptest_campaignInventoryBuyerWrapperMap = new Map<String, Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>>();
        mptest_campaignInventoryBuyerWrapperMap.put('GeneralInventories', mp_um);
            
        AvailableUnitsController auc = new AvailableUnitsController();
        
        auc.availableInventoryList = um;
        auc.fwObject = fw;
        //auc.campaignInventoryBuyerWrapperMap = mptest_campaignInventoryBuyerWrapperMap;
        
        auc.getCampaignList();
        //auc.getPromotionList();
        auc.getProjectList();
        auc.getBuildingList();
        auc.getBedroomTypeList();
        //auc.getPriceList();
        auc.refreshthePropertyFilters();
        auc.refreshtheBuildingFilters();
        auc.refreshtheBedroomFilters();
        auc.getSpaMethods();
        auc.getProperties();
        auc.getRelatedInventories();
        auc.showNextRecords();
        auc.getAgencyRelatedInventories();
        
        AvailableUnitsController.getInventoryUsersList(a.id);
        auc.getCampaignDetails(campaignIdsList);
        //auc.getAssociatedProperties(campaignIdsList);
        auc.getAssociatedProperties(camp.id);
        //auc.getInventoryDetails(inventoryCampaignIdsMap.keySet(), inventoryCampaignIdsMap, 'campaign');        
        AvailableUnitsController.getInventoryDetails(string.valueof(camp.id));
        
        //auc.selectInventory();
        auc.getAssociatedCampaigns();
        //auc.getTeamRelatedInventories();
        auc.getGeneralInventories();
        AvailableUnitsController.getCampaignRelatedInventories();
        AvailableUnitsController.getTeamUsers();
        auc.sortToggle();
        auc.getSortedList();
        AvailableUnitsController.getRelatedCampaign();
        
        test.stopTest();
    }
    
    
    public static testmethod void AvailableUnitsControllerTest_testMethod3() {
        
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Agency_Short_Name__c = 'testShrName';
        insert a;
        
        Contact con = new Contact();
        con.LastName = 'testlnme';
        con.AccountId = a.Id ;
        insert con;
        
        profile p= [select Id from Profile where name='Customer Community - Admin'];
        User portalUser = new User(alias = 'test456', email='testusr1@test.com',
                emailencodingkey='UTF-8', lastname='User 456',UserRoleId=RID, languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.id, country='United Arab Emirates',IsActive =true,
                ContactId = con.Id,timezonesidkey='America/Los_Angeles', username='testusr1@test.com');
                
                insert portalUser;
        
        //Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get(rectypeName).getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
       
            sr.NSIBPM__Customer__c = a.id;
            sr.Agency__c = a.id;
            sr.Eligible_to_Sell_in_Dubai__c = true;
            sr.Agency_Type__c = 'Individual';
            sr.ID_Type__c = 'Passport';
            sr.Agency__c = a.id;
            sr.Agency_Email_2__c = 'test2@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
            sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
            
            insert sr;
            
        Location__c loc = new Location__c();
        loc.Location_Code__c =  'test';
        loc.Location_ID__c = 'testloc2010';
        insert loc;
        
        
        Inventory__c  inv = new Inventory__c ();
        inv.Unit_Location__c = loc.id;
        inv.Property_Country__c = 'UAE';
        
        inv.Status__c = 'Released';
        inv.Is_Assigned__c = false;
        inv.List_Price__c = 900;
        insert inv;
        
        UtilityWrapperManager.InventoryBuyerWrapper umi = new UtilityWrapperManager.InventoryBuyerWrapper(true, false,false, 100, 100, 'test', 'test', 'test','test', 2, inv, null, null,null);
        
        list<UtilityWrapperManager.InventoryBuyerWrapper> listumi = new list<UtilityWrapperManager.InventoryBuyerWrapper>();
        listumi.add(umi);
        
        AvailableUnitsController.FilterWrapper fw = new AvailableUnitsController.FilterWrapper('GeneralInventories', 'test', 'test', 'test', 'test', 'test','', 100, 100);
        
        Campaign__c camp = new Campaign__c ();
        camp.Campaign_Name__c= 'test';
        camp.Start_Date__c = system.today()-1;
        camp.End_Date__c = system.today() + 1;
        camp.Marketing_Start_Date__c = system.today()-1;
        camp.Marketing_End_Date__c = system.today() + 1;
        
        
        insert camp;
        
        
        Campaign_Inventory__c  cinv = new Campaign_Inventory__c();
        cinv.Campaign__c = camp.id;
        cinv.Inventory__c = inv.id;
        cinv.Start_Date__c = system.today()-1;
        cinv.End_Date__c = system.today()+1;
        
        insert cinv;
        
        
        Map<Id, String> inventoryCampaignIdsMap = new Map<Id, String>();    
        inventoryCampaignIdsMap.put(cinv.Inventory__c , cinv.Campaign__c);
        
        
        List<Id> campaignIdsList = new List<Id>();
        campaignIdsList.add(camp.id);
        
        Inventory_User__c iu = new Inventory_User__c ();
        iu.Inventory__c = inv.id;
        iu.user__c = portalUser.id;
        iu.Start_Date__c = system.today() - 1;
        iu.End_Date__c = system.today() + 1;
        
        
        insert iu;
        
        Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> mp_um = new Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>();
        mp_um.put(camp.id, umi);
        
        
        UtilityWrapperManager  um = new UtilityWrapperManager ();
        um.dealRecord = sr;
        um.ibwList = listumi;
        
        Map<String, Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>> mptest_campaignInventoryBuyerWrapperMap = new Map<String, Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>>();
        mptest_campaignInventoryBuyerWrapperMap.put('GeneralInventories', mp_um);
            
        AvailableUnitsController auc = new AvailableUnitsController();
        
        auc.priceRangeStartValue = 1000;
        auc.priceRangeEndValue = 2000;
        auc.availableInventoryList = um;
        auc.fwObject = fw;
        //auc.campaignInventoryBuyerWrapperMap = mptest_campaignInventoryBuyerWrapperMap;
        
        auc.getCampaignList();
        //auc.getPromotionList();
        auc.getProjectList();
        auc.getBuildingList();
        auc.getBedroomTypeList();
        //auc.getPriceList();
        auc.refreshthePropertyFilters();
        auc.refreshtheBuildingFilters();
        auc.refreshtheBedroomFilters();
        auc.getSpaMethods();
        auc.getProperties();
        auc.getRelatedInventories();
        auc.showNextRecords();
        auc.getAgencyRelatedInventories();
        
        AvailableUnitsController.getInventoryUsersList(a.id);
        auc.getCampaignDetails(campaignIdsList);
        //auc.getAssociatedProperties(campaignIdsList);
        auc.getAssociatedProperties(camp.id);
        //auc.getInventoryDetails(inventoryCampaignIdsMap.keySet(), inventoryCampaignIdsMap, 'campaign');
        AvailableUnitsController.getInventoryDetails('test');
        
        //auc.selectInventory();
        auc.getAssociatedCampaigns();
        //auc.getTeamRelatedInventories();
        auc.getGeneralInventories();
        AvailableUnitsController.getCampaignRelatedInventories();
        AvailableUnitsController.getTeamUsers();
        auc.sortToggle();
        auc.getSortedList();
        AvailableUnitsController.getRelatedCampaign();
        
        AvailableUnitsController.getInventoryDetails('test');
        AvailableUnitsController.getAgencyDetails('test');
        AvailableUnitsController.getCorporateAgents('test');
        AvailableUnitsController.validateSelectedUnits(a.id, 'test');
        
        
    }
    
    
}