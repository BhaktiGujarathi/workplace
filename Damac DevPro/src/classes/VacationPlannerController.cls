/**************************************************************************************************
* Name               : VacationPlannerController                                                  *
* Description        : This is a controller class for VacationPlanner page.                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE                                                              *
* 1.0         NSI - Vineet      17/01/2017                                                        *
**************************************************************************************************/
public class VacationPlannerController extends DamacUtility{
	
	public String userSearchString {get; set;}
	public String errorMessage {get; set;}
	public List<User> userList {get; set;}
	private Map<Id, User> childUserMap;
	
	private void init(){
		errorMessage = '';
	}	  
	
	/*********************************************************************************************
    * @Description : Controller.                                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public VacationPlannerController(){
		init(); 
		try{
			childUserMap = UtilityQueryManager.getUserChildDetails(new Set<Id>{UserInfo.getUserId()});		
			if(!childUserMap.values().isEmpty()){
				userList = new List<User>(childUserMap.values()); 
			}else{
				userList = new List<User>();
				errorMessage = 'No reporting users found.';	
			}
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
	}
	
	/*********************************************************************************************
    * @Description : Method to save leave details for sub ordinates.                             *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void saveDetails(){
		try{
			if(!userList.isEmpty()){
				update userList;
				throwError('CONFIRM', 'Leave details saved.');	 
			}	
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }	
	}
	
	/*********************************************************************************************
    * @Description : Method to search users.                                                     *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void searchUsers(){
		try{
			userList.clear();
			for(User thisUser : childUserMap.values()){
				if(String.isNotBlank(thisUser.Name) && thisUser.Name.containsIgnoreCase(userSearchString)){
					userList.add(thisUser);		
				}	
			}
			if(userList.isEmpty()){
				errorMessage = 'No user found for the matching string.';	
			}
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }		
	}
}// End of class.