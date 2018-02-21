/**************************************************************************************************
* Name               : LightningLoginFormControllerTest                                           *
* Description        : Test class for LightningLoginFormController class.                         *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class LightningLoginFormControllerTest {

    static testMethod void testLogin() {
    	LightningLoginFormController lfpcObject = new LightningLoginFormController();
    	LightningLoginFormController.login('test', 'test', 'test.salesforce.com');
    }
    
    static testMethod void testMethod2() {
		LightningLoginFormController.getIsUsernamePasswordEnabled(); 
    }
    
    static testMethod void testMethod3() {
		LightningLoginFormController.getIsSelfRegistrationEnabled(); 
    }
    
    static testMethod void testMethod4() {
		LightningLoginFormController.getSelfRegistrationUrl(); 
    }
    
    static testMethod void testMethod5() {
		LightningLoginFormController.getForgotPasswordUrl(); 
    }
    
    static testMethod void testMethod6() {
		LightningLoginFormController.getForgotPasswordUrl(); 
    }
}// End of class.