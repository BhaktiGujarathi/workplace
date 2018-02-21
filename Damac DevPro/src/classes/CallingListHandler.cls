public with sharing class CallingListHandler {
    
    private static set<Id> setCallingItemIdsForApproval ;
    private static list<Task> lstTaskToBeGenerated ;
    
    public static void onBeforeUpdate( map<Id, Calling_List__c> mapUpdatedCallingItems, map<Id, Calling_List__c> mapOldCallingItems ) {
    	if( mapUpdatedCallingItems != null && !mapUpdatedCallingItems.isEmpty() ) {
    		setCallingItemIdsForApproval = new set<Id>();
    		lstTaskToBeGenerated = new list<Task>();
    		map<Id, list<SR_Booking_Unit__c>> mapCaseBookingUnits = CallingListHelper.getUnitInfo( mapUpdatedCallingItems.values() );
    		for( Calling_List__c objCall : mapUpdatedCallingItems.values() ) {
    			checkOwnershipChanges( objCall, mapOldCallingItems.get( objCall.Id )  );
    			checkApprovalStatus( objCall, mapOldCallingItems.get( objCall.Id ) );
    			validateCallingListRecords( objCall, mapOldCallingItems.get( objCall.Id ), mapCaseBookingUnits );
    		}
    		
    		if( !lstTaskToBeGenerated.isEmpty() ) {
    			insert lstTaskToBeGenerated ;
    		}
    		
    		if( !setCallingItemIdsForApproval.isEmpty() ) {
    			ApprovalHandler.processCallingListApproval( setCallingItemIdsForApproval );
    		}
    	}
    }    
    
    public static void checkOwnershipChanges( Calling_List__c updatedCallingItem, Calling_List__c oldCallingItem ) {
    	if( String.isNotBlank( updatedCallingItem.OwnerId ) && String.isNotBlank( oldCallingItem.OwnerId ) && 
    		updatedCallingItem.OwnerId != oldCallingItem.OwnerId ) {
    		updatedCallingItem.Calling_List_Status__c = 'In Progress';
    	}
    }
    
    public static void checkApprovalStatus( Calling_List__c updatedCallingItem, Calling_List__c oldCallingItem ) {
		if( updatedCallingItem.Submit_for_Approval__c &&
			updatedCallingItem.Approving_Authorities__c != oldCallingItem.Approving_Authorities__c ) {
			Approval.UnlockResult unlockedResult = Approval.unlock( updatedCallingItem );
			setCallingItemIdsForApproval.add( updatedCallingItem.Id );
			if( String.isNotBlank( updatedCallingItem.Approving_Authorities__c ) ) {
				String strApprovingAuthorities = oldCallingItem.Approving_Authorities__c;
                String strRole = strApprovingAuthorities.contains( ',' ) ?
                         		 strApprovingAuthorities.subString( 0, strApprovingAuthorities.indexOf( ',' ) ) :
                         		 strApprovingAuthorities ;
				updatedCallingItem.Approval_Status__c = 'Approved by ' + UserInfo.getUserName() + ' (' + strRole + ')';
			}
			else {
				updatedCallingItem.Approval_Status__c = 'Approved';
				lstTaskToBeGenerated.add( TaskUtility.getTask( (SObject)updatedCallingItem, 'Customer refusing to pay, take legal action.', 'Legal', 'Bounced Cheque', system.today().addDays( 1 ) ) ) ;
			}
		}
    }
    
    
    public static void validateCallingListRecords( Calling_List__c updatedCallingItem, Calling_List__c oldCallingItem, map<Id, list<SR_Booking_Unit__c>> mapCaseBookingUnits ) {
    	if( updatedCallingItem.Calling_List_Type__c != null && updatedCallingItem.Call_Outcome__c != null && 
			( !updatedCallingItem.Calling_List_Type__c.equalsIgnoreCase( oldCallingItem.Calling_List_Type__c ) || 
			  !updatedCallingItem.Call_Outcome__c.equalsIgnoreCase( oldCallingItem.Call_Outcome__c ) )
		  ) {
			if( updatedCallingItem.Calling_List_Type__c.equalsIgnoreCase( 'BC Calling' ) ) {
				handleBounceChequeCallingItem( updatedCallingItem, mapCaseBookingUnits );
			}
		}
    }
    
    private static void handleBounceChequeCallingItem( Calling_List__c objCall, map<Id, list<SR_Booking_Unit__c>> mapCaseBookingUnits ) {
    	if( objCall.Call_Outcome__c.equalsIgnoreCase( 'Refusing To Pay' ) ) { 	
			//---------Add Check for Off plan units info to be fetched from IPMS.------------------------------------
			/*if(  ) {
				
			}
			else {
				objCall.Call_Outcome__c.addError( Label.EHO_Error );
			}*/
			
			//Check for EHO on units.
			if( mapCaseBookingUnits != null && mapCaseBookingUnits.containsKey( objCall.Case__c ) &&
				CallingListHelper.areUnitsForEHO( mapCaseBookingUnits.get( objCall.Case__c ) ) ) {
				//Values to be replaced by actual approving authorities for refuse to pay
				objCall.Approving_Authorities__c = 'VP - Operations,General Manager';
				objCall.Submit_for_Approval__c = true ;
				setCallingItemIdsForApproval.add( objCall.Id );
			}
		}
    }
}