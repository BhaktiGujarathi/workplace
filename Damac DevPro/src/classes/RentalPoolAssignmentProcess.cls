public with sharing class RentalPoolAssignmentProcess{
    public list<SelectOption> lstUnits {get;set;}
    public string strSelectedUnit {get;set;}
    public list<Case> lstOpenCase {get;set;}
    public list<Case> lstCloseCase {get;set;}
    public string strCaseID;
    public string strPenalties {get; set;}
    public string strAdminFee {get; set;}
    public string strOtherDues {get; set;}
    public string strOverDues {get; set;}
    public string strOverDuesInstall {get; set;}
    public string strInvoices {get; set;}
    public string strServiceCharges {get; set;}
    public boolean blnSubmitCase;
    public boolean blnSOAGenerate {get;set;}
    public boolean blnPoASellValue {get;set;}
    public Case objCaseCreate{get;set;}
    public Booking_Unit__c objBookingUnit {get;set;}
    
    private Attachment objAttach; 
    private list<Attachment> lstAttachment = new list<Attachment>();
    
    public RentalPoolAssignmentProcess(){
        init();
    }//End Constructor
    
    public void init() {
        strSelectedUnit = '';
        strPenalties = '00';
        strAdminFee = '00';
        strOtherDues = '00';
        strOverDues = '00';
        strOverDuesInstall = '00';
        strInvoices = '00';
        strServiceCharges = '00';
        blnSOAGenerate = false;
        objCaseCreate = new Case();
        objBookingUnit = new Booking_Unit__c();
        lstUnits = new list<SelectOption>();
        lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        lstUnits.add(new selectOption('', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c = '0017E00000cWKII'
                                      and Rental_Pool__c = true]){
        lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }
    }
    
    public void autoPopulateBUDetails(){
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
         
         objBookingUnit = [select ID,
                              Bedroom_Type__c,
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
     }
     
     public void createRPAssignmentSR(){
         Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rental Pool Assignment').getRecordTypeId();
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
                 insert objCase;
                 strCaseID = objCase.ID;
            }
            if (blnSOAGenerate == true && strCaseID != null) {
                system.debug('inside if');
                generateSoADoc();
            }
            if (lstAttachment != null && lstAttachment.size()>0 && strCaseID != null) {
                createAttach();
            }
     }
     
     public void SOAtobeGenerated() {
        system.debug('!!!!!!!!!!!inside SOA method');
        blnSOAGenerate = true;
    }
    
     public void submitCase() {
         blnSubmitCase = true;     
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
            }
          
          objCustAttach.Name = objAttach.Name.substring(3) ;
      counter++;
    }
    update lstCustomAttachment ;
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
}