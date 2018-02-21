/*
*Change History:
* CH01 # 337 # 14-03-2017 # Sivasankar # Encrypting the Mobile number
*/
public class AccountTrgHandler implements TriggerFactoryInterface  {

    //------ Variables
    public List<User> userListToActivate = new List<User>();
    public List<User> userListToDeActivate = new List<User>();
    
    
    public static void updateAgencySites(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        set<ID> accids = new set<Id>();
        for(Id thisKey : mapNewRecords.keySet()){
                Account newAccount = (Account)mapNewRecords.get(thisKey);
                Account oldAccount = (Account)mapOldRecords.get(thisKey);
            if(newAccount.Blacklisted__c != oldAccount.Blacklisted__c || newAccount.Terminated__c != oldAccount.Terminated__c){
                accids.add(thisKey);
            }
        }
        //and (Agency__r.Blacklisted__c = true or Agency__r.Terminated__c = true) 
        List<Agent_Site__c> lstAgs = new List<Agent_Site__c>();
        for(Agent_Site__c ags : [select id,name,Start_Date__c,Agency__r.Blacklisted__c,IsAccountBlackListedTerminated__c,Agency__r.Terminated__c,Active__c,Agency__c,End_Date__c,Reinstated_Date__c from Agent_Site__c where Agency__c in : accids]){
            if((ags.Agency__r.Blacklisted__c || ags.Agency__r.Terminated__c) && ags.End_Date__c == null){
                ags.End_Date__c = system.today();
                ags.Active__c = false;
                ags.IsAccountBlackListedTerminated__c = true;
            }
            else if(!ags.Agency__r.Blacklisted__c && !ags.Agency__r.Terminated__c && ags.IsAccountBlackListedTerminated__c){
                ags.End_Date__c = null;
                ags.Active__c = true;
                ags.IsAccountBlackListedTerminated__c = false;
            }
            lstAgs.add(ags);
        }
        if(lstAgs != null && !lstAgs.isempty()){
            update lstags;
        }
        
    }   
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> newAccountsList){ 
        List<Account> updateAccountList = new List<Account>();
        try{
        	encryptMobileNumbers((List<Account>)newAccountsList);//CH01
            for(sObject thisSObject : newAccountsList){
                Account thisAccount = (Account) thisSObject;
                if(thisAccount.IsPersonAccount){
                    updateAccountList.add(thisAccount);      
                }   
            }
            /* Calling method to update keys. */
            if(!updateAccountList.isEmpty()){
                updateKeys(updateAccountList);
            }  
           
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ 
        List<Account> updateAccountList = new List<Account>();
        try{
        	encryptMobileNumbers((List<Account>)mapNewRecords.values());//CH01
            for(Id thisKey : mapNewRecords.keySet()){
                Account newAccount = (Account)mapNewRecords.get(thisKey);
                Account oldAccount = (Account)mapOldRecords.get(thisKey);
                if(newAccount.IsPersonAccount){
                    if(newAccount.FirstName != oldAccount.FirstName ||
                       newAccount.LastName != oldAccount.LastName ||
                       newAccount.Phone != oldAccount.Phone ||
                       newAccount.Email__c != oldAccount.Email__c){
                        updateAccountList.add(newAccount);  
                    }   
                }
            }
            /* Calling method to update keys. */
            if(!updateAccountList.isEmpty()){
                updateKeys(updateAccountList);      
            }
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
         
    /*
    * By Pavithra , Is invoked by approval process result when Blacklisted/Terminated/Unblacklisted/Unterminated
    */
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        List<Id> accountListForDeactivateUser = new List<Id>();
        List<Id> accountListToActivateUser = new List<Id>();
        set<Id> accountIds = new set<Id>();
        
        for(Sobject sobj: mapNewRecords.values()){
            Account updatedAccount = (Account) sobj;
            Account previousValues = (Account) mapOldRecords.get(updatedAccount.Id);
            if((updatedAccount.Blacklisted__c &&  previousValues.Blacklisted__c==false) || (updatedAccount.Terminated__c && previousValues.Terminated__c==false)){
                accountListForDeactivateUser.add(updatedAccount.Id);                
            }else if(updatedAccount.Blacklisted__c != previousValues.Blacklisted__c || updatedAccount.Terminated__c != previousValues.Terminated__c && (updatedAccount.Terminated__c == false && updatedAccount.Blacklisted__c == false)){   
            //else if(() ((updatedAccount.Blacklisted__c==false &&  previousValues.Blacklisted__c==true) || (updatedAccount.Terminated__c==false && previousValues.Terminated__c==true))){
                accountListToActivateUser.add(updatedAccount.Id); 
            }
        }
        
        //---------- Blacklisted or Termination is unchecked 
        if(!accountListForDeactivateUser.isEmpty()){
            deactivateAgencyUsers(accountListForDeactivateUser);
            system.enqueueJob(new AsyncAgentWebservice (accountListForDeactivateUser,'Agent Updation'));
        }
        //---------- Blacklisted or Termination is checked 
        if(!accountListToActivateUser.isEmpty()){
            activateAgencyUsers(accountListToActivateUser);
            system.enqueueJob(new AsyncAgentWebservice (accountListToActivateUser,'Agent Updation'));
        }        
        updateAgencySites(mapNewRecords,mapOldRecords);
    }
    
    /*
    * Activate Account Users
    */
    public void activateAgencyUsers(List<Id> listToActivateUser){      
        System.debug('Activate '+listToActivateUser);
        for(User activateUser : UtilityQueryManager.getAllUsersOfAccounts(listToActivateUser)){
            activateUser.isActive = true ;
            userListToActivate.add(activateUser);
        }

        if(!userListToActivate.isEmpty())
           System.enqueueJob(new UpdateIsActiveOnUser(userListToActivate,userListToDeActivate));

    }

    /*
    * DeActivate Account Users
    */
    public void deactivateAgencyUsers(List<Id> listToDeActivateUser){
        System.debug('DeActivate '+listToDeActivateUser);
        for(User deactivateUser : UtilityQueryManager.getAllUsersOfAccounts(listToDeActivateUser)){
            deactivateUser.isActive = false ;
            userListToDeActivate.add(deactivateUser);
        }
        if(!userListToDeActivate.isEmpty())
            System.enqueueJob(new UpdateIsActiveOnUser(userListToActivate,userListToDeActivate));
    } 
    
    /*********************************************************************************************
    * @Description : Method to update the keys on account record.                                *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void updateKeys(List<Account> newAccountRecordsList){
        for(Account thisAccount : newAccountRecordsList){
            if(thisAccount.IsPersonAccount){
                if(String.isNotBlank(thisAccount.FirstName) && 
                   String.isNotBlank(thisAccount.LastName)){
                    if(String.isNotBlank(thisAccount.Email__c)){
                        thisAccount.Email_Key__c = thisAccount.FirstName+'__'+ thisAccount.LastName +'__'+ thisAccount.Email__c;        
                    }
                    if(String.isNotBlank(thisAccount.Phone)){
                        thisAccount.Phone_Key__c = thisAccount.FirstName+'__'+ thisAccount.LastName +'__'+ thisAccount.Phone;       
                    }
                }
            }   
        }   
    }
    
    // TOBE Implemented
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords,map<Id,sObject> mapOldRecords){ }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){ 

    }
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){ }
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    
    //CH01.Start
    /*********************************************************************************************
	* @Description : Method to mask the mobile number and encrypt them accordingly               *
	* @Params      : List<Account__c>                                                            *
	* @Return      : void                                                                        *
	*********************************************************************************************/
	@Testvisible private void encryptMobileNumbers(List<Account> newListAccounts){
		//iterate the Inquiries for masking
		for(Account thisAccount: newListAccounts){
			if (thisAccount.Record_Type_Name__c.containsIgnoreCase('Business') || thisAccount.Record_Type_Name__c.containsIgnoreCase('Person')){
				if(!validateMobileNumbers(thisAccount)){
					if(thisAccount.Record_Type_Name__c.containsIgnoreCase('Person')){
						thisAccount.PersonAssistantPhone = ( String.isBlank(thisAccount.Asst_Phone_Encrypt__c) && String.isBlank(thisAccount.Asst_Phone_Country_Code__c) ? '' :  ((String.isNotBlank(thisAccount.Asst_Phone_Encrypt__c) && (Trigger.isInsert || thisAccount.PersonAssistantPhone == null)) ? (thisAccount.Asst_Phone_Country_Code__c.subStringAfter(':')).trim()+''+UtilityHelperCls.removeFirstZero(thisAccount.Asst_Phone_Encrypt__c) : thisAccount.PersonAssistantPhone));
						thisAccount.PersonHomePhone = ( String.isBlank(thisAccount.Home_Phone_Encrypt__c) && String.isBlank(thisAccount.Home_Phone_Country_Code__c) ? '' :  ((String.isNotBlank(thisAccount.Home_Phone_Encrypt__c) && (Trigger.isInsert || thisAccount.PersonHomePhone == null)) ? (thisAccount.Home_Phone_Country_Code__c.subStringAfter(':')).trim()+''+UtilityHelperCls.removeFirstZero(thisAccount.Home_Phone_Encrypt__c) : thisAccount.PersonHomePhone));
						thisAccount.PersonMobilePhone = ( String.isBlank(thisAccount.Mobile_Encrypt__c) && String.isBlank(thisAccount.Mobile_Country_Code__c) ? '' :  ((String.isNotBlank(thisAccount.Mobile_Encrypt__c) && (Trigger.isInsert || thisAccount.PersonMobilePhone == null)) ? (thisAccount.Mobile_Country_Code__c.subStringAfter(':')).trim()+''+UtilityHelperCls.removeFirstZero(thisAccount.Mobile_Encrypt__c) : thisAccount.PersonMobilePhone));
						thisAccount.PersonOtherPhone = ( String.isBlank(thisAccount.Other_Phone_Encrypt__c) && String.isBlank(thisAccount.Other_Phone_Country_Code__c) ? '' :  ((String.isNotBlank(thisAccount.Other_Phone_Encrypt__c) && (Trigger.isInsert || thisAccount.PersonOtherPhone == null)) ? (thisAccount.Other_Phone_Country_Code__c.subStringAfter(':')).trim()+''+UtilityHelperCls.removeFirstZero(thisAccount.Other_Phone_Encrypt__c) : thisAccount.PersonOtherPhone));
						
						//Encrypting Mobile and storing it on the record.
						System.debug('Before Encryption = '+thisAccount);
						thisAccount.Asst_Phone_Encrypt__c = UtilityHelperCls.encryptMobile(UtilityHelperCls.removeFirstZero(thisAccount.PersonAssistantPhone));
						thisAccount.Home_Phone_Encrypt__c = UtilityHelperCls.encryptMobile(UtilityHelperCls.removeFirstZero(thisAccount.PersonHomePhone));
						thisAccount.Mobile_Encrypt__c = UtilityHelperCls.encryptMobile(UtilityHelperCls.removeFirstZero(thisAccount.PersonMobilePhone));
						thisAccount.Other_Phone_Encrypt__c = UtilityHelperCls.encryptMobile(UtilityHelperCls.removeFirstZero(thisAccount.PersonOtherPhone));
					}
					System.debug('Before Encryption = '+thisAccount);
					thisAccount.Phone = ( String.isBlank(thisAccount.Phone_Encrypt__c) && String.isBlank(thisAccount.Phone_Country_Code__c) ? '' :  ((String.isNotBlank(thisAccount.Phone_Encrypt__c) && (Trigger.isInsert || thisAccount.Phone == null)) ? (thisAccount.Phone_Country_Code__c.subStringAfter(':')).trim()+''+UtilityHelperCls.removeFirstZero(thisAccount.Phone_Encrypt__c) : thisAccount.Phone));
					thisAccount.Phone_Encrypt__c = UtilityHelperCls.encryptMobile(UtilityHelperCls.removeFirstZero(thisAccount.Phone));
					System.debug('After Encryption = '+thisAccount);
				}
			}
		}
	}
	

	
	/*********************************************************************************************
	* @Description : Method to validate the mobile number and country code values                *
	* @Params      : Account                                                            		 *
	* @Return      : void                                                                        *
	*********************************************************************************************/
	@TestVisible private Boolean validateMobileNumbers(Account thisAccount){
		Boolean isError = false;
		if(String.isNotBlank(thisAccount.Asst_Phone_Country_Code__c) && String.isBlank(thisAccount.Asst_Phone_Encrypt__c)){
			 thisAccount.Asst_Phone_Encrypt__c.addError('Asst. Phone can\'t be balnk if country code is selected.');
			 isError = true;
		}
		if (String.isBlank(thisAccount.Asst_Phone_Country_Code__c) && String.isNotBlank(thisAccount.Asst_Phone_Encrypt__c)){
			thisAccount.Asst_Phone_Country_Code__c.addError('Asst. Phone Country Code can\'t be balnk if Asst. Phone is Populated.');
			isError = true;
		}
		if(String.isNotBlank(thisAccount.Home_Phone_Country_Code__c) && String.isBlank(thisAccount.Home_Phone_Encrypt__c)){
			 thisAccount.Home_Phone_Encrypt__c.addError('Home Phone can\'t be balnk if Home Phone country code is selected.');
			 isError = true;
		}
		if (String.isBlank(thisAccount.Home_Phone_Country_Code__c) && String.isNotBlank(thisAccount.Home_Phone_Encrypt__c)){
			thisAccount.Home_Phone_Country_Code__c.addError('Home Phone Country Code can\'t be balnk if Home Phone is Populated.');
			isError = true;
		}
		if(String.isNotBlank(thisAccount.Mobile_Country_Code__c) && String.isBlank(thisAccount.Mobile_Encrypt__c)){
			 thisAccount.Mobile_Encrypt__c.addError('Mobile can\'t be balnk if Mobile country code is selected.');
			 isError = true;
		}
		if (String.isBlank(thisAccount.Mobile_Country_Code__c) && String.isNotBlank(thisAccount.Mobile_Encrypt__c)){
			thisAccount.Mobile_Country_Code__c.addError('Mobile Country Code can\'t be balnk if Mobile is Populated.');
			isError = true;
		}
		if(String.isNotBlank(thisAccount.Other_Phone_Country_Code__c) && String.isBlank(thisAccount.Other_Phone_Encrypt__c)){
			 thisAccount.Other_Phone_Encrypt__c.addError('Other Phone can\'t be balnk if Other Phone country code is selected.');
			 isError = true;
		}
		if (String.isBlank(thisAccount.Other_Phone_Country_Code__c) && String.isNotBlank(thisAccount.Other_Phone_Encrypt__c)){
			thisAccount.Other_Phone_Country_Code__c.addError('Other Phone Country Code can\'t be balnk if Other Phone is Populated.');
			isError = true;
		}
		if(String.isNotBlank(thisAccount.Phone_Country_Code__c) && String.isBlank(thisAccount.Phone_Encrypt__c)){
			 thisAccount.Phone_Encrypt__c.addError('Phone can\'t be balnk if Phone country code is selected.');
			 isError = true;
		}
		if (String.isBlank(thisAccount.Phone_Country_Code__c) && String.isNotBlank(thisAccount.Phone_Encrypt__c)){
			thisAccount.Phone_Country_Code__c.addError('Phone Country Code can\'t be balnk if Phone is Populated.');
			isError = true;
		}
		return isError;
	}
    //CH01.End
}// End of class.