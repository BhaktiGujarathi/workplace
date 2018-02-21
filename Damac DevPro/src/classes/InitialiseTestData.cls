/*
* Name : Pavithra Gajendra
* Date : 03/08/2017
* Purpose : Class to Initialise Test Data
* Company : NSI Gulf
* 
*/
@isTest
public class InitialiseTestData {
    
    public static Id accRecordTypeId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
    public static Id communityProfile = [select Id from Profile where name='Customer Community - Agent'].Id;
    public static Id propertyConsultantProfile = [select Id from Profile where name='Property Consultant'].Id;
    public static Id communityAdminProfile = [select Id from Profile where name='Customer Community - Admin'].Id;
    public static Id communityAuthProfile = [SELECT Id FROM Profile WHERE name='Customer Community - Auth Officer'].Id;
    public static Id communityOwnerProfile = [SELECT Id FROM Profile WHERE name='Customer Community - Owner'].Id;
    
    public static Account getBlacklistedAccount(String accName){
        Account acc = new Account();
        acc.Name = accName ;
        acc.RecordTypeId = accRecordTypeId ;
        acc.Blacklisted__c = true ;
        acc.Reason_for_Blacklisting__c = 'Agency Blacklisting unit test';
        return acc ;
    }
    
    public static Account getCorporateAccount(String accName){
        Account acc = new Account();
        acc.Name = accName ;
        acc.RecordTypeId = accRecordTypeId ;
        acc.Reason_for_Blacklisting__c = 'Agency Blacklisting unit test';
        acc.Reason_for_Termination__c = 'Agency Termination unit test';
        acc.Eligible_For_Tier_Program__c = true ;
        acc.Quarter_4_Sales__c = 2000000 ;
        acc.Quarter_2_Sales__c = 2000000 ;
        acc.Quarter_1_Sales__c = 2000000 ;
        return acc ;
    }
    
    public static Account getTerminatedAccount(String accName){
        Account acc = new Account();
        acc.Name = accName ;
        acc.RecordTypeId = accRecordTypeId ;
        acc.Terminated__c = true ;
        acc.Reason_for_Termination__c = 'Agency Termination unit test';
        return acc ;
    }
    
    public static Contact getCorporateAgencyContact(String lastNameCon){
        Account acc = getCorporateAccount(lastNameCon);
        insert acc ; 
        Contact con = new Contact();
        con.LastName = lastNameCon;
        con.AccountId = acc.Id ;
        return con ; 
    }
    
    public static User getPortalUser(String agentUserName, Id contactId){
        User portalUser = new User(alias = 'test456', email=agentUserName,
                emailencodingkey='UTF-8', lastname='User 456', languagelocalekey='en_US',
                localesidkey='en_US', profileid = communityProfile, country='United Arab Emirates',IsActive =true,
                ContactId = contactId,timezonesidkey='America/Los_Angeles', username=agentUserName);      
        return portalUser;
    }
    
    public static User getPortalUser(String agentUserName,Id contactId,String profileType){
        Id profileId = (profileType == 'Admin')? communityAdminProfile:
                       (profileType == 'Auth')?communityAuthProfile:
                       (profileType == 'Owner')?communityOwnerProfile:communityProfile;
         
        User portalUser = new User(alias = 'test456', email=agentUserName,
                emailencodingkey='UTF-8', lastname='User 456', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileId, country='United Arab Emirates',IsActive =true,
                ContactId = contactId,timezonesidkey='America/Los_Angeles', username=agentUserName);      
        return portalUser;
    }
    
    public static Agency_Tier_Case_Status__c getAgencyTierDetails(String tierName){
        Agency_Tier_Case_Status__c agencyTier = new Agency_Tier_Case_Status__c();
        agencyTier.Name = tierName ;
        agencyTier.Case_Status__c = 'Book a Hotel;Book a Car' ;
        return agencyTier ; 
    }
    
    
     public static Contact getAgentContact(String lastNameCon,Id accountId){
        Contact con = new Contact();
        con.LastName = lastNameCon;
        con.AccountId = accountId ;
        return con ; 
    }
    
    public static Account getAdminAccount(Integer salesVal,String accName){
        Account acc = new Account();
        acc.Name = accName ;
        acc.RecordTypeId = accRecordTypeId ;
        acc.Reason_for_Blacklisting__c = 'Agency Blacklisting unit test';
        acc.Reason_for_Termination__c = 'Agency Termination unit test';
        acc.Eligible_For_Tier_Program__c = true ;
        acc.Quarter_1_Sales__c = salesVal ;
        acc.Quarter_2_Sales__c = salesVal ;
        acc.Quarter_3_Sales__c = salesVal ;
        acc.Quarter_4_Sales__c = salesVal ;
        return acc ;
    }
    
    public static Contact getAdminContact(String lastNameCon,Id accountId){
       
        
        Contact con = new Contact();
        con.LastName = lastNameCon;
        con.AccountId = accountId ;
        con.Email ='testemail@test.com';
        con.Portal_Administrator__c = true;
        return con;
    }
    
    public static Contact getAgentsContact(String lastNameCon,Id accountId){
        Contact con = new Contact();
        con.LastName = lastNameCon;
        con.AccountId = accountId ;
        con.Email ='testemail@test.com';
        con.Agent_Representative__c = true;
        return con;
    }
    
    public static CollaborationGroup getDefaultCollaborationGroup(String groupName){
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = groupName ;
        cg.CollaborationType = 'Public';
        return cg ; 
    }
    
    public static Location__c getLocationDetails(String locId,String locType){
        Location__c locationNew = new Location__c();
        locationNew.Location_ID__c = locId ;
        locationNew.Location_Type__c = locType ; 
        return locationNew ;
    }
    
    public static Inventory__c getInventoryDetails(String inventId,String buildingId,String floorId,Integer addId,Integer propertyId){
        Inventory__c invent = new Inventory__c();
        invent.Inventory_ID__c = inventId ;
        invent.Building_ID__c = buildingId ;
        invent.Floor_ID__c = floorId ;
        invent.Marketing_Name__c = 'Damac Heights';
        invent.Address_Id__c = String.valueOf(addId) ;
        invent.Property_ID__c = String.valueOf(propertyId) ;
        return invent ;
    }
    
    public static Address__c getAddressDetails(Integer addressId){
        Address__c add = new Address__c();
        add.Address_ID__c = addressId ;
        add.ADDRESS_LINE1__c = 'Damac Star Properties LLC';
        add.ADDRESS_LINE2__c = 'P.O Box 2195';
        add.City__c = 'DUBAI';
        add.ATTRIBUTE_CATEGORY__c = 'BUILDING';
        add.Country__c = 'AE';
        return add ; 
    }
    public static Payment_Terms__c getPaymentTerm(id planid){
        Payment_Terms__c pp = new Payment_Terms__c();
        pp.Payment_Plan__c=planid;
        
        return pp;
    }
    public static Payment_Plan__c getPaymentPlan(string bldid){
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Building_ID__c=bldid;
        pp.Effective_From__c= system.today();
        return pp;
    }
    public static Property__c getPropertyDetails(Integer propertyId){
        Property__c newProperty = new Property__c();
        newProperty.Property_ID__c  = propertyId ;
        newProperty.Property_Code__c    = 'VIR' ;
        newProperty.Property_Name__c    = 'VIRIDIS @ AKOYA OXYGEN' ;
        newProperty.District__c = 'AL YUFRAH 2' ;
        newProperty.AR_Transaction_Type__c  = 'INV VIR' ;
        newProperty.Penalty_Transaction_Type__c = 'DM-PENALTIES-VIR' ;
        newProperty.Brokerage_Distribution_Set__c   = '11600' ;
        newProperty.Sales_Commission_Dist_Set__c    = '11601' ;
        newProperty.Currency_Of_Sale__c = 'AED' ;
        newProperty.Signature_Col_Customer_Stmt__c  = 'Front Line Investment Management Co. LLC' ;
        return newProperty ; 
    }
    
    public static Campaign__c getCampaignDetails(){
        Campaign__c newCampaign = new Campaign__c();
        newCampaign.Marketing_Active__c = true ;
        newCampaign.Campaign_Name__c = 'Akoya Oxygen' ;
        newCampaign.Marketing_Start_Date__c = Date.today() ;
        newCampaign.Marketing_End_Date__c = Date.today()+7 ;
        newCampaign.Campaign_Location__c = 'Dubai';
        newCampaign.Start_Date__c = Date.today();
        newCampaign.End_Date__c = Date.today()+7 ;
        return newCampaign ;
    }
    
    public static User getPropertyConsultantUsers(String pcUserName){
         User userPC = new User(alias = 'test456', email=pcUserName,
                emailencodingkey='UTF-8', lastname='User 456', languagelocalekey='en_US',
                localesidkey='en_US', profileid = propertyConsultantProfile, country='United Arab Emirates',IsActive =true,
                timezonesidkey='America/Los_Angeles', username=pcUserName,Languages_Known__c='English;Arabic;Hindi;French',Date_of_Joining__c=Date.today().addDays(-2));      
        return userPC;
    }
    
    public static Inquiry__c getInquiryDetails(String recordTypeName,Integer inqNo){
        Id inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry.RecordTypeId = inquiryRecordTypeId ;
        newInquiry.First_Name__c = 'Test';
        newInquiry.Last_Name__c = 'Inquiry';
        newInquiry.Mobile_Phone_Encrypt__c = '05789088';
        newInquiry.Mobile_Phone__c = '05789088';
        newInquiry.Mobile_CountryCode__c = '0917';
        newInquiry.Email__c = 'test@mail.com';
        newInquiry.Preferred_Language__c = 'Arabic';
        newInquiry.Inquiry_Source__c = 'Social' ;
        newInquiry.Inquiry_Status__c = 'New' ;
        return newInquiry ;
    }
    
    public static Assigned_PC__c assignPCToCampaign(Id pcId,Id campaignId){
        Assigned_PC__c assignedPC = new Assigned_PC__c();
        assignedPC.Campaign__c = campaignId ;
        assignedPC.User__c = pcId ;
        assignedPC.Start_Date__c = Date.today() ;
        assignedPC.End_Date__c = Date.today() + 10 ;
        return assignedPC ;
    }
    
    public static Assigned_Property_User__c assignPCToProperty(Id pcId,Id propertyId){
        Assigned_Property_User__c assignPCandProperty = new Assigned_Property_User__c();
        assignPCandProperty.Associated_Property__c = propertyId ;
        assignPCandProperty.Assigned_User__c = pcId ;
        return assignPCandProperty ;
    }
    
    public static Inquiry_Score_Changes__c inquiryScoreChanges(String previous,String currentStatus){
        Inquiry_Score_Changes__c newInquiryStatusScore = new Inquiry_Score_Changes__c();
        newInquiryStatusScore.Name = previous+'>>'+currentStatus;
        newInquiryStatusScore.Current_Status__c =  currentStatus;
        newInquiryStatusScore.Inquiry_Previous_Status__c = previous;
        newInquiryStatusScore.Inquiry_Score__c = 'Warm';
        return newInquiryStatusScore ; 
    }
    
    public static Announcement__c createAnnouncement(Date startDate,Date endDate,boolean isActive,String tier,String agencyType){
        Announcement__c announcement = new Announcement__c();
        announcement.Title__c = 'Test Announcement';
        announcement.Description__c = 'This is a test announcement.';
        announcement.Start_Date__c = startDate;
        announcement.End_Date__c = endDate;
        announcement.Active__c = isActive;
        announcement.Agency_Tier__c = tier;
        announcement.Agency_Type__c = agencyType;
        return announcement;
    }
    
    public static Attachment createAttachment(Id parentId){
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=parentId;
        return attach;
    }
    
    public static Case__c createCases(){
        Case__c cases = new Case__c();
        cases.Status__c = 'New';
        cases.Case_Subject__c = 'Request for Site Viewing';
        cases.Case_Description__c = 'Test Case';
        return cases;
    } 
    
    public static Page_Flow__c createPageFlow(String name){
        Page_Flow__c pageFlow = new Page_Flow__c();
        pageFlow.Name = name;
        return pageFlow;
    }
    
    public static Campaign__c createCampaign(){
        Campaign__c campaign = new Campaign__c();
        campaign.Sales_Admin_Active__c = true;
        campaign.Marketing_Active__c = true;
        campaign.Credit_Control_Active__c = true;
        campaign.Campaign_Description__c = 'This is a test campaign';
        campaign.Campaign_Location__c = 'United Arab Emirates';
        campaign.Status__c = 'In Progress';
        campaign.Campaign_Name__c = 'Test';
        campaign.Start_Date__c=System.now().Date();
        campaign.End_Date__c = System.now().Date().addDays(10);
        campaign.Marketing_Start_Date__c = System.now().Date();
        campaign.Marketing_End_Date__c = System.now().Date().addDays(10);
        return campaign;
    }
    
    public static Assigned_Agent__c assignCampaignsToAgents(Date endDate,Date startDate,Id userId){
        Campaign__c campaign = createCampaign();
        insert campaign;
        
        System.debug('***campaign '+[SELECT Campaign_Name__c,End_Date__c,Start_Date__c,
                                         Campaign_Description__c,Campaign_Location__c,
                                         Status__c,Active__c
                                          FROM Campaign__c]);
        
        Assigned_Agent__c assignedAgents = new Assigned_Agent__c();
        assignedAgents.End_Date__c = endDate;
        assignedAgents.Start_Date__c = startDate;
        assignedAgents.User__c = userId;
        assignedAgents.Campaign__c = campaign.Id;
        return assignedAgents;
        
    }
    
    /*********************************************************************************************
    * @Description : Method to create Booking test records.                                      *
    * @Params      : List<Booking__c>                                                            *
    * @Return      : List<Booking__c>                                                            *
    *********************************************************************************************/
    public static List<Booking__c> createBookingRecords(List<Booking__c> Booking){
        List<Booking__c> createBookingList = new List<Booking__c>();
        Booking__c createBookingObject;
        for(Booking__c thisRecord : Booking){
            createBookingObject = new Booking__c();
            createBookingObject.Completed_Date__c =  thisRecord.Completed_Date__c != null ? thisRecord.Completed_Date__c : system.today();
            createBookingObject.Deal_SR__c = thisRecord.Deal_SR__c;
            createBookingObject.Booking_Channel__c = 'Office';
            createBookingObject.Status__c = 'New';
            createBookingObject.Unique_Key__c = 'BOOKING'+String.valueOf(System.now().millisecond());
            createBookingList.add(createBookingObject);             
        }   
        if(!createBookingList.isEmpty()){ 
            Database.insert(createBookingList);
        }
        system.debug('#### Booking Record Created = '+createBookingList);
        return createBookingList;
    }  
    
    /*********************************************************************************************
    * @Description : Method to create Booking Unit test records.                                 *
    * @Params      : List<Booking_Unit__c>                                                       *
    * @Return      : List<Booking_Unit__c>                                                       *
    *********************************************************************************************/
    public static List<Booking_Unit__c> createBookingUnitRecords(List<Booking_Unit__c> bookingUnitList){
        List<Booking_Unit__c> createBookingUnitList = new List<Booking_Unit__c>();
        Booking_Unit__c createBookingUnitObject;
        for(Booking_Unit__c thisRecord : bookingUnitList){
            createBookingUnitObject = new Booking_Unit__c();
            createBookingUnitObject.Booking__c = thisRecord.Booking__c;
            createBookingUnitObject.Inventory__c = thisRecord.Inventory__c;
            createBookingUnitObject.Unit_Selling_Price__c = thisRecord.Unit_Selling_Price__c != null ? thisRecord.Unit_Selling_Price__c : 15000000.00;
            createBookingUnitObject.Requested_Price__c = thisRecord.Requested_Price__c != null ? thisRecord.Requested_Price__c : 10000000.00;
            createBookingUnitObject.Requested_Token_Amount__c = thisRecord.Requested_Token_Amount__c != null ? thisRecord.Requested_Token_Amount__c : 40000.00;
            createBookingUnitObject.Payment_Method__c = thisRecord.Payment_Method__c != null ? thisRecord.Payment_Method__c : 'Online_Payment';
            createBookingUnitObject.Online_Payment_Party__c = thisRecord.Online_Payment_Party__c != null ? thisRecord.Online_Payment_Party__c : 'Third Party';
            createBookingUnitObject.No_of_parking__c = thisRecord.No_of_parking__c != null ? thisRecord.No_of_parking__c : 1.00;
            createBookingUnitObject.Primary_Buyer_s_Email__c = thisRecord.Primary_Buyer_s_Email__c != null ? thisRecord.Primary_Buyer_s_Email__c : 'test@test.com';
            createBookingUnitObject.Primary_Buyer_s_Name__c = thisRecord.Primary_Buyer_s_Name__c != null ? thisRecord.Primary_Buyer_s_Name__c : 'Damac Test';
            createBookingUnitObject.Primary_Buyer_Country__c = thisRecord.Primary_Buyer_Country__c != null ? thisRecord.Primary_Buyer_Country__c : 'United Arab Emirates';
            createBookingUnitObject.Primary_Buyer_s_Nationality__c = thisRecord.Primary_Buyer_s_Nationality__c != null ? thisRecord.Primary_Buyer_s_Nationality__c : 'Emirati';
            createBookingUnitObject.Unique_Key__c = 'BOOKING_UNIT'+String.valueOf(System.now().millisecond()); 
            createBookingUnitList.add(createBookingUnitObject);             
        }   
        if(!createBookingUnitList.isEmpty()){ 
            Database.insert(createBookingUnitList);
        }
        system.debug('#### Booking Unit Record Created = '+createBookingUnitList);
        return createBookingUnitList;
    }  
    
    /*********************************************************************************************
    * @Description : Method to create buyer test records.                                        *
    * @Params      : List<Buyer__c>                                                              *
    * @Return      : List<Buyer__c>                                                              *
    *********************************************************************************************/
    public static List<Buyer__c> createBuyerRecords(List<Buyer__c> bookingUnitList){
        List<Buyer__c> createBuyersList = new List<Buyer__c>();
        Buyer__c createBuyerRecord;
        for(Buyer__c thisRecord : bookingUnitList){
            createBuyerRecord = new Buyer__c();
            createBuyerRecord.Buyer_Type__c =  'Individual';
            createBuyerRecord.Address_Line_1__c =  'Ad1';
            createBuyerRecord.Email__c = 'test@test.com';
            createBuyerRecord.Booking__c = thisRecord.Booking__c;
            createBuyerRecord.Unique_Key__c = 'BUYER'+String.valueOf(System.now().millisecond()); 
            createBuyerRecord.Title__c = thisRecord.Title__c != null ? thisRecord.Title__c : 'MR.';
            createBuyerRecord.Title_Arabic__c = thisRecord.Title_Arabic__c != null ? thisRecord.Title_Arabic__c : 'الأميرة';
            createBuyerRecord.First_Name__c = thisRecord.First_Name__c != null ? thisRecord.First_Name__c : 'Damac';
            createBuyerRecord.First_Name_Arabic__c = thisRecord.First_Name_Arabic__c != null ? thisRecord.First_Name_Arabic__c : 'Damac';
            createBuyerRecord.Last_Name__c = thisRecord.Last_Name__c != null ? thisRecord.Last_Name__c : 'Test';
            createBuyerRecord.Last_Name_Arabic__c = thisRecord.Last_Name_Arabic__c != null ? thisRecord.Last_Name_Arabic__c : 'Test';
            createBuyerRecord.Address__c = thisRecord.Address__c != null ? thisRecord.Address__c : 'Test Location';
            createBuyerRecord.Address_Arabic__c = thisRecord.Address_Arabic__c != null ? thisRecord.Address_Arabic__c : 'Test Location';
            createBuyerRecord.City__c = thisRecord.City__c != null ? thisRecord.City__c : 'Dubai';
            createBuyerRecord.City_Arabic__c = thisRecord.City_Arabic__c != null ? thisRecord.City_Arabic__c : 'Dubai'; 
            createBuyerRecord.Country__c = thisRecord.Country__c != null ? thisRecord.Country__c : 'United Arab Emirates';
            createBuyerRecord.Country_Arabic__c = thisRecord.Country_Arabic__c != null ? thisRecord.Country_Arabic__c : 'United Arab Emirates';
            createBuyerRecord.Phone__c = thisRecord.Phone__c != null ? thisRecord.Phone__c : '557788996';
            createBuyerRecord.Phone_Country_Code__c = thisRecord.Phone_Country_Code__c != null ? thisRecord.Phone_Country_Code__c : 'United Arab Emirates: 00971';
            createBuyerRecord.Organisation_Name__c = thisRecord.Organisation_Name__c != null ? thisRecord.Organisation_Name__c : 'Damac Limited';
            createBuyerRecord.Organisation_Name_Arabic__c = thisRecord.Organisation_Name_Arabic__c != null ? thisRecord.Organisation_Name_Arabic__c : 'Damac Limited';
            createBuyerRecord.CR_Number__c = thisRecord.CR_Number__c != null ? thisRecord.CR_Number__c : '786';
            createBuyerRecord.CR_Registration_Expiry_Date__c = thisRecord.CR_Registration_Expiry_Date__c != null ? thisRecord.CR_Registration_Expiry_Date__c : '01/01/2100';
            createBuyerRecord.CR_Registration_Place__c = thisRecord.CR_Registration_Place__c != null ? thisRecord.CR_Registration_Place__c : 'United Arab Emirates';
            createBuyerRecord.CR_Registration_Place_Arabic__c = thisRecord.CR_Registration_Place_Arabic__c != null ? thisRecord.CR_Registration_Place_Arabic__c : 'United Arab Emirates'; 
            createBuyerRecord.Date_of_Birth__c = thisRecord.Date_of_Birth__c != null ? thisRecord.Date_of_Birth__c : string.valueof(system.today().addyears(-30));
            createBuyerRecord.Nationality__c = thisRecord.Nationality__c != null ? thisRecord.Nationality__c : 'Indian';
            createBuyerRecord.Nationality_Arabic__c = thisRecord.Nationality_Arabic__c != null ? thisRecord.Nationality_Arabic__c : 'UAE';
            createBuyerRecord.Passport_Expiry_Date__c = thisRecord.Passport_Expiry_Date__c != null ? thisRecord.Passport_Expiry_Date__c : string.valueof(system.today().addyears(20));
            createBuyerRecord.Passport_Number__c = thisRecord.Passport_Number__c != null ? thisRecord.Passport_Number__c : 'X1234567';
            createBuyerRecord.Place_of_Issue__c = thisRecord.Place_of_Issue__c != null ? thisRecord.Place_of_Issue__c : 'Dubai';
            createBuyerRecord.Place_of_Issue_Arabic__c = thisRecord.Place_of_Issue_Arabic__c != null ? thisRecord.Place_of_Issue_Arabic__c : 'Dubai';
            createBuyersList.add(createBuyerRecord);             
        }   
        if(!createBuyersList.isEmpty()){ 
            Database.insert(createBuyersList);
        }
        system.debug('#### Booking Unit Record Created = '+createBuyersList);
        return createBuyersList;
    } 
    
    
    /*********************************************************************************************
    * @Description : Method to create Account test records.                                      *
    * @Params      : List<Account>                                                               *
    * @Return      : List<Account>                                                               *
    *********************************************************************************************/
    public static List<Account> createAccountRecords(List<Account> accountList){
        List<Account> createAccountList = new List<Account>();
        Account createAccountObject;
        Integer counter = 0;
        for(Account thisRecord : accountList){
            createAccountObject = new Account();
            createAccountObject.Name = 'Test Account - '+String.valueOf(counter);
            createAccountObject.RecordTypeId = thisRecord.RecordTypeId != null ? thisRecord.RecordTypeId : accRecordTypeId;
            createAccountObject.Eligible_For_Tier_Program__c = thisRecord.Eligible_For_Tier_Program__c != null ? thisRecord.Eligible_For_Tier_Program__c : false;
            createAccountList.add(createAccountObject);   
            counter++;          
        }   
        if(!createAccountList.isEmpty()){ 
            Database.insert(createAccountList);
        }
        system.debug('#### Account Record Created = '+createAccountList);
        return createAccountList;
    }  
    
     public static Agent_Commission__c createAgentCommission(Id accountId, Date registrationDate,Date checkDate){
        Agent_Commission__c agentCommission = new Agent_Commission__c();
        agentCommission.Agency__c = accountId;
        agentCommission.Amount__c = 500000000;
        agentCommission.Registration_Date__c = registrationDate;
        agentCommission.Check_Date__c = checkDate;
        agentCommission.Internal_Verification__c = 'Y';
       
        return agentCommission;
    }
    
    public static NSIBPM__Service_Request__c createBookingServiceRequest(Boolean dpOk,Boolean docOk,Id accountId,Date registrationDate){
        NSIBPM__Service_Request__c serviceRequest = new NSIBPM__Service_Request__c();
        serviceRequest.DP_ok__c = dpOk;
        serviceRequest.Doc_ok__c = docOk;
        serviceRequest.Agency__c = accountId;
        serviceRequest.Registration_Date__c = registrationDate;
        insert serviceRequest;
        return serviceRequest;
        
    }
    
    public static Booking__c createBookingRecords(Id AccountId,NSIBPM__Service_Request__c SR,Decimal Amount,String Status){
        
        Booking__c booking = new Booking__c();
        booking.Deal_SR__c = SR.Id;
        booking.Status__c = Status;
        booking.Account__c = AccountId;
        insert booking;
        return booking;
    }
    
    public static Property__c insertProperties(){
        Property__c property = getPropertyDetails(123);
        insert property;
        return property;
    }
    
    public static void createInventoryUser(Property__C property){
        Inventory_User__c inventoryUser = new Inventory_User__c();
        Address__c address = getAddressDetails(345);
        insert address;
        
        Location__c location = new Location__c();
        location.Building_Name__c = 'abc';
        location.Property_Name__c = property.ID;
        location.Address_ID__c = String.valueOf(address.Address_ID__c);
        location.Location_ID__c = 'abc';
        
        insert location;
        Inventory__c inventory = getInventoryDetails('INV-123','bld-1','flr-1',address.Address_ID__c.intValue(),(Integer)property.Property_ID__c);
        inventory.Status__c = 'Released';
        inventory.Unit_Type__c = 'Unit';
        inventory.Unit_Location__c = location.ID;
      
        insert inventory;
        
        inventoryUser.Inventory__c = inventory.Id;
        insert inventoryUser;
    }
    
    public static Notification__c createNotification(Id accountId,Id contactId){
        Notification__c notification = new Notification__C();
        notification.Account__c = accountId;
        notification.Contact__c = contactId;
        notification.Description__c = 'Your passport is getting expired in a week. Please update.';
        notification.Title__c = 'Passport Expiry';
        notification.Active__c = true;
        insert notification;
        return notification;
    }

    /*********************************************************************************************
    * @Description : Method to create test SR template records.                                  *
    * @Params      : List<NSIBPM__SR_Template__c>                                                * 
    * @Return      : List<NSIBPM__SR_Template__c>                                                *
    *********************************************************************************************/
    public static List<NSIBPM__SR_Template__c> createTestTemplateRecords(List<NSIBPM__SR_Template__c> templateList){
        List<NSIBPM__SR_Template__c> createTemplateList = new List<NSIBPM__SR_Template__c>();
        NSIBPM__SR_Template__c TemplateObject;
        Integer userNumber  = 0;
        try{
            for(NSIBPM__SR_Template__c thisRecord : TemplateList){
                templateObject = new NSIBPM__SR_Template__c();
                templateObject.Name = thisRecord.Name != null ? thisRecord.Name : 'Agent Registration';
                templateObject.NSIBPM__SR_RecordType_API_Name__c = thisRecord.NSIBPM__SR_RecordType_API_Name__c != null ? thisRecord.NSIBPM__SR_RecordType_API_Name__c : 'Agent Registration';
                templateObject.NSIBPM__Active__c = thisRecord.NSIBPM__Active__c != null ? thisRecord.NSIBPM__Active__c : true;
                templateObject.NSIBPM__Menu__c = thisRecord.NSIBPM__Menu__c != null ? thisRecord.NSIBPM__Menu__c : 'My Pay & Benefits';
                templateObject.NSIBPM__Active__c = true;
                templateObject.NSIBPM__Available_for_menu__c = true;
                templateObject.NSIBPM__Sub_menu_section__c = thisRecord.NSIBPM__Sub_menu_section__c;
                createTemplateList.add(templateObject);             
            }   
            if(!createTemplateList.isEmpty()){ 
                Database.insert(createTemplateList);
            }
            system.debug('#### Template Record Created = '+createTemplateList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createTemplateList;
    }  

     /*********************************************************************************************
    * @Description : Method to create SR Status records.                                         *
    * @Params      : List<NSIBPM__SR_Status__c>                                                  *
    * @Return      : List<NSIBPM__SR_Status__c>                                                  *
    *********************************************************************************************/
    public static List<NSIBPM__SR_Status__c> createSrStatusRecords(List<NSIBPM__SR_Status__c> srStatusList){
        List<NSIBPM__SR_Status__c> createSrStatusList = new List<NSIBPM__SR_Status__c>();
        NSIBPM__SR_Status__c srStatusObject;
        try{
            for(NSIBPM__SR_Status__c thisRecord : srStatusList){
                srStatusObject = new NSIBPM__SR_Status__c();
                srStatusObject.Name = thisRecord.NSIBPM__Code__c != null ? thisRecord.NSIBPM__Code__c : 'SUBMITTED';
                srStatusObject.NSIBPM__Code__c = thisRecord.NSIBPM__Code__c != null ? thisRecord.NSIBPM__Code__c : 'SUBMITTED';
                srStatusObject.NSIBPM__DEV_Id__c = thisRecord.NSIBPM__DEV_Id__c;
                srStatusObject.NSIBPM__Type__c = thisRecord.NSIBPM__Type__c != null ? thisRecord.NSIBPM__Type__c : 'End';
                createSrStatusList.add(srStatusObject);             
            }   
            if(!createSrStatusList.isEmpty()){ 
                Database.insert(createSrStatusList);
            }
            system.debug('#### SR Status Record Created = '+createSrStatusList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createSrStatusList;
    }    

    /*********************************************************************************************
    * @Description : Method to create test Service Request records.                              *
    * @Params      : List<NSIBPM__Service_Request__c>                                            *
    * @Return      : List<NSIBPM__Service_Request__c>                                            *
    *********************************************************************************************/
    public static List<NSIBPM__Service_Request__c> createTestServiceRequestRecords(List<NSIBPM__Service_Request__c> serviceRequestList){
        List<NSIBPM__Service_Request__c> createserviceRequestList = new List<NSIBPM__Service_Request__c>();
        NSIBPM__Service_Request__c serviceRequestObject;
        Integer userNumber  = 0;
        try{
            for(NSIBPM__Service_Request__c thisRecord : serviceRequestList){
                serviceRequestObject = new NSIBPM__Service_Request__c();
                serviceRequestObject.NSIBPM__User__c = thisRecord.NSIBPM__User__c != null ? thisRecord.NSIBPM__User__c : UserInfo.getUserId();
                serviceRequestObject.NSIBPM__Email__c = thisRecord.NSIBPM__Email__c != null ? thisRecord.NSIBPM__Email__c : 'test@damac.ae';
                serviceRequestObject.NSIBPM__Send_SMS_to_Mobile__c = thisRecord.NSIBPM__Send_SMS_to_Mobile__c != null ? thisRecord.NSIBPM__Send_SMS_to_Mobile__c : '+971556670889';
                serviceRequestObject.NSIBPM__External_SR_Status__c = thisRecord.NSIBPM__External_SR_Status__c;
                serviceRequestObject.recordTypeId = thisRecord.recordTypeId; 
                serviceRequestObject.NSIBPM__SR_Template__c = thisRecord.NSIBPM__SR_Template__c;
                serviceRequestObject.Country_of_Sale__c = 'UAE;KSA';
                createserviceRequestList.add(serviceRequestObject);            
            }
            system.debug('#### createserviceRequestList = '+createserviceRequestList); 
            if(!createserviceRequestList.isEmpty()){
                Database.insert(createserviceRequestList);
            }
            system.debug('#### Service Request Record Created = '+createserviceRequestList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createserviceRequestList;
    } 

    /*********************************************************************************************
    * @Description : Method to get record type Id for the provided record type name.             *
    * @Params      : String                                                                      *
    * @Return      : Id                                                                          *
    *********************************************************************************************/
    public static Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
    }   

     /*********************************************************************************************
    * @Description : Method to create status records.                                            *
    * @Params      : List<NSIBPM__Status__c>                                                     *
    * @Return      : List<NSIBPM__Status__c>                                                     *
    *********************************************************************************************/
    public static List<NSIBPM__Status__c> createStatusRecords(List<NSIBPM__Status__c> statusList){
        List<NSIBPM__Status__c> createStatusList = new List<NSIBPM__Status__c>(); 
        NSIBPM__Status__c statusObject;
        try{
            Integer counter = 1;
            for(NSIBPM__Status__c thisRecord : statusList){
                statusObject = new NSIBPM__Status__c();
                statusObject.NSIBPM__Code__c = thisRecord.NSIBPM__Code__c != null ? thisRecord.NSIBPM__Code__c : 'PENDING';
                statusObject.Name = thisRecord.Name != null ? thisRecord.Name : 'PENDING';
                createStatusList.add(statusObject);    
                counter++;         
            }   
            if(!createStatusList.isEmpty()){ 
                Database.insert(createStatusList);
            }
            system.debug('#### Status Record Created = '+createStatusList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createStatusList;
    }   

    /*********************************************************************************************
    * @Description : Method to create test Step records.                                         *
    * @Params      : List<NSIBPM__Step__c>                                                       *
    * @Return      : List<NSIBPM__Step__c>                                                       *
    *********************************************************************************************/
    public static List<NSIBPM__Step__c> createTestStepRecords(List<NSIBPM__Step__c> stepsList){
        List<NSIBPM__Step__c> createStepsList = new List<NSIBPM__Step__c>();
        NSIBPM__Step__c stepObject;
        Integer userNumber  = 0;
        try{
            for(NSIBPM__Step__c thisRecord : stepsList){
                stepObject = new NSIBPM__Step__c();
                stepObject.NSIBPM__Step_No__c = thisRecord.NSIBPM__Step_No__c != null ? thisRecord.NSIBPM__Step_No__c : Decimal.valueOf(userNumber);
                stepObject.NSIBPM__SR__c = thisRecord.NSIBPM__SR__c;
                stepObject.NSIBPM__Status__c = thisRecord.NSIBPM__Status__c;
                stepObject.NSIBPM__SR_Step__c = thisRecord.NSIBPM__SR_Step__c;
                stepObject.NSIBPM__Summary__c = thisRecord.NSIBPM__Summary__c != null ? thisRecord.NSIBPM__Summary__c : 'Test_Step';
                stepObject.NSIBPM__Rejection_Reason__c = thisRecord.NSIBPM__Rejection_Reason__c != null ? thisRecord.NSIBPM__Rejection_Reason__c : 'Test Rejected';
                stepObject.NSIBPM__Start_Date__c = thisRecord.NSIBPM__Start_Date__c != null ? thisRecord.NSIBPM__Start_Date__c : system.today();
                stepObject.NSIBPM__Closed_Date__c = thisRecord.NSIBPM__Closed_Date__c != null ? thisRecord.NSIBPM__Closed_Date__c : system.today().addDays(7);
                if(thisRecord.OwnerId != null){
                    stepObject.OwnerId = thisRecord.OwnerId;
                }
                stepObject.NSIBPM__Step_Template__c = thisRecord.NSIBPM__Step_Template__c;
                createStepsList.add(stepObject);
                userNumber++;               
            }   
            if(!createStepsList.isEmpty()){ 
                Database.insert(createStepsList);
            }
            system.debug('#### Steps Record Created = '+createStepsList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createStepsList;
    } 

    /*********************************************************************************************
    * @Description : Method to create transition records.                                        *
    * @Params      : List<NSIBPM__Transition__c>                                                 *
    * @Return      : List<NSIBPM__Transition__c>                                                 *
    *********************************************************************************************/
    public static List<NSIBPM__Transition__c> createTransitionRecords(List<NSIBPM__Transition__c> transitionList){
        List<NSIBPM__Transition__c> createTransitionList = new List<NSIBPM__Transition__c>(); 
        NSIBPM__Transition__c transitionObject;
        try{
            Integer counter = 1;
            for(NSIBPM__Transition__c thisRecord : transitionList){
                transitionObject = new NSIBPM__Transition__c();
                transitionObject.NSIBPM__From__c = thisRecord.NSIBPM__From__c;
                transitionObject.NSIBPM__To__c = thisRecord.NSIBPM__To__c;
                transitionObject.NSIBPM__Transition_Code__c = thisRecord.NSIBPM__Transition_Code__c != null ? thisRecord.NSIBPM__Transition_Code__c : 'Test'+String.valueOf(counter);
                createTransitionList.add(transitionObject);    
                counter++;         
            }   
            if(!createTransitionList.isEmpty()){ 
                Database.insert(createTransitionList);
            }
            system.debug('#### Transition Record Created = '+createTransitionList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createTransitionList;
    }   

    /*********************************************************************************************
    * @Description : Method to create step transition records.                                   *
    * @Params      : List<NSIBPM__Step_Transition__c>                                            *
    * @Return      : List<NSIBPM__Step_Transition__c>                                            *
    *********************************************************************************************/
    public static List<NSIBPM__Step_Transition__c> createStepTransitionRecords(List<NSIBPM__Step_Transition__c> stepTransitionList){
        List<NSIBPM__Step_Transition__c> createStepTransitionList = new List<NSIBPM__Step_Transition__c>(); 
        NSIBPM__Step_Transition__c stepTransitionObject;
        try{
            Integer counter = 1;
            for(NSIBPM__Step_Transition__c thisRecord : stepTransitionList){
                stepTransitionObject = new NSIBPM__Step_Transition__c();
                stepTransitionObject.NSIBPM__SR_Step__c = thisRecord.NSIBPM__SR_Step__c;
                stepTransitionObject.NSIBPM__Transition__c = thisRecord.NSIBPM__Transition__c;
                stepTransitionObject.NSIBPM__SR_Status_Internal__c = thisRecord.NSIBPM__SR_Status_Internal__c;
                stepTransitionObject.NSIBPM__SR_Status_External__c = thisRecord.NSIBPM__SR_Status_External__c;
                stepTransitionObject.NSIBPM__SR_Step__c = thisRecord.NSIBPM__SR_Step__c; 
                createstepTransitionList.add(stepTransitionObject);    
                counter++;         
            }   
            if(!createStepTransitionList.isEmpty()){ 
                Database.insert(createStepTransitionList);
            }
            system.debug('#### Step Transition Record Created = '+createStepTransitionList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createStepTransitionList;
    }   

    /*********************************************************************************************
    * @Description : Method to create group records.                                             *
    * @Params      : List<Group>                                                                 *
    * @Return      : List<Group>                                                                 *
    *********************************************************************************************/
    public static List<Group> createGroupRecords(List<Group> groupsList){
        List<Group> createGroupsList = new List<Group>();
        Group groupObject;
        try{
            for(Group thisRecord : groupsList){
                groupObject = new Group();
                groupObject.Name = thisRecord.Name != null ? thisRecord.Name : 'Test Group Queue';
                groupObject.Type = thisRecord.Type != null ? thisRecord.Type : 'Queue';
                createGroupsList.add(groupObject);              
            }   
            if(!createGroupsList.isEmpty()){ 
                Database.insert(createGroupsList);
            }
            system.debug('#### Groups Record Created = '+createGroupsList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createGroupsList;
    } 

    /*********************************************************************************************
    * @Description : Method to create test user data.                                            *
    * @Params      : List<User>                                                                  *
    * @Return      : List<User>                                                                  *
    *********************************************************************************************/
    public static List<User> createTestUserRecords(List<User> userList){
        List<User> createUserList = new List<User>();
        
        User userObject;
        Integer userNumber  = 0;
        try{
            Profile standardProfile = [SELECT Id FROM profile WHERE Name = 'Standard User'];
            UserRole groupHsseRole = [SELECT Id FROM UserRole WHERE Name = 'HOS1'];
            for(User thisRecord : userList){
              String milli = String.valueOf(System.now().millisecond());
                String testName = 'standarduser'+userNumber;
                userObject = new User();
                userObject.alias = thisRecord.alias != null ? thisRecord.alias : 'standt'+userNumber+milli;
                userObject.alias = userObject.alias.subString(0, 8);
                userObject.email = thisRecord.email != null ? thisRecord.email : testName+'@alfuttaim.ae';
                userObject.emailencodingkey = 'UTF-8';
                userObject.lastname = thisRecord.lastname != null ? thisRecord.lastname : testName;
                userObject.languagelocalekey = 'en_US';
                userObject.localesidkey = 'en_US';
                userObject.profileId = thisRecord.profileId != null ? thisRecord.profileId : standardProfile.Id;
                userObject.timezonesidkey = 'America/Los_Angeles';
                userObject.username = testName+userNumber+milli+'@alfuttaim.ae';
                userObject.ManagerId = thisRecord.ManagerId;
                userObject.UserRoleId = groupHsseRole.Id;
                userNumber++; 
                createUserList.add(userObject);                            
            }   
            if(!createUserList.isEmpty()){
                Database.insert(createUserList);
                
            }          
            system.debug('#### User Record Created = '+createUserList);
        }catch(Exception ex){
            system.debug('#### Error at line number = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
        return createUserList;
    } 

    public static List<NSIBPM__Document_Master__c> createSRDocMasterRecords(integer n) {
        List<NSIBPM__Document_Master__c> DM_List = new List<NSIBPM__Document_Master__c>();
        NSIBPM__Document_Master__c DM;
        for (Integer i = 0; i < n; i++) {
          Dm = new NSIBPM__Document_Master__c();
          Dm.Name = 'Test DM_' + i;
          Dm.NSIBPM__Code__c = 'CODE_' + i;
          Dm.NSIBPM__Document_Type_Code__c = 'DOCTYPE_CODE_' + i;
          DM_List.add(DM);
        }
        insert DM_List;
        return DM_List;
  }

  public static List<NSIBPM__SR_Doc__c> createSRDocRecords(List<NSIBPM__Service_Request__c> SR_List, List<NSIBPM__Document_Master__c> DM_List) {
    List<NSIBPM__SR_Doc__c> SRDoc_List = new List<NSIBPM__SR_Doc__c>();
    for (NSIBPM__Service_Request__c SR : SR_List) {
      NSIBPM__SR_Doc__c SRDoc;
      for (Integer i = 0; i < DM_List.Size(); i++) {
        SRDoc = new NSIBPM__SR_Doc__c();
        SRDoc.Name = 'Test' + i;
        SRDoc.NSIBPM__Document_Master__c = DM_List[i].Id;
        SRDoc.NSIBPM__Service_Request__c = SR.Id;
        SRDoc_List.add(SRDoc);
      }
    }

    insert SRDoc_List;
    return SRDoc_List;
  }

  public static Page_Flow__c createPageFlow(){
        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Agent Registration';
        objPF.Master_Object__c = 'NSIBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = 'Agent_Registration';
        return objPF;
  }

  public static Page__c createPageForPageFlow(String pageAPI,Id pageFlowId,Integer order){
        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = order;
        objPg.What_Id__c = 'NSIBPM__Service_Request__c';
        objPg.Render_By_Default__c = true;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = pageAPI ;
        objPg.Page_Flow__c = pageFlowId;
        return objPg;
  }

  public static Section__c createSection(String sectionType,Integer order,Id pageFlowId){
        Section__c objSec = new Section__c();
        objSec.Page__c = pageFlowId;
        objSec.Name = 'Page1 Section1';
        objSec.Default_Rendering__c = true;
        objSec.Layout__c = '1';
        objSec.Section_Description__c = 'Test';
        objSec.Order__c = order;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = sectionType;
        return objSec;
  }

  public static Section_Detail__c createSectionDetail(Id secId,String fieldAPIName,String componentType){
        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = secId;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'componentType';
        objSecDet.Object_Name__c = 'NSIBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = fieldAPIName;
        objSecDet.Render_By_Default__c = true;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        return objSecDet;
  }

  public static Section_Detail__c createSectionButton(Id secId,String componentType){
        Section_Detail__c SaveBtn = new Section_Detail__c();
        SaveBtn.Section__c = secId;
        SaveBtn.Order__c = 3;
        SaveBtn.Button_Position__c = 'Center';
        SaveBtn.Navigation_Directions__c = 'Previous';
        SaveBtn.Render_By_Default__c = true;
        SaveBtn.Component_Type__c = 'Command Button';
        SaveBtn.Component_Label__c = 'Client';
        SaveBtn.Cancel_Request__c = true;
        return SaveBtn;
  }
  
  public static Guided_Sales__c createGuidedSales(ID inquiryId){
        Guided_Sales__c newGuidedSales = new Guided_Sales__c(Inquiry__c = inquiryId,City__c = 'Dubai',
                                                            Master_Development__c='Damac Executive Heights',
                                                            Project__c='Damac Executive Heights');
        
        return newGuidedSales;
  }
  
  public static Campaign_Inventory__c createCampaignInvnetory(ID campId, ID inventoryID){
        Campaign_Inventory__c camInv = new Campaign_Inventory__c(Inventory__c = inventoryID,Campaign__c = campId);
        
        return camInv;
  }
  
  public static Promotion__c createPromotion(ID campId,String campTitle){
        Promotion__c promotion = new Promotion__c(Campaign__c = campId,End_Date__c = Date.today().addDays(7),Promotion_Description__c = 'test Promotions',Promotion_Title__c = campTitle,Start_Date__c = Date.today().addDays(-5));
        
        return promotion;
  }
  
  public static Team_Building__c createTeamBuilding(String lcoation,String project,String agencyTeam){
    Team_Building__c teamBuilding = new Team_Building__c();

    teamBuilding.Start_Date__c = Date.today();
    teamBuilding.End_Date__c = Date.today().addDays(15);
    teamBuilding.Location__c = lcoation;
    teamBuilding.Project__c = project;
    teamBuilding.Unique_Key__c = agencyTeam+'###'+lcoation;
    teamBuilding.Agency_or_Group_Id__c = agencyTeam;

    return teamBuilding;

  }
}// End of class.