public with sharing class CallingListUtility {
    public static Id getGroupIdFromDeveloperName( String strDeveloperName, String strGroupType ) {
    	if( String.isNotBlank( strDeveloperName ) ) {
    		list<Group> lstGroups =  new list<Group>( [ SELECT Id
    														 , DeveloperName  
						    								 , Type
						    							  FROM Group 
						    							 WHERE Type = :strGroupType
						    							   AND DeveloperName = :strDeveloperName ] );
    		if( lstGroups != null && !lstGroups.isEmpty() ) {
    			return lstGroups[0].Id;
    		}
    	}
    	return '';
    }
    
    public static list<SR_Booking_Unit__c> getUnitsRelatedToCase( set<Id> setCaseId ) {
    	return new list<SR_Booking_Unit__c>( [ SELECT Booking_Unit__c
    										, Case__c
    										, Booking_Unit__r.Early_Handover__c
    									 FROM SR_Booking_Unit__c
    									WHERE Case__c IN :setCaseId ] );
    }
    
    public static list<Calling_List__c> getCallingLists( set<Id> setCallingListIds ) {
    	return new list<Calling_List__c>( [ SELECT Id
    											 , Account__c
    											 , Approval_Status__c
    											 , Approving_Authorities__c
    											 , Call_Date__c
    											 , Calling_List_Status__c
    											 , Calling_List_Type__c
    											 , Call_Outcome__c
    											 , Case__c
    											 , Promise_To_Pay_Date__c
    											 , Submit_for_Approval__c
    										  FROM Calling_List__c
    										 WHERE Id IN :setCallingListIds ] );
    }
    
    public static list<User> getUserFromRoles( set<String> setRoleNames ) {
    	 return new list<User>( [ SELECT Id
    	 							   , UserRole.Name 
    	 							FROM User 
    	 						   WHERE UserRole.Name IN :setRoleNames
                                     AND IsActive = true ] );
    }
}