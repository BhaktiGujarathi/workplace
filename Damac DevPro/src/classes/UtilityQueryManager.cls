/**************************************************************************************************
* Name               : UtilityQueryManager                                                        *
* Description        : This is a utility class to manage SOQL queries.                            *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         17/01/2017                                                              *
**************************************************************************************************/
public class UtilityQueryManager {  

  public static Integer unreadNotificationCount{set;get;}
  public static boolean noAnnounements{set;get;}
  public static Decimal totalCommissionAmount{set;get;}
  public static Decimal totalUnitPrice{set;get;}
  
  /*********************************************************************************************
    * @Description : Method to get campaign details related to the logged in user.               *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, Campaign__c>                                                        *
    *********************************************************************************************/ 
    @TestVisible private static Map<Id, Campaign__c> getUsersCampaignDetails(Set<Id> userIdsSet){
        Map<Id, Campaign__c> userCampaignMap = new Map<Id, Campaign__c>();
        for(Campaign__c thisCampaign : [SELECT Id FROM Campaign__c WHERE Id IN: userIdsSet]){
            userCampaignMap.put(thisCampaign.Id, thisCampaign);
        }   
        return userCampaignMap;
    }
    
  /*********************************************************************************************
    * @Description : Method to get query and get sharing records.                                *
    * @Params      : String                                                                      *
    * @Return      : Map<String, Set<String>>                                                    *
    *********************************************************************************************/
    public static Map<String, Set<String>> getObjectRecord(String objectName, Set<Id> userIdsSet){
      Map<String, Set<String>> ownerRecordMap = new Map<String, Set<String>>(); 
      String sharingQuery = 'SELECT Id, OwnerId FROM '+objectName+' WHERE OwnerId IN :userIdsSet LIMIT 50000';  
      for(SObject thisRecord : Database.query(sharingQuery)){
      if(ownerRecordMap.containsKey(String.valueOf(thisRecord.get('OwnerId')))){
        ownerRecordMap.get(String.valueOf(thisRecord.get('OwnerId'))).add(String.valueOf(thisRecord.get('Id')));    
      }else{
        ownerRecordMap.put(String.valueOf(thisRecord.get('OwnerId')), new Set<String>{String.valueOf(thisRecord.get('Id'))}); 
      }
      }
      return ownerRecordMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get query and get sharing records.                                *
    * @Params      : String                                                                      *
    * @Return      : List<SObject>                                                               *
    *********************************************************************************************/
    public static List<SObject> getSharingRecord(String objectName, Set<String> parentIdSet){
      String sharingObjectName;
      if(objectName.endsWithIgnoreCase('__c')){
      sharingObjectName = objectName.substringBefore('__c')+'__share';    
    }else{
      sharingObjectName = objectName+'share'; 
    }
      String sharingQuery = 'SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel FROM '+sharingObjectName+' WHERE ParentId IN :parentIdSet LIMIT 50000';  
      return Database.query(sharingQuery);
    }
  /*********************************************************************************************
    * @Description : Method to get Users child users detail.                                     *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, User>                                                               *
    *********************************************************************************************/
    public static Map<Id, User> getUserChildDetails(Set<Id> UsersIdSet){
        Map<Id, User> childUserMap = new Map<Id, User>();
        for(User thisUser : [SELECT Id, Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, 
                                    Manager.Manager.Manager.ManagerId, Manager.Manager.Manager.Manager.ManagerId,
                                    Leave_Type__c, Leave_Start_Date__c, Leave_End_Date__c, Leave_Reason__c
                              FROM User 
                              WHERE (ManagerId IN: UsersIdSet OR 
                                   Manager.ManagerId IN: UsersIdSet OR
                                     Manager.Manager.ManagerId IN: UsersIdSet OR 
                                     Manager.Manager.Manager.ManagerId IN: UsersIdSet) AND
                                     isActive = true]){
            childUserMap.put(thisUser.Id, thisUser);
        }
        return childUserMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get Users manager detail.                                         *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, User>                                                               *
    *********************************************************************************************/
    public static Map<Id, User> getUserManagerDetails(Set<Id> userIdSet){
        Map<Id, User> userDetailsMap = new Map<Id, User>();
        for(User thisUser : [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, 
                                     Manager.Manager.Manager.ManagerId
                              FROM User WHERE Id IN: userIdSet]){
            userDetailsMap.put(thisUser.Id, thisUser);  
        }   
        return userDetailsMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get user records sharing data.                                    *
    * @Params      : Map<Id, User>                                                               *
    * @Return      : Map<Id, List<UserShare>>                                                    *
    *********************************************************************************************/
    public static Map<Id, List<UserShare>> getUserShareMap(Set<Id> userIdSet){
        Map<Id, List<UserShare>> userShareMap = new Map<Id, List<UserShare>>();
        for(UserShare thisShareRecord : [SELECT Id, UserId, UserOrGroupId, RowCause, UserAccessLevel 
                                         FROM UserShare 
                                         WHERE UserId IN: userIdSet AND RowCause = 'Manual']){
            if(userShareMap.containsKey(thisShareRecord.UserOrGroupId)){
                userShareMap.get(thisShareRecord.UserOrGroupId).add(thisShareRecord);   
            }else{
                userShareMap.put(thisShareRecord.UserOrGroupId, new List<UserShare>{thisShareRecord});      
            }                                   
        }
        return userShareMap;
    }

    /*********************************************************************************************
    * @Description : Method to get user notifications in portal based on user role               *                      
    * @Params      : String                                                                           *
    * @Return      : List<Notification__c>                                                                          *
    *********************************************************************************************/
    public static List<Notification__c> getNotifications(String condition){
      List<Notification__c> notificationList = new List<Notification__c>();
      unreadNotificationCount = 0;

      String query = 'SELECT id,Title__c,Short_Description__c,Description__c,Read__c,CreatedDate '+
                              ' FROM Notification__c WHERE '+condition;
      system.debug(query);
      for(Notification__c thisNotification:Database.query(query)){
        if(!thisNotification.Read__c){
          unreadNotificationCount ++;
        }

        notificationList.add(thisNotification);
      }
      return notificationList; 
    }

    /*********************************************************************************************
    * @Description : Method to get notification content based on notification id                 *                      
    * @Params      : String                                                                            *
    * @Return      : Notification__c                                                                           *
    *********************************************************************************************/
    public static Notification__c getNotificationDescription(String notificationId){
      Notification__c notification = new Notification__c();
      for(Notification__c thisNotification:[SELECT id,Title__c,Short_Description__c,Description__c,Read__c
                                          FROM Notification__c
                                          WHERE id =: notificationId AND Active__c  =:true 
                                          LIMIT 1]){
        notification = thisNotification;
      }
      return notification; 
    }

    /*********************************************************************************************
    * @Description : Method to update the notification as read                                   *                      
    * @Params      : String                                                                          *
    * @Return      : void                                                                           *
    *********************************************************************************************/
    public static void markNotificationAsRead(String notificationId){
      
      try{
        Notification__c notification = new Notification__c(id=notificationId);
        notification.Read__c = true;
        update notification;
      } 
      catch(Exception ex){
        system.debug('DB update::UtilityQueryManager::markNotificationAsRead::'+ex.getMessage());
      }
    }

    /*********************************************************************************************
    * @Description : Method to get contact for current user                                      *                      
    * @Params      : none                                                                          *
    * @Return      : Contact                                                                          *
    *********************************************************************************************/
   public static Contact getContactInformation(){
      Contact contactInfo = null;
      for(User thisUser:[SELECT ContactID,Contact.Agent_Representative__c,
                          Contact.Authorised_Signatory__c,Contact.Owner__c,
                          Contact.Portal_Administrator__c,Contact.AccountID 
                          FROM User WHERE id=: UserInfo.getUserId() LIMIT 1]){
        contactInfo= new Contact(id=thisUser.ContactID);
        contactInfo.Agent_Representative__c = thisUser.Contact.Agent_Representative__c;
        contactInfo.Authorised_Signatory__c = thisUser.Contact.Authorised_Signatory__c;
        contactInfo.Owner__C = thisUser.Contact.Owner__c;
        contactInfo.Portal_Administrator__c = thisUser.Contact.Portal_Administrator__c;
        contactInfo.AccountID = thisUser.Contact.AccountID;
      }
      return contactInfo; 
    }

    /*********************************************************************************************
    * @Description : Method to get account id for current user                                     *                      
    * @Params      : none                                                                          *
    * @Return      : Contact                                                                          *
    *********************************************************************************************/
    public static Id getAccountId(){
      Id accountId = null;
      for(User thisUser:[SELECT ContactID,Contact.AccountId FROM User WHERE id=: UserInfo.getUserId() LIMIT 1]){
        accountId = thisUser.Contact.AccountID;
      }
      return accountId; 
    }

    /*********************************************************************************************
    * @Description : Method to get account id for current user                                     *                      
    * @Params      : none                                                                          *
    * @Return      : Contact                                                                          *
    *********************************************************************************************/
    public static Account getAccountInformation(Id accountID){

      for(Account thisAccount:[SELECT Agency_Tier__c,Id,Eligible_For_Tier_Program__c from Account WHERE Id=:accountID]){
        return thisAccount;
      }
      return null;
    }


    /*********************************************************************************************
    * @Description : Get the latest announcement                                               *                      
    * @Params      : none                                                                      *
    * @Return      : Announcement__c                                                                   *
    *********************************************************************************************/
    public static Announcement__c getLatestAnnouncement(Account account){
      Announcement__c announcement = new Announcement__c();
      noAnnounements = true;
      for(Announcement__c thisAnnouncement:[SELECT id,Title__c,Description__c, Active__c,Header__c,
                                        Footer__c FROM Announcement__c 
                                    WHERE (Agency_Type__c = 'Corporate' OR Agency_Type__c = 'All') AND Active__c = true
                                            AND (Agency_Tier__c=:account.Agency_Tier__c OR Agency_Tier__c='All') 
                                            AND End_Date__c>=TODAY
                                  ORDER BY Start_Date__c DESC LIMIT 1]){
        announcement= thisAnnouncement;
        noAnnounements = false;
      }
      return announcement;  
    }

    /*********************************************************************************************
    * @Description : Get all the annoucements                                              *                      
    * @Params      : none                                                                      *
    * @Return      : List<Announcement__c>                                                                  *
    *********************************************************************************************/
    public static List<Announcement__c> getAllAnnouncements(Account account){
      List<Announcement__c> announcementList = new List<Announcement__c>();
      for(Announcement__c thisAnnouncement:[SELECT id,Title__c,Description__c, Active__c,Header__c,
                                            Footer__c,Start_Date__c,End_Date__c FROM Announcement__c 
                                            WHERE (Agency_Type__c = 'Corporate' OR Agency_Type__c = 'All')
                                            AND Active__c = true
                                            AND (Agency_Tier__c=:account.Agency_Tier__c 
                                            OR Agency_Tier__c='All') 
                                            AND End_Date__c>=TODAY
                                            ORDER BY Start_Date__c DESC]){
        announcementList.add(thisAnnouncement);
      }
      return announcementList; 
    }

    /*********************************************************************************************
    * @Description : Get the latest campaigns                                          *                      
    * @Params      : none                                                                      *
    * @Return      :                                                                   *
    *********************************************************************************************/
    public static Assigned_Agent__c getLatestCampaign(){
      Assigned_Agent__c latestCampaign = new Assigned_Agent__c();
      for(Assigned_Agent__c thisCampaign:[SELECT Campaign_Name__c,End_Date__c,Start_Date__c,Campaign__r.Active__c,
                                          Campaign__r.Status__c
                                          FROM Assigned_Agent__c 
                                          WHERE 
                                          End_Date__c >=TODAY
                                          AND Campaign__r.Active__c= true
                                          AND User__c =: UserInfo.getUserId() 
                                          AND Campaign__r.Status__c IN('Planned','In Progress')
                                          ORDER BY Start_Date__c ASC limit 1]){
        
        latestCampaign = thisCampaign;
      }
      system.debug('***Latest Campaign'+latestCampaign);
      return latestCampaign; 
    }

    /*********************************************************************************************
    * @Description : Get the all the project types from inventory object                                          *                      
    * @Params      : none                                                                      *
    * @Return      : List<String>                                                                  *
    *********************************************************************************************/
    public static List<String> getAllProjectTypes(){

      List<String> projectType = new List<String>();
      for(AggregateResult thisType:[SELECT Unit_Type__c 
                                    FROM Inventory__c 
                                    WHERE Unit_Type__c != null
                                    AND Status__c = 'Released' 
                                    GROUP BY Unit_Type__c ]){
                  
            String typeString = (String)thisType.get('Unit_Type__c');
            if(null != typeString){
              projectType.add(DamacUtility.capitalizeEachWord(typeString)); 
            }
                     
      }

      system.debug('***projectTYpe'+projectType);
      return projectType;
    }

    /*********************************************************************************************
    * @Description : Get the project lists allocated to the user                                          *                      
    * @Params      : none                                                                      *
    * @Return      : List<Property__c>                                                                  *
    *********************************************************************************************/
    public static List<Property__c> getProjectLists(Set<Id> propertyIDs){

      List<Property__c> property = new List<Property__c>();

      String query = 'SELECT ';

      for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('Property_Lists','Property__c')){
          query += fieldSets.getFieldPath() + ', '; 
      }

      query += 'Id FROM Property__c WHERE ID IN :propertyIDs AND Property_Name__c != null LIMIT 10000'; // page is made read only and the limit 
                                                                           // is 10000

      system.debug('property query '+query);
      for(Property__c thisProperty:Database.query(query)){

        if(null != thisProperty.Property_Name__c)
          thisProperty.Property_Name__c = thisProperty.Property_Name__c.toUpperCase();

        if(null != thisProperty.District__c)
          thisProperty.District__c = thisProperty.District__c.toUpperCase();
          
        property.add(thisProperty);
        
      }
      return property;
      
    }
   public static String getAllFields(DescribeSObjectResult describeResult) {
    String sObjectName = describeResult.getName();
    String query = ' SELECT ';
    List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
    List<RecordType> rts = [select Id
                            from RecordType
                            where SObjectType = :sObjectName
                           ];
    if (rts.size() > 0) {

    }
    query += (rts.size() > 0) ? 'RecordType.DeveloperName , ' : '';
    query +=  String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
    System.debug('getAllFields.query==>' + query);
    return query;
  }

   /*********************************************************************************************
    * @Description : Get all the inventory id's assigned to the logged in agent                *                      
    * @Params      : none                                                                      *
    * @Return      : Set<Id>                                                                   *
    *********************************************************************************************/
    public static Set<Id> getInventoryIDs(String query){

        Set<Id> inventoryId = new Set<Id>();
        for(Inventory_User__c thisInventoryUser:Database.query(query)){
          inventoryId.add(thisInventoryUser.Inventory__c);
        }

        return inventoryId;
    }

    /*********************************************************************************************
    * @Description : Get all properties which are unique in inventories satisfying filter      *
                     conditions                        
    * @Params      : none                                                                      *
    * @Return      : Set<Id>                                                                   *
    *********************************************************************************************/
    public static Set<Id> getPropertyIDs(Set<Id> inventoryIds){

        Set<Id> propertyId = new Set<Id>();
        for(AggregateResult thisInventory:[SELECT Property__c 
                                        FROM Inventory__c
                                        WHERE ID 
                                        IN :inventoryIds 
                                        GROUP BY Property__c]){
          //propertyId.add(thisInventory.Property__c);
           Id individualPropertyId = (Id)thisInventory.get('Property__c');
           propertyId.add(individualPropertyId);
        }

        return propertyId;
    }

    
    /*********************************************************************************************
    * @Description : Get all cities to be added in filter                                      *
                     conditions                        
    * @Params      : none                                                                      *
    * @Return      : List<String>                                                                   *
    *********************************************************************************************/
    public static List<String> getAllCities(){
      List<String> cities = new List<String>();

      for(AggregateResult thisCity:[SELECT Address__r.City__c city
                                    FROM Inventory__c
                                    WHERE Address__r.City__c != null
                                    AND Status__c = 'Released'
                                    GROUP BY Address__r.City__c]){
        String city = (String)thisCity.get('city');

        if(null != city)
          cities.add(DamacUtility.capitalizeEachWord(city));
      }

      return cities;

    }

    /*********************************************************************************************
    * @Description : Get the address location of all assigned properties                      
    * @Params      : none                                                                      *
    * @Return      : List<String>                                                                   *
    *********************************************************************************************/
    public static Map<String,Map<String,String>> getAddressLocation(Set<Id> propertyIDs,Set<Id> inventoryIds){
      Map<String,Map<String,String>> addressMap = new Map<String,Map<String,String>>();
      system.debug('>>propertyIDs'+propertyIDs);
      system.debug('>>inventoryIds'+inventoryIds);
      for(Inventory__c thisInventory:[SELECT Address__r.Latitude__c, Address__r.Longitude__c,
                                      Property__r.Property_Name__c 
                                      FROM Inventory__c  
                                      WHERE Property__r.Id IN : propertyIDs
                                      AND ID IN :inventoryIds
                                      AND Unit_Location__c != null 
                                      AND Address__c != null]){
          Map<String,String> locationMap = new Map<String,String>();

          if(null != thisInventory.Address__r.Latitude__c &&
            null != thisInventory.Address__r.Longitude__c){
            locationMap.put('Latitude',thisInventory.Address__r.Latitude__c);
            locationMap.put('Longitude',thisInventory.Address__r.Longitude__c);

            addressMap.put(thisInventory.Property__r.Property_Name__c,locationMap);
            system.debug('>>addressMap '+addressMap);
          }
      }
      return addressMap;

    }
    
    /*********************************************************************************************
    * @Description : This recursively extracts all users from the group and subgroups.  
    *                It will blow governor limits if the nesting goes too deep:                      
    * @Params      : Set<Group ID>                                                                *
    * @Return      : List<ID> - Ids of Group Members                                              *
    *********************************************************************************************/
    public static Set<id> getUserIdsFromGroups(Set<Id> groupIds)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        
        // Loop through all group members in a group
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId IN:groupIds])
        {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                result.addAll(getUSerIdsFromGroups(new Set<ID>{m.UserOrGroupId}));
            }
        }
        
        return result;  
    }

     /*********************************************************************************************
    * @Description : get the process flow id based on process flow name.  
    *                It will blow governor limits if the nesting goes too deep:                      
    * @Params      : String                                                                 *
    * @Return      : String                                             *
    *********************************************************************************************/
    public static String getProcessFlowId(String PageFlowName){
       
       String pageFlowId = '';
       for(Page_Flow__c thisPageFlow : [SELECT Id FROM Page_Flow__c WHERE name=: PageFlowName limit 1]){
          pageFlowId = string.valueOf(thisPageFlow.Id);
       }

       return pageFlowId;
    
    }

    /*********************************************************************************************
    * @Description : Get the Ammendments for current user account                                        *                      
    * @Params      : none                                                                      *
    * @Return      : List<Property__c>                                                                  *
    *********************************************************************************************/
    public static List<Contact> getAllContacts(Id accountId){

      List<Contact> amendment = new List<Contact>();

      String query = 'SELECT ';

      for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('Agency_Contact','Contact')){
          query += fieldSets.getFieldPath() + ', '; 
      }

      query += 'Id,Name FROM Contact WHERE AccountID = \''+accountId+'\' order by'+
          ' Name ASC';

      system.debug('amendment query '+query);
      for(Contact thisAmendment :Database.query(query)){
        amendment.add(thisAmendment);
        
      }
      return amendment;
      
    }

    /*********************************************************************************************
    * @Description : Get the Company Profile Details                                      *                      
    * @Params      : Id AccountId                                                         *
    * @Return      : Account                                                              *
    *********************************************************************************************/
    public static Account getCompanyProfileDetail(Id accountId){

      /*for(Account thisAccount:[SELECT Id, 
                               Name, Agency_Name_Arabic__c, Trade_License_Number__c,
                               Trade_License_Expiry_Date__c, Date_of_Incorporation__c,
                               Emirate__c, Country_of_Incorporation_New__c,
                               Alias_Name__c,Agency_Type__c,Corporate_Agency_Type__c ,
                               Street__c ,Street2__c,City__c,State__c,Country__c,
                               Fax,P_O_Box_Zip_Postal_Code__c,
                               Agency_Email__c,Zip_Postal_Code__c,P_O_Box_No__c ,
                               Telephone__c,Beneficiary_Name__c,Bank_Account_Number__c,
                               Bank_Name__c,Bank_Address__c,Bank_Branch__c,
                               Bank_Country__c,Swift_Code__c,IBAN_Number__c,
                               City_Of_Incorporation_New__c,RERA_Expiry_Date__c,ORN_Number__c,
                               IFSC_Code__c
                               FROM Account
                               WHERE ID = : accountId limit 1]){
          return thisAccount;
      }*/
        Account thisAccount = new Account();
        DescribeSObjectResult describeResult = Account.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
        query += ' WHERE Id =: accountId LIMIT 1';
        System.debug('==>' + query);
        for(account acc : Database.query(query)){
          thisAccount = Database.query(query);
            return thisaccount;
      }
    
     
      return new Account();
      
    }

    /*********************************************************************************************
    * @Description : Get the Profile Name for Logged in User                                   *                      
    * @Params      : none                                                                      *
    * @Return      : String                                                        *
    *********************************************************************************************/
    public static String getProfileName(){

      for(Profile thisProfile:[SELECT Id,Name FROM Profile 
                              WHERE Id = : UserInfo.getProfileId() LIMIT 1]){
          return thisProfile.Name;
      }

      return null;
    }

    /*********************************************************************************************
    * @Description : Get the Profile Name for Logged in User                                   *                      
    * @Params      : none                                                                      *
    * @Return      : String                                                                    *
    *********************************************************************************************/
    public static List<Inquiry__c> getCILs(String condition,Id inquiryRecordTypeId,Set<Id> userIds){
        
        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('CIL_List','Inquiry__c')){
          query += fieldSets.getFieldPath() + ', '; 
        }

        
        query += 'Id FROM Inquiry__c WHERE RecordTypeId = \''+inquiryRecordTypeId+'\''+condition+' ORDER BY CreatedDate DESC'; 

        List<Inquiry__c> inquiryList = new List<Inquiry__c>();
        for(Inquiry__c thisInquiry:Database.query(query)){
          inquiryList.add(thisInquiry);
        }

        return inquiryList;
    }

     /*********************************************************************************************
    * @Description : Get all the agent id's under auth officer/owner                           *                      
    * @Params      : Id                                                                        *
    * @Return      : String                                                                    *
    *********************************************************************************************/
    public static Set<Id> getAllUsers(Id accountId){
      Set<Id> userIds = new Set<Id>();
      for(User thisUser:[SELECT Id from User WHERE Contact.AccountID = : accountId]){
        userIds.add(thisUser.Id);
      }
      return userIds;
    }

     /*********************************************************************************************
    * @Description : Get the attachment count under the given record                           *                      
    * @Params      : Id                                                                        *
    * @Return      : Integer                                                                    *
    *********************************************************************************************/
    public static Integer getTheAttachmentCount(Id recordId){

      List<Attachment> attachmentList = new List<Attachment>();
      for(Attachment attachment:[SELECT Id from Attachment where ParentId=:recordId]){
        attachmentList.add(attachment);
      }

      return attachmentList.size();
    }

    /*********************************************************************************************
    * @Description : Get all the cases created by user - for admins by all his agent           *                      
    * @Params      : none                                                                      *
    * @Return      : String,userIds                                                                    *
    *********************************************************************************************/
    public static List<Case__c> getCases(String condition,Set<Id> userIds){
        
      String query = 'SELECT ';
      for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('Case_List','Case__c')){
        query += fieldSets.getFieldPath() + ', '; 
      }

      query += 'Id FROM Case__c WHERE '+condition+' ORDER BY CreatedDate DESC'; 

      List<Case__c> caseList = new List<Case__c>();
      for(Case__c thisCase:Database.query(query)){
        caseList.add(thisCase);
      }

      return caseList;
    }

    /*********************************************************************************************
    * @Description : Get all the noofbedrooms                                                  *                      
    * @Params      : none                                                                      *
    * @Return      : List<String>                                                              *
    *********************************************************************************************/
    public static List<String> getAllBedRooms(){
        
      List<String> noOfBedrooms = new List<String>();

      for(AggregateResult thisInventory:[SELECT IPMS_Bedrooms__c
                                      FROM Inventory__c
                                      WHERE IPMS_Bedrooms__c != null
                                      AND Status__c = 'Released'
                                      GROUP BY IPMS_Bedrooms__c]){
        noOfBedrooms.add(DamacUtility.capitalizeEachWord((String)thisInventory.get('IPMS_Bedrooms__c')));
      }
      
      return noOfBedrooms;

    }

    /*********************************************************************************************
    * @Description : Get inventories                                                           *                      
    * @Params      : Id                                                                      *
    * @Return      : List<Inventory__c>                                                         *
    *********************************************************************************************/
    public static List<Inventory__c> getInventoryList(String condition,Set<Id> InventoryIDs){

      List<Inventory__c> inventory = new List<Inventory__c>();

      String query = 'SELECT ';

      for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('Project_Unit','Inventory__c')){
          query += fieldSets.getFieldPath() + ', '; 
      }

      query += condition;

      system.debug('inventory query '+query);
      for(Inventory__c thisProperty:Database.query(query)){
        inventory.add(thisProperty);
        
      }
      return inventory;
      
    }

    /*********************************************************************************************
    * @Description : Get the announcement request with the given id and  account                *                      
    * @Params      : String,Id                                                                         *
    * @Return      : Announcement_Request__c                                                         *
    *********************************************************************************************/
    public static Announcement_Request__c getAnnouncementRequest(String announcementId,Id accountId){

      Announcement_Request__c announcementRequest = new Announcement_Request__c();
      system.debug('announcementId==>'+announcementId);
      system.debug('accountId==>'+accountId);

      for(Announcement_Request__c thisAnnouncement:[SELECT Announcement_URL__c,Footer__c,
                                                           Header_Allignment__c,Id,Agency__c,Announcement__c 
                                                    FROM Announcement_Request__c
                                                    WHERE Announcement__c =: announcementId
                                                    AND Agency__c =: accountId LIMIT 1]){
        announcementRequest = thisAnnouncement;
      }

      return announcementRequest;
      
    }
    
    /*********************************************************************************************
    * @Description : Get the price range values to be displayed in price range dropdown         *                      
    * @Params      : none                                                                         *
    * @Return      : List<String>                                                        *
    *********************************************************************************************/
    public static List<Inventory_Price__c> getPriceRange(){

     List<Inventory_Price__c> inventoryPriceList = new List<Inventory_Price__c>();
     for(Inventory_Price__c thisInventoryPrice:[SELECT order__c,
                                                range_dropdown_label__c,range_dropdown_values__c 
                                                FROM Inventory_Price__c order by order__c ASC]){
                                                    
              inventoryPriceList.add(thisInventoryPrice);                                  
      }
      
      return inventoryPriceList;
      
    }
    
    
    /*********************************************************************************************
    * @Description : Get the announcement request with the given id and  account                *                      
    * @Params      : String,Id                                                                         *
    * @Return      : Announcement_Request__c                                                         *
    *********************************************************************************************/
    public static Announcement__c getAnnouncementDetail(String announcementId){

      Announcement__c announcementRequest = new Announcement__c();
      
      for(Announcement__c thisAnnouncement:[SELECT Title__c,Description__c 
                                                    FROM Announcement__c
                                                    WHERE Id =: announcementId
                                                    LIMIT 1]){
        announcementRequest = thisAnnouncement;
      }

      return announcementRequest;
      
    }

     /*********************************************************************************************
    * @Description : Get all the agent id's under auth officer/owner                           *                      
    * @Params      : Id                                                                        *
    * @Return      : String                                                                    *
    *********************************************************************************************/
    public static List<User> getAllUsersOfAccounts(List<Id> accountIds){
      return [SELECT Id,isActive from User WHERE Contact.AccountID IN : accountIds];
    }

     /*********************************************************************************************
    * @Description : Get all the events                                                        *                      
    * @Params      : none                                                                      *
    * @Return      : List<Assigned_Agent__c>                                                   *
    *********************************************************************************************/
    public static List<Assigned_Agent__c> getAllCampaigns(){
      List<Assigned_Agent__c> allCampaigns = new List<Assigned_Agent__c>();
      for(Assigned_Agent__c thisCampaign:[SELECT Campaign_Name__c,End_Date__c,Start_Date__c,
                                          Campaign__r.Campaign_Description__c, Campaign__r.Campaign_Location__c,
                                          Campaign__r.Status__c
                                          FROM Assigned_Agent__c 
                                          WHERE  
                                          End_Date__c >=TODAY
                                          AND Campaign__r.Active__c = true
                                          AND Campaign__r.Status__c IN('Planned','In Progress')
                                          AND User__c =: UserInfo.getUserId() 
                                          ORDER BY Start_Date__c  ASC]){
        
        allCampaigns.add(thisCampaign);
      }
     
      return allCampaigns; 
    }
    
     /*********************************************************************************************
    * @Description : check if there is a pending SR for logged in user                         *                      
    * @Params      : String accountID                                                          *
    * @Return      : NSIBPM__Service_Request__c                                                   *
    *********************************************************************************************/
    public static NSIBPM__Service_Request__c checkPendingSR(Id accountID){
      
        for(NSIBPM__Service_Request__c thisSR:[SELECT nsibpm__internal_status_name__c,
                                               NSIBPM__Customer__c,Id,name 
                                               FROM NSIBPM__Service_Request__c
                                               WHERE (nsibpm__internal_status_name__c != 'Approved' AND
                                               nsibpm__internal_status_name__c != 'Rejected' 
                                               //AND nsibpm__internal_status_name__c != 'Draft'
                                               AND nsibpm__internal_status_name__c != 'Closed')
                                               AND NSIBPM__Customer__c =:accountID 
                                               AND RecordType.DeveloperName = 'Agent_Update'
                                               LIMIT 1]){
           return thisSR; 
        }
        
        return null;
    }
    
    /*********************************************************************************************
    * @Description : Get all general inventories                                               *                      
    * @Params      : none                                                         *
    * @Return      : Set<Id>                                                *
    *********************************************************************************************/
    public static Set<Id> getAllGeneralInventories(String query){
        Set<Id> allGeneralInventoryId = new Set<Id>();
        for(Inventory__c thisInventory:Database.query(query)){
            system.debug(thisInventory);
            allGeneralInventoryId.add(thisInventory.Id);                                
       }
        system.debug('--General Inventories-- '+allGeneralInventoryId);
        return allGeneralInventoryId;
    }
    
    
    /*********************************************************************************************
    * @Description : Get all min and max price range                                         *                      
    * @Params      : none                                                                    *
    * @Return      : Set<Id>                                                                 *
    *********************************************************************************************/
    public static Map<String,Decimal> getMinMaxPrice(String marketingName){
        Map<String,Decimal> minMaxPriceMap = new Map<String,Decimal>();
        for(AggregateResult thisResult:[SELECT min(List_Price_calc__c) minSelPrice,
                                        max(List_Price_calc__c) maxSelPrice,
                                        min(Special_Price_calc__c) minSpecialPrice,
                                        max(Special_Price_calc__c) maxSpecialPrice
                                        FROM Inventory__c
                                        WHERE Marketing_Name__c =: marketingName
                                        AND Status__c ='Released'
                                        AND Unit_Location__c != null AND Address__c != null
                                       ]){
                                         
              Decimal minSellingPrice = (null != thisResult.get('minSelPrice'))?Math.Floor((Decimal)thisResult.get('minSelPrice'))
                                        :0;
                                           
              Decimal maxSellingPrice = (null != thisResult.get('maxSelPrice'))?Math.Floor((Decimal)thisResult.get('maxSelPrice'))
                                        :0;  
              Decimal maxSpecialPrice = (null != thisResult.get('maxSpecialPrice'))?Math.Floor((Decimal)thisResult.get('maxSpecialPrice'))
                                        :0; 
              Decimal minSpecialPrice = (null != thisResult.get('minSpecialPrice'))?Math.Floor((Decimal)thisResult.get('minSpecialPrice'))
                                        :0;  
                             
              minMaxPriceMap.put('min',(minSellingPrice>minSpecialPrice?minSpecialPrice:minSellingPrice));
              minMaxPriceMap.put('max',(maxSellingPrice>maxSpecialPrice?maxSellingPrice:maxSpecialPrice));                          
       }
        system.debug('-- Min Max Price --'+minMaxPriceMap);
        return minMaxPriceMap;
    }

    /*********************************************************************************************
    * @Description : Get the commission list for agency                                        *                      
    * @Params      : Id accountId                                                                      *
    * @Return      : List<Agent_Commission__c>                                                         *
    *********************************************************************************************/
    public static List<Agent_Commission__c> getCommission(Id accountId){

      List<Agent_Commission__c> commission = new List<Agent_Commission__c>();

      String query = 'SELECT ';

      for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('Agent_Commission_List','Agent_Commission__c')){
          query += fieldSets.getFieldPath() + ', '; 
      }

      query += ' Id FROM Agent_Commission__c  WHERE Agency__c = :accountId AND ((Check_Date__c != NULL  AND'+
               ' Registration_Date__c = LAST_N_DAYS:90) OR (Check_Date__c = NULL))  LIMIT 10000'; // page is made read only and the limit 
                                                                           // is 10000 AND Internal_Verification__c = \'Y\'

      system.debug('**commission query '+query);
      for(Agent_Commission__c thisCommission:Database.query(query)){
        commission.add(thisCommission);
        
      }

      String agrQuery = 'SELECT sum(Reservation_Price__c) unitprice, sum(Amount__c) commission from Agent_Commission__c WHERE Agency__c =:accountId AND ((Check_Date__c != NULL  AND'+
               ' Registration_Date__c = LAST_N_DAYS:90) OR (Check_Date__c = NULL))';

       for(AggregateResult thisResult:Database.query(agrQuery)){
          totalCommissionAmount = ((Decimal)thisResult.get('commission'));
          totalUnitPrice = ((Decimal)thisResult.get('unitprice'));
       }


      return commission;
      
    }

     public static List<String> getAllFloorPackageName(Set<Id> inventoryIds, String marketingName){
        List<String> packageName = new List<String>();
        for(AggregateResult thisInventory:[SELECT Floor_Package_Name__c 
                                        FROM Inventory__c
                                        WHERE Id in:inventoryIds AND Marketing_Name__c =:marketingName 
                                        GROUP BY Floor_Package_Name__c LIMIT 10000]){
          packageName.add((String)thisInventory.get('Floor_Package_Name__c'));
        }
        return packageName;
    }

}// End of class.