public without sharing class CreAllocationUtility {
    
    public static final set<String> setGCCCountries = new set<String>{ 'Kuwaiti', 'Qatari', 'Bahraini','Omani' };
    public static final set<String> setUAEKSACountries = new set<String>{ 'Saudi', 'UAE' }; 
    
    public static set<String> extractCustomerContact( list<Account> lstAccounts ) {
    	set<String> setCustomerContact = new set<String>();
    	for( Account objAcc : lstAccounts ) {
    		if( objAcc.Phone != null ) {
    			setCustomerContact.add( objAcc.Phone );
    		}
    	}
    	return setCustomerContact ;
    }
    
    public static set<String> extractCustomerExtId( list<Account> lstAccounts ) {
    	set<String> setCustomerExtId = new set<String>();
    	for( Account objAcc : lstAccounts ) {
    		if( objAcc.Primary_CRE__c == null && objAcc.Secondary_CRE__c == null && objAcc.Cust_Account_ID__c != null ) {
    			setCustomerExtId.add( objAcc.Cust_Account_ID__c );
    		}
    	}
    	return setCustomerExtId ;
    }
    
    public static set<String> extractCreGroupName( CreAllocationUtility.CreAllocationDetailObject objCreDetails ) {
    	set<String> setCreGroupName = new set<String>();
    	for( Account objAcc : objCreDetails.lstAccounts ) {
    		if( objAcc.Primary_CRE__c == null && objAcc.Secondary_CRE__c == null && objAcc.Tertiary_CRE__c == null &&
    			objAcc.Nationality__pc != null && objAcc.AnnualRevenue != null ) {
				
				String strCountryType =  getCountryGroupOfCustomer( objAcc.Nationality__pc ) ;
				String strCustomerType = getCustomerType( objAcc.AnnualRevenue, CreAllocationHandler.lstCustomerTypesSetting ) ;
    			
    			if( objCreDetails.mapCreGroupInfo.containsKey( objAcc.Nationality__pc ) ) {
    				if( objCreDetails.mapCreGroupInfo.get( objAcc.Nationality__pc ).containsKey( strCustomerType ) ) {
    					setCreGroupName.addAll( objCreDetails.mapCreGroupInfo.get( objAcc.Nationality__pc ).get( strCustomerType ) );
    				}
    			}
    			else if( objCreDetails.mapCreGroupInfo.containsKey( strCountryType ) ) {
    				if( objCreDetails.mapCreGroupInfo.get( strCountryType ).containsKey( strCustomerType ) ) {
    					setCreGroupName.addAll( objCreDetails.mapCreGroupInfo.get( strCountryType ).get( strCustomerType ) );
    				}
    			}
    		}
    	}
    	return setCreGroupName ;
    }
    
    public static String getCustomerType( Decimal decAmount, list<CRE_Allocation_Customer_Type_Setting__mdt> lstCustomerTypesSetting ) {
    	for( CRE_Allocation_Customer_Type_Setting__mdt objType : lstCustomerTypesSetting ) {
    		if( objType.Minimum_Value__c <= decAmount && ( ( objType.Maximum_Value__c != null && objType.Maximum_Value__c > decAmount ) || objType.Is_Max__c )  ) {
    			return objType.MasterLabel;
    		}
    	}
    	return '';
    }
    
    public static set<Id> extractCreId( list<GroupMember> lstCreMembers ) {
    	set<Id> setCreId = new set<Id>();
    	String strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix() ;
    	for( GroupMember objMember : lstCreMembers ) {
    		if( objMember.UserOrGroupId != null && String.valueOf( objMember.UserOrGroupId ).subString(0,3).equalsIgnoreCase( strUserKeyPrefix ) ) {
    			setCreId.add( objMember.UserOrGroupId );
    		}
    	}
    	return setCreId ;
    }
    
    public static String getCountryGroupOfCustomer( String strNationality ) {
    	if( setGCCCountries.contains( strNationality ) ) {
    		return Label.GCC_Group;
    	}
    	else if( setUAEKSACountries.contains( strNationality ) ) {
    		return Label.UAE_KSA_Group;
    	}
    	return Label.Other_Group;
    }
    
    public static set<Account> getAccountsBasedOnContact( set<Id> setCreIds ) {
    	if( setCreIds != null && !setCreIds.isEmpty() ) {
	    	return new set<Account>( [ SELECT Id
			    						    , Phone
			    							, Primary_CRE__c
			    							, Secondary_CRE__c
			    							, Tertiary_CRE__c
			    							, ( SELECT Id
			    								  FROM Tasks )
			    						 FROM Account
			    					    WHERE Primary_CRE__c IN :setCreIds
			    					       OR Secondary_CRE__c IN :setCreIds
			    					       OR Tertiary_CRE__c IN :setCreIds ] );
    	}
    	return null;
    }
    
    public static list<CRE_Allocation_Group_Setting__mdt> getGroupSettings() {  
    	return new list<CRE_Allocation_Group_Setting__mdt>([ SELECT DeveloperName
    															  , MasterLabel
    															  , Group_Name__c
    															  , Parent_Queue__c
    															  , Secondary_Group_Name__c
    															  , Tertiary_Group_Name__c
    															  , Queue__c
    															FROM CRE_Allocation_Group_Setting__mdt ] );
    }
    
    public static map<String, Decimal> getTaskWeightage() {
    	map<String, Decimal> mapTypeWeightage = new map<String, Decimal>();
    	for( CRE_Allocation_Task_Weightage_Setting__mdt objWeight :  [ SELECT MasterLabel
    																		, Weightage__c
    																	 FROM CRE_Allocation_Task_Weightage_Setting__mdt ] ) {
    		mapTypeWeightage.put( objWeight.MasterLabel, objWeight.Weightage__c );																	 	
		}
		return mapTypeWeightage ;
    }
    
    public static list<CRE_Allocation_Customer_Type_Setting__mdt> getCustomerTypesSetting() {
    	return new list<CRE_Allocation_Customer_Type_Setting__mdt>( [ SELECT Id
    																	   , MasterLabel
    																	   , Maximum_Value__c
    																	   , Minimum_Value__c
    																	   , DeveloperName
    																	   , Is_Max__c
    																	FROM CRE_Allocation_Customer_Type_Setting__mdt ] ) ;
    }
    
    public static list<GroupMember> getGroupMembers( set<String> setCreGroupName ) {
    	return new list<GroupMember>( [ SELECT Id
    										 , UserOrGroupId 
    										 , Group.DeveloperName
    									  FROM GroupMember 
    									 WHERE Group.DeveloperName IN :setCreGroupName ] );
    }
    
    public static list<Task> getTasks( set<Id> setCreId ) {
    	return new list<Task>( [ SELECT Id
    								  , Type
    								  , OwnerId
    							   FROM	Task
    							  WHERE OwnerId IN :setCreId
    							    AND CreatedDate = LAST_N_DAYS:90 
    							    AND Type != null
    						   ORDER BY CreatedDate DESC ] );
    }
    
    public static list<Case> getCases( set<Id> setCreId ) {
    	return new list<Case>( [ SELECT Id
    								  , CreatedById
    							   FROM Case
    							  WHERE CreatedById IN :setCreId 
    						   ORDER BY CreatedDate DESC ] );
    }
    
    public static map<Id, User> getUserInfo( set<Id> setCreId ) {
    	return new map<Id, User>( [ SELECT Id
    								  , CreatedDate
    							   FROM User
    							  WHERE Id IN :setCreId ] ) ;
    }
    
    public static list<Booking_Unit__c> getUnitsFromCREIds( set<Id> setCreId ) {
    	return new list<Booking_Unit__c>( [ SELECT Id
    											 , Handover_Complete__c
    											 , Inventory__r.Property_Status__c
    											 , Booking__r.Account__r.Primary_CRE__c
    											 , Booking__r.Account__r.Secondary_CRE__c
    											 , Booking__r.Account__r.Tertiary_CRE__c
    										  FROM Booking_Unit__c 
    										 WHERE Booking__r.Account__r.Primary_CRE__c IN :setCreId 
    										 	OR Booking__r.Account__r.Secondary_CRE__c IN :setCreId
    										 	OR Booking__r.Account__r.Tertiary_CRE__c IN :setCreId ] ) ;
    }
    
    public static set<Group> getAllGroups() {
    	return new set<Group>( [ SELECT Id
    								   , DeveloperName
    								FROM Group
    							   WHERE Type = 'Regular' ] );
    }
    
    public class CreAllocationDetailObject{
    	public map<String, map<String, list<String>>> mapCreGroupInfo;
    	public map<String, list<Id>> mapGroupNameCreId ;
    	public list<Account> lstAccounts ;
    	
    	public CreAllocationDetailObject( list<Account> lstAccounts ) {
    		mapCreGroupInfo = new map<String, map<String, list<String>>>();
    		mapGroupNameCreId = new map<String, list<Id>>();
    		this.lstAccounts = lstAccounts ;
    	}
    }
}