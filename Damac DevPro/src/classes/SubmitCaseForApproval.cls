public with sharing class SubmitCaseForApproval {
    @InvocableMethod
    public static void submitCase( list<SR_Attachments__c> lstCustomAttachment ) {
    	system.debug('SubmitCaseForApproval class called..');
    	if( !lstCustomAttachment.isEmpty() ) {
    		boolean isValid = false ;
    		for( SR_Attachments__c objCust : [ SELECT Id
    											   , isValid__c
    											   , Case__r.Amount_to_be_waived__c
    											  FROM SR_Attachments__c 
    											 WHERE Case__c = :lstCustomAttachment[0].Case__c ] ) {
    			if( objCust.isValid__c == false ) {
    				isValid = false ;
    				break;
    			}
    			else {
    				isValid = true ; 
    			}
    		}
    		
    		if( isValid ) {
    			makeCall( lstCustomAttachment[0].Id, lstCustomAttachment[0].Case__c ); 
    		}
    	}
    }
    
    public static void afterUpdate(  list<SR_Attachments__c> lstCustomAttachment  ) {
    	for( SR_Attachments__c objCust : lstCustomAttachment ) { 
    		
    	}
    } 
    
    @future
    public static void  makeCall( Id objAttachId , Id caseId) {
    	SR_Attachments__c objAttach = [ SELECT Id  , isValid__c 
    											   , Case__r.Amount_to_be_waived__c
    											   , Booking_Unit__c
    											  FROM SR_Attachments__c 
    											  
    											 WHERE Case__c = :caseId AND Id =: objAttachId limit 1];
    	
    	Case objCase = new Case();
			objCase.Id = objAttach.Case__c ;
			objCase.Amount_to_be_waived__c = objAttach.Case__r.Amount_to_be_waived__c ;
			objCase.Submit_for_Approval__c = true ;
			list<Booking_Unit__c> lstUnits = [SELECT Id
                                              , Registration_ID__c
                                              , Unit_Details__c
                                              , Inventory__r.Building_Code__c
                                              , Registration_status__c
                                              //Unit Details
                                              , Property_Name_Inventory__c
                                              , Inventory__r.Property_City__c
                                              , Inventory__r.Bedroom_Type__c
                                              , Inventory__r.Unit_Type__c
                                              , Permitted_Use__c
                                              , Inventory__r.Property_Status__c
                                              , Booking_Type__c
                                              , Plot_Price__c
                                              , Booking__r.CreatedDate
                                              , Agreement_Date__c
                                              , Inventory__r.Unit_Plan__c
                                              , Inventory__r.Floor_Plan__c
                                              , JOPD_Area__c
                                              
                                              //Flags
                                              , Mortgage__c
                                              , DP_OK__c
                                              , Doc_OK__c
                                              
                                              //Unit Status
                                              , OQOOD_Reg_Flag__c
                                              , Early_Handover__c
                                              , Handover_Flag__c
                                              , PCC_Release__c
                                              
                                              //Additional Details
                                              , Area_Varied__c
                                              , Unit_Selling_Price__c
                                              , Inventory_Area__c
                                              FROM Booking_Unit__c
                                             WHERE Id = :objAttach.Booking_Unit__c ];
			
			PenaltyWaiverService.ApprovingAuthoritiesWrapper objResponse = PenaltyWaiverService.getApprovingAuthorities( lstUnits[0] , String.valueOf( objAttach.Case__r.Amount_to_be_waived__c ) );
			
			objCase.Approving_Authorities__c = objResponse.recommendingAuthorityOne + ','+ objResponse.recommendingAuthorityTwo + ',' +objResponse.approvingAuthorityOne;
			system.debug('objCase=='+objCase);
			update objCase ;
}
    
    public static void getBookingUnits( Id accountId ) {
    	map<Id, Booking_unit__c> temp = new map<Id, Booking_unit__c>( [ select Id
    										, ( Select Id
    												 , Case__r.Approved_Amount__c
    											 FROM SR_Booking_Units__r
    											 where Case__r.Recordtype.DeveloperName = 'Penalty_Waiver')
    									FROM Booking_Unit__c
    									where Booking__r.Account__c = :accountId ] );
    	if( temp != null && !temp.isEmpty() ) {
			map<Id, integer> mapPrevWaivers = new map<Id, Integer>();
			for( Booking_unit__c objUnit : temp.values() ) {
				if( objUnit.SR_Booking_Units__r != null && !objUnit.SR_Booking_Units__r.isEmpty() ) {
					
				}
			}
    	}
    }
}