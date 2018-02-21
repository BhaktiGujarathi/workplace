public with sharing class VehicleNotificationService {
	public static final String STR_COMMUTER_SHUTTLE = 'Commuter Shuttle';
	public static final String STR_SUBJECT_LINE 	= 'Vehicle Submitted Notification';
	public static final String STR_REGULAR 	 	 	= 'Regular';
	public static final String STR_ROLE 	 		= 'Role';
	public static final String STR_RELATEDID 	 	= 'RelatedId';
	/* * * * * * * * * * * * *
	*  Method Name:  getPublicGroupMailAddresses
	*  Purpose:      This Method collects the list of emails of group member associated with the group
	*  Param:        String
	* * * * * * * * * * * * */
	public static List<String> getPublicGroupMailAddresses( String groupName ) {
		List<String> userMailAddresses = new List<String>();
		List<User> userToGetEmail = [ SELECT email
										   FROM user
							   			  WHERE id IN :getUserIdsFromGroup( groupName )  ];
	    if( userToGetEmail.size() > 0 ) {
			for( User objUser : userToGetEmail ) {
				userMailAddresses.add( objUser.email );
			}
	    }
		return userMailAddresses;
	}

	/* * * * * * * * * * * * *
	*  Method Name:  sendEmail
	*  Purpose:      This method notify the public group members for vehcile submitted today
	*  Param:        String
	* * * * * * * * * * * * */
	public static String sendEmail( String bodyOfEmail ) {
        List<String> userMailAddresses = getPublicGroupMailAddresses( STR_COMMUTER_SHUTTLE );
		Boolean isSuccess = false;
		String emailStatusMessage = '';
        Messaging.SingleEmailMessage objEmailTemplate = new Messaging.SingleEmailMessage();
		List<String> lstSendTo1 = new List<String>{'arjun.khatri@eternussolutions.com'};
        objEmailTemplate.setToAddresses(lstSendTo1);
        objEmailTemplate.setSubject( STR_SUBJECT_LINE );
        objEmailTemplate.setHtmlBody( bodyOfEmail );

	    Messaging.SendEmailResult[] sendEmailStatus = Messaging.sendEmail( new Messaging.SingleEmailMessage[] { objEmailTemplate } );

		for( Messaging.SendEmailResult objSendEmailResult : sendEmailStatus ) {
			if( objSendEmailResult.isSuccess() ) {
				isSuccess = true;
			}else {
				isSuccess = false;
				emailStatusMessage = String.join( objSendEmailResult.getErrors()  , ' , '  );
				break;
			}
		}
		if( isSuccess == true ) {
			emailStatusMessage = 'Success';
		}
	    return emailStatusMessage;
	}

	/* * * * * * * * * * * * *
	*  Method Name:  getUserIdsFromGroup
	*  Purpose:      This method collects all user's id from group and its subgroup
	*  Param:        Id
	* * * * * * * * * * * * */
	public static Set<id> getUserIdsFromGroup( String strGroupName ) {
		Set<Id> usersIdToGetEmail = new Set<Id>();
		Set<Id> subGroupId = new Set<Id>();
        String userTypePrefix = Schema.SObjectType.User.getKeyPrefix();

		for( Group objGroup : [ Select Id,Type ,DeveloperName,RelatedId
							 	   , ( Select Id, UserOrGroupId From GroupMembers LIMIT 100)
							    From Group
							   Where Name =: strGroupName
							     AND RelatedId = null ] ) {
			if( objGroup.GroupMembers.size() > 0 ) {
				for ( GroupMember objGroupMem : objGroup.GroupMembers ) {
					if( ( (String)objGroupMem.UserOrGroupId).startsWith( userTypePrefix ) ) {
						usersIdToGetEmail.add( objGroupMem.UserOrGroupId );
					}
					else if ( objGroup.Type == STR_REGULAR ) {
						subGroupId.add( objGroupMem.UserOrGroupId );
					}
				}
			}
		}
		if( subGroupId.size() > 0 ) {
			usersIdToGetEmail.addAll(getAllUserIdFromRoleIds(subGroupId));
		}
		return usersIdToGetEmail;
	}

	/* * * * * * * * * * * * *
	*  Method Name:  getAllUserIdFromRoleIds
	*  Purpose:      This method returns set of all user's id  from Roles
	*  Param:        Set
	* * * * * * * * * * * * */
	public static Set<Id> getAllUserIdFromRoleIds( Set<Id> setGroupIds ) {
		Set<Id> relatedRoleIdToGetUsersId = new Set<Id>();
		Set<Id> userRoleIdToGetUsersId = new Set<Id>();
		Set<Id> usersIdToGetEmail = new Set<Id>();
		Map<Id,Group> groupMap = new Map<Id, Group>([ Select Id,Type ,DeveloperName,RelatedId
								  						From Group
						 							   Where Id IN: setGroupIds
							       						 AND RelatedId != null]);
		if( groupMap.size() > 0 ) {
			relatedRoleIdToGetUsersId.addAll( Pluck.ids( STR_RELATEDID , groupMap ) );
		}

		if( relatedRoleIdToGetUsersId.size() > 0 ) {
			userRoleIdToGetUsersId.addAll( getAllSubordinateRoleIds( relatedRoleIdToGetUsersId ) );
		}
		Map<Id,User> idToUserMap = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :userRoleIdToGetUsersId]);
		if( idToUserMap.size() > 0 ) {
			usersIdToGetEmail.addAll( Pluck.ids( idToUserMap ) );
		}
		return usersIdToGetEmail;
	}

	/* * * * * * * * * * * * *
	*  Method Name:  getAllSubordinateRoleIds
	*  Purpose:      This is recursive method which returns set of all subordinate user's id
	*  Param:        Set
	* * * * * * * * * * * * */
	public static Set<Id> getAllSubordinateRoleIds( Set<Id> roleIds ) {
		Integer level = 1;
	    Integer SUPPORTING_LEVEL = 4;
	    Set<Id> currentRoleIds = new Set<Id>();
		List<UserRole> usersRole = [select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleId != null ];

		if( usersRole.size() > 0 ) {
			currentRoleIds.addAll( Pluck.ids( usersRole ) );
		}
	    if(currentRoleIds.size() > 0 && level <= SUPPORTING_LEVEL ) {
	        currentRoleIds.addAll(getAllSubordinateRoleIds(currentRoleIds));
			level++;
	    } else{
			currentRoleIds.addAll(roleIds);
		}
	    return currentRoleIds;
	}
}