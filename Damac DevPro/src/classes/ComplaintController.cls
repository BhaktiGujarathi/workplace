public with sharing class ComplaintController {
	public List<Booking_Unit__c> bookingUnitList{get; set;}
	public Booking_Unit__c bookingUnitDetails{get; set;}
	public List<Account> accountsList{get; set;}
	public String selectedAcc{get; set;} //this will be used if accountId is selected from component dropdown
	public String selectedBookingUnitId{get; set;}
	public Case complaintCaseObj{get; set;}
	public transient String crfAttachmentBody { get; set; }
	public transient String crfAttachmentName { get; set; }
	public transient String attachment1Body { get; set; }
	public transient String attachment1Name { get; set; }
	public transient String attachment2Body { get; set; }
	public transient String attachment2Name { get; set; }

	public ComplaintController() {
		complaintCaseObj = new Case(Type=ComplaintProcessUtility.COMPLAINT_CASE_TYPE,RecordTypeId=ComplaintProcessUtility.getRecordTypeId(),Status=ComplaintProcessUtility.COMPLAINT_INITIAL_STATUS);
		bookingUnitList = new List<Booking_Unit__c>();
		accountsList = new List<Account>();
		accountsList =  [SELECT Name, Id, IsPersonAccount FROM Account];
	}

	public void getUpdatedUnitDetails(){
		String bookingUnitId = Apexpages.currentpage().getparameters().get('bookingUnitId');
        if(!String.isBlank(bookingUnitId) && bookingUnitId != 'none'){
            bookingUnitDetails = [SELECT Name,Id,Inventory__c, Inventory__r.Property__r.Name,Inventory__r.Property_City__c,Bedroom_Type__c,Unit_Type__c,
									Permitted_Use__c,Inventory__r.Building_Location__r.Status__c,Rental_Pool_Status__c,Area__c,Selling_Price__c,
									Unit_s_Current_Status__c,OQOOD_Reg_Flag__c,Early_Handover__c,Handover_Complete__c,Unit_Selling_Price_AED__c,
									DP_Overdue__c
                          		FROM Booking_Unit__c WHERE Id =: bookingUnitId];
        }
    	System.debug(bookingUnitDetails);
	}

	public void getUnitList(){
        if(!String.isBlank(selectedAcc)){
            bookingUnitList = [SELECT Inventory__r.Unit_Location__r.Unit_Name__c,Unit_Details__c, Id, Booking__c FROM Booking_Unit__c WHERE Booking__r.Account__c =: selectedAcc AND Re_Assigned__c = false];
			System.debug('bookingUnitList ==== '+ bookingUnitList);
        }
    }

		public void complaintSubmitCase(){
			complaintCaseObj.Status=ComplaintProcessUtility.COMPLAINT_SUBMIT_STATUS;
			saveComplaintCase();
		}

		public void saveComplaintCase(){
			if( String.isBlank( complaintCaseObj.AccountId ) ) {  complaintCaseObj.AccountId = selectedAcc;  }
			if( String.isBlank( complaintCaseObj.Booking_Unit__c ) ) {  complaintCaseObj.Booking_Unit__c = selectedBookingUnitId;  }
			try{

				upsert complaintCaseObj;

				if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
					uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), complaintCaseObj.Id, extractType(crfAttachmentName), ComplaintProcessUtility.COMPLAINT_CRF_NAME);
					crfAttachmentBody = null;
					crfAttachmentName = null;

				}

				if( String.isNotBlank( attachment1Body ) && String.isNotBlank( attachment1Name ) ){
					uploadAttachment( extractName(attachment1Name), extractBody(attachment1Body), complaintCaseObj.Id, extractType(attachment1Name), ComplaintProcessUtility.COMPLAINT_ATT1_NAME );
					attachment1Body = null;
					attachment1Name = null;
				}

				if( String.isNotBlank( attachment2Body ) && String.isNotBlank( attachment2Name ) ){
					uploadAttachment( extractName(attachment2Name), extractBody(attachment2Body), complaintCaseObj.Id, extractType(attachment2Name), ComplaintProcessUtility.COMPLAINT_ATT2_NAME );
					attachment2Body = null;
					attachment2Name = null;
				}
			} catch(Exception e){

			}
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