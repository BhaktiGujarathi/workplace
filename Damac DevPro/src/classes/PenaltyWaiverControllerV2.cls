public with sharing class PenaltyWaiverControllerV2 {
    
    public Id accountId { get; set; }
    public Account objCustomerAccount {get; set;}
    public Id bookingUnitId { get; set; }
    public Booking_Unit__c selectedUnit { get; set; }
    public WrapperBookingUnit objUnitWrap { get; set; }
    public Case objCase { get; set; }
    public SR_Attachments__c objCRFAttach { get; set; }
    public SR_Attachments__c objPOAAttach { get; set; }
    public Id deleteAttRecId { get; set; } 
    public GenerateSOAController.soaResponse objSOA { get; set; }
    public PenaltyWaiverService.SopResponseObject objResponse { get; set; }
    public list<Case> lstOpenCases { get; set; }
    public list<Case> lstClosedCases { get; set; }
    public transient String crfAttachmentBody { get; set; }
    public transient String crfAttachmentName { get; set; }
    public transient String poaAttachmentBody { get; set; }
    public transient String poaAttachmentName { get; set; }
    public transient String strDisplayMessage { get; set; }
    
    private Attachment objAttach;	
    private map<Id, Account> mapAllAccounts;
    private map<Id, Booking_Unit__c> mapAllBookingUnits;
    private list<Attachment> lstAttachment;
    private map<String,list<SR_Attachments__c>> mapTypeSrAttch ;
    private map<Id, SR_Attachments__c> mapSrAttach ;
    private Id accountIdOld ;
    
    
    public PenaltyWaiverControllerV2() {
    	system.debug(' PenaltyWaiverControllerV2 called...... ');
        lstAttachment = new list<Attachment>();
    }
    
    public list<SelectOption> getlstBookingUnits() {
    	system.debug('Getter Called....');
	    if( accountIdOld != accountId ) {
    		accountIdOld = accountId ;
    		bookingUnitId = null ;
    		selectedUnit = null ;
    		objUnitWrap = null ;
    		objCase = null ;
        }
	    if( accountId != null ) {
	    	mapAllBookingUnits = PenaltyWaiverUtility.getAllRelatedBookingUnits( accountId );
	        if( mapAllBookingUnits != null && !mapAllBookingUnits.isEmpty() ) {
	            list<SelectOption> lstBooking = new list<SelectOption>();
	            lstBooking.add( new SelectOption( '' ,'--NONE--' ) );
	            for( Booking_Unit__c objUnit : mapAllBookingUnits.values() ) {
	                lstBooking.add( new SelectOption( objUnit.Id ,objUnit.Unit_Details__c ) );
	            }
	            return lstBooking ;
	        }
    	}	
        return null;
    }
    
    /*public void getBookingUnits() {
        mapAllBookingUnits = PenaltyWaiverUtility.getAllRelatedBookingUnits( accountId );
        if( mapAllBookingUnits != null && !mapAllBookingUnits.isEmpty() ) {
            lstBookingUnits = new list<SelectOption>();
            lstBookingUnits.add( new SelectOption( '' ,'--NONE--' ) );
            for( Booking_Unit__c objUnit : mapAllBookingUnits.values() ) {
                lstBookingUnits.add( new SelectOption( objUnit.Id ,objUnit.Unit_Details__c ) );
            }
        }
    }*/
    
    public void getBookinUnitDetails() {
        objSOA = null ;
        objResponse = null ;
        Map<Id,Case> mapcase= new map<Id,Case>();
        Set<Id> caseids = new Set<Id>();
        lstOpenCases = new list<Case>();
        lstClosedCases = new list<Case>();
        Map<Id,String> caseId_status = new Map<Id,String>();
        system.debug('Booking Unit Id == '+bookingUnitId);
        objCase = null;
        selectedUnit = mapAllBookingUnits.get( bookingUnitId );
        objUnitWrap = PenaltyWaiverService.getBookingUnitDetails( selectedUnit );
        
        for( Case objCase : PenaltyWaiverUtility.getAllRelatedCases( bookingUnitId ) ) {
        	caseId_status.put(objCase.id,objCase.status); 
        	if( String.isNotBlank( objCase.Status ) && objCase.Status.equalsIgnoreCase( 'Closed' ) ) {
        		lstClosedCases.add( objCase );
        	}
        	else {
        		lstOpenCases.add( objCase );
        	}
        }
        List<SR_Booking_Unit__c> lstSrbookingUnit = PenaltyWaiverUtility.getAllRelatedJunctions( bookingUnitId );
        for(SR_Booking_Unit__c srBookinUnitobj : lstSrbookingUnit){
        	caseids.add(srBookinUnitobj.case__c);
        }
        mapcase = PenaltyWaiverUtility.getCaseMap(caseids);
        for(Case objcase :mapcase.values()){
        	if(!caseId_status.containskey(objcase.id)){
        		if( String.isNotBlank( objcase.Status ) && objcase.Status.equalsIgnoreCase( 'Closed' ) ) {
        			lstClosedCases.add( objCase );
        		}
        		else{
        			lstOpenCases.add( objCase );
        		}
        	}
        }
        objCase = PenaltyWaiverUtility.getExistingOpenCase( bookingUnitId ) ;
        if( objCase.Id != null ) {
        	getAttachments( objCase.Id );
        }
        else {
        	objCRFAttach = null ;
        	objPOAAttach = null ;
        }
    }
    
    public void upsertCaseDetails() {    	
    	objCase = handleCaseData( objCase );
        Boolean isNewCase = objCase.Id == null ? true : false ;
        upsert objCase;
        
        if( isNewCase ) {    
	        SR_Booking_Unit__c objJunction = new SR_Booking_Unit__c();
	        objJunction.Booking_Unit__c = bookingUnitId ;
	        objJunction.Case__c = objCase.Id;
	        insert objJunction ;
        }
        
        list<SR_Attachments__c> lstCustomAttachments = new list<SR_Attachments__c>();
        if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ) {
        	/*uploadAttachment( extractName( crfAttachmentName ) , 
        					  extractBody( crfAttachmentBody ) , 
        					  objCase.Id , 
        					  PenaltyWaiverUtility.ATTACH_TYPE_SHORT_CRF );*/
        	SR_Attachments__c objCustAttach = new SR_Attachments__c();
        	objCustAttach.Case__c = objCase.Id;
        	objCustAttach.Name = extractName( crfAttachmentName ) ;
        	/*objCustAttach.Attachment_URL__c = DocumentUploadService.uploadDocument( EncodingUtil.Base64Encode( extractBody( crfAttachmentBody ) ) ,
        																			bookingUnitId , 
        																			'REGISTRATION',
        																			objCase.Id ,
        																			extractName( crfAttachmentName ) ).url;*/
        	objCustAttach.Attachment_URL__c = 'https://sftest.deeprootsurface.com/docs/e/39169185_33_SOA.pdf';
        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_CRF ;
        	objCustAttach.Booking_Unit__c = bookingUnitId ;
        	objCase.Is_CRF_Uploaded__c = true ;
        	lstCustomAttachments.add( objCustAttach );
        }
        
        if( String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ) {
        	/*uploadAttachment( extractName( poaAttachmentName ) ,
        					  extractBody( poaAttachmentBody ) , 
        					  objCase.Id ,
        					  PenaltyWaiverUtility.ATTACH_TYPE_SHORT_POA );*/
        					  
        	SR_Attachments__c objCustAttach = new SR_Attachments__c();
        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_POA ;
        	objCustAttach.Case__c = objCase.Id;
        	objCustAttach.Booking_Unit__c = bookingUnitId ;
        	objCustAttach.Attachment_URL__c = 'https://sftest.deeprootsurface.com/docs/e/39169185_33_SOA.pdf';
        	objCustAttach.Name = extractName( poaAttachmentName ) ;
        	/*objCustAttach.Attachment_URL__c = DocumentUploadService.uploadDocument( EncodingUtil.Base64Encode( extractBody( poaAttachmentBody ) ) ,
        																			bookingUnitId , 
        																			'REGISTRATION',
        																			objCase.Id ,
        																			extractName( poaAttachmentName ) ).url;		*/		  
        					  
        	objCase.Is_POA_Uploaded__c = true ;
        	lstCustomAttachments.add( objCustAttach );
        	
        }
        
        if( !lstCustomAttachments.isEmpty() ) {
        	insert lstCustomAttachments ;
        	getAttachments( objCase.Id );
        	crfAttachmentBody = null;
        	crfAttachmentName = null;
        	poaAttachmentBody = null;
        	poaAttachmentName = null;
        	lstAttachment = null;
        	lstAttachment = new list<Attachment>();
        	strDisplayMessage = null;
        	deleteAttRecId = null;
    		objAttach = null;
        }
        
        /*if( lstAttachment != null && !lstAttachment.isEmpty() ) { 
        	list<SR_Attachments__c> lstCustomAttachment = uploadCustomAttachment( lstAttachment );
        	integer counter = 0;
        	for( SR_Attachments__c objCustAttach : lstCustomAttachment ) {
        		lstAttachment[ counter ].ParentId = objCustAttach.Id;
        		counter++;
        	}
        	insert lstAttachment ;
        	updateCustomAttachment( lstAttachment, lstCustomAttachment );
	        update objCase;
        	getAttachments( objCase.Id );
        	crfAttachmentBody = null;
        	crfAttachmentName = null;
        	poaAttachmentBody = null;
        	poaAttachmentName = null;
        	lstAttachment = null;
        	lstAttachment = new list<Attachment>();
        	strDisplayMessage = null;
        	deleteAttRecId = null;
    		objAttach = null;
        }*/
        strDisplayMessage = '<span class="symbol icon-tick"></span> Information saved successfully. Case Id : '+objCase.Id;
    }
    
    public void submitCase() {
        //upsertCaseDetails() ;
        objCase = handleCaseData( objCase );
        objCase.Status = PenaltyWaiverUtility.STATUS_SUBMITTED;
        /*objCase.Approving_Authorities__c = 'PC60,PC65,Sales Admin';
        objCase.Submit_for_Approval__c = true ;*/
        objCase.Approval_Status__c = 'Pending';
        try {
        	upsert objCase;
        	strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK +' Penalty waiver request has been raised.';
        }
        catch( Exception e ) {
        	strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage() ;
        }
    }
    
    public void uploadAttachment( String strfileName, Blob objBody, Id parentId, String strType ) {
    	objAttach = new Attachment() ;
    	objAttach.Body = objBody ;
    	objAttach.Name = strType + strfileName ;
    	objAttach.ParentId = parentId ;
    	if( lstAttachment != null ) {
    		lstAttachment.add( objAttach );
    	}
    }
    
    public list<SR_Attachments__c> uploadCustomAttachment( list<Attachment> lstAttachment ) {
		list<SR_Attachments__c> lstCustomAttachment = new list<SR_Attachments__c>();
		for( Attachment objAttach : lstAttachment ) {
			SR_Attachments__c objCustAttach = new SR_Attachments__c();
	        objCustAttach.Case__c = objCase.Id;
	        lstCustomAttachment.add( objCustAttach );
		}
		
		if( lstCustomAttachment != null && !lstCustomAttachment.isEmpty() ) {
			try {
				insert lstCustomAttachment ;
			}
			catch( Exception e ) {
				system.debug('--Exception occured while inserting custom attachment--'+e.getMessage() );
			}
		}
		return lstCustomAttachment;
    }
    
    private void updateCustomAttachment( list<Attachment> lstAttachment, list<SR_Attachments__c> lstCustomAttachment ) {
    	integer counter = 0;
    	for( Attachment objAttach : lstAttachment ) {
			SR_Attachments__c objCustAttach = lstCustomAttachment[ counter ];
	        objCustAttach.Attachment__c = objAttach.Id ;
	        String strType = objAttach.Name.subString( 0, 3);
	        if( strType.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_SHORT_POA ) ) {
	        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_POA ;
	        }
	        else if( strType.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_SHORT_CRF ) ) {
	        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_CRF ;
	        }
	        else if( strType.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_SHORT_SOP ) ) {
	        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_SOP ;
	        }
	        else if( strType.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_SHORT_SOA ) ) {
	        	objCustAttach.Type__c = PenaltyWaiverUtility.ATTACH_TYPE_FULL_SOA ;
	        }
	        objCustAttach.Name = objAttach.Name.substring(3) ;
			counter++;
		}
		update lstCustomAttachment ;
    }
    
    public void insertStatementOfAccount() {
        objResponse = null ;
    	if( String.isNotBlank( selectedUnit.Registration_ID__c ) ) {
    		try {
	    		objSOA = GenerateSOAController.getSOADocument( selectedUnit.Registration_ID__c ) ;
	    	}
	    	catch( Exception e ) {
	    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
	    	}	
    	}
    	else {
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + ' The selected unit dosent have a Registration Id associated with it.';
    	}
    	    	
    	/*try {
        	uploadAttachment( 'Statement Of Account.txt', 
        					  Blob.valueOf( 'Test Attachment for Statement Of Account' ), null , 
        					  PenaltyWaiverUtility.ATTACH_TYPE_SHORT_SOA );
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' Statement of account generated successfully.';
    	}
    	catch( Exception e ) {
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
    	}*/
    }
    
    public void insertStatementOfPenalty() {
    	objSOA = null ;
        if( String.isNotBlank( selectedUnit.Registration_ID__c ) ) {
    		try {
	    		objResponse = PenaltyWaiverService.getSOPDocument( selectedUnit.Registration_ID__c );
	    	}
	    	catch( Exception e ) {
	    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
	    	}	
    	}
    	else {
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + ' The selected unit dosent have a Registration Id associated with it.';
    	}
        
        /*try {
        	uploadAttachment( 'Statement Of Penalty.txt', 
        					  Blob.valueOf( 'Test Attachment for Statement Of Penalty' ), null , 
        					  PenaltyWaiverUtility.ATTACH_TYPE_SHORT_SOP );
        	strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' Statement of penalty generated successfully.';
    	}
    	catch( Exception e ) {
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
    	}*/
    }
    
    public void deleteAttachment() {
    	SR_Attachments__c objCustAttach = mapSrAttach != null && mapSrAttach.containsKey( deleteAttRecId ) ?
    									  mapSrAttach.get( deleteAttRecId ) :
    									  null ;
    	if( objCustAttach.Type__c.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_FULL_POA ) ) {
    		objCase.Is_POA_Uploaded__c = false ;
    		objPOAAttach = null ;
    	}
    	else if( objCustAttach.Type__c.equalsIgnoreCase( PenaltyWaiverUtility.ATTACH_TYPE_FULL_CRF ) ) {
    		objCase.Is_CRF_Uploaded__c = false;
    		objCRFAttach = null ;
    	}
    	
    	try{
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK +' Document for '+ objCustAttach.Type__c +' deleted successfully.';
    		update objCase ;
    		delete objCustAttach ;
    	}
    	catch( Exception e ) {
    		strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + ' Exception generated while deleting the attachment '+e.getMessage() ;
    		system.debug( 'Exception generated while deleting the attachment '+e.getMessage() );
    	}
    }
    
    private void getAttachments( Id caseId ) {
    	system.debug('attachment method called..');
    	mapTypeSrAttch = new map<String,list<SR_Attachments__c>>();
    	mapSrAttach = PenaltyWaiverUtility.fetchCaseAttachments( caseId ) ;
    	for( SR_Attachments__c objCustAttach : mapSrAttach.values() ) {
    		if( mapTypeSrAttch.containsKey( objCustAttach.Type__c ) ) {
    			mapTypeSrAttch.get( objCustAttach.Type__c ).add( objCustAttach );
    		}
    		else {
    			mapTypeSrAttch.put( objCustAttach.Type__c, new list<SR_Attachments__c>{ objCustAttach } );
    		}
    	}
    	if( mapTypeSrAttch != null && !mapTypeSrAttch.isEmpty() ) { 
			objCRFAttach = mapTypeSrAttch.containsKey( PenaltyWaiverUtility.ATTACH_TYPE_FULL_CRF ) ? 
						   mapTypeSrAttch.get( PenaltyWaiverUtility.ATTACH_TYPE_FULL_CRF )[0] : null ;
			system.debug(objCRFAttach);			   
			objPOAAttach = mapTypeSrAttch.containsKey( PenaltyWaiverUtility.ATTACH_TYPE_FULL_POA ) ? 
						   mapTypeSrAttch.get( PenaltyWaiverUtility.ATTACH_TYPE_FULL_POA )[0] : null ;
    		system.debug(objPOAAttach);
    	}
    	else {
    		objCRFAttach = null ;
    		objPOAAttach = null ;
    	}
    }
    
    private Case handleCaseData( Case objCase ) {
        objCase.Penalty_Amount__c = Integer.valueOf( objUnitWrap.objIPMSDetailsWrapper.strPenaltyCharged );
        objCase.Penalty_as_of_date__c = system.today();
        objCase.AccountId = accountId;
        objCase.Booking_Unit__c = bookingUnitId ;
        objCase.RecordTypeId = PenaltyWaiverUtility.getRecordTypeId( PenaltyWaiverUtility.PENALTY_WAIVER_RECTYPE, PenaltyWaiverUtility.CASE_SOBJ );
        objCase.SR_Type__c = 'Penalty Waiver SR';
        objCase.Status = PenaltyWaiverUtility.STATUS_NEW ;
        if( objCase.Penalty_Amount__c != null && objCase.Amount_to_be_waived__c != null) {
        	objCase.Percent_to_be_waived__c = ( objCase.Amount_to_be_waived__c / objCase.Penalty_Amount__c )*100;
        }
        else {
        	objCase.Percent_to_be_waived__c = 0 ;
        }	
        if( !objCase.IsPOA__c ) {
        	objCase.POA_Name__c = '';
        	objCase.POA_Relationship_with_Buyer__c = '';
        	objCase.POA_Expiry_Date__c = null;
        	objCase.POA_Issued_By__c = '';
        	poaAttachmentBody  = '';
 			poaAttachmentName  = '';
        }
        return objCase; 
    }
    
    private String extractName( String strName ) {
    	return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    
    private Blob extractBody( String strBody ) {
    	strBody = EncodingUtil.base64Decode( strBody ).toString();
    	return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }
    
    public static Integer sumApprovedAmountCase(Id BookingUnitId){
    	Decimal totalAmount= 0;
    	Map<Id,Decimal> caseid_Approvedamount = new Map<Id,Decimal>();
    	List<Case> caseLst = PenaltyWaiverUtility.getAllPenaltyWaiverCase(BookingUnitId);
    	List<SR_Booking_Unit__c> SrBookingunitLst = PenaltyWaiverUtility.getAllPenaltyWaivercasesJunctions(BookingUnitId);
    	for(Case caseobj : caseLst){
    		caseid_Approvedamount.put(caseobj.id,caseobj.Approved_Amount__c);
    	}
    	for(SR_Booking_Unit__c srBookingunitobj : SrBookingunitLst){
    		if(!(caseid_Approvedamount.containskey(srBookingunitobj.case__c))){
    			caseid_Approvedamount.put(srBookingunitobj.case__c,srBookingunitobj.case__r.Approved_Amount__c);
    		}
    	}
    	
    	for(Decimal amount :caseid_Approvedamount.values()){
    		totalAmount= totalAmount + amount;
    	}
    	
    	return Integer.valueof(totalAmount);
    }
    
    /*public static Integer caseApprovedAmountSumAccount(Id accountId){
    	Decimal totalapprovedamount = 0 ;
    	List<Case> caselst = new List<case>();
    	caselst = PenaltyWaiverUtility.getAllpenaltyWaiverCaseFromAccount(accountId);
    	for(Case caseobj : caselst){
    		totalapprovedamount+= caseobj.Approved_Amount__c;
    	}
    	
    	return Integer.valueOf(totalapprovedamount);
    }*/
}