public with sharing class CallingListHelper {
    
    public static map<Id, list<SR_Booking_Unit__c>> getUnitInfo( list<Calling_List__c> lstCallingItems ) {
    	system.debug('=== Method getUnitInfo Called ===');
    	map<Id, list<SR_Booking_Unit__c>> mapCaseBookingUnits ;
    	set<Id> setCaseIds = extractCaseIdFromCallingItems( lstCallingItems );
    	system.debug('=== setCaseIds==='+setCaseIds);	
    	if( setCaseIds != null && !setCaseIds.isEmpty() ) {
    		mapCaseBookingUnits = new map<Id, list<SR_Booking_Unit__c>>();
	    	for( SR_Booking_Unit__c objJunc : CallingListUtility.getUnitsRelatedToCase( setCaseIds ) ) {
	    		if( mapCaseBookingUnits.containsKey( objJunc.Case__c ) ) {
	    			mapCaseBookingUnits.get( objJunc.Case__c).add( objJunc ) ;
	    		}
	    		else {
	    			mapCaseBookingUnits.put( objJunc.Case__c, new list<SR_Booking_Unit__c> { objJunc } ) ;
	    		}
	    	}
    	}
    	return mapCaseBookingUnits ;
    }
    
    public static set<Id> extractCaseIdFromCallingItems( list<Calling_List__c> lstCallingItems ) {
    	set<Id> setCaseIds = new set<Id>();
    	for( Calling_List__c objCall : lstCallingItems ) {
    		if( objCall.Case__c != null ) {
    			setCaseIds.add( objCall.Case__c );
    		}
    	}
    	return setCaseIds ;
    }
    
    public static boolean areUnitsForEHO( list<SR_Booking_Unit__c> lstUnits ) {
    	for( SR_Booking_Unit__c objJunc : lstUnits ) {
    		if( objJunc.Booking_Unit__r.Early_Handover__c ) {
    			return true ;
    		}
    	}
    	return false ;
    }
}