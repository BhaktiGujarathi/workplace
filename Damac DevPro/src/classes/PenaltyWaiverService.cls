public with sharing class PenaltyWaiverService {
    /*public static PenaltyWaiverResponseWrapper getPenaltyDetails( Id accountId ) {
        //Get the details related to penalty against each of the booking unit.
        return new PenaltyWaiverResponseWrapper( accountId );
    }
    
    public class PenaltyWaiverResponseWrapper {
        public Integer intTotalPenalty {get; set;}
        public Integer intTotalWaivedPenalty {get; set;}
        public list<Booking_Unit__c> lstBookingUnit {get; set;}
        public map<Id, Booking_Unit__c> mapBookingUnit ;
        
        public PenaltyWaiverResponseWrapper( Id accountId ) {
            intTotalPenalty = 100;
            intTotalWaivedPenalty = 50;
            lstBookingUnit = [SELECT Id
                                  , Name
                                  , Property_Name__c
                                  , Token_Amount_val__c
                                  , Token_Amount__c
                                  , Requested_Token_Amount__c
                                  , Booking__c
                                  , Booking__r.Account__c
                                  , Booking_Unit_No__c
                                  , Booking_Unit_Type__c
                                  , Building_Name__c
                                  , Penalty_Amount__c
                                  , Unit_Location__c 
                              	  , Inventory__c
                              	  , Inventory__r.Property_City__c
                              	  , Inventory__r.Bedroom_Type__c
                              	  , Inventory__r.Unit_Type__c
                              	  , Inventory__r.Property_Status__c
                               FROM Booking_Unit__c
                              WHERE Booking__r.Account__c = :accountId ];
            mapBookingUnit = new map<Id, Booking_Unit__c>( lstBookingUnit );
        }
        
        public PenaltyWaiverResponseWrapper() {
            intTotalPenalty = 0;
            intTotalWaivedPenalty = 0;
            lstBookingUnit = new list<Booking_Unit__c>();
        }
    }*/
    
    public static WrapperBookingUnit getBookingUnitDetails( Booking_Unit__c objUnit ) {
        WrapperBookingUnit objUnitWrap = new WrapperBookingUnit();
        //Unit Details
        objUnitWrap.objBookingUnit = objUnit;
        objUnitWrap.objIPMSDetailsWrapper = UnitDetailsService.getBookingUnitDetails( objUnit.Registration_ID__c );
        objUnitWrap.intPrevWaivers = PenaltyWaiverControllerV2.sumApprovedAmountCase( objUnit.Id );
        return objUnitWrap ;
    }
    
    public static PenaltyWaiverService.SopResponseObject getSOPDocument( String strRegId ) {
    	GenerateSOPService.PenaltyWaiverHttpSoap11Endpoint objSOPService = new GenerateSOPService.PenaltyWaiverHttpSoap11Endpoint() ;
    	objSOPService.timeout_x = 120000;
    	String strResponse = objSOPService.GeneratePenaltyStatment( String.valueOf( strRegId + system.now() ) , 
    												'GET_PENALTY_STATEMENT' ,
    												'SFDC' ,
    												strRegId ,
    												'',
    												String.valueOf( strRegId + system.now() ) );
    
    	SopResponseObject objResponse = (SopResponseObject)JSON.deserialize(strResponse, PenaltyWaiverService.SopResponseObject.class);
    	system.debug( objResponse  );
    	return objResponse ;
    }
    
    
    
    public static PenaltyWaiverService.ApprovingAuthoritiesWrapper getApprovingAuthorities( Booking_Unit__c objBookingUnit , String amount ) {
    	ApprovingAuthoritiesWrapper objResponse ;
    	actionComUpdated.PenaltyWaiverHttpSoap11Endpoint objSOPService = new actionComUpdated.PenaltyWaiverHttpSoap11Endpoint() ;
    	objSOPService.timeout_x = 120000;
    	String strResponse = objSOPService.PenaltyWaiverDetails( String.valueOf( objBookingUnit.Registration_Id__c )  , 
    												'Penalty Waiver' ,
    												'Normal' ,
    												String.valueOf( objBookingUnit.Inventory__r.Property_City__c ) ,
    												'',
    												String.valueOf( objBookingUnit.Property_Name_Inventory__c ),
    												String.valueOf( objBookingUnit.Inventory__r.Building_Code__c ),
    												String.valueOf( objBookingUnit.Inventory__r.Bedroom_Type__c ),
    												String.valueOf( objBookingUnit.Inventory__r.Unit_Type__c ),
    												String.valueOf( objBookingUnit.Permitted_Use__c ),
    												'',
    												String.valueOf( objBookingUnit.Inventory__r.Property_Status__c ),
    												'',
    												'',
    												objBookingUnit.Registration_Status__c,
    												amount,
    												'65',
    												amount,
    												'',
    												'',
    												'',
    												'',
    												double.valueOf('0'),
    												double.valueOf('0'),
    												double.valueOf('0'),
    												double.valueOf('0') ); 
    	if( String.isNotBlank( strResponse ) ) {
    		objResponse = ( ApprovingAuthoritiesWrapper )JSON.deserialize(strResponse, PenaltyWaiverService.ApprovingAuthoritiesWrapper.class);
    	}
    	return objResponse ;
    }
    
    public static void createTaskInIPMS( set<Id> setTaskIds, set<Id> setCaseIds ) {
    	
    	map<Id, Case> mapCaseDetails = PenaltyWaiverUtility.getCaseMap( setCaseIds );
    	
    	for( Task objTask : PenaltyWaiverUtility.getTasks( setTaskIds ) ) {
    		TaskCreationUtility.TaskBean objBean = new TaskCreationUtility.TaskBean();
            objBean.p_REQUEST_NUMBER = String.valueOf( System.currentTimeMillis() );
            objBean.p_REQUEST_NAME = 'CREATE_SR';
            objBean.p_SOURCE_SYSTEM = 'SFDC';
            objBean.PARAM_ID = objTask.WhatId;
            objBean.ATTRIBUTE1 = 'TASK';
			objBean.ATTRIBUTE2 = 'Penalty Waiver';
			objBean.ATTRIBUTE3 = mapCaseDetails.get(objTask.WhatId).Status;
			objBean.ATTRIBUTE4 = objTask.Owner.Name;
			objBean.ATTRIBUTE5 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Party_ID__c;
			objBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
			objBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy')); // format this as DD-MON- YYYY
			objBean.ATTRIBUTE8 = objTask.Id;
			Datetime dt = objTask.ActivityDate;
			objBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy'));
			objBean.ATTRIBUTE10 = objTask.WhatId;
			objBean.ATTRIBUTE11 = objTask.Assigned_User__c;
			objBean.ATTRIBUTE12 = objTask.Subject;
			objBean.ATTRIBUTE13 = objTask.Status;
			objBean.ATTRIBUTE14 = objTask.Type;
			objBean.ATTRIBUTE15 = objTask.Description;
			objBean.ATTRIBUTE16 = mapCaseDetails.get(objTask.WhatId).CaseNumber;
			objBean.ATTRIBUTE17 = mapCaseDetails.get(objTask.WhatId).POA_Name__c;
			objBean.ATTRIBUTE18 = mapCaseDetails.get(objTask.WhatId).Case_Type__c;
			objBean.ATTRIBUTE19 = mapCaseDetails.get(objTask.WhatId).Buyer_Type__c;
			 objBean.ATTRIBUTE20 = String.valueOf( mapCaseDetails.get(objTask.WhatId).POA_Expiry_Date__c ) ;
			  objBean.ATTRIBUTE21 = mapCaseDetails.get(objTask.WhatId).POA_Relation_With_Owner__c;
			  objBean.ATTRIBUTE22 = mapCaseDetails.get(objTask.WhatId).POA_Issued_By__c;
			  objBean.ATTRIBUTE23 = String.valueOf( mapCaseDetails.get(objTask.WhatId).Percent_to_be_waived__c );
			  objBean.ATTRIBUTE24 = String.valueOf( mapCaseDetails.get(objTask.WhatId).Amount_to_be_waived__c );
			  objBean.ATTRIBUTE25 = mapCaseDetails.get(objTask.WhatId).Approval_Status__c;
			  objBean.ATTRIBUTE26 = String.valueOf( mapCaseDetails.get(objTask.WhatId).Approved_Amount__c );
			  objBean.ATTRIBUTE27 = mapCaseDetails.get(objTask.WhatId).Approving_Authorities__c;
			  objBean.ATTRIBUTE28 = mapCaseDetails.get(objTask.WhatId).Penalties__c;
			  objBean.ATTRIBUTE29 = String.valueOf( mapCaseDetails.get(objTask.WhatId).Penalty_Amount__c );
			  objBean.ATTRIBUTE30 = String.valueOf( mapCaseDetails.get(objTask.WhatId).Penalty_as_of_date__c );
			  objBean.ATTRIBUTE31 = mapCaseDetails.get(objTask.WhatId).Actual_Approving_Percent__c;
			  objBean.ATTRIBUTE32 = mapCaseDetails.get(objTask.WhatId).Penalty_Category__c;
			  objBean.ATTRIBUTE33 = mapCaseDetails.get(objTask.WhatId).Purpose_of_POA__c;
			  objBean.ATTRIBUTE35 = '';
			  objBean.ATTRIBUTE36 = '';
			  objBean.ATTRIBUTE37 = '';
			  objBean.ATTRIBUTE38 = '';
			  objBean.ATTRIBUTE39 = '';
			  TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
			  String response = objClass.SRDataToIPMS(objBean);
			  system.debug('resp*****'+response);
    	}
    }
    
    
    public class SopResponseObject {
      	public String Status ;
      	public String PROC_STATUS ;
    	public String url { get; set; }
    	public String PROC_MESSAGE ;
    	public String Message ;
    	public String PARAM_ID ;
    	public String REQUEST_ID ;
    	public String STAGE_ID ;
    } 
    
    public class ApprovingAuthoritiesWrapper {
    	public String allowed ;
    	public String message ;
    	public String recommendingAuthorityOne ;
    	public String recommendingAuthorityTwo ;
    	public String recommendingAuthorityThree ;
    	public String recommendingAuthorityFour ;
    	public String approvingAuthorityOne ;
    	public String approvingAuthorityTwo ;
    	public String approvingAuthorityThree ;
    	public String adminFeePsf ;
    	public String adminFeeFlat ;
    	public String adminFeePercentage ;
    }
}