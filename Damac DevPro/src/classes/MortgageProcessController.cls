public with sharing class MortgageProcessController {
	public List<Account> accountsList{get; set;}
	public String selectedAcc{get; set;} //this will be used if accountId is selected from component dropdown
	public String selectedBookingUnitId{get; set;}
	public List<Booking_Unit__c> bookingUnitList{get; set;}
	public Booking_Unit__c bookingUnitDetails{get; set;}
	public List<Payment_Terms__c> listMortgagePaymentPlans{get; set;}
	public Case mortgageCaseObj{get; set;}
	public transient String crfAttachmentBody { get; set; }
	public transient String crfAttachmentName { get; set; }
	public transient String poaAttachmentBody { get; set; }
	public transient String poaAttachmentName { get; set; }
	public Boolean custEligibleMortgage { get; set; }

	public MortgageProcessController() {
		custEligibleMortgage = false;
		bookingUnitList = new List<Booking_Unit__c>();
		listMortgagePaymentPlans = new List<Payment_Terms__c>();
		accountsList = new List<Account>();
		accountsList =  [SELECT Name, Id, IsPersonAccount FROM Account];
		mortgageCaseObj = new Case(Type=MortgageProcessUtility.MORTGAGE_RECTYPE_NAME,RecordTypeId=MortgageProcessUtility.getRecordTypeId(),Status=MortgageProcessUtility.MORTGAGE_INITIAL_STATUS);
	}

	public void getUnitList(){
        if(!String.isBlank(selectedAcc)){
            bookingUnitList = [SELECT Inventory__r.Unit_Location__r.Unit_Name__c,Unit_Details__c, Id, Booking__c FROM Booking_Unit__c WHERE Booking__r.Account__c =: selectedAcc AND Re_Assigned__c = false];
			System.debug('bookingUnitList ==== '+ bookingUnitList);
        }
    }

    public void getUpdatedUnitDetails(){
        if(!String.isBlank(selectedBookingUnitId) && selectedBookingUnitId != 'none'){
            bookingUnitDetails = [SELECT Name,Id,Inventory__c, Inventory__r.Property__r.Name,Inventory__r.Property_City__c,Bedroom_Type__c,Unit_Type__c,
									Permitted_Use__c,Inventory__r.Building_Location__r.Status__c,Rental_Pool_Status__c,Area__c,Selling_Price__c,Agent_Name__c,Construction_Status__c,
									Unit_s_Current_Status__c,OQOOD_Reg_Flag__c,Early_Handover__c,Handover_Complete__c,Unit_Selling_Price_AED__c,
									DP_Overdue__c
                          		FROM Booking_Unit__c WHERE Id =: selectedBookingUnitId];

      		listMortgagePaymentPlans = [SELECT Description__c, Percent_Value__c,Milestone_Event__c,Milestone_Event_Arabic__c,Expected_Date__c
      									FROM Payment_Terms__c WHERE Booking_Unit__c =: selectedBookingUnitId];
        }
    	System.debug(bookingUnitDetails);
	}

	public void mortgageEligibilityCheck(){
		mortgageCaseObj.Customer_Eligible_For_Mortgage__c = true;
		custEligibleMortgage = true;
	}

	public void saveCase(){
		if( String.isBlank( mortgageCaseObj.AccountId ) ) {  mortgageCaseObj.AccountId = selectedAcc;  }
		if( String.isBlank( mortgageCaseObj.Booking_Unit__c ) ) {  mortgageCaseObj.Booking_Unit__c = selectedBookingUnitId;  }
		try{

			upsert mortgageCaseObj;

			if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
				uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), mortgageCaseObj.Id, extractType(crfAttachmentName), MortgageProcessUtility.MORTGAGE_CRF_NAME);
				crfAttachmentBody = null;
				crfAttachmentName = null;

			}

			if( String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ){
				uploadAttachment( extractName(poaAttachmentName), extractBody(poaAttachmentBody), mortgageCaseObj.Id, extractType(poaAttachmentName), MortgageProcessUtility.MORTGAGE_POA_NAME );
				poaAttachmentBody = null;
				poaAttachmentName = null;
			}
		} catch(Exception e){

		}
	}

	public void mortgageSubmitCase(){
		mortgageCaseObj.Status=MortgageProcessUtility.MORTGAGE_SUBMIT_STATUS;
		saveCase();
	}

	public void uploadAttachment( String strfileName, Blob objBody, Id parentId, String strType, String strAttachmentName ) {
		SR_Attachments__c srAttchmentObj = new SR_Attachments__c(Case__c = parentId,Type__c = strType,Name=strAttachmentName);
		insert srAttchmentObj;

		Attachment objAttach = new Attachment();
		objAttach.Body = objBody;
		objAttach.Name = strType + strfileName;
		objAttach.ParentId = srAttchmentObj.Id;

		insert objAttach;

		srAttchmentObj.Attachment__c = objAttach.Id;
		update srAttchmentObj;
	}

	private String extractName( String strName ) {
		return strName.substring( strName.lastIndexOf('\\')+1 ) ;
	}

	private Blob extractBody( String strBody ) {
		strBody = EncodingUtil.base64Decode( strBody ).toString();
		return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
	}

	private String extractType( String strName ) {
		strName = strName.substring( strName.lastIndexOf('\\')+1 );
		return strName.substring( strName.lastIndexOf('.')+1 ) ;
	}
}