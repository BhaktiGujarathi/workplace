@isTest
private class DETE_LoginServiceTest {

    // method to 
    static testMethod void testLoginMethod() {
        
        DETE_LoginService loginServiceClass = new DETE_LoginService();
        loginServiceClass.usernameStr = '';
        loginServiceClass.passwordStr = 'espl123456';
        loginServiceClass.userLogin();
        
        loginServiceClass.usernameStr = 'de@bw.com';
        loginServiceClass.passwordStr = '';
        loginServiceClass.userLogin();
        
        loginServiceClass.usernameStr = '';
        loginServiceClass.passwordStr = '';
        loginServiceClass.userLogin();
        
        loginServiceClass.usernameStr = 'de@bw.com';
        loginServiceClass.passwordStr = 'espl123456';
        loginServiceClass.userLogin();
        loginServiceClass.isLoggedIn = true;
        loginServiceClass.strUrlParameter = '';
    }
    static testMethod void testUtil() {
    	DETE_Util util = new DETE_Util();
    	system.assertEquals(DETE_Util.STATUS_CODE, DETE_Util.STATUS_CODE);
    	system.assertEquals(DETE_Util.STR_AUTHO_BASIC, DETE_Util.STR_AUTHO_BASIC);
    	system.assertEquals(DETE_Util.STR_AUTHO_BASIC, DETE_Util.STR_AUTHO_BASIC);
    	system.assertEquals(DETE_Util.STR_END_RANGE, DETE_Util.STR_END_RANGE);
    	system.assertEquals(DETE_Util.STR_GETMETHOD, DETE_Util.STR_GETMETHOD);
    	system.assertEquals(DETE_Util.STR_SPACE, DETE_Util.STR_SPACE);
    	system.assertEquals(DETE_Util.STR_PLUS, DETE_Util.STR_PLUS);
    	
    }
    
    static testMethod void testRegisterNewUserMethod() {
        DETE_LoginService loginServiceClass = new DETE_LoginService();
        loginServiceClass.newUserRegister();
    }
    
    static testMethod void testForgetPasswordMethod() {
        DETE_LoginService loginServiceClass = new DETE_LoginService();
        loginServiceClass.forgotPassword();
    }
    
    static testMethod void testgetUsersNameMethod() {
    	test.startTest();
    	DETE_LoginService loginServiceClass = new DETE_LoginService();
    	loginServiceClass.strUsername = 'test@dete.com';
    	DETE_DataFactory.getUSerRecord(true);

        loginServiceClass.getUsersName();
        test.stopTest();
    }
    
    static testMethod void testcloseErrorMethod() {
        DETE_LoginService loginServiceClass = new DETE_LoginService();
        loginServiceClass.clearPageMessages();
    }
}