/**************************************************************************************************
* Name               : Test_DamacForgotPasswordController                                                
* Description        : An apex page controller for DamacForgotPasswordController                                          
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/

@isTest
public class Test_DamacForgotPasswordController {

    public static Contact portalUserContact;
    public static User portalUser;
    
    static void init(){
        portalUserContact = InitialiseTestData.getCorporateAgencyContact('testAgent1');
        insert portalUserContact;
        
        portalUser = InitialiseTestData.getPortalUser('testAgent1@damac.com', portalUserContact.Id);
        portalUser.isActive = true;
        insert portalUser;
        
    }
    
    @isTest static void testForgotPasswordValidUserName(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacForgotPasswordController damacForgotPassword = new DamacForgotPasswordController();
            damacForgotPassword.username = 'testAgent1@damac.com';
            damacForgotPassword.forgotPassword();
            //system.assertEquals(damacForgotPassword.forgotPassword(),new PageReference('/Damac_ForgotPasswordConfirm'));
        }
        Test.stopTest();
    }
    
     @isTest static void testForgotPasswordInvalidUserName(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacForgotPasswordController damacForgotPassword = new DamacForgotPasswordController();
            damacForgotPassword.username = 'testAgent2@damac.com';
            system.assertEquals(damacForgotPassword.forgotPassword(),null);
        }
        Test.stopTest();
    }
}