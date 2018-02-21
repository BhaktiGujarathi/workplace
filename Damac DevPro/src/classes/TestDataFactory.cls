/**************************************************************************************************
* Name               : TestDataFactory                                                            *
* Description        : This is a test data factory class for creating test records.               *
* Created Date       : 23/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      23/05/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
public class TestDataFactory { 
    
    /*********************************************************************************************
    * @Description : Method to create Event records.                                             * 
    * @Params      : List<Event>                                                                 *
    * @Return      : List<Event>                                                                 *
    *********************************************************************************************/
    public static List<Event> createEventRecords(List<Event> EventList){
        List<Event> createEventList = new List<Event>();
        Event newEvent;
        for(Event thisRecord : EventList){
            newEvent= new Event();
            newEvent.Subject = thisRecord.Subject != null ? thisRecord.Subject : 'Test Event';
            newEvent.StartDateTime = thisRecord.StartDateTime != null ? thisRecord.StartDateTime : system.now() ;
            newEvent.EndDateTime = thisRecord.EndDateTime != null ? thisRecord.EndDateTime : system.now().addDays(1);
            newEvent.Type = thisRecord.Type != null ? thisRecord.Type : 'Meeting';
            newEvent.Status__c = thisRecord.Status__c != null ? thisRecord.Status__c : 'Planned';
            newEvent.WhatId = thisRecord.WhatId;
            newEvent.WhoId = thisRecord.WhoId;
            createEventList.add(newEvent);             
        }   
        if(!createEventList.isEmpty()){ 
            Database.insert(createEventList);
        }
        system.debug('#### Event Record Created = '+createEventList);
        return createEventList;
    } 

    /*********************************************************************************************
    * @Description : Method to create Campaign records.                                           *
    * @Params      : List<Campaign__c>                                                            *
    * @Return      : List<Campaign__c>                                                            *
    *********************************************************************************************/
    public static List<Campaign__c> createCampaignRecords(List<Campaign__c> CampaignList){
        List<Campaign__c> createCampaignList = new List<Campaign__c>();
        Id CampaignRecordTypeId   = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
        Campaign__c newCampaign;
        for(Campaign__c thisRecord : CampaignList){
            newCampaign= new Campaign__c();
            newCampaign.RecordTypeId = thisRecord.RecordTypeId;
            newCampaign.Sales_Admin_Active__c = thisRecord.Sales_Admin_Active__c != null ? thisRecord.Sales_Admin_Active__c : true;
            newCampaign.Marketing_Active__c = thisRecord.Marketing_Active__c != null ? thisRecord.Marketing_Active__c :true;
            newCampaign.Credit_Control_Active__c = thisRecord.Credit_Control_Active__c != null ? thisRecord.Credit_Control_Active__c :true;
            newCampaign.Campaign_Description__c = thisRecord.Campaign_Description__c != null ? thisRecord.Campaign_Description__c :'This is a test campaign';
            newCampaign.Campaign_Location__c = thisRecord.Campaign_Location__c != null ? thisRecord.Campaign_Location__c :'United Arab Emirates';
            newCampaign.Status__c = thisRecord.Status__c != null ? thisRecord.Status__c :'In Progress';
            newCampaign.Campaign_Name__c = thisRecord.Campaign_Name__c != null ? thisRecord.Campaign_Name__c :'Test';
            newCampaign.Start_Date__c = thisRecord.Start_Date__c != null ? thisRecord.Start_Date__c : system.now().Date();
            newCampaign.End_Date__c = thisRecord.End_Date__c != null ? thisRecord.End_Date__c : system.now().Date().addDays(10);
            newCampaign.Marketing_Start_Date__c = thisRecord.Marketing_Start_Date__c != null ? thisRecord.Marketing_Start_Date__c : system.now().Date();
            newCampaign.Marketing_End_Date__c = thisRecord.Marketing_End_Date__c != null ? thisRecord.Marketing_End_Date__c : system.now().Date().addDays(10);
            createCampaignList.add(newCampaign);             
        }   
        if(!createCampaignList.isEmpty()){ 
            Database.insert(createCampaignList);
        }
        system.debug('#### Campaign Record Created = '+createCampaignList);
        return createCampaignList;
    } 
    
    /*********************************************************************************************
    * @Description : Method to create Inquiry records.                                           *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : List<Inquiry__c>                                                            *
    *********************************************************************************************/
    public static List<Inquiry__c> createInquiryRecords(List<Inquiry__c> InquiryList){
        List<Inquiry__c> createInquiryList = new List<Inquiry__c>();
        Id inquiryRecordTypeId = DamacUtility.getRecordTypeId('Inquiry__c', 'Inquiry');
        Inquiry__c newInquiry;
        Integer userNumber  = 0;
        for(Inquiry__c thisRecord : InquiryList){
            newInquiry= new Inquiry__c();
            newInquiry.OwnerId = thisRecord.OwnerId;
            newInquiry.Campaign__c = thisRecord.Campaign__c;
            newInquiry.RecordTypeId = thisRecord.RecordTypeId != null ? thisRecord.RecordTypeId : inquiryRecordTypeId ;
            newInquiry.First_Name__c = thisRecord.First_Name__c != null ? thisRecord.First_Name__c : 'Test'+userNumber;
            newInquiry.Last_Name__c = thisRecord.Last_Name__c != null ? thisRecord.Last_Name__c : 'Inquiry'+userNumber;
            newInquiry.Mobile_Phone_Encrypt__c = thisRecord.Mobile_Phone_Encrypt__c != null ? thisRecord.Mobile_Phone_Encrypt__c : '557030789';
            newInquiry.Mobile_CountryCode__c = thisRecord.Mobile_CountryCode__c != null ? thisRecord.Mobile_CountryCode__c : 'United Arab Emirates: 00971';
            newInquiry.Email__c = thisRecord.Email__c != null ? thisRecord.Email__c : 'test'+userNumber+'@damac.com';
            newInquiry.Preferred_Language__c = thisRecord.Preferred_Language__c != null ? thisRecord.Preferred_Language__c : 'English';
            newInquiry.Inquiry_Source__c = thisRecord.Inquiry_Source__c != null ? thisRecord.Inquiry_Source__c : 'Digital';
            newInquiry.Inquiry_Status__c = thisRecord.Inquiry_Status__c != null ? thisRecord.Inquiry_Status__c : 'New' ;
            newInquiry.Duplicate__c = thisRecord.Duplicate__c;
            createInquiryList.add(newInquiry);             
        }   
        if(!createInquiryList.isEmpty()){ 
            Database.insert(createInquiryList);
        }
        system.debug('#### Inquiry Record Created = '+createInquiryList);
        return createInquiryList;
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
            Profile standardProfile = [SELECT Id FROM profile WHERE Name = 'Property Consultant'];
            UserRole groupHsseRole = [SELECT Id FROM UserRole WHERE Name = 'PC1'];
            for(User thisRecord : userList){
              String milli = String.valueOf(System.now().millisecond());
                String testName = 'standarduser'+userNumber;
                userObject = new User();
                userObject.alias = thisRecord.alias != null ? thisRecord.alias : 'standt'+userNumber+milli;
                userObject.alias = userObject.alias.subString(0, 8);
                userObject.email = thisRecord.email != null ? thisRecord.email : testName+'@damac.ae';
                userObject.emailencodingkey = 'UTF-8';
                userObject.lastname = thisRecord.lastname != null ? thisRecord.lastname : testName;
                userObject.languagelocalekey = 'en_US';
                userObject.localesidkey = 'en_US';
                userObject.profileId = thisRecord.profileId != null ? thisRecord.profileId : standardProfile.Id;
                userObject.timezonesidkey = 'America/Los_Angeles';
                userObject.username = testName+userNumber+milli+'@damac.ae';
                userObject.ManagerId = thisRecord.ManagerId;
                userObject.UserRoleId = groupHsseRole.Id;
                userObject.Extension = thisRecord.Extension != null ? thisRecord.Extension : '123';
                userObject.Break_Time__c = thisRecord.Break_Time__c != null ? thisRecord.Break_Time__c : system.now();
                userNumber++; 
                createUserList.add(userObject);                            
            }   
            if(!createUserList.isEmpty()){
                Database.insert(createUserList);
                
            }          
            system.debug('#### User Record Created = '+createUserList);
        return createUserList;
    } 
}// End of class.