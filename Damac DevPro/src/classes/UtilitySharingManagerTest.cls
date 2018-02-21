/**************************************************************************************************
* Name               : UtilitySharingManagerTest                                                  *
* Description        : Test class for UtilitySharingManager class.                                *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class UtilitySharingManagerTest {
    
    static UtilitySharingManager usmObject = new UtilitySharingManager();
    static List<User> createUserList;
    static List<NSIBPM__Service_Request__c> createserviceRequestList;
    static Map<Id, User> userDetailsMap;
    private static void init(){ 
         createUserList = InitialiseTestData.createTestUserRecords(new List<User>{new User(), new User(), new User(), new User(), new User()}); 
         if(createUserList != null && createUserList.size() > 0){
            createUserList[0].ManagerId = createUserList[1].Id; 
            createUserList[1].ManagerId = createUserList[2].Id; 
            createUserList[2].ManagerId  = createUserList[3].Id;    
            createUserList[3].ManagerId = createUserList[4].Id; 
            update createUserList;
         }
         userDetailsMap = UtilityQueryManager.getUserManagerDetails(new Set<Id>{createUserList[0].Id});
         createserviceRequestList = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{new NSIBPM__Service_Request__c()});
    }
    
    static testMethod void testShareRecord() { 
        init();
        List<SObject> shareRecordsList = new List<SObject>();
        shareRecordsList.addAll(usmObject.invokeAccess(userDetailsMap.get(createUserList[0].Id), 'NSIBPM__Service_Request__c', createserviceRequestList[0].Id, 'Manual'));
        system.enqueueJob(new UtilitySharingManager(shareRecordsList, new List<sObject>()));       
    }
    
    static testMethod void testUserShareRecord() { 
        init();
        List<SObject> shareRecordsList = new List<SObject>();
        shareRecordsList.addAll(usmObject.invokeAccess(userDetailsMap.get(createUserList[0].Id), 'User', createUserList[0].Id, ''));
        system.enqueueJob(new UtilitySharingManager(shareRecordsList, new List<sObject>()));       
    }
    /*
    @isTest(seeAllData=true) static void testDeleteShareRecord() { 
        init();
        List<SObject> shareRecordsList = new List<SObject>();
        List<NSIBPM__Service_Request__Share> thisShareRecord = [SELECT Id, ParentId, AccessLevel, UserOrGroupId, RowCause FROM NSIBPM__Service_Request__Share limit 40000];
        if(thisShareRecord != null && thisShareRecord.size() > 0){
            shareRecordsList.add(thisShareRecord[0]);
            system.enqueueJob(
            new UtilitySharingManager(new List<sObject>(), shareRecordsList));      
        }
    }*/
}// End of class.