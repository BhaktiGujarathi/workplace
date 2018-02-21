/**************************************************************************************************
* Name               : Test_DamacLoginController                                                 
* Description        : An apex page controller for DamacLoginController                                          
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacLoginController {

    static void init(){
        cookie Name = new Cookie('username', 'test', null, 365, false);
        //cookie PasswordCokies = new Cookie('password', 'test', null, 365, false);
        ApexPages.currentPage().setCookies(new Cookie[] {Name});
        
        
    }
    
    @isTest static void loginGuestUser() {
        
        Test.StartTest();
        init();
        
        DamacLoginController damacLogin = new DamacLoginController();
        damacLogin.rememberMe = true;
        damacLogin.username = 'test@damac.com';
        damacLogin.password = 'salesforce1';
        damacLogin.login();
        
        PageReference pg = new PageReference('/Damac_Home');
        //system.assertEquals(damacLogin.redirectToHome(),pg);
        damacLogin.redirectToHome();
        
        Test.stopTest();
        
    }
}