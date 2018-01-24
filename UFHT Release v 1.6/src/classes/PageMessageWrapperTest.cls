/**
  * @Class Name: PageMessageWrapperTest
  * @Description: This class contains unit tests for PageMessageWrapper.cls
  * ====================================================================================================================
  *       Version   | Date        | Author             | Comments
  * --------------------------------------------------------------------------------------------------------------------
  *       1.0       | 07/02/2017  | Eternus Solutions  | 1. Created test class for PageMessageWrapper.
  * ====================================================================================================================
  **/
@isTest
private class PageMessageWrapperTest {
    
    static testMethod void messageWrapperTestCase() {
        String messageStr = 'Testing the Message wraper';
        String msgTypeStr = 'Info';
        
        Test.StartTest();
            PageMessageWrapper messageWrapperObj =  new PageMessageWrapper(messageStr, msgTypeStr);
        Test.StopTest();
    }
    
}