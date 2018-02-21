/**************************************************************************************************
* Name               : DamacLoginController                                                 
* Description        : An apex page controller for site login                                             
* Created Date       : NSI - Diana                                                                        
* Created By         : 10/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          10/Jan/2017                                                               
**************************************************************************************************/


global with sharing class DamacLoginController {
/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/

	public string username{set;get;}
	public string password{set;get;}
	public boolean rememberMe{set;get;}
    public string registrationPageID{set;get;}
/**************************************************************************************************
    Method:         DamacLoginController
    Description:    Constructor executing model of the class 
**************************************************************************************************/

	public DamacLoginController() {
		rememberMe = false;
       
        if (ApexPages.currentPage().getCookies().get('username') != NULL)
            username = ApexPages.currentPage().getCookies().get('username').getValue();
        if (ApexPages.currentPage().getCookies().get('password') != NULL) {
            string codedpassword = ApexPages.currentPage().getCookies().get('password').getValue();
            system.debug('codedpassword ::' + codedpassword );
            blob blobcodedpassword =  EncodingUtil.base64Decode(codedpassword);
            password = blobcodedpassword.toString();
            system.debug('password::' + password);
        }


       
        registrationPageID = UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Page_Flow_Name);


	}
/**************************************************************************************************
    Method:         redirectToHome
    Description:    If the user is already logged in - redirect to portal landing page
**************************************************************************************************/

    public PageReference redirectToHome(){
        if(UserInfo.getUserType() != 'Guest'){
            return new PageReference('/Damac_Home');
        }

        return null;
    }

/**************************************************************************************************
    Method:         login
    Description:    Site login functionality
**************************************************************************************************/

	global PageReference login() {
		blob blobPassword = blob.valueof(password);
		string codedPassword = EncodingUtil.base64Encode(blobPassword);
		if (rememberMe == true) {
            cookie Name = new Cookie('username', Username, null, 365, false);
            cookie PasswordCokies = new Cookie('password', codedPassword, null, 365, false);
            ApexPages.currentPage().setCookies(new Cookie[] {Name, PasswordCokies});

        }

        return Site.login(username,password,'/Damac_Home');
	}
}