/**************************************************************************************************
* Name               : LightningSelfRegisterControllerTest                                        *
* Description        : Test class for LightningSelfRegisterController class.                      *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class LightningSelfRegisterControllerTest {
    
    static List<User> createUserList;
    private static void init(){
         createUserList = InitialiseTestData.createTestUserRecords(new List<User>{new User()}); 
    }
    
    @IsTest() static void testMethod1() {
        init();
        String jsonString = ' [ { "FirstName":"door handle1", ' + '"fieldPath":"LastName" } ]';
        LightningSelfRegisterController lsrcObject = new LightningSelfRegisterController();
        LightningSelfRegisterController.selfRegister('Bob', 'Jones', 'bob@jones.com', 'test', 'test', 'test', 'test', jsonString, 'test', false);   
        LightningSelfRegisterController.getExtraFields('test');
        
    }
    
    @IsTest() static void testMethod2() {
        String jsonString = ' [ { "FirstName":"door handle1", ' + '"fieldPath":"LastName" } ]';
        LightningSelfRegisterController lsrcObject = new LightningSelfRegisterController();
        LightningSelfRegisterController.selfRegister('Bob', 'Jones', 'bob@jones.com', '8yhMsHDN&ituQgO$WO', '8yhMsHDN&ituQgO$W', 'test', 'test', jsonString, 'test', true);   
        LightningSelfRegisterController.getExtraFields('test');
    }
}// End of class.