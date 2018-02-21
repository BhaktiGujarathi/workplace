public with sharing class PenaltyWaiverUtility {
	 
	public static final String PENALTY_WAIVER_RECTYPE = 'Penalty_Waiver';
	public static final String CASE_SOBJ = 'Case';
	public static final String STATUS_NEW = 'New';
	public static final String STATUS_SUBMITTED = 'Submitted';
	public static final String ATTACH_TYPE_SHORT_CRF = 'crf';
	public static final String ATTACH_TYPE_FULL_CRF = 'Customer Request Form';
	public static final String ATTACH_TYPE_SHORT_POA = 'poa';
	public static final String ATTACH_TYPE_FULL_POA = 'Power of Attorney';
	public static final String ATTACH_TYPE_SHORT_SOA = 'soa';
	public static final String ATTACH_TYPE_FULL_SOA = 'Statement of Account';
	public static final String ATTACH_TYPE_SHORT_SOP = 'sop';
	public static final String ATTACH_TYPE_FULL_SOP = 'Statement of Penalty';
	public static final String SPAN_TICK = '<span class="symbol icon-tick"></span>';
	public static final String SPAN_CROSS = '<span class="symbol icon-cross"></span>';
    
    public static map<Id, Booking_Unit__c> getAllRelatedBookingUnits( Id accountId ) {
        
        /*set<Id> setBookingId  = new set<Id>();
        for( Buyer__c objBuy : [ select id, Booking__r.Id from Buyer__c where Primary_Buyer__c = true AND Account__c = :accountId ] ) {
        	if( objBuy.Booking__c != null ) {
        		setBookingId.add( objBuy.Booking__c );
        	}
        }
        */
        return new map<Id, Booking_Unit__c>([SELECT Id
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
                                                  
                                                  //?
                                                  , Bedroom_Type__c
                                                  , Token_Amount_val__c
                                                  , Rental_Pool_Agreement__c
                                                  , Token_Amount__c
                                                  , Requested_Token_Amount__c
                                                  , Booking__r.Account__c
                                                  , Penalty_Amount__c
                                               FROM Booking_Unit__c
                                              WHERE Booking__r.Account__c = :accountId ] );
    }
    
    public static Id getRecordTypeId( String strDeveloperName, String strObjectName ) {
        list<RecordType> lstRecordType = [SELECT Id
                                               , Name
                                               , DeveloperName
                                               , SobjectType 
                                            FROM RecordType 
                                           WHERE DeveloperName = :strDeveloperName
                                             AND SobjectType = :strObjectName 
                                             AND IsActive = true ];
        if( lstRecordType != null && lstRecordType.isEmpty() == false ) {
            return lstRecordType[0].Id;
        }
        return null;
    }
    
    public static Case getExistingOpenCase( Id bookingUnitId ) {
        list<SR_Booking_Unit__c> lstexistingOpenCases = [ SELECT Id
                                                               , Booking_Unit__c
                                                               , Case__c
                                                               , Excess_Amount_Refund_Liability_AED__c
                                                               , Is_Bulk_Deal__c
                                                               , SR__c
                                                               , Unit_Status__c
                                                            FROM SR_Booking_Unit__c
                                                           WHERE Booking_Unit__c = :bookingUnitId
                                                             AND Case__r.Approval_Status__c != 'Approved'
                                                             AND Case__r.RecordTypeId = :getRecordTypeId( PENALTY_WAIVER_RECTYPE, CASE_SOBJ )
                                                        ORDER BY CreatedDate DESC ];
        if( lstexistingOpenCases != null && !lstexistingOpenCases.isEmpty() ) {
            return getCaseDetails( lstexistingOpenCases[0].Case__c );
        }
        return new Case();
    }
    
    public static map<Id,SR_Attachments__c> fetchCaseAttachments( Id caseId ) {
    	return new map<Id,SR_Attachments__c>([ SELECT Id
    											  , Case__c
    											  , Name
    											  , View__c
    											  , Attachment__c
    											  , Type__c
    											  , IsValid__c
                                                  , Attachment_URL__c
    										   FROM SR_Attachments__c
    										  WHERE Case__c = :caseId
    									   ORDER BY CreatedDate DESC ]);
    }
    
    public static Case getCaseDetails( Id caseId ) {
    	list<Case> lstCase = [SELECT Id
    							   , Amount_to_be_waived__c
    							   , Percent_to_be_waived__c
    							   , Status
    							   , Penalty_Category__c
    							   , IsPOA__c
    							   , POA_Name__c
    							   , Additional_Details__c
    							   , POA_Relationship_with_Buyer__c
    							   , POA_Expiry_Date__c
    							   , POA_Issued_By__c
    							   , Is_CRF_Uploaded__c
    							   , Purpose_of_POA__c 
    							FROM Case
    						   WHERE Id = :caseId];
 		if( lstCase != null && !lstCase.isEmpty() ) {
 			return lstCase[0];
 		}
 		return new Case();
    }
    
    public static list<Task> getTasks( set<Id> setCaseIds ) {
    	return new list<Task>( [ SELECT WhoId
	                                  , WhatId
	                                  , Type
	                                  , Status
	                                  , OwnerId
	                                  , Id
	                                  , Subject
	                                  , CreatedDate
	                                  , Description
	                                  , Assigned_User__c
	                                  , ActivityDate
	                                  , Owner.Name
                                   FROM Task
                                  WHERE Id IN : setCaseIds ] );
    }
    
    public static map<Id, Case> getCaseMap( set<Id> setCaseIds ) {
    	return new map<Id, Case>( [ SELECT Id
    									 , Status
    									 , Buyer__r.Party_ID__c
    									 , Booking_Unit__r.Registration_ID__c
    									 , CaseNumber
    									 , Relationship_with_Seller__c
    									 , Case_Type__c
    									 , Buyer_Type__c
    									 , Booking_Unit__r.Unit_Details__c
    									 , Booking_Unit__r.Inventory__r.Property_City__c
    									 , Buyer__r.First_Name__c
    									 , Booking_Unit__r.Inventory__r.Property_Status__c
    									 , Buyer__r.Last_Name__c
    									 , Booking_Unit__r.Inventory__r.Property_Country__c
    									 , Buyer__r.Nationality__c
    									 , Booking_Unit__r.Inventory__r.Property__r.DIFC__c
    									 , Buyer__r.Passport_Number__c
    									 , Buyer__r.Passport_Expiry_Date__c
    									 , Buyer__r.IPMS_Buyer_ID__c
    									 , Seller__r.Party_ID__c
    									 , Seller__r.FirstName
    									 , Seller__r.LastName
    									 , Seller__r.Nationality__pc
    									 , Case.RecordType.Name
                            		  FROM Case 
                            		 WHERE Id IN :setCaseIds ] );
    }
     
    public static list<Case> getAllRelatedCases( Id bookingUnitId ) {
    	return new list<Case>( [ SELECT Id
    								  , RecordType.Name
    								  , Status
    							   FROM Case
    							  WHERE Booking_Unit__c = :bookingUnitId ] );
    }
    
    public static list<SR_Booking_Unit__c> getAllRelatedJunctions( Id bookingUnitId ) {
    	return new list<SR_Booking_Unit__c>( [ SELECT Id
    												, Case__c
    												, Case__r.RecordType.Name
    												, Case__R.Status 
    											 FROM SR_Booking_Unit__c 
    											WHERE Booking_Unit__c = :bookingUnitId ] );
    }
    
    public static list<Case> getAllPenaltyWaiverCase(Id bookingUnitId){
    	return new list<Case>([SELECT Id
    								, Approved_Amount__c
    								, RecordType.Name
    								, RecordTypeId
    								, Status
    								FROM Case
    								WHERE Booking_Unit__c =:bookingUnitId
    								AND RecordTypeId =:getRecordTypeId( PENALTY_WAIVER_RECTYPE, CASE_SOBJ )
    								AND Approval_Status__c ='Approved'
    								AND Status ='Closed']);
    }
    
    public static list<SR_Booking_Unit__c> getAllPenaltyWaivercasesJunctions(Id bookingUnitId){
    	return new list<SR_Booking_Unit__c>([SELECT Id,
    												Case__r.Approved_Amount__c
    												,Case__c
    												FROM SR_Booking_Unit__c
    												WHERE Booking_Unit__c = :bookingUnitId
    												AND  Case__r.RecordTypeId = :getRecordTypeId( PENALTY_WAIVER_RECTYPE, CASE_SOBJ )
    												AND Case__r.Approval_Status__c= 'Approved'
    												AND Case__r.Status = 'Closed']);
    }
    
    /*public static List<Case> getAllpenaltyWaiverCaseFromAccount(Id Accountid){
    	return new List<Case>([Select id
    								, Approved_Amount__c
    								FROM Case
    								WHERE AccountId = :Accountid
    								AND RecordTypeId =:getRecordTypeId( PENALTY_WAIVER_RECTYPE, CASE_SOBJ )
    								AND Approval_Status__c ='Approved'
    								AND Status ='Closed']); 
    	
    }*/
}