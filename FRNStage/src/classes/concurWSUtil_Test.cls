@isTest
public class concurWSUtil_Test
{
    static testmethod void test1() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new createBlankOrderMockTest());
        concurWSUtil CWS = new concurWSUtil();
        concurWSUtil.concurWS('1234sfbsfghs');
        Test.stopTest();
    }
}