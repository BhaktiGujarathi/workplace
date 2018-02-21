public with sharing class RentalPoolCREProcess {

    public Booking_Unit__c objBookingUnit {get;set;}
    public Id accountId {get;set;}
    public list<Case> lstOpenCase {get;set;}
    public list<Case> lstCloseCase {get;set;}
    public list<selectOption> lstModes {get;set;}
    public list<selectOption> lstUnits ;
    public string strSelectedUnit {get;set;}
    public string strUnitAvailableDate {get;set;}
    //public string strRentalPoolDate {get;set;}
    public string strSelectedMode {get;set;}
    public boolean blnPoAValue {get;set;}
    public string strPOAName {get;set;}
    public string strPOARelationWithOwner {get;set;}
    public string strPOAExpiryDate {get;set;}
    public string strPOAIssuedBy {get;set;}
    public boolean blnSOAGenerate {get;set;}
    public string poaAttachmentBody {get;set;}
    public string poaAttachmentName {get;set;}
    public string crfAttachmentBody {get;set;}
    public string crfAttachmentName {get;set;}
    public string SOAurl {get;set;}
    public string agreementAttachmentBody {get;set;}
    public string agreementAttachmentName {get;set;}
    public string strSelectedUnitName {get;set;}
    public string strCaseID;
    public boolean blnIsCRFGenerated;
    public boolean blnIsAgreementGenerated;
    public boolean blnIsPOAGenerated;
    public boolean blnIsSOAGenerated;
    public boolean blnSubmitCase;
    public Case objCase { get; set; }
    
    private Attachment objAttach; 
    private list<Attachment> lstAttachment;
    
    public RentalPoolCREProcess(){
        init();
    }//End Constructor

    public void init(){
        objBookingUnit = new Booking_Unit__c();
        lstModes = new list<selectOption>();
        //lstUnits = new list<selectOption>();
        blnIsCRFGenerated = false;
        blnIsAgreementGenerated = false;
        blnIsPOAGenerated = false;
        blnIsSOAGenerated = false;
        blnSubmitCase = false;
        lstAttachment = new list<Attachment>();

        lstModes.add(new selectOption('Courier', 'Courier'));
        lstModes.add(new selectOption('Collection By Hand', 'Collection By Hand'));


        //lstUnits.add(new selectOption('', '--None--'));
        /*for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c = '0017E00000cWKII'
                                      and (Handover_Complete__c = true
                                       or Early_Handover__c = true)
                                      and Booking_Unit_Type__c =: 'Service Apartment']){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for*/
    }//end init
    
    public list < SelectOption > getlstUnits(){
        lstUnits = new list<selectOption>();
        lstUnits.add(new selectOption('', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c =: accountId
                                      and (Handover_Complete__c = true
                                       or Early_Handover__c = true)
                                      and Booking_Unit_Type__c =: 'Service Apartment']){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for
        return lstUnits;
    }//end getlstUnits
    
    public void autoPopulateBUDetails(){
    	lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        if(strSelectedUnit!= null){
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
       if(strSelectedUnit!= null){
         objBookingUnit = [select ID,
                              Bedroom_Type__c,
                              Booking_Unit_Type__c,
                              Permitted_Use__c,
                              Unit_Details__c,
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
         strSelectedUnitName = objBookingUnit.Unit_Details__c;
       }else{
         strSelectedUnitName = '';
       }
    }//end autoPopulateBUDetails
    
    public void SOAtobeGenerated() {
        system.debug('!!!!!!!!!!!inside SOA method');
        blnSOAGenerate = true;
        GenerateSOAController.soaResponse objSOA = GenerateSOAController.getSOADocument('41332');
        system.debug('!!!!!objSOA'+objSOA.url);
        SOAurl = objSOA.url;
     }//end SOAtobeGenerated
    
     public void createRentalPoolSR(){
        system.debug('---inside createRentalPoolSR');
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rental Pool Agreement').getRecordTypeId();
        if(strSelectedUnit!=null && strCaseID == null){
            Case objCase = new Case();
            objCase.RecordTypeID = caseRecordTypeId;
            objCase.Booking_Unit__c = strSelectedUnit;
            if(blnSubmitCase == true)
             objCase.Status = 'Submitted';
            else
             objCase.Status = 'Draft Request';
             objCase.Origin = 'Walk-In';
             objCase.Inspection_Status__c = 'Request Sent To Hospitality';
             objCase.Subject = 'Rental Pool Agreement SR';
             objCase.Description = 'Rental Pool Agreement SR';
             objCase.Unit_Available_From__c = date.parse(strUnitAvailableDate);
             //objCase.Rental_Pool_Start_Date__c = date.parse(strRentalPoolDate);
             objCase.Mode_of_Dispatch_of_Agreement__c = strSelectedMode;
             objCase.Rental_Pool_Offer__c = 'Offer 1';
            if(blnPoAValue == true){
                objCase.POA_Issued_By__c = strPOAIssuedBy;
                objCase.POA_Name__c = strPOAName;
                if (strPOAExpiryDate != null && strPOAExpiryDate != '')
                objCase.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                objCase.Purpose_of_POA__c = strPOARelationWithOwner;
            }
            try{
             if(objCase!=null){
            if ((String.isBlank( crfAttachmentBody ) || String.isBlank( crfAttachmentName )) && blnSubmitCase == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed CRF document.'));
            } else if (blnPoAValue == true && String.isBlank( poaAttachmentBody ) && blnSubmitCase == true) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
            } else if(blnPoAValue == true  && String.isBlank(strPOAIssuedBy) && String.isBlank(strPOAName) && String.isBlank(strPOAExpiryDate) && strPOARelationWithOwner==''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Power of Attorney Details'));
            }else if ((String.isBlank( agreementAttachmentBody ) || String.isBlank( agreementAttachmentName )) && blnSubmitCase == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed Agreement document.'));
            }else{
                insert objCase;
                strCaseID = objCase.ID;
                
                //Sent notification to Hospitality Team
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  // Step 2: Set list of people who should get the email
                     List<String> sendTo = new List<String>();
                     sendTo.add('yogeshsharma2391@gmail.com');
                     mail.setToAddresses(sendTo);

                  // Step 2. Set email contents - you can use variables!
                  mail.setSubject('Provide Booking Unit Details');
                  String body = 'Hello Yogesh, ';
                  body += 'Rental Pool SR is created for this booking Unit:' + strSelectedUnitName;
                  body += 'Please provide additonal information related to this booking unit';

                  mail.setHtmlBody(body);

                  // Step 5. Add your email to the master list
                  mails.add(mail);

                  // Step 6: Send all emails in the master list
                  Messaging.sendEmail(mails);

                if (blnSubmitCase == false)
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Rental Pool SR is Created  ' + strCaseID));
                else
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Rental Pool SR is Submitted  ' + strCaseID));
                 blnSubmitCase = false;
                }
             }
            }catch(DMLException errorMessage){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage.getMessage()));
            }//end try-catch

        } else if(strSelectedUnit == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select an Unit'));
            
        } else if (strCaseID != null) {
             objCase = new Case(Id = strCaseID);
             objCase.Booking_Unit__c = strSelectedUnit;
             objCase.Unit_Available_From__c = date.parse(strUnitAvailableDate);
             //objCase.Rental_Pool_Start_Date__c = date.parse(strRentalPoolDate);
             objCase.Mode_of_Collection__c = strSelectedMode;
            if(blnPoAValue == true){
                objCase.POA_Issued_By__c = strPOAIssuedBy;
                objCase.POA_Name__c = strPOAName;
                if (strPOAExpiryDate != null && strPOAExpiryDate != '')
                objCase.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                objCase.POA_Relation_With_Owner__c = strPOARelationWithOwner;
            }
            update objCase;
        }//end else-if
        if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) && strCaseID != null && blnIsCRFGenerated == false) {
            system.debug('createCRF calling---');
            createCRF();
             Task objCRFTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Generate and Upload Signed CRF'
                              and OwnerId =: '0050Y000001SBsP'
                              and WhatID =: strCaseID];
            objCRFTask.Status = 'Completed';
            update objCRFTask;
            
             Task objTask  = new Task();
                objTask.Subject = 'Generate and Upload Signed Agreement';
                objTask.WhatID = strCaseID ; 
                objTask.OwnerId = '0050Y000001SBsP';
                objTask.status = 'In Progress';
                objTask.priority= 'Medium';
                objTask.Process_Name__C = 'Rental Pool Agreement';
             insert objTask;
             
             Case objCRFCase = [Select ID, Status from Case where ID =: strCaseID];
             objCRFCase.Status = 'CRF Generated';
             update objCRFCase;
             
            blnIsCRFGenerated = true;
        }
        if (blnSOAGenerate == true && strCaseID != null && blnIsSOAGenerated == false) {
                system.debug('inside if');
                generateSoADoc();
                blnIsSOAGenerated = true;
        }
        if (blnPoAValue == true && String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) && strCaseID != null && blnIsPOAGenerated == false) {
                system.debug('inside if');
                generatePoADoc();
                blnIsPOAGenerated = true;
        }
        if (String.isNotBlank( agreementAttachmentBody ) && String.isNotBlank( agreementAttachmentName ) && strCaseID != null && blnIsAgreementGenerated == false) {
                system.debug('inside if');
                generateAgreementDoc();
                Task objCRFTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Generate and Upload Signed Agreement'
                              and OwnerId =: '0050Y000001SBsP'
                              and WhatID =: strCaseID
                              and Process_Name__C =: 'Rental Pool Agreement'];
                objCRFTask.Status = 'Completed';
                update objCRFTask;
                
                Case objAgreementCase = [Select ID, Status from Case where ID =: strCaseID];
                objAgreementCase.Rental_Pool_Agreement_Signed__c = true;
                objAgreementCase.Status = 'Agreement Generated';
                update objAgreementCase;
                
                blnIsAgreementGenerated = true;
        }
        if (lstAttachment != null && lstAttachment.size()>0 && strCaseID != null) {
            createAttach();
        }
    }//end createRentalPoolSR
    
    public void createCRF() {
         if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ) {
          uploadAttachments( extractName( 'Rental Pool CRF.pdf' ) , 
                    extractBody( crfAttachmentBody ) , 
                    strCaseID , 
                    'CRF' );
            }
     }//end createCRF
     
     public void submitCase() {
        blnSubmitCase = true;
        if (strCaseId != null) {
            Case objCase = [select ID,
                             Status
                        from Case
                        where ID =: strCaseId];
            if (String.isBlank( crfAttachmentBody ) || String.isBlank( crfAttachmentName )){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed CRF document.'));
            } else if (blnPoAValue == true && String.isBlank( poaAttachmentBody )) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
            } else if (String.isBlank( agreementAttachmentBody ) || String.isBlank( agreementAttachmentName )){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed Agreement document.'));
            } else {
                objCase.Status = 'Submitted';
                update objCase;
                createRentalPoolSR();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Rental Pool SR is Submitted'));
            }
        } else {
            createRentalPoolSR();
        }
    }//end submitCase
     
     public void generateSoADoc(){
         PageReference pdf = Page.StatementOfAccountPage;
         Blob body =  pdf.getContentAsPDF();
          uploadAttachments( extractName( 'Statement of Account.pdf' ) ,
                     body , 
                    strCaseID ,
                    'SOA' );
    }//end generateSoADoc
     
     public void generatePoADoc(){
          uploadAttachments( extractName('POA.pdf') ,
                    extractBody( poaAttachmentBody ) , 
                    strCaseID ,
                    'POA' );
    }//end generatePoADoc
    
    public void generateAgreementDoc(){
          uploadAttachments( extractName('Rental Pool Agreement.pdf') ,
                    extractBody( agreementAttachmentBody ) , 
                    strCaseID ,
                    'Agreement' );
    }//end generateAgreementDoc
    
     public void uploadAttachments( String strfileName, Blob objBody, Id parentId, String strType ) {
      system.debug('--objBody-'+objBody);
      system.debug('--strType-'+strType);
      
      objAttach = new Attachment() ;
      objAttach.Body = objBody ;
      objAttach.Name = strType + strfileName ;
      objAttach.ParentId = parentId ;
      system.debug('--parentId-'+parentId);
      lstAttachment.add( objAttach );
      system.debug('--uploadAttachments');
    }//end uploadAttachments
    
    private String extractName( String strName ) {
      return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    
    private Blob extractBody( String strBody ) {
      strBody = EncodingUtil.base64Decode( strBody ).toString();
      return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }
    
    public void createAttach() {
        system.debug('---inside createAttach');
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
          }else if( strType.equalsIgnoreCase( 'agreement') ) {
                objCustAttach.Type__c = 'Rental Pool Agreement' ;
            }
          
          objCustAttach.Name = objAttach.Name.substring(3) ;
      counter++;
    }
    update lstCustomAttachment ;
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
    
}