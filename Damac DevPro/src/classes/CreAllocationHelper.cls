public with sharing class CreAllocationHelper {
    
    public static String makeQueryString( set<Group> setGroupsForReallocation ) {
    	String strQuery = '';
    	if( setGroupsForReallocation != null && !setGroupsForReallocation.isEmpty() ) {
			strQuery += 'SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName = ';
			for( Group objGroup : setGroupsForReallocation ) {
				strQuery += objGroup.DeveloperName;
				setGroupsForReallocation.remove( objGroup );
				break;
			}
    	}
    	return strQuery;
    }
    
    public static CreAllocationUtility.CreAllocationDetailObject getCreAllocationDetailObject( list<Account> lstAccounts ) {
    	CreAllocationUtility.CreAllocationDetailObject objCreDetails = new CreAllocationUtility.CreAllocationDetailObject( lstAccounts );
    	getCreGroupInformation( objCreDetails ); 
    	if( objCreDetails.mapCreGroupInfo != null && !objCreDetails.mapCreGroupInfo.isEmpty() ) {
    		getCreUsers( objCreDetails );
    	}
    	system.debug('==objCreDetails=='+objCreDetails);
    	return objCreDetails ;
    }
        
    private static void getCreGroupInformation( CreAllocationUtility.CreAllocationDetailObject objCreDetails ) {
    	map<String, map<String, list<String>>> mapCreGroupInfo ;
    	list<CRE_Allocation_Group_Setting__mdt> lstGroupSettings = CreAllocationUtility.getGroupSettings();
    	if( lstGroupSettings != null && !lstGroupSettings.isEmpty() ) {
    		mapCreGroupInfo = new map<String, map<String, list<String>>>();
	    	for( CRE_Allocation_Group_Setting__mdt objGroupSetting : lstGroupSettings ) { 
	    		if( mapCreGroupInfo.containsKey( objGroupSetting.Parent_Queue__c ) ) {
    				mapCreGroupInfo.get( objGroupSetting.Parent_Queue__c ).put( objGroupSetting.MasterLabel, new list<String>{ objGroupSetting.Group_Name__c , objGroupSetting.Secondary_Group_Name__c, objGroupSetting.Tertiary_Group_Name__c} );
	    		}
	    		else {
	    			mapCreGroupInfo.put( objGroupSetting.Parent_Queue__c, new map<String, list<String>>{ objGroupSetting.MasterLabel => new list<String>{ objGroupSetting.Group_Name__c , objGroupSetting.Secondary_Group_Name__c, objGroupSetting.Tertiary_Group_Name__c } } );
	    		}
	    	}
    		objCreDetails.mapCreGroupInfo = mapCreGroupInfo ; 
    	}
    }
    
    private static void getCreUsers( CreAllocationUtility.CreAllocationDetailObject objCreDetails ) {
    	system.debug('== Inside getCreUsers method == ');
    	set<String> setCreGroupName = CreAllocationUtility.extractCreGroupName( objCreDetails );
    	if( setCreGroupName != null && !setCreGroupName.isEmpty() ) {
    		list<GroupMember> lstCreMembers = CreAllocationUtility.getGroupMembers( setCreGroupName );
	    	system.debug('--lstCreMembers--'+lstCreMembers);
	    	if( lstCreMembers != null && !lstCreMembers.isEmpty() ) {
				set<Id> setCreId = CreAllocationUtility.extractCreId( lstCreMembers );
				system.debug('--setCreId--'+setCreId);
				if( setCreId != null && !setCreId.isEmpty() ) {
					map<Id, Integer> mapCreWorkLoad = calculateCreWorkLoad( setCreId );
					system.debug('--mapCreWorkLoad--'+mapCreWorkLoad);
					if( mapCreWorkLoad != null ) {
						String strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix() ;
						for( GroupMember objMember : lstCreMembers ) {
							if( objMember.UserOrGroupId != null && 
								String.valueOf( objMember.UserOrGroupId ).subString(0,3).equalsIgnoreCase( strUserKeyPrefix ) &&
								mapCreWorkLoad.containsKey( objMember.UserOrGroupId ) ) {
				    			if( objCreDetails.mapGroupNameCreId.containsKey( objMember.Group.DeveloperName ) ) {
				    				if( mapCreWorkLoad.get( objCreDetails.mapGroupNameCreId.get( objMember.Group.DeveloperName )[0] ) >  mapCreWorkLoad.get( objMember.UserOrGroupId ) ) {
				    					objCreDetails.mapGroupNameCreId.get( objMember.Group.DeveloperName ).clear();
				    					objCreDetails.mapGroupNameCreId.get( objMember.Group.DeveloperName ).add( objMember.UserOrGroupId );
				    				}
				    				else {
				    					objCreDetails.mapGroupNameCreId.get( objMember.Group.DeveloperName ).add( objMember.UserOrGroupId );//.sort();
				    				}
				    			}
				    			else {
				    				objCreDetails.mapGroupNameCreId.put( objMember.Group.DeveloperName, new list<Id> { objMember.UserOrGroupId } );
				    			}
				    		}
						}
					}
				}
			}
    	}
    }
    
    public static map<Id, Integer> calculateCreWorkLoad( set<Id> setCreId ) {
    	map<Id, Integer> mapCreWorkLoad = new map<Id, Integer>() ;
    	map<Id,map<String,Integer>> mapCreIdTasks ;
    	map<Id,Integer> mapCreIdCases ;
    	map<Id,map<String, Integer>> mapCreExistingUnits ;
    	system.debug( 'setCreId===' +setCreId );
    	
    	list<Task> lstCreTasks = CreAllocationUtility.getTasks( setCreId );
    	system.debug( 'lstCreTasks===' +lstCreTasks );
    	system.debug( 'lstCreTasks===' +lstCreTasks.size() );
    	
    	if( lstCreTasks != null && !lstCreTasks.isEmpty() ) {
    		mapCreIdTasks = createMapCreIdTasks( lstCreTasks );
    	}else {
    		mapCreIdTasks = new map<Id,map<String,Integer>>() ;
    	}
    	list<Case> lstCreCases = CreAllocationUtility.getCases( setCreId );
    	system.debug( 'lstCreCases===' +lstCreCases );
    	system.debug( 'lstCreCases===' +lstCreCases.size() );
    	if( lstCreCases != null && !lstCreCases.isEmpty() ) {
    		mapCreIdCases = createMapCreIdCases( lstCreCases ) ;
    	}
    	else {
    		mapCreIdCases = new map<Id,Integer>() ;
    	}
    	
    	list<Booking_Unit__c> lstBookingUnit = CreAllocationUtility.getUnitsFromCREIds( setCreId );
    	if( lstBookingUnit != null && !lstBookingUnit.isEmpty() ) {
    		mapCreExistingUnits = createMapCreBookingUnits( lstBookingUnit ) ;
    	}
    	else {
    		mapCreExistingUnits = new map<Id,map<String,Integer>>() ;
    	}
    	system.debug( 'mapCreIdTasks===' +mapCreIdTasks );
    	system.debug( 'mapCreIdCases===' +mapCreIdCases );
    	
    	if( mapCreIdTasks != null || mapCreIdCases != null || mapCreExistingUnits != null ) {
    		map<Id, User> mapUserInfo = CreAllocationUtility.getUserInfo( setCreId );
    		map<String, Decimal> mapTypeWeightage = CreAllocationUtility.getTaskWeightage();
    		for( Id creId : setCreId ) {
    			Decimal intNumberOfTasks = 0;
    			Decimal intCreWorkDuration = 0;
    			if( mapCreIdCases != null && mapCreIdCases.containsKey( creId ) && mapTypeWeightage.containsKey( 'Case' ) ) {
    				intNumberOfTasks += mapCreIdCases.get( creId ) * mapTypeWeightage.get( 'Case' );
    			}
    			
    			if( mapCreIdTasks != null && mapCreIdTasks.containsKey( creId ) ) {
    				for( String strTaskType : mapCreIdTasks.get( creId ).keySet() ) {
    					if( mapTypeWeightage.containsKey( strTaskType ) ) {
    						intNumberOfTasks += mapCreIdTasks.get( creId ).get( strTaskType ) * mapTypeWeightage.get( strTaskType );
    					}
    				}
    			}
    			
    			if( mapCreExistingUnits != null && mapCreExistingUnits.containsKey( creId ) ) {
    				for( String strUnitType : mapCreExistingUnits.get( creId ).keySet() ) {
    					if( mapTypeWeightage.containsKey( strUnitType ) ) {
    						intNumberOfTasks += mapCreExistingUnits.get( creId ).get( strUnitType ) * mapTypeWeightage.get( strUnitType );
    					}
    				}
    			}
    			
    			if( mapUserInfo != null && mapUserInfo.containsKey( creId ) ) {
    				Date dateCreCreation = Date.valueOf( mapUserInfo.get( creId ).CreatedDate ) ;
    				Integer intNumberOfMonths = dateCreCreation.monthsBetween( system.today() );
    				if( intNumberOfMonths == 0 ) {
    					intCreWorkDuration = 1;
    				}
    				else if( intNumberOfMonths > 3 ) {
    					intCreWorkDuration = 3;
    				} 
    				else {
    					intCreWorkDuration = intNumberOfMonths ;
    				}
    			}
    			
    			if( intNumberOfTasks != 0 && intCreWorkDuration != 0 ) {
    				mapCreWorkLoad.put( creId, Integer.valueOf( intNumberOfTasks / intCreWorkDuration ) );
    			}
    			else {
    				mapCreWorkLoad.put( creId, 0 );
    			}
    		}
    	}
    	system.debug('mapCreWorkLoad=='+mapCreWorkLoad);
    	return mapCreWorkLoad ;
    }
    
    private static map<Id,map<String,Integer>> createMapCreIdTasks( list<Task> lstCreTasks ) {
    	map<Id,map<String,Integer>> mapCreIdTasks = new map<Id,map<String,Integer>>();
    	for( Task objTask :  lstCreTasks ) {
    		Integer counter = 0;
    		if( objTask.Type != null ) {
	    		if( mapCreIdTasks.containsKey( objTask.ownerId ) ) {
	    			if( mapCreIdTasks.get( objTask.ownerId ).containsKey( objTask.Type ) ) {
	    				counter = mapCreIdTasks.get( objTask.ownerId ).get( objTask.Type ) ;
	    				mapCreIdTasks.get( objTask.ownerId ).put( objTask.Type ,counter + 1 );
	    			}
	    			else {
	    				mapCreIdTasks.get( objTask.ownerId ).put( objTask.Type, 1 ) ;
	    			}
	    		}
	    		else {
	    			mapCreIdTasks.put( objTask.OwnerId, new map<String, Integer>{ objTask.Type => 1 } );
	    		}
    		}
    	}
    	return mapCreIdTasks ;
    }
    
    private static map<Id,Integer> createMapCreIdCases( list<Case> lstCreCases ) {
    	map<Id,Integer> mapCreIdCases = new map<Id,Integer>();
    	for( Case objCase : lstCreCases ) {
    		Integer counter = 0 ;
    		if( mapCreIdCases.containsKey( objCase.CreatedById ) ) {
    			counter = mapCreIdCases.get( objCase.CreatedById );
    			mapCreIdCases.put( objCase.CreatedById, counter + 1 );
    		}
    		else {
    			mapCreIdCases.put( objCase.CreatedById, 1 ) ;
    		}
    	}
    	return mapCreIdCases ; 
    }
    
    private static map<Id,map<String, Integer>> createMapCreBookingUnits( list<Booking_Unit__c> lstBookingUnit ) {
    	map<Id,map<String, Integer>> mapCreExistingUnits = new map<Id,map<String, Integer>>() ;
    	for( Booking_Unit__c objUnit : lstBookingUnit ) {
    		String strUnitType = objUnit.Inventory__r.Property_Status__c ;
    		
    		//Check for primary CRE.
    		if( objUnit.Booking__r.Account__r.Primary_CRE__c != null ) {
    			if( mapCreExistingUnits.containsKey( objUnit.Booking__r.Account__r.Primary_CRE__c ) ) {
    				if( mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Primary_CRE__c ).containsKey( strUnitType ) ) {
    					Integer counter = mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Primary_CRE__c ).get( strUnitType );
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Primary_CRE__c ).put( strUnitType, counter + 1 );
    				}
    				else {
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Primary_CRE__c ).put( strUnitType, 1 );
    				}
    			}
	    		else {
	    			mapCreExistingUnits.put( objUnit.Booking__r.Account__r.Primary_CRE__c, new map<String, Integer>{ strUnitType => 1 } );
	    		}
    		}
    		
    		//Check for Secondary CRE.
    		if( objUnit.Booking__r.Account__r.Secondary_CRE__c != null ) {
    			if( mapCreExistingUnits.containsKey( objUnit.Booking__r.Account__r.Secondary_CRE__c ) ) {
    				if( mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Secondary_CRE__c ).containsKey( strUnitType ) ) {
    					Integer counter = mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Secondary_CRE__c ).get( strUnitType );
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Secondary_CRE__c ).put( strUnitType, counter + 1 );
    				}
    				else {
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Secondary_CRE__c ).put( strUnitType, 1 );
    				}
    			}
	    		else {
	    			mapCreExistingUnits.put( objUnit.Booking__r.Account__r.Secondary_CRE__c, new map<String, Integer>{ strUnitType => 1 } );
	    		}
    		}
    		
    		//Check for Tertiary CRE.
    		if( objUnit.Booking__r.Account__r.Tertiary_CRE__c != null ) {
    			if( mapCreExistingUnits.containsKey( objUnit.Booking__r.Account__r.Tertiary_CRE__c ) ) {
    				if( mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Tertiary_CRE__c ).containsKey( strUnitType ) ) {
    					Integer counter = mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Tertiary_CRE__c ).get( strUnitType );
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Tertiary_CRE__c ).put( strUnitType, counter + 1 );
    				}
    				else {
    					mapCreExistingUnits.get( objUnit.Booking__r.Account__r.Tertiary_CRE__c ).put( strUnitType, 1 );
    				}
    			}
	    		else {
	    			mapCreExistingUnits.put( objUnit.Booking__r.Account__r.Tertiary_CRE__c, new map<String, Integer>{ strUnitType => 1 } );
	    		}
    		}
    	}
    	return mapCreExistingUnits ;
    }
    
}