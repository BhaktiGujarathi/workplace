/**************************************************************************************************
* Name               : DamacForgotPasswordController                                               
* Description        : An apex page controller for forgot password                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 11/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          11/Jan/2017                                                               
**************************************************************************************************/

public with sharing class DamacForgotPasswordController {
/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/
	public string username{set;get;}
	public boolean isUserActive{set;get;}
/**************************************************************************************************
    Method:         DamacForgotPasswordController
    Description:    Constructor executing model of the class 
**************************************************************************************************/

	public DamacForgotPasswordController() {

		isUserActive = false;
		
	}
/**************************************************************************************************
    Method:         forgotPassword
    Description:    Site forgot password functionality --> check if the user exists 
**************************************************************************************************/

	public PageReference forgotPassword(){

		for(User currentUser:[Select Id,isActive,username, contactid from User where username=:username ]){
			isUserActive = currentUser.isActive;
		}

		if(isUserActive){
			PageReference pr = new PageReference('/Damac_ForgotPasswordConfirm');
			Site.forgotPassword(username);
			return pr;
		}
		else{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid username'));
		}
		return null;
	}

}