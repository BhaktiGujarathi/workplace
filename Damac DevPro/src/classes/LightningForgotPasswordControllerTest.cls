/**************************************************************************************************
* Name               : LightningForgotPasswordControllerTest                                      *
* Description        : Test class for LightningForgotPasswordController class.                    *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class LightningForgotPasswordControllerTest {
	
	static List<User> createUserList;
	private static void init(){
		 createUserList = InitialiseTestData.createTestUserRecords(new List<User>{new User()});	
	}
	
    static testMethod void testWithValidUser() {
    	init();
    	try{
	    	LightningForgotPasswordController lfpcObject = new LightningForgotPasswordController();
	    	if(createUserList != null && createUserList.size() > 0){
	    		LightningForgotPasswordController.forgotPassowrd(createUserList[0].userName, ''); 	
	    	}
    	}catch(Exception e){
            system.debug('Exception: '+e.getMessage());
        }
    }
    
    static testMethod void testWithInValidUser() {
		LightningForgotPasswordController.forgotPassowrd('test', ''); 
    }
}// End of class.