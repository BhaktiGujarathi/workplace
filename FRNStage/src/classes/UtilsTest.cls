@isTest
public class UtilsTest{
    static testMethod void getSObjectTypeTest(){
        Test.startTest();
            Schema.SObjectType objectName = Utils.getSObjectType('Account');
        Test.stopTest();
    }
    
    static testMethod void generateQueryTest(){
        Test.startTest();
            String querystr = Utils.generateQuery(Account.SObjectType
                                                , null
                                                , null
                                                , ''
                                                 );
        Test.stopTest();
    }
    
    static testMethod void getInnerQueryListTest(){
        Test.startTest();
            List<String> queryList = Utils.getInnerQueryList(Account.SObjectType
                                                           , new Set<String>{'Opportunities', 'Contacts'}
                                                            );
        Test.stopTest();
    }
    
    static testMethod void getInnerQueryListTest1(){
        Test.startTest();
            List<String> queryList = Utils.getInnerQueryList(Account.SObjectType
                                                           , new Map<String, List<String>> {'Opportunities' => new List<String>{'Name', 'StageName'},
                                                                                            'Contacts' => new List<String>{'Name'}
                                                                                           }
                                                            );
        Test.stopTest();
    }
    
    static testMethod void startsWithInvalidTest(){
        Test.startTest();
            boolean startwithFlag = Utils.startsWith('TestString',
                                               'A'
                                              );
        Test.stopTest();
    }
    
    static testMethod void startsWithValidTest(){
        Test.startTest();
            boolean startwithFlag = Utils.startsWith('TestString',
                                               'T'
                                              );
        Test.stopTest();
    }
    
    static testMethod void getRecordTypeMapForObjectGenericTest(){
        Test.startTest();
            Map<String, Id> recordtypeMap = Utils.getRecordTypeMapForObjectGeneric(Account.SObjectType);
        Test.stopTest();
    }
    
    static testMethod void currentTimeLongTest(){
        Test.startTest();
            String timeStr = Utils.currentTimeLong();
        Test.stopTest();
    }
    
    
}