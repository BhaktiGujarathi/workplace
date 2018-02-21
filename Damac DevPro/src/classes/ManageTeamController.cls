/**************************************************************************************************
* Name               : ManageTeamController                                                       *
* Description        : This is a controller class for Manage Team page.                           *
* Created Date       : 22/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE                                                              *
* 1.0         NSI - Vineet      22/01/2017                                                        *
**************************************************************************************************/
public class ManageTeamController extends DamacUtility{
	
	public String userSearchString {get; set;}
	public String selectedGroupName {get; set;}
	public String selectedInitial {get; set;}
	public String selectedLanguage {get; set;}
	public String selectedNationality {get; set;}
	public String selectedHos {get; set;}
	public String selectedDos {get; set;}
	public String selectedOffice {get; set;}
	public String selectedValue {get; set;}
	public String selectedFilter {get; set;}
	public String errorMessage {get; set;}
	public String removeUserId {get; set;}
	public String editGroupId {get; set;}
	public String deleteGroup {get; set;}
	public Boolean showNewTeam {get; set;}
	public TeamWrapper twObject {get; set;}
	public List<UserWrapper> uwObjectList {get; set;} 
	public List<GroupWrapper> gwObjectList {get; set;} 
	public List<String> directoryList {get; set;} 
	public List<SelectOption> languages {get; set;}
	public List<SelectOption> nationality {get; set;}
	public List<SelectOption> salesOffices {get; set;}
	public Map<String, GroupWrapper> gwObjectMap {get; set;}
	public Map<String, List<User>> hosSelectedUsersList {get; set;}
	
	private Integer defaultRows = 15;
	private Integer counter = 0;
	private Group createGroup = new Group();
	private List<String> INTERNAL_PROFILE = new List<String>{'Head of Sales', 'Director of Sales', 'Property Consultant', 'Sales Manager'};
	private Map<String, List<User>> initialsUserMap;
    private Map<String, List<User>> languageUsersListMap;
    private Map<String, List<User>> nationalityUsersListMap;
    private Map<String, List<User>> officeUsersListMap;
    private Map<String, List<User>> hosUsersListMap;
    private Map<String, List<User>> dosUsersListMap;
    private Map<String, User> userNameMap;
	private UserMapWrapper umwObject;
	
	private void init(){
		uwObjectList = new List<UserWrapper>();
		twObject = new TeamWrapper('', new List<User>());	
		initialsUserMap = new Map<String, List<User>>();
		hosSelectedUsersList = new Map<String, List<User>>();
		directoryList = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
	}
	
	/*********************************************************************************************
    * @Description : Controller.                                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public ManageTeamController(){
		init();	
		try{
		    /* Calling method to get available users. */
		    umwObject = getAvailableUser();
		    initialsUserMap = umwObject.initialsUserMap;
		    languageUsersListMap = umwObject.languageUsersListMap;
		    nationalityUsersListMap = umwObject.nationalityUsersListMap;
		    officeUsersListMap = umwObject.officeUsersListMap;
		    hosUsersListMap = umwObject.hosUsersListMap;
		    dosUsersListMap = umwObject.dosUsersListMap;
		    userNameMap = umwObject.userNameMap;
		    
		    languages = new List<SelectOption>(getLanguages());
		    nationality = new List<SelectOption>(getNationality());
		    salesOffices = new List<SelectOption>(getSalesOffice());
		    for(String thisKey : initialsUserMap.keySet()){
		    	for(User thisUsers : initialsUserMap.get(thisKey)){
		    		if(defaultRows == counter){
		    			break;	
		    		}else{
		    			uwObjectList.add(new UserWrapper(false, thisUsers));
		    		}	
		    		counter++;
		    	}	
		    }
    		/* Calling method to get available teams. */
    		gwObjectMap = getAvailableTeams();
    		gwObjectList = new List<GroupWrapper>(gwObjectMap.values());
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
	}
	
	/*********************************************************************************************
    * @Description : Method to get available languages.                                          *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
	public List<SelectOption> getLanguages(){
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select Language --'));
        if(languageUsersListMap != null){
	        for(String thisKey : languageUsersListMap.keySet()){
	        	options.add(new SelectOption(thisKey, thisKey));
	        }
        }
        return options;
	}
	
	/*********************************************************************************************
    * @Description : Method to get available nationality.                                        *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
	public List<SelectOption> getNationality(){
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select Nationality --'));
        if(nationalityUsersListMap != null){
	        for(String thisKey : nationalityUsersListMap.keySet()){
	        	options.add(new SelectOption(thisKey, thisKey));
	        }
        }
        return options;
	}
	
	/*********************************************************************************************
    * @Description : Method to get available sales office.                                       *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
	public List<SelectOption> getSalesOffice(){
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select Office --'));
        if(officeUsersListMap != null){
	        for(String thisKey : officeUsersListMap.keySet()){
	        	options.add(new SelectOption(thisKey, thisKey));
	        }
        }
        return options;
	}
	
	/*********************************************************************************************
    * @Description : Method to edit team details.                                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void editGroup(){
	    Set<Id> groupMembersSet = new Set<Id>();
    	try{ 
    		showNewTeam = true;
    	    if(String.isNotBlank(editGroupId)){
    	        if(gwObjectMap.containsKey(editGroupId)){
    	            twObject.teamMembers.clear();
    	            twObject.teamName = editGroupId;
        	        createGroup = gwObjectMap.get(editGroupId).selectedGroup;
        			for(User thisUser : gwObjectMap.get(editGroupId).groupMemberList){
    				    twObject.teamMembers.add(thisUser);	
    				    groupMembersSet.add(thisUser.Id);
        			}
        			for(UserWrapper thisUserWrapped : uwObjectList){
        			    if(groupMembersSet.contains(thisUserWrapped.activeUser.Id)){
        			        thisUserWrapped.isUserSelected = true;       
        			    }
        			}
    	        }
    	    }
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }	    
	}
    
    /*********************************************************************************************
    * @Description : Method to delete group details.                                             *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void deleteGroup(){
        try{ 
            if(String.isNotBlank(deleteGroup)){
                Group deleteGroupRecord = new Group(Id=deleteGroup);
                gwObjectList.clear();
                for(GroupWrapper thisGwObject : gwObjectMap.values()){
                    if(thisGwObject.selectedGroup.Id != deleteGroupRecord.Id){
                        gwObjectList.add(thisGwObject);    
                    }
                }
                delete deleteGroupRecord;
            	throwError('CONFIRM', 'Team deleted.');
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
	public void addTeamMember(){
		try{
			if(String.isNotBlank(userSearchString) && userNameMap.containsKey(userSearchString)){
				twObject.teamMembers.add(userNameMap.get(userSearchString));	
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
			uwObjectList.clear();
			for(String thisKey : userNameMap.keySet()){
				if(thisKey.containsIgnoreCase(userSearchString)){
					uwObjectList.add(new UserWrapper(false, userNameMap.get(thisKey)));
				}	
			}
			if(uwObjectList.isEmpty()){
				errorMessage = 'No user found for the matching string.';	
			}
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }		
	}
	
	/*********************************************************************************************
    * @Description : Method to select team members.                                              *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void selectMembers(){
		try{
			showNewTeam = true;
			twObject.teamMembers.clear();
			for(UserWrapper thisUser : uwObjectList){
				if(thisUser.isUserSelected){
					twObject.teamMembers.add(thisUser.activeUser);	
					if(String.isNotBlank(thisUser.activeUser.EMP_ID__c) && 
					   hosUsersListMap.containsKey(thisUser.activeUser.EMP_ID__c) && 
					   !hosUsersListMap.get(thisUser.activeUser.EMP_ID__c).isEmpty()){
					    twObject.teamMembers.addAll(hosUsersListMap.get(thisUser.activeUser.EMP_ID__c));   
					}
					if(String.isNotBlank(thisUser.activeUser.EMP_ID__c) && 
					   dosUsersListMap.containsKey(thisUser.activeUser.EMP_ID__c) && 
					   !dosUsersListMap.get(thisUser.activeUser.EMP_ID__c).isEmpty()){
					    twObject.teamMembers.addAll(dosUsersListMap.get(thisUser.activeUser.EMP_ID__c));   
					}
				}
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
	public void removeTeamMember(){ 
		try{
			twObject.teamMembers.clear();
			for(UserWrapper thisUser : uwObjectList){
				String thisUserId = thisUser.activeUser.Id;
				if(thisUser.isUserSelected){
					if(String.isNotBlank(removeUserId) && thisUserId.startsWith(removeUserId)){
						thisUser.isUserSelected = false;	
					}else{
						twObject.teamMembers.add(thisUser.activeUser);
					}	
				}
			}
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }	
	} 
	
	/*********************************************************************************************
    * @Description : Method to save team details.                                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void saveTeam(){
		List<GroupMember> groupMemberList = new List<GroupMember>();
		Map<String, List<User>> teamUserListMap = new Map<String, List<User>>();
		try{
			if(createGroup.Id == null){
    			createGroup.Name = twObject.teamName;
    			createGroup.DeveloperName = twObject.teamName.trim().contains(' ') ? twObject.teamName.replaceAll(' ', '_')+'_DAMAC_TEAM' : twObject.teamName.trim()+'_DAMAC_TEAM'; 
    			insert createGroup;
			}
			if(createGroup.Id != null && twObject.teamMembers != null && twObject.teamMembers.size() > 0){
				for(User thisUser : twObject.teamMembers){
					groupMemberList.add(new GroupMember(GroupId = createGroup.Id, UserOrGroupId = thisUser.Id));	
				}	
				teamUserListMap.put(createGroup.Id, new List<User>(twObject.teamMembers));
			}
			if(!groupMemberList.isEmpty()){
				upsert groupMemberList;
				gwObjectList.add(new GroupWrapper(createGroup, twObject.teamMembers));  
				/* Calling method to remove inventory user record. */
				if(!teamUserListMap.isEmpty()){
				    InventoryTrgHandler.addUserAccess(teamUserListMap);
				}
				throwError('CONFIRM', 'Team details saved.');
			}
		}catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }		
	}
	
	/********************************************************************************************* 
    * @Description : Method to get available users based on selected intials.                    *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void getRelevantUsers(){
	    try{
    		uwObjectList.clear();
    		if(String.isNotBlank(selectedFilter)){
    			if(selectedFilter.equalsIgnoreCase('Initial') && String.isNotBlank(selectedInitial)){
    				for(User thisUser : initialsUserMap.get(selectedInitial)){
    					uwObjectList.add(new UserWrapper(false, thisUser));	
    				}	
    			}
    			if(selectedFilter.equalsIgnoreCase('Office') && String.isNotBlank(selectedOffice)){
    				for(User thisUser : officeUsersListMap.get(selectedOffice)){
    					uwObjectList.add(new UserWrapper(false, thisUser));	
    				}	
    			}
    			if(selectedFilter.equalsIgnoreCase('nationality') && String.isNotBlank(selectedNationality)){
    				for(User thisUser : nationalityUsersListMap.get(selectedNationality)){
    					uwObjectList.add(new UserWrapper(false, thisUser));	
    				}	
    			}
    			if(selectedFilter.equalsIgnoreCase('language') && String.isNotBlank(selectedLanguage)){
    				for(User thisUser : languageUsersListMap.get(selectedLanguage)){
    					uwObjectList.add(new UserWrapper(false, thisUser));	
    				}	
    			}
    			if(selectedFilter.equalsIgnoreCase('hos') && String.isNotBlank(selectedValue)){
    				if(userNameMap.containsKey(selectedValue) && String.isNotBlank(userNameMap.get(selectedValue).EMP_ID__c)){
        				for(User thisUser : hosUsersListMap.get(userNameMap.get(selectedValue).EMP_ID__c)){
        					uwObjectList.add(new UserWrapper(false, thisUser));	
        				}	
    				}
    			} 
    			if(selectedFilter.equalsIgnoreCase('dos') && String.isNotBlank(selectedValue)){
    				if(userNameMap.containsKey(selectedValue) && String.isNotBlank(userNameMap.get(selectedValue).EMP_ID__c)){
        				for(User thisUser : dosUsersListMap.get(userNameMap.get(selectedValue).EMP_ID__c)){
        					uwObjectList.add(new UserWrapper(false, thisUser));	
        				}	
    				}
    			}
    		}
	    }catch(exception ex){
            throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
	}
	
	/*********************************************************************************************
    * @Description : Method to get show new team section.                                        *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void createNewTeam(){
		showNewTeam = true;	
		twObject = new TeamWrapper('', new List<User>());	
	}
	
	/*********************************************************************************************
    * @Description : Remote action method to auto populate the fields.                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	@RemoteAction 
    public static List<String> searchUser(String searchTerm, String autoFor) {
        List<String> usersList = new List<String>();
        try{
	        String queryString = 'SELECT Id, Name FROM User WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Profile.Name=\''+autoFor+'\' AND IsActive = true';
	        for(User thisUser : Database.query(queryString)){
	            usersList.add(thisUser.Name);
	        }
        }catch(exception ex){
            DamacUtility.throwError('ERROR', 'Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
        return usersList;
    }
    
	/*********************************************************************************************
    * @Description : Method to get available team.                                               *
    * @Params      : void                                                                        *
    * @Return      : Map<String, GroupWrapper>                                                   *
    *********************************************************************************************/
	@testVisible private Map<String, GroupWrapper> getAvailableTeams(){
		String userType = Schema.SObjectType.User.getKeyPrefix();
		List<Group> groupList = new List<Group>();
		Set<Id> memberUserIdSet = new Set<Id>();
		Map<Id, User> userDetailsMap = new Map<Id, User>();
		Map<String, GroupWrapper> gwObjectMap = new Map<String, GroupWrapper>();
		for(User thisUser : [SELECT Id, Name, UserRoleId FROM User WHERE Id IN: memberUserIdSet]){
	        userDetailsMap.put(thisUser.Id, thisUser);    
	    } 
		for(Group thisGroup : [SELECT Id, Name, DeveloperName, 
									  (SELECT Id, UserOrGroupId FROM GroupMembers)
							   FROM Group 
							   WHERE DeveloperName LIKE '%_DAMAC_TEAM']){
			if(String.isNotBlank(thisGroup.Name)){
		    	groupList.add(thisGroup);
			}
			for(GroupMember thisMember : thisGroup.GroupMembers){
    			if (((String)thisMember.UserOrGroupId).startsWith(userType)){
                    memberUserIdSet.add(thisMember.UserOrGroupId);
                }
			}
		}
		if(!memberUserIdSet.isEmpty()){
		    if(!userDetailsMap.isEmpty()){
		        for(Group thisGroup : groupList){
		            GroupWrapper gwObject = new GroupWrapper(thisGroup, new List<User>());
		            for(GroupMember thisMember : thisGroup.GroupMembers){
    		            if(userDetailsMap.containsKey(thisMember.UserOrGroupId)){
    		                gwObject.groupMemberList.add(userDetailsMap.get(thisMember.UserOrGroupId));
    		            }   
		            }
		            gwObjectMap.put(thisGroup.Name, gwObject);
		        }   
		    }
		}
		return gwObjectMap;
	} 
	
	/*********************************************************************************************
    * @Description : Method to save leave details for sub ordinates.                             *
    * @Params      : void                                                                        *
    * @Return      : UserMapWrapper                                                              *
    *********************************************************************************************/
    @testVisible private UserMapWrapper getAvailableUser() {
    	
    	Map<String, List<User>> initialsUserMap = new Map<String, List<User>>();
    	Map<String, List<User>> languageUsersListMap = new Map<String, List<User>>();
    	Map<String, List<User>> nationalityUsersListMap = new Map<String, List<User>>();
    	Map<String, List<User>> officeUsersListMap = new Map<String, List<User>>();
    	Map<String, List<User>> hosUsersListMap = new Map<String, List<User>>();
    	Map<String, List<User>> dosUsersListMap = new Map<String, List<User>>();
    	Map<String, User> userNameMap = new Map<String, User>();
    	
        for(User thisUser : [SELECT Id, Name, UserRoleId, UserRole.Name, Profile.Name, Languages_Known__c, 
        							Nationality__c, Sales_Office__c, HOS_ID__c, DOS_ID__c, EMP_ID__c  
        					 FROM User 
        					 WHERE IsActive = true AND IsPortalEnabled = false AND Profile.Name IN: INTERNAL_PROFILE
        					 ORDER BY Name]){ 
            /* Creating map of initials and users. */
            if(initialsUserMap.containsKey(thisUser.Name.substring(0,1).toUpperCase())){
            	initialsUserMap.get(thisUser.Name.substring(0,1).toUpperCase()).add(thisUser);		
            }else{
            	initialsUserMap.put(thisUser.Name.substring(0,1).toUpperCase(), new List<User>{thisUser});	
            }
            /* Creating map of language and users. */
            if(String.isNotBlank(thisUser.Languages_Known__c)){
            	for(String thisLanguage : splitMutliSelect(thisUser.Languages_Known__c)){
            		if(languageUsersListMap.containsKey(thisLanguage)){
		            	languageUsersListMap.get(thisLanguage).add(thisUser);		
		            }else{
		            	languageUsersListMap.put(thisLanguage, new List<User>{thisUser});	
		            }
           		}	
            }
            /* Creating map of nationality and users. */
            if(String.isNotBlank(thisUser.Nationality__c)){
        		if(nationalityUsersListMap.containsKey(thisUser.Nationality__c)){
	            	nationalityUsersListMap.get(thisUser.Nationality__c).add(thisUser);		
	            }else{
	            	nationalityUsersListMap.put(thisUser.Nationality__c, new List<User>{thisUser});	
	            }
            }
            /* Creating map of office and users. */
            if(String.isNotBlank(thisUser.Sales_Office__c)){
        		if(officeUsersListMap.containsKey(thisUser.Sales_Office__c)){
	            	officeUsersListMap.get(thisUser.Sales_Office__c).add(thisUser);		
	            }else{
	            	officeUsersListMap.put(thisUser.Sales_Office__c, new List<User>{thisUser});	
	            }
            }
            /* Creating map of HOS and users. */
            if(String.isNotBlank(thisUser.HOS_ID__c)){
        		if(hosUsersListMap.containsKey(thisUser.HOS_ID__c)){
	            	hosUsersListMap.get(thisUser.HOS_ID__c).add(thisUser);		
	            }else{
	            	hosUsersListMap.put(thisUser.HOS_ID__c, new List<User>{thisUser});	
	            }
            }
            /* Creating map of DOS and users. */
            if(String.isNotBlank(thisUser.DOS_ID__c)){
        		if(dosUsersListMap.containsKey(thisUser.DOS_ID__c)){
	            	dosUsersListMap.get(thisUser.DOS_ID__c).add(thisUser);		
	            }else{
	            	dosUsersListMap.put(thisUser.DOS_ID__c, new List<User>{thisUser});	
	            }
            }
            /* Creating map of name and users. */
            userNameMap.put(thisUser.Name, thisUser);
        }
        
        return new UserMapWrapper(initialsUserMap, languageUsersListMap, nationalityUsersListMap, officeUsersListMap, hosUsersListMap, dosUsersListMap, userNameMap);
    }
    
    /*********************************************************************************************
    * @Description : Method to save user details map based on different keys.                    *
    *********************************************************************************************/
    public class UserMapWrapper{
    	public Map<String, User> userNameMap;
    	public Map<String, List<User>> initialsUserMap;
    	public Map<String, List<User>> languageUsersListMap;
    	public Map<String, List<User>> nationalityUsersListMap;
    	public Map<String, List<User>> officeUsersListMap;
    	public Map<String, List<User>> hosUsersListMap;
    	public Map<String, List<User>> dosUsersListMap;
    	
    	public UserMapWrapper(Map<String, List<User>> initialsUserMap, 
    						  Map<String, List<User>> languageUsersListMap, 
    						  Map<String, List<User>> nationalityUsersListMap,
    						  Map<String, List<User>> officeUsersListMap,
    						  Map<String, List<User>> hosUsersListMap,
    						  Map<String, List<User>> dosUsersListMap,
    						  Map<String, User> userNameMap){
    		this.initialsUserMap = initialsUserMap;
    		this.languageUsersListMap = languageUsersListMap;
    		this.nationalityUsersListMap = nationalityUsersListMap;
    		this.officeUsersListMap = officeUsersListMap;	
    		this.hosUsersListMap = hosUsersListMap;
    		this.dosUsersListMap = dosUsersListMap;
    		this.userNameMap = userNameMap;
    	}
    } 
    
    /*********************************************************************************************
    * @Description : Method to save leave details for sub ordinates.                             *
    *********************************************************************************************/
	public class TeamWrapper{
		public String teamName {get; set;}
		public List<User> teamMembers {get; set;}
		
		public TeamWrapper(String teamName, List<User> teamMembers){
			this.teamName = teamName;
			this.teamMembers = new List<User>(teamMembers);	
		}	
	}    
	
	/*********************************************************************************************
    * @Description : Method to save leave details for sub ordinates.                             *
    *********************************************************************************************/
	public class UserWrapper{
		public Boolean isUserSelected {get; set;}
		public User activeUser {get; set;}
		
		public UserWrapper(Boolean isUserSelected, User activeUser){
			this.isUserSelected = isUserSelected;
			this.activeUser = activeUser;	
		}	
	}    
	
	/*********************************************************************************************
    * @Description : Method to get group and group members.                                      *
    *********************************************************************************************/
	public class GroupWrapper{
		public Group selectedGroup {get; set;}
		public List<User> groupMemberList {get; set;}
		
		public GroupWrapper(Group selectedGroup, List<User> groupMemberList){
			this.selectedGroup = selectedGroup;
			this.groupMemberList = groupMemberList;	
		}	
	}  
}// End of class.