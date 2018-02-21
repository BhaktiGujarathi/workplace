/**************************************************************************************************
* Name               : ValidateServiceRequest                                                     *
* Description        : Method to validate Service Request.                                        *
*                       - Used to control the access to page.                                     *
* Created Date       : 07/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      07/05/2017      Initial Draft.                                    *
**************************************************************************************************/
global class ValidateServiceRequest {
	webservice static String isDealValidToProceed(String dealId, String roleName){ 
		String message = 'success';
   		NSIBPM__Service_Request__c thisDeal = getSrDetails(dealId); 
   		if(thisDeal != null){  	
	   		if(String.isNotBlank(thisDeal.NSIBPM__Internal_Status_Name__c) && 
	   		   thisDeal.NSIBPM__Internal_Status_Name__c.containsIgnoreCase('Rejected')){
	   			message = 'You cannot access this page. This record has been rejected.';	
	   		}else if(thisDeal.Is_Submitted_For_Approval__c){
	   			message = ' You cannot access this page. This record is submitted for approval.';
	   		}else if(String.isNotBlank(roleName) && roleName.containsIgnoreCase('PC') && 
	   				 thisDeal.NSIBPM__Steps_SR__r != null && thisDeal.NSIBPM__Steps_SR__r.size() > 0){
	   			message = 'You cannot access this page. This deal has been confirmed, the details are locked for editing.';	
	   		}else if(String.isNotBlank(roleName) && roleName.containsIgnoreCase('Contracts') && 
	   				 thisDeal.Doc_ok__c){
	   			message = 'You cannot access this page. This deal has been confirmed and all docs are ok, the details are locked for editing.';	
	   		}
	   		else{
	   			message = 'success';
	   		}
   		}
   		return message;
    }    
    
    /*********************************************************************************************
    * @Description : Method to get SR Detail after insertion.                                    *
    * @Params      : String                                                                      *
    * @Return      : NSIBPM__Service_Request__c                                                  *
    *********************************************************************************************/
    private static NSIBPM__Service_Request__c getSrDetails(String srId){
        NSIBPM__Service_Request__c dealSr = new NSIBPM__Service_Request__c();
        for(NSIBPM__Service_Request__c thisSr : [SELECT Id, Name, NSIBPM__Submitted_Date__c, NSIBPM__Submitted_DateTime__c, 
                                                        Token_Deposit_Due_Date_Time__c, NSIBPM__Internal_SR_Status__c, 
                                                        NSIBPM__External_SR_Status__c, RecordTypeId, Deal_ID__c, Delivery_Mode__c,
                                                        Agent_Name__c, Agency__c, Booking_Wizard_Level__c, Token_Amount_Approval_Status__c,
                                                        NSIBPM__Internal_Status_Name__c, Is_Submitted_For_Approval__c, All_Primary_Buyer_Same__c,
                                                        All_Joint_Buyer_Same__c, Doc_ok__c,
                                                 		(SELECT Id, Unique_Key__c FROM Bookings__r),
                                                 		(SELECT Id, Step_Name__c, NSIBPM__Step_Template__c, NSIBPM__Step_Template__r.NSIBPM__Code__c 
                                                 		 FROM NSIBPM__Steps_SR__r 
                                                 		 WHERE NSIBPM__Step_Template__r.NSIBPM__Code__c =: 'AWAITING_PC_CONFIRMATION' AND 
                                                 		 	   Is_Closed__c = true LIMIT 1)
                                                 FROM NSIBPM__Service_Request__c 
                                                 WHERE Id =: srId]){
            dealSr = thisSr;
            break;  
        }   
        return dealSr;
    }
    
    /*********************************************************************************************
    * @Description : Method to validate the country of Sale .                                    *
    * @Params      : String                                                                      *
    * @Return      : Boolean					                                                 *
    *********************************************************************************************/
    webservice static string validateCountryOfSale(String srChangeAgencyID){
    	
    	NSIBPM__Service_Request__c serviceRequest = [SELECT NSIBPM__Parent_SR__c,Agency__c FROM NSIBPM__Service_Request__c WHERE ID=:srChangeAgencyID ];
    	Set<ID> inventoryID = new Set<ID>();
    	for(Booking_Unit__c bookingUnit : [SELECT Inventory__c FROM Booking_Unit__c WHERE Booking__r.Deal_SR__c =:serviceRequest.NSIBPM__Parent_SR__c AND Inventory__c != null])
			inventoryID.add(bookingUnit.Inventory__c);
			
		return (PropertyBookingController.validateSelectedUnits(serviceRequest.Agency__c,inventoryID) ? 'Sucess' : 'Error');
    }
}// End of class.