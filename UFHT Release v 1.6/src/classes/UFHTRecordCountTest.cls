@isTest
public class UFHTRecordCountTest {
    static testMethod void updateRecordCountTestFirst() {
    
        List<UFHT__Ultra_Track_Container__c > ufhtList= new List<UFHT__Ultra_Track_Container__c >();
       
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Account',
                                                         UFHT__Object_Name__c ='Account',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
                                                         
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Case',
                                                         UFHT__Object_Name__c ='Case',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
        insert ufhtList;
        Test.startTest();
        UFHTRecordCount.updateRecordCount('Account',2,4);
        Test.stopTest();
     }
     static testMethod void updateRecordCountTestSecond() {

        List<UFHT__Ultra_Track_Container__c > ufhtList= new List<UFHT__Ultra_Track_Container__c >();
       
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Account',
                                                         UFHT__Object_Name__c ='Account',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = null,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
                                                         
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Case',
                                                         UFHT__Object_Name__c ='Case',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
        insert ufhtList;
        Test.startTest();
        UFHTRecordCount.updateRecordCount('Account',1,4);
        Test.stopTest();
     }
     static testMethod void updateRecordCountTestThird() {

        List<UFHT__Ultra_Track_Container__c > ufhtList= new List<UFHT__Ultra_Track_Container__c >();
       
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Account',
                                                         UFHT__Object_Name__c ='Account',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = null,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
                                                         
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Case',
                                                         UFHT__Object_Name__c ='Case',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
        insert ufhtList;
        Test.startTest();
        UFHTRecordCount.updateRecordCount('Account',1,4);
        Test.stopTest();
     }
     static testMethod void updateRecordCountTestFourth() {

        List<UFHT__Ultra_Track_Container__c > ufhtList= new List<UFHT__Ultra_Track_Container__c >();
       
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Account',
                                                         UFHT__Object_Name__c ='Account',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = null,
                                                         UFHT__Good_To_Have__c = null,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
                                                         
        ufhtList.add(new UFHT__Ultra_Track_Container__c (UFHT__Object_Label__c = 'Case',
                                                         UFHT__Object_Name__c ='Case',
                                                         UFHT__Is_Tracking_Enabled__c =True,
                                                         UFHT__Must_Have__c = 2,
                                                         UFHT__Good_To_Have__c = 3,
                                                         UFHT__Tracked_Fields__c = 'Name:0,Description:0'));
        insert ufhtList;
        Test.startTest();
        UFHTRecordCount.updateRecordCount('Account',1,4);
        Test.stopTest();
     }
     
}