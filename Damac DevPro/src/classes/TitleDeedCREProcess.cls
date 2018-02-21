public with sharing class TitleDeedCREProcess {

    public string strSelectedUnit {get;set;}
    //public string strSelectedMode {get;set;}
    public list<SelectOption> lstUnits;
    public Id accountId {get;set;}
    //public list<SelectOption> lstModes {get;set;}
    public list<SelectOption> lstRelationShip {get;set;}
    public string strOverdues {get; set;}
    public string strPenaltiesOnServiceCharges {get; set;}
    public string strPenalties {get; set;}
    public string strAdminFee {get; set;}
    public string strOtherDues {get; set;}
    public string strTotalAmt {get; set;}
    public String strSelectedCategory {get;set;}
    public List<SelectOption> lstCategories {get;set;}
    public list<Case> lstExistingCase;
    public string strCaseID;
    public string strPOAIssuedBy {get; set;}
    public string strPOAName {get; set;}
    public string strPOAExpiryDate {get; set;}
    public string strPOARelationWithOwner {get; set;}
    public transient String strDisplayMessage { get; set; }
    public transient String crfAttachmentBody { get; set; }
	public transient String crfAttachmentName { get; set; }
    public boolean blnStep1 {get;set;}
    public boolean blnStep2 {get;set;}
    public boolean blnStep3 {get;set;}
    public boolean blnPoAValue {get;set;}
    public boolean blnSOAGenerate {get;set;}
    public transient String poaAttachmentBody { get; set; }
    public transient String poaAttachmentName { get; set; }
    public list<Case> lstOpenCase {get;set;}
    public list<Case> lstCloseCase {get;set;}
    public Booking_Unit__c objBookingUnit {get;set;}
    public Id deleteAttRecId { get; set; }
    public SR_Attachments__c objCRFAttach { get; set; }
    public Case objCase { get; set; }
    public boolean blnSubmitCase;
    private string strPropertyCity;
    private boolean blnPropertyDIFC;
	private boolean blnIsPOAGenerated;
	private boolean blnIsSOAGenerated;
	private Attachment objAttach;
	public boolean blnIsError {get;set;} 
	private list<Attachment> lstAttachment = new list<Attachment>();

    public TitleDeedCREProcess(){
        init();
    }//End Constructor

    public void init(){
        blnStep1 = true;
        blnStep2 = true;
        blnStep3 = true;
        blnPoAValue = false;
        blnSubmitCase = false;
        blnIsError = false;
        lstUnits = new list<SelectOption>();
       // lstModes = new list<SelectOption>();
        lstRelationShip = new list<SelectOption>();
        objBookingUnit = new Booking_Unit__c();
        blnIsSOAGenerated = false;
        blnIsPOAGenerated = false;
        strSelectedUnit = '';
        strOverdues = '00';
        strPenaltiesOnServiceCharges = '00';
        strPenalties = '00';
        strAdminFee = '00';
        strOtherDues = '00';
        strTotalAmt = '00';
        strPOAIssuedBy = '';
        strPOAName = '';
        strPOAExpiryDate = '';
        strPOARelationWithOwner = '';
        blnSOAGenerate = false;
        strSelectedCategory = 'Unit Details';
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        lstCategories.add(new selectOption('Close SRs', 'Close SRs'));
        //lstModes.add(new selectOption('Courier', 'Courier'));
        //lstModes.add(new selectOption('Collection By Hand', 'Collection By Hand'));

        lstRelationShip.add(new selectOption('--None--', '--None--'));
        lstRelationShip.add(new selectOption('Father', 'Father'));
        lstRelationShip.add(new selectOption('Mother', 'Mother'));
        lstRelationShip.add(new selectOption('Brother', 'Brother'));
        lstRelationShip.add(new selectOption('Sister', 'Sister'));

        //lstUnits.add(new selectOption('', '--None--'));
        /*for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c = '0017E00000cWKII'
                                      and Handover_Complete__c = true]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for*/
    }//End init

    public list < SelectOption > getlstUnits(){
        lstUnits = new list<selectOption>();
        lstUnits.add(new selectOption('', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c =: accountId
                                      and Handover_Complete__c = true]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for
        return lstUnits;
    }//end getlstUnits

    //Auto-populate BU Details
    public void autoPopulateBUDetails(){
        lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        lstExistingCase = new list<Case>();
        if(strSelectedUnit!=null){
        for(Case objCase : [select ID,
                                    CaseNumber,
                                    Status,
                                    Booking_Unit__c
                               from Case
                              where Booking_Unit__c =: strSelectedUnit]){
                if(objCase.Status != 'Closed'){
                    lstOpenCase.add(objCase);
                }else{
                    lstCloseCase.add(objCase);
                }//end if-else
         }//end for
        }//end if
        
         if(strSelectedUnit!=null){
         objBookingUnit = [select ID,
                              Bedroom_Type__c,
                              Inventory__r.Property_Name_2__c,
                              Inventory__r.Property_City__c,
                              Inventory__r.Bedroom_Type__c,
                              Inventory__r.Unit_Type__c,
                              Inventory__r.Property_Status__c,
                              Inventory__r.Property__r.DIFC__c,
                              Booking_Unit_Type__c,
                              Permitted_Use__c,
                              Rental_Pool_Status__c,
                              Unit_Selling_Price__c,
                              Area__c,
                              Related_Promotion_Title__c,
                              Final_Invoice__c,
                              Penalty_Amount__c,
                              Booking_Type__c,
                              Plot_Price__c,
                              CreatedDate,
                              Agreement_Date__c,
                              JOPD_Area__c,
                              Dispute_Flag__c,
                              DSR_Flag__c,
                              DP_OK__c,
                              Doc_OK__c,
                              OQOOD_Reg_Flag__c,
                              Early_Handover__c,
                              Handover_Flag__c,
                              PCC_Generate__c,
                              Rental_Pool__c
                         from Booking_Unit__c
                        where ID =: strSelectedUnit];
                strPropertyCity = objBookingUnit.Inventory__r.Property_City__c;
                blnPropertyDIFC = objBookingUnit.Inventory__r.Property__r.DIFC__c;
                system.debug('---blnPropertyDIFC-' + blnPropertyDIFC);
             
              if(checkExistingSRExists().size() > 0){
                 string errorMessage = 'Error : An open Service Request already exists for the chosen Booking Unit. You will be unable to proceed';
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
                 blnIsError = true;
              }
               
             if((strPropertyCity != 'dubai') || blnPropertyDIFC == false){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Title Deed Is Eligible For Dubai Region & DIFC flag only'));
                blnIsError = true;
             }
             }else {
            objBookingUnit = new Booking_Unit__c ();
         }//end if-else
         system.debug('--strSelectedUnit-'+strSelectedUnit);
         if(strSelectedUnit == 'a0x7E000000MQ2bQAG'){
            system.debug('--inside if');
            strOverdues = '10';
            strPenaltiesOnServiceCharges = '20';
            strPenalties = '20';
            strAdminFee = '200';
            strOtherDues = '50';
            strTotalAmt = '300';
         }//end if
    }//end autoPopulateBUDetails

    public list<Case> checkExistingSRExists(){
        set<String> setAllowedSRTypes = new set<String>();
        setAllowedSRTypes.add('Complaint');
        setAllowedSRTypes.add('Promotion_Package');
        setAllowedSRTypes.add('Proof_of_Payment_SR');
        setAllowedSRTypes.add('Rental_Pool_Agreement');
        setAllowedSRTypes.add('Token_Refund');
        setAllowedSRTypes.add('Customer_Refund');
        setAllowedSRTypes.add('Rental_Pool_Termination');
        setAllowedSRTypes.add('Utility_Registration_SR');
        setAllowedSRTypes.add('Cheque_Replacement_SR');

        
        map<Id,Case> mapId_Case = new map<Id,Case>([Select Id
                                                         , Booking_Unit__c
                                                         , AccountId
                                                         , CaseNumber
                                                         , RecordType.DeveloperName
                                                         , RecordType.Name
                                                    From Case
                                                    where Booking_Unit__c =: strSelectedUnit
                                                    and   Status != 'Closed'
                                                    and   Status != 'Rejected'
                                                    and   RecordType.DeveloperName NOT IN : setAllowedSRTypes]);
        if(mapId_Case != null && !mapId_Case.isEmpty()){
            lstExistingCase.addAll(mapId_Case.values());
        }
        for(SR_Booking_Unit__c objSBU : [Select Id
                                              , Case__c
                                              , Case__r.Status
                                              , Case__r.CaseNumber
                                              , Case__r.RecordType.DeveloperName
                                              , Case__r.RecordType.Name
                                              , Booking_Unit__c 
                                         From SR_Booking_Unit__c
                                         where Booking_Unit__c =:strSelectedUnit
                                         and Case__r.Status != 'Closed'
                                         and Case__r.Status != 'Rejected'
                                         and Case__r.RecordType.DeveloperName = 'AOPT']){
            if(!mapId_Case.containsKey(objSBU.Case__c)){
                Case objCase = objSBU.Case__r;
                lstExistingCase.add(objCase);
            }
        }
        return lstExistingCase;
    }//end checkExistingSRExists

    public void createTitleDeedSR(){
         if((strPropertyCity != 'dubai') || blnPropertyDIFC == false){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Title Deed Is Eligible For Dubai Region & DIFC flag only'));
                blnIsError = true;
        }else {
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Deed').getRecordTypeId();
        system.debug('!!!!strSelectedUnit'+strSelectedUnit);
        if(strSelectedUnit!='--None--' && strSelectedUnit != null && strCaseID == null){
            Case objCase = new Case();
            objCase.RecordTypeID = caseRecordTypeId;
            objCase.Booking_Unit__c = strSelectedUnit;
            if(blnSubmitCase == true)
             objCase.Status = 'Submitted';
            else
             objCase.Status = 'Draft Request';
             objCase.Origin = 'Walk-In';
             objCase.Description = 'Title Deed Assignment';
            if(strTotalAmt== '00'){
            	objCase.Penalties__c = strPenalties;
            	objCase.Penalties_LP_Fee_on_Service_Charges__c = strPenaltiesOnServiceCharges;
            	objCase.Overdues_Dues_Towards_Service_Charges__c = strOverdues;
            	objCase.Admin_Fee_For_Title_Deed__c = strAdminFee;
            	objCase.Other_Dues__c = strOtherDues;
            	objCase.Total_Amount_To_Be_Paid__c = strTotalAmt;
            	objCase.Mode_of_Collection__c = 'Courier';
            } /*else {
            	createTaskForPaymentDues();
            //////}*/
            if(blnPoAValue == true){
            	objCase.POA_Issued_By__c = strPOAIssuedBy;
            	objCase.POA_Name__c = strPOAName;
            	if (strPOAExpiryDate != null && strPOAExpiryDate != '')
            	objCase.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
            	objCase.Purpose_of_POA__c = strPOARelationWithOwner;
            }
            try{
             if(objCase!=null){
                /*if ((String.isBlank( crfAttachmentBody ) || String.isBlank( crfAttachmentName )) && blnSubmitCase == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed CRF document.'));
                blnIsError = true;
            } else */if (blnPoAValue == true && String.isBlank( poaAttachmentBody ) && blnSubmitCase == true) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
                blnIsError = true;
            } else if(blnPoAValue == true  && String.isBlank(strPOAIssuedBy) && String.isBlank(strPOAName) && String.isBlank(strPOAExpiryDate) && strPOARelationWithOwner=='--None--'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Power of Attorney Details'));
                blnIsError = true;
            }else if (strTotalAmt != '00' && blnSubmitCase == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please pay your dues before submitting'));
                blnIsError = true;
            }else{
                insert objCase;
                strCaseID = objCase.ID;
                if(strTotalAmt!= '00')
                 createTaskForPaymentDues();
                 String err = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()+ '/' + strCaseID + '" target="_blank">View SR</a>';
                if (blnSubmitCase == false){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Title Deed Case is Created  ' + err));
                    blnIsError = true;
                }else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Title Deed Case is Submitted  ' + err));
                    blnIsError = false;
                }
                 blnSubmitCase = false;
                }
             }
            }catch(DMLException errorMessage){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage.getMessage()));
            }//end try-catch

        } else if(strSelectedUnit == null) {
        	system.debug('!!!!!!!!!!pageError');
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select an Unit'));
        	blnIsError = true;
        } else if (strCaseID != null) {
        	objCase = new Case(Id = strCaseID);
        	if(strTotalAmt== '00'){
            	objCase.Penalties__c = strPenalties;
            	objCase.Penalties_LP_Fee_on_Service_Charges__c = strPenaltiesOnServiceCharges;
            	objCase.Overdues_Dues_Towards_Service_Charges__c = strOverdues;
            	objCase.Admin_Fee_For_Title_Deed__c = strAdminFee;
            	objCase.Other_Dues__c = strOtherDues;
            	objCase.Total_Amount_To_Be_Paid__c = strTotalAmt;
            	objCase.Mode_of_Collection__c = 'Courier';
            } else {
            	createTaskForPaymentDues();
            }
            if(blnPoAValue == true){
            	objCase.POA_Issued_By__c = strPOAIssuedBy;
            	objCase.POA_Name__c = strPOAName;
            	if (strPOAExpiryDate != null && strPOAExpiryDate != '')
            	objCase.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
            	objCase.Purpose_of_POA__c = strPOARelationWithOwner;
            }
            update objCase;
        }
        if(blnPoAValue == true && strCaseID != null && blnIsPOAGenerated == false){
        	updatePoADetails();
        	blnIsPOAGenerated = true;
        }
        if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) && strCaseID != null) {
        	createCRF();
		}
		if (blnSOAGenerate == true && strCaseID != null && blnIsSOAGenerated == false) {
            	system.debug('inside if');
            	generateSoADoc();
            	blnIsSOAGenerated = true;
        }
        if (lstAttachment != null && lstAttachment.size()>0 && strCaseID != null) {
        	createAttach();
        }
      }
    }//end createTitleDeedSR

    public void createTaskForPaymentDues(){

            Task objTask  = new Task();
            objTask.Subject = 'Take follow-up with customer for Payment';
            objTask.WhatID = strCaseID ; 
            objTask.OwnerId = '0050Y000001SBsP';
            objTask.status = 'In Progress';
            objTask.priority= 'Medium';
            insert objTask;      

    }//End createTaskForPaymentDues
	
	public void SOAtobeGenerated() {
		system.debug('!!!!!!!!!!!inside SOA method');
		blnSOAGenerate = true;
	}
	public void generateSoADoc(){
		system.debug('!!!!!!!!!!!inside SOA Creation method');
		 PageReference pdf = Page.StatementOfAccountPage;
		 Blob body =  pdf.getContentAsPDF();
          uploadAttachments( extractName( 'Statement of Account.pdf' ) ,
                     body , 
                    strCaseID ,
                    'SOA' );
        
	}
    public void updatePoADetails(){
        if(blnPoAValue == true){
            Task objTask  = new Task();
            objTask.Subject = 'Verify Documents';
            objTask.WhatID = strCaseID ; 
            objTask.OwnerId = '0050Y000001SBsP';
            objTask.status = 'In Progress';
            objTask.priority= 'Medium';
            objTask.Process_Name__c = 'Title Deed';
            insert objTask;
        
        system.debug('!!!!!!!poaAttachmentBody'+poaAttachmentBody);
        system.debug('!!!!!!!poaAttachmentName'+poaAttachmentName);    
        if( String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ) {
          uploadAttachments( extractName( poaAttachmentName ) ,
                    extractBody( poaAttachmentBody ) , 
                    strCaseID ,
                    'POA' );
        }
        }//end if
    }//end updatePoADetails

    public void deleteAttachment() {
      SR_Attachments__c objCustAttach ;
      Case objCase = [select ID,
                             Is_CRF_Uploaded__c,
                             Is_CRF_Verified__c
						from Case
						where ID =: strCaseID];
      if( objCustAttach.Type__c.equalsIgnoreCase( 'Customer Request Form' ) ) {
        objCase.Is_CRF_Uploaded__c = false;
        objCase.Is_CRF_Verified__c = false;
        objCRFAttach = null ;
      }
      
      try{
        strDisplayMessage = '<span class="symbol icon-tick"></span>' +' Document for '+ objCustAttach.Type__c +' deleted successfully.';
        update objCase ;
        delete objCustAttach ;
      }
      catch( Exception e ) {
        strDisplayMessage = '<span class="symbol icon-cross"></span>' + ' Exception generated while deleting the attachment '+e.getMessage() ;
        system.debug( 'Exception generated while deleting the attachment '+e.getMessage() );
      }
    }
    public void createCRF() {
    	system.debug('!!!!!!!!!crfAttachmentBody'+crfAttachmentBody);
		system.debug('!!!!!!!!!crfAttachmentName'+crfAttachmentName);
		 if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ) {
          uploadAttachments( extractName( 'TD CRF.pdf' ) , 
                    extractBody( crfAttachmentBody ) , 
                    strCaseID , 
                    'CRF' );
        }
    }
    
    public void createAttach() {
    	if( lstAttachment != null && !lstAttachment.isEmpty() ) { 
          list<SR_Attachments__c> lstCustomAttachment = uploadCustomAttachment( lstAttachment, strCaseID );
          integer counter = 0;
          for( SR_Attachments__c objCustAttach : lstCustomAttachment ) {
            lstAttachment[ counter ].ParentId = objCustAttach.Id;
            counter++;
          }
          insert lstAttachment ;
          updateCustomAttachment( lstAttachment, lstCustomAttachment );
          lstAttachment= new list<Attachment>();
        }
    }
    public void submitCase() {
        blnSubmitCase = true;
    	if (strCaseId != null) {
    		Case objCase = [select ID,
                             Status
						from Case
						where ID =: strCaseId];
			/*if (String.isBlank( crfAttachmentBody ) || String.isBlank( crfAttachmentName )){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed CRF document.'));
			     blnIsError = true;
			} else */if (blnPoAValue == true && String.isBlank( poaAttachmentBody )) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
			     blnIsError = true;
			} else if (strTotalAmt != '00'){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please pay your dues before submitting'));
			     blnIsError = true;
			} else {
				objCase.Status = 'Submitted';
				update objCase;
				String SubmitMessage = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()+ '/' + strCaseID + '" target="_blank">View SR</a>';
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Title Deed Case is Submitted' + SubmitMessage));
			     blnIsError = false;
			}
			createTitleDeedSR();
    	} else {
    		createTitleDeedSR();
    	}
    }
    
    public list<SR_Attachments__c> uploadCustomAttachment( list<Attachment> lstAttachment, Id caseId ) {
	    list<SR_Attachments__c> lstCustomAttachment = new list<SR_Attachments__c>();
	    for( Attachment objAttach : lstAttachment ) {
	      SR_Attachments__c objCustAttach = new SR_Attachments__c();
	          objCustAttach.Case__c = caseId;
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
          if( strType.equalsIgnoreCase( 'poa' ) ) {
            objCustAttach.Type__c = 'Power of Attorney' ;
          }
          else if( strType.equalsIgnoreCase( 'crf' ) ) {
            objCustAttach.Type__c = 'Customer Request Form' ;
          }
          else if( strType.equalsIgnoreCase( 'soa') ) {
	        	objCustAttach.Type__c = 'Statement of Account' ;
	        	objCustAttach.isValid__c = true;
	        }
          
          objCustAttach.Name = objAttach.Name.substring(3) ;
      counter++;
    }
    update lstCustomAttachment ;
    }
    
    public void uploadAttachments( String strfileName, Blob objBody, Id parentId, String strType ) {
    	system.debug('!!!!!!inside attachemnet creation');
      objAttach = new Attachment() ;
      objAttach.Body = objBody ;
      objAttach.Name = strType + strfileName ;
      objAttach.ParentId = parentId ;
      lstAttachment.add( objAttach );
    }
    
    private String extractName( String strName ) {
      return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    
    private Blob extractBody( String strBody ) {
      strBody = EncodingUtil.base64Decode( strBody ).toString();
      return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }

}//end TitleDeedCREProcess