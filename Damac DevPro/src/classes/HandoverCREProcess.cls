public with sharing class HandoverCREProcess {

    public string strSelectedUnit {get;set;}
    public string strPOAIssuedBy {get; set;}
    public Id accountId {get;set;}
    public string strPOAName {get; set;}
    public string strPOAExpiryDate {get; set;}
    public string strScheduleHandoverDate {get; set;}
    public string strUnitViewDate {get; set;}
    public string strPOARelationWithOwner {get; set;}
    public string strCaseID;
    public boolean blnPoAValue {get;set;}
    public list<SelectOption> lstUnits {get;set;}
    public String strSelectedCategory {get;set;}
    public List<SelectOption> lstCategories {get;set;}
    public list<SelectOption> lstRelationShip {get;set;}
    public list<SelectOption> lstSlots {get;set;}
    public list<SelectOption> lstBuildings {get;set;}
    public list<SelectOption> lstNewUnits {get;set;}
    public list<Case> lstOpenCase {get;set;}
    public list<Case> lstCloseCase {get;set;}
    public list<SNAGs__c> lstSNAGs {get;set;}
    public Booking_Unit__c objBookingUnit {get;set;}
    public Case objCase {get;set;}
    public boolean blnSubmitCase;
    public transient String poaAttachmentBody { get; set; }
    public transient String poaAttachmentName { get; set; }
    public boolean blnSOAGenerate {get;set;}
    public boolean blnPCCGenerate {get;set;}
    public string strTimeSlot {get;set;}
    public string strSelectBuilding {get;set;}
    public string strUnit {get;set;}
    public boolean blnDisplayUnits {get;set;}
    public list<selectedUnits> lstSelectedUnits {get;set;}
    private Attachment objAttach; 
    private list<Attachment> lstAttachment = new list<Attachment>();
    private Id caseRecordTypeId;
    public map<id, selectedUnits> mapBUIdselectedUnits {get;set;}
    public UnitDetailsService.BookinUnitDetailsWrapper objBookinUnitDetailsWrapper {get; set;}
    public List<docInfo> lstDocs {get;set;}
    KeyHandoverChecklist.KayHandover objKeyHandover {get; set;}
    public boolean isMeetingSchedule {get; set;}
    public boolean isSlotUnavailableForMeeting {get; set;}
    public boolean isInvalidDate {get; set;}
    public String SOAurl {get; set;}
    private DateTime selectedStartDateTime;
    private list<Event> lstEvent = new list<Event>();
    
    public HandoverCREProcess(){
        init();
    }
    
    public void init(){
        blnPoAValue = false;
        isMeetingSchedule = false;
        isSlotUnavailableForMeeting = false;
        isInvalidDate = false;
        objCase = new Case();
        strPOAIssuedBy = '';
        strPOAName = '';
        strPOAExpiryDate = '';
        strPOARelationWithOwner = '';
        strScheduleHandoverDate = ''; 
        strUnitViewDate = '';
        SOAurl = '';
        blnSubmitCase = false;
        blnSOAGenerate = false;
        lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        lstSNAGs = new list<SNAGs__c>();
        lstUnits = new list<SelectOption>();
        lstRelationShip = new list<SelectOption>();
        lstSlots = new list<SelectOption>();
        lstSelectedUnits = new list<selectedUnits>();
        mapBUIdselectedUnits = new map<Id, selectedUnits>();
        lstNewUnits = new list<SelectOption>();
        //lstNewUnits.add(new selectOption('--None--', '--None--'));      
        //table options
        strSelectedCategory = 'Unit Details';
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        lstCategories.add(new selectOption('Close SRs', 'Close SRs'));

        lstRelationShip.add(new selectOption('--None--', '--None--'));
        lstRelationShip.add(new selectOption('Father', 'Father'));
        lstRelationShip.add(new selectOption('Mother', 'Mother'));
        lstRelationShip.add(new selectOption('Brother', 'Brother'));
        lstRelationShip.add(new selectOption('Sister', 'Sister'));
        
        lstSlots.add(new selectOption('09:00 - 10:00', '09:00 - 10:00'));
        lstSlots.add(new selectOption('10:00 - 11:00', '10:00 - 11:00'));
        lstSlots.add(new selectOption('11:00 - 12:00', '11:00 - 12:00'));
        lstSlots.add(new selectOption('12:00 - 13:00', '12:00 - 13:00'));
        lstSlots.add(new selectOption('13:00 - 14:00', '13:00 - 14:00'));
        lstSlots.add(new selectOption('14:00 - 15:00', '14:00 - 15:00'));
        lstSlots.add(new selectOption('15:00 - 16:00', '15:00 - 16:00'));
        lstSlots.add(new selectOption('16:00 - 17:00', '16:00 - 17:00'));
        lstSlots.add(new selectOption('17:00 - 18:00', '17:00 - 18:00'));
        lstSlots.add(new selectOption('18:00 - 19:00', '18:00 - 19:00'));
        
        objBookinUnitDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
        objKeyHandover = new KeyHandoverChecklist.KayHandover();
        lstDocs = new list<docInfo>();
        
        caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Handover').getRecordTypeId();
        
        lstBuildings = new list<selectOption>();
        lstBuildings.add(new selectOption('', '--None--'));
        
        for (Location__c objLocation : [Select Id,
                                               Name,
                                               Building_Name__c,
                                               Completion__c,
                                               RecordTypeId,
                                               RecordType.DeveloperName
                                        From Location__c
                                        Where Completion__c > 80
                                        And RecordType.DeveloperName = 'Building']) {
            if (objLocation.Building_Name__c != null){
                lstBuildings.add(new selectOption(objLocation.Id, objLocation.Building_Name__c));
            }
        }
    }
    
    /*public list < SelectOption > getlstUnits(){
        lstUnits = new list<selectOption>();
        lstUnits.add(new selectOption('', '--None--'));
      if (strSelectBuilding != null) {
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c,
                                            Booking__r.Account__c,
                                            Inventory__c,
                                            Inventory__r.Building_Location__c
                                     from Booking_Unit__c
                                    where Booking__r.Account__c =: accountId 
                                    and Inventory__r.Building_Location__c =: strSelectBuilding]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for
      }  
        
        return lstUnits;
    }//end getlstUnits*/
    
    //Auto-populate BU Details
    public void autoPopulateBUDetails(){
        //lstUnits.clear();

        lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        
        //Select Property
        if (strSelectBuilding != null) {
            lstUnits = new list<selectOption>();
            lstUnits.add(new selectOption('', '--None--'));
            for(Booking_Unit__c objBU : [Select Id,
                                                Name,
                                                Unit_Details__c,
                                                Booking__c,
                                                Booking__r.Account__c,
                                                Inventory__c,
                                                Inventory__r.Building_Location__c
                                         from Booking_Unit__c
                                        where Booking__r.Account__c =: accountId 
                                        and Inventory__r.Building_Location__c =: strSelectBuilding]){
                
                lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
            }//End for
        }  
        if (lstUnits.size() > 1) {
            system.debug('!!!!!!!!lstUnits'+lstUnits.size());
            blnDisplayUnits = true;
        } else {
            blnDisplayUnits = false;
            strSelectedUnit = null;
            strUnit = null;
            lstSelectedUnits.clear();
            lstNewUnits.clear();
        }

        //Display Unit Information for Selected Unit
        if (strUnit != null) {
            for(Case objRelCase : [Select ID,
                                          CaseNumber,
                                          Status,
                                          Booking_Unit__c,
                                          RecordTypeId,
                                          Handover_Status__c,
                                          Agreed_Handover_Date__c,
                                          Call_Outcome__c,
                                          Unit_Viewing_Date__c,
                                          POA_Name__c,
                                          POA_Relation_With_Owner__c,
                                          POA_Expiry_Date__c,
                                          POA_Issued_By__c
                                   From Case
                                   Where Booking_Unit__c =: strUnit]){
                if(objRelCase.Status != 'Closed') {
                    if (objRelCase.RecordTypeId == caseRecordTypeId) {
                        strCaseID = objRelCase.id;
                        objCase = new Case(Id = objRelCase.id);
                        objCase.Handover_Status__c = objRelCase.Handover_Status__c;
                        objCase.Call_Outcome__c = objRelCase.Call_Outcome__c;
                        objCase.POA_Name__c = objRelCase.POA_Name__c;
                        objCase.POA_Issued_By__c = objRelCase.POA_Issued_By__c;
                        //if(objRelCase.POA_Name__c != null)
                        //blnSOAGenerate = true;
                        datetime poaexpirydate = objRelCase.POA_Expiry_Date__c;   
                        if (poaexpirydate != null)          
                        strPOAExpiryDate = poaexpirydate.format('dd/MM/yyyy');
                        strPOARelationWithOwner = objRelCase.POA_Relation_With_Owner__c;
                        datetime handoverDate = objRelCase.Agreed_Handover_Date__c; 
                        if (handoverDate != null)
                        strScheduleHandoverDate = handoverDate.format('dd/MM/yyyy');
                        datetime unitViewDate = objRelCase.Unit_Viewing_Date__c; 
                        if (unitViewDate != null)
                        strUnitViewDate = unitViewDate.format('dd/MM/yyyy');
                    } else {
                        lstOpenCase.add(objRelCase);
                    }
                } else {
                    lstCloseCase.add(objRelCase);
                }//end if-else
            }//end for
            
            objBookinUnitDetailsWrapper = UnitDetailsService.getBookingUnitDetails('91826');
            system.debug('******Wrapper-'+objBookinUnitDetailsWrapper);
            
        } else {
            objBookinUnitDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
        }
        
        //Select Unit for Handover
        if (strSelectedUnit != null){

            if (strUnit == null) {
                strUnit = strSelectedUnit;
            }

            if (!mapBUIdselectedUnits.containsKey(strSelectedUnit)) {
               for (Booking_Unit__c objBU : [select ID,
                              Area_Varied__c,
                              Handover_Notice_Sent__c,
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
                              Inventory__c,
                              Inventory__r.Building_Location__c,
                              Inventory__r.Building_Location__r.Rental_Index__c,
                              Inventory__r.Property__r.Name,
                              Inventory__r.Property_City__c,
                              Inventory__r.Bedroom_Type__c,
                              Inventory__r.Unit_Type__c,
                              Inventory__r.Property_Status__c,
                              Booking__r.CreatedDate,
                              Inventory__r.Unit_Plan__c,
                              Inventory__r.Floor_Plan__c,
                              Inventory_Area__c,
                              PCC_Generate__c,
                              Title_Deed__c,
                              PCC_Release__c,
                              Rental_Pool__c,
                              Booking_Type__c,
                              Unit__c,
                              Unit__r.Location_ID__c
                         from Booking_Unit__c
                                where ID =: strSelectedUnit]) {
                     //objBookingUnit = objBU;
                     selectedUnits newUnit = new selectedUnits();
                     newUnit.isSelect = true;
                     newUnit.bookingUnitId = objBU.Id;
                     newUnit.bookingUnitDetail = objBU.Unit_Details__c == null ? '' : objBU.Unit_Details__c;
                     newUnit.objBU = objBU;
                     //newUnit.bookingUnitDetail = 'Booking Unit';
                     lstSelectedUnits.add(newUnit);
                     mapBUIdselectedUnits.put(objBU.Id, newUnit);
                     lstNewUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
                     system.debug('!!!!!!!!newUnit'+newUnit.objBU.Bedroom_Type__c);
                     
                }
            } /*else {
                selectedUnits newUnit = mapBUIdselectedUnits.get(strSelectedUnit);
                //lstSelectedUnits.remove(newUnit);
                newUnit.isSelect = true;
                lstSelectedUnits.add(newUnit);
            }*/
            //change-shraddha
            strSelectedUnit = '--None--';
         } 
         if (strUnit != null) {
             
             objBookingUnit = mapBUIdselectedUnits.get(strUnit).objBU;
             
           /*for (SNAGs__c objSNAG : [Select Id, 
                                        Booking_Unit__c,
                                        Severity__c,
                                        Name,
                                        SNAG_Description__c,
                                        Status__c,
                                        Target_Completion_Date__c,
                                        CreatedDate
                                    From SNAGs__c
                                    Where Booking_Unit__c =: strUnit]){                                         
                    lstSNAGs.add(objSNAG);                  
            }*/
            
            
         }
    }//end autoPopulateBUDetails
    
    public Pagereference selectedUnits() {
        system.debug('!!!!!call units');
        list<selectedUnits> lstSelUnits = new list<selectedUnits>();
        lstNewUnits = new list<SelectOption>();
        mapBUIdselectedUnits = new map<Id, selectedUnits>();
        for (selectedUnits objUnit : lstSelectedUnits) {
            if (objUnit.isSelect == true) {
                lstSelUnits.add(objUnit);
                mapBUIdselectedUnits.put(objUnit.bookingUnitId, objUnit);
                lstNewUnits.add(new selectOption(objUnit.bookingUnitId, objUnit.bookingUnitDetail));
            }
        }
        lstSelectedUnits = new list<selectedUnits>();
        lstSelectedUnits.addAll(lstSelUnits);
        system.debug('*******lstNewUnits'+lstNewUnits);
        return null;
    }
    
    public Pagereference createHandoverSR(){
       Boolean isErrorPresent = false;
       list<SR_Booking_Unit__c> listSRBookingUnitToInsert = new list<SR_Booking_Unit__c>();
       
       if(strScheduleHandoverDate == null || strScheduleHandoverDate == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select future Handover Date'));
            isErrorPresent = true;
        } else {
            Date handoverDate = date.parse(strScheduleHandoverDate);
            if (handoverDate < Date.Today()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select future Handover Date'));
                isErrorPresent = true;
            }
        }
        
        if (blnPoAValue) {
            if(strPOAExpiryDate == null || strPOAExpiryDate == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select past Date of Issue'));
                isErrorPresent = true;
            } else {
                Date issuedate = date.parse(strPOAExpiryDate);
                if (issuedate > Date.Today()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select past Date of Issue'));
                    isErrorPresent = true;
                }
            }
            
            if (strPOARelationWithOwner == null || strPOARelationWithOwner.trim() == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Specify Purpose of POA'));
                isErrorPresent = true;
            }
            
            if (poaAttachmentName == null || poaAttachmentName == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Upload Power of Attorney'));
                isErrorPresent = true;
            }
        }
        
        /*for (docInfo objDocInfo : lstDocs) {
            system.debug('=='+objDocInfo.objAttachment.Body+'^^^^^'+objDocInfo);
            isErrorPresent = true;
        }*/
        
        if (!isErrorPresent) {
            set<Id> setSelectedBookingUnit = mapBUIdselectedUnits.keyset();
            for (
                    SR_Booking_Unit__c objSRBookingUnit :
                        [Select Id,
                                Booking_Unit__c,
                                Case__c
                         From SR_Booking_Unit__c
                         Where Booking_Unit__c IN :mapBUIdselectedUnits.keyset()
                        ]
            ) {
                if (setSelectedBookingUnit.contains(objSRBookingUnit.Booking_Unit__c)) {
                    setSelectedBookingUnit.remove(objSRBookingUnit.Booking_Unit__c);
                    strCaseID = objSRBookingUnit.Case__c;
                }
            }

            if (!setSelectedBookingUnit.isEmpty()) {
                Case objCaseCreate = new Case();
                if(blnSubmitCase) {
                    objCaseCreate.Status = 'Submitted';
                } else {
                    objCaseCreate.Status = 'Draft Request';
                }
                objCaseCreate.RecordTypeID = caseRecordTypeId;
                objCaseCreate.AccountId = accountId;
                objCaseCreate.Origin = 'Walk-In';
                objCaseCreate.Subject = 'Handover SR';
                objCaseCreate.Description = 'Handover SR';
                objCaseCreate.SR_Type__c = 'Handover';
                //if (strUnitViewDate != null && selectedStartDateTime != null) {
                    objCaseCreate.Unit_Viewing_Date__c = selectedStartDateTime;
                //}
                if (strScheduleHandoverDate != null) {
                    objCaseCreate.Agreed_Handover_Date__c = date.parse(strScheduleHandoverDate);
                }
                if (strPOAExpiryDate != null) {
                    objCaseCreate.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                }
                objCaseCreate.POA_Name__c = strPOAName;
                objCaseCreate.Purpose_of_POA__c = strPOARelationWithOwner;
                objCaseCreate.POA_Issued_By__c = strPOAIssuedBy;
                
                insert objCaseCreate;
                
                strCaseID = objCaseCreate.Id;
                
                for (Id selectedBookingUnitId : setSelectedBookingUnit) {
                    listSRBookingUnitToInsert.add(
                        new SR_Booking_Unit__c(
                            Booking_Unit__c = selectedBookingUnitId,
                            Case__c = objCaseCreate.Id
                        )
                    );
                }
                
                if (!listSRBookingUnitToInsert.isEmpty()) {
                    insert listSRBookingUnitToInsert;
                }
                
                for (Event objEvent : lstEvent) {
                    objEvent.WhatId = objCaseCreate.Id;
                }
                //update lstEvent;
                insert lstEvent;
            }

            if(blnPoAValue) {
                updatePoADetails();
            }
            if (lstAttachment != null && !lstAttachment.isEmpty()) {
                createAttach();
            }
            
            if (lstDocs != null && !lstDocs.isEmpty()) {
                insertDocuments(lstDocs);
            }
        }
        
        /*
        system.debug('!!!!strSelectedUnit'+strSelectedUnit);
        if(strSelectedUnit!='' && strSelectedUnit != null && strCaseID == null){
            Case objCaseCreate = new Case();
            if(blnSubmitCase == true)
                objCaseCreate.Status = 'Submitted';
            else 
                objCaseCreate.Status = 'Draft Request';
            objCaseCreate.AccountId = '0017E00000cWKII';
            objCaseCreate.RecordTypeID = caseRecordTypeId;
            objCaseCreate.Booking_Unit__c = strSelectedUnit;            
            objCaseCreate.Origin = 'Walk-In';
            objCaseCreate.Description = 'Handover Process';
            objCaseCreate.Handover_Status__c = objCase.Handover_Status__c;
            objCaseCreate.Call_Outcome__c = objCase.Call_Outcome__c;
            if (strScheduleHandoverDate != null && !String.isBlank(strScheduleHandoverDate) )
                objCaseCreate.Agreed_Handover_Date__c = date.parse(strScheduleHandoverDate);
            if (strUnitViewDate != null && !String.isBlank(strUnitViewDate) )
                objCaseCreate.Unit_Viewing_Date__c = date.parse(strUnitViewDate);
            if(blnPoAValue == true){
                objCaseCreate.POA_Issued_By__c = objCase.POA_Issued_By__c;
                objCaseCreate.POA_Name__c = objCase.POA_Name__c;
                if (strPOAExpiryDate != null && strPOAExpiryDate != '')
                objCaseCreate.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                objCaseCreate.POA_Relation_With_Owner__c = strPOARelationWithOwner;             
            }
            insert objCaseCreate;

            strCaseID = objCaseCreate.ID;
            if (blnSubmitCase == false)
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Handover Case is Created  ' + strCaseID));
        } else if(strSelectedUnit == null) {
            system.debug('!!!!!!!!!!pageError');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select an Unit'));
            
        } else if (strCaseID != null) {
            Case objCaseCreate = new Case(Id = strCaseID);
            objCaseCreate.Call_Outcome__c = objCase.Call_Outcome__c;
            system.debug('!!!!!!strScheduleHandoverDate'+strScheduleHandoverDate);
            if (strScheduleHandoverDate != null && !String.isBlank(strScheduleHandoverDate) ) {
                system.debug('+++++strScheduleHandoverDate'+date.parse(strScheduleHandoverDate));
                objCaseCreate.Agreed_Handover_Date__c = date.parse(strScheduleHandoverDate);
            }
           system.debug('!!!!!!strUnitViewDate'+strUnitViewDate);
            if (strUnitViewDate != null && !String.isBlank(strUnitViewDate) ){
                system.debug('+++++strUnitViewDate'+date.parse(strUnitViewDate));
                objCaseCreate.Unit_Viewing_Date__c = date.parse(strUnitViewDate);
            }
                
            if(blnPoAValue == true){
                objCaseCreate.POA_Issued_By__c = strPOAIssuedBy;
                objCaseCreate.POA_Name__c = strPOAName;
                if (strPOAExpiryDate != null && strPOAExpiryDate != '')
                objCaseCreate.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                objCaseCreate.POA_Relation_With_Owner__c = strPOARelationWithOwner;
            }
            update objCaseCreate;
        }
        if(blnPoAValue == true && strCaseID != null){
            updatePoADetails();
        }
        if (blnSOAGenerate == true && strCaseID != null) {
                system.debug('inside if');
                generateSoADoc();
        }
        if (blnPCCGenerate == true && strCaseID != null) {
                system.debug('inside if');
                Case objCaseCreate = new Case(Id = strCaseID);
                objCaseCreate.Handover_Status__c = 'PCC Handed-over to Customer';
                update objCaseCreate;
                generatePCCDoc();
        }
        if (lstAttachment != null && lstAttachment.size()>0 && strCaseID != null) {
            createAttach();
        }
        */
        
        if (lstDocs != null && !lstDocs.isEmpty()) {
            
        }
        
        return null;
    }
    
    public void createAttach() {
        if( lstAttachment != null && !lstAttachment.isEmpty() ) { 
            system.debug('========'+strCaseID);
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
        system.debug('>>>>>>>>>>>'+caseId);
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
          else if( strType.equalsIgnoreCase( 'soa') ) {
                objCustAttach.Type__c = 'Statement of Account' ;
          } else if( strType.equalsIgnoreCase( 'pcc') ) {
                objCustAttach.Type__c = 'Payment Clearance Certificate' ;
          }
          
          objCustAttach.Name = objAttach.Name.substring(3) ;
      counter++;
    }
    update lstCustomAttachment ;
    lstAttachment.clear();
    lstAttachment = new list<Attachment>();
    }
    
    public void updatePoADetails(){
        if(blnPoAValue){
           /* if (blnSubmitCase) {
                Task objTask  = new Task();
                objTask.Subject = 'Verify Power of Attorney';
                objTask.WhatID = strCaseID ; 
                //objTask.OwnerId = '0050Y000001SBsP';
                objTask.status = 'In Progress';
                objTask.priority= 'Medium';
                objTask.Process_Name__c = 'Handover';
                insert objTask;
            }*/

            system.debug('!!!!!!!poaAttachmentBody'+poaAttachmentBody);
            system.debug('!!!!!!!poaAttachmentName'+poaAttachmentName);    
            if( String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ) {
              uploadAttachments( extractName( poaAttachmentName ) ,
                        extractBody( poaAttachmentBody ) , 
                        strCaseID ,
                        'POA' );
            }
        }
        blnPoAValue = false;
    }

    public void insertDocuments(list<docInfo> lstDocs) {
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();

        for(docInfo objDocInfo : lstDocs){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = objDocInfo.strType;
            objSR.isValid__c = objDocInfo.blnIsValid;
            objSR.IsRequired__c = objDocInfo.strRequired.equalsIgnoreCase('Yes') ? true: false;
            objSR.Case__c = strCaseID;
            lstSrAttachment.add(objSR);
        }

        if (!lstSrAttachment.isEmpty()) {
            insert lstSrAttachment;
            map<String,Id> mapName_Id = new map<String,Id>();

            for(SR_Attachments__c objSR : lstSrAttachment) {
                mapName_Id.put(objSR.Name, objSR.Id);
            }

            list<Attachment> lstAttachmentToInsert = new list<Attachment>();
            for(docInfo objDocInfo : lstDocs) {
                if(objDocInfo.objAttachment.Body != null) {
                    objDocInfo.objAttachment.ParentId = mapName_Id.get(objDocInfo.strType);
                    lstAttachmentToInsert.add(objDocInfo.objAttachment);
                }
            }

            if(!lstAttachmentToInsert.isEmpty()) {
                insert lstAttachmentToInsert;

                map<Id,Id> mapParent_Id = new map<Id,Id>();
                for(Attachment objAttachment : lstAttachmentToInsert){
                    mapParent_Id.put(objAttachment.ParentId, objAttachment.Id);
                }

                lstSrAttachment = null;
                lstSrAttachment = new list<SR_Attachments__c>();

                for(Id objId : mapParent_Id.keySet()){
                    SR_Attachments__c objSR = new SR_Attachments__c();
                    objSR.Id = objId;
                    objSR.Attachment__c = mapParent_Id.get(objId);
                    lstSrAttachment.add(objSR);
                }

                if(!lstSrAttachment.isEmpty()) {
                    update lstSrAttachment;
                }
                lstSrAttachment = null;
            }
        }
    }

    public void submitCase() {
        blnSubmitCase = true;
        if (strCaseId != null) {
            Case objCase = [select ID,
                             Status,
                             Agreed_Handover_Date__c
                        from Case
                        where ID =: strCaseId];
            if (objCase.Agreed_Handover_Date__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Case can not be submitted till you do not provide Handover Date.'));
            }
             else if (blnPoAValue == true && String.isBlank( poaAttachmentBody )) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
            } else {
                objCase.Status = 'Submitted';
                update objCase;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Handover Case is Submitted'));
            }
        } else {
            createHandoverSR();
        }
        Task objTask  = new Task();
        objTask.Subject = 'Verify Power of Attorney';
        objTask.WhatID = strCaseID ; 
        //objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        objTask.Process_Name__c = 'Handover';
        insert objTask;
    }
    public void SOAtobeGenerated() {
        system.debug('!!!!!!!!!!!inside SOA method');
        blnSOAGenerate = true;
        GenerateSOAController.soaResponse objSOA = GenerateSOAController.getSOADocument('41397');
        system.debug('!!!!!objSOA'+objSOA.url);
        SOAurl = objSOA.url;
    }
    public void PCCtobeGenerated() {
        system.debug('!!!!!!!!!!!inside SOA method');
        blnPCCGenerate = true;
    }
    /*public void generateSoADoc(){
        system.debug('!!!!!!!!!!!inside SOA Creation method');
         PageReference pdf = Page.StatementOfAccountPage;
         Blob body =  pdf.getContentAsPDF();
          uploadAttachments( extractName( 'Statement of Account.pdf' ) ,
                     body , 
                    strCaseID ,
                    'SOA' );
        
    }
    
    public void generatePCCDoc(){
        //system.debug('!!!!!!!!!!!inside SOA Creation method');
        Task objTask  = new Task();
            objTask.Subject = 'Generate Letter of Discharge';
            objTask.WhatID = strCaseID ; 
            objTask.OwnerId = '0050Y000001SBsP';
            objTask.status = 'In Progress';
            objTask.priority= 'Medium';
            objTask.Process_Name__c = 'Handover';
            insert objTask;
        
         PageReference pdf = Page.PCCPage;
         Blob body =  pdf.getContentAsPDF();
          uploadAttachments( extractName( 'Payment Clearance Certificate.pdf' ) ,
                     body , 
                    strCaseID ,
                    'PCC' );
        
    }*/
    
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

    public PageReference confirmDate() {
        isMeetingSchedule = false;
        isSlotUnavailableForMeeting = false;
        isInvalidDate = false;

        list<String> selectedDateParse = new list<String>();
        if (strUnitViewDate != null) {
            selectedDateParse = strUnitViewDate.split('/');
        }

        list<String> selectedTimeSlotParse = new list<String>();
        list<String> selectedStartTimeParse = new list<String>();
        list<String> selectedEndTimeParse = new list<String>();
        DateTime selectedStartDateTime;
        DateTime selectedEndDateTime;

        if (strTimeSlot != null && strUnitViewDate != null) {
            selectedTimeSlotParse = strTimeSlot.split(' - ');
            selectedStartTimeParse = selectedTimeSlotParse[0].split(':');
            selectedEndTimeParse = selectedTimeSlotParse[1].split(':');

            selectedStartDateTime = Datetime.newInstanceGmt(Integer.ValueOf(selectedDateParse[2]), Integer.ValueOf(selectedDateParse[1]), Integer.ValueOf(selectedDateParse[0]), Integer.ValueOf(selectedStartTimeParse[0]), Integer.ValueOf(selectedStartTimeParse[1]), 0);
            selectedEndDateTime = Datetime.newInstanceGmt(Integer.ValueOf(selectedDateParse[2]), Integer.ValueOf(selectedDateParse[1]), Integer.ValueOf(selectedDateParse[0]), Integer.ValueOf(selectedEndTimeParse[0]), Integer.ValueOf(selectedEndTimeParse[1]), 0);

            if (selectedStartDateTime < datetime.now()) {
                isInvalidDate = true;
                return null;
            }
        } else {
            isInvalidDate = true;
            return null;
        }

        // selectedDateParse != null && && selectedStartTimeParse != null && !selectedDateParse.isEmpty() && selectedEndTimeParse != null && !selectedEndTimeParse.isEmpty()
        /*if (selectedDateParse.size()>0) {
                    system.debug('!!!!selectedDateParse'+selectedDateParse);
            selectedStartDateTime = Datetime.newInstanceGmt(Integer.ValueOf(selectedDateParse[2]), Integer.ValueOf(selectedDateParse[1]), Integer.ValueOf(selectedDateParse[0]), Integer.ValueOf(selectedStartTimeParse[0]), Integer.ValueOf(selectedStartTimeParse[1]), 0);
            selectedEndDateTime = Datetime.newInstanceGmt(Integer.ValueOf(selectedDateParse[2]), Integer.ValueOf(selectedDateParse[1]), Integer.ValueOf(selectedDateParse[0]), Integer.ValueOf(selectedEndTimeParse[0]), Integer.ValueOf(selectedEndTimeParse[1]), 0);
        }*/

        system.debug('------Start Date--'+selectedStartDateTime);
        system.debug('------End Date--'+selectedEndDateTime);

        set<Id> creIds = new set<Id>();
        for (Account objAccount : [Select Id, Primary_CRE__c, Secondary_CRE__c, Tertiary_CRE__c From Account Where Id=: accountId]) {
            if (objAccount.Primary_CRE__c != null) {
                creIds.add(objAccount.Primary_CRE__c);
            }
            if (objAccount.Secondary_CRE__c != null) {
                creIds.add(objAccount.Secondary_CRE__c);
            }
            if (objAccount.Tertiary_CRE__c != null) {
                creIds.add(objAccount.Tertiary_CRE__c);
            }
        }

        map<Id, Event> mapEvents = new map<Id, Event>();
        System.debug('!!!!!!!!!selectedStartDateTime'+selectedStartDateTime);
        System.debug('!!!!!!!!!selectedEndDateTime'+selectedEndDateTime);
        System.debug('!!!!!!!!!creIds'+creIds);
        if (selectedStartDateTime != null && selectedEndDateTime != null && creIds != null) {
            for (Event objEvent: [Select Id, StartDateTime, EndDateTime, OwnerId 
                                    From Event 
                                    where( (StartDateTime =: selectedStartDateTime OR EndDateTime =: selectedEndDateTime) 
                                        OR (StartDateTime >=: selectedStartDateTime And EndDateTime <=: selectedStartDateTime) 
                                    OR (StartDateTime >=: selectedEndDateTime And EndDateTime <=: selectedEndDateTime)
                                    )
                                    And OwnerId IN: creIds]) {
                mapEvents.put(objEvent.OwnerId, objEvent);
                system.debug('!!!!!!!!mapEvents'+mapEvents);
            }        
        }
        
        lstEvent = new list<Event>();
        for (Account objAccount : [Select Id, PersonContactId, Primary_CRE__c, Secondary_CRE__c, Tertiary_CRE__c From Account Where Id=: accountId]) {
            if (objAccount.Primary_CRE__c != null && !mapEvents.containskey(objAccount.Primary_CRE__c)) {
                Event objEvent = new Event();
                objEvent.OwnerId = objAccount.Primary_CRE__c;
                objEvent.WhoId = objAccount.PersonContactId;
                objEvent.StartDateTime = selectedStartDateTime;
                objEvent.EndDateTime = selectedEndDateTime;
                objEvent.Type = 'Meeting';
                objEvent.Subject = 'Meeting';
                lstEvent.add(objEvent);
            } else if (objAccount.Secondary_CRE__c != null && !mapEvents.containskey(objAccount.Secondary_CRE__c)){
                Event objEvent = new Event();
                objEvent.OwnerId = objAccount.Secondary_CRE__c;
                objEvent.WhoId = objAccount.PersonContactId;
                objEvent.StartDateTime = selectedStartDateTime;
                objEvent.EndDateTime = selectedEndDateTime;
                objEvent.Type = 'Meeting';
                objEvent.Subject = 'Meeting';
                lstEvent.add(objEvent);
            } else if (objAccount.Tertiary_CRE__c != null && !mapEvents.containskey(objAccount.Tertiary_CRE__c)) {
                Event objEvent = new Event();
                objEvent.OwnerId = objAccount.Tertiary_CRE__c;
                objEvent.WhoId = objAccount.PersonContactId;
                objEvent.StartDateTime = selectedStartDateTime;
                objEvent.EndDateTime = selectedEndDateTime;
                objEvent.Type = 'Meeting';
                objEvent.Subject = 'Meeting';
                lstEvent.add(objEvent);
            } else {
                isSlotUnavailableForMeeting = true;
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select different time slot.'));
            }
        }
        
        if (lstEvent != null && !lstEvent.isEmpty()){
            //insert lstEvent;
            system.debug('!!!!!!!lstEvent'+lstEvent);
            
            isMeetingSchedule = true;
        }
        
        fetchSnagDetails();
        fetchRequiredDocuments();
        return null;
    }

    public void fetchSnagDetails() {
        set<Id> setLocationId = new set<Id>();
        list<SNAGs__c> listSnagsAlreadyPrsent = new list<SNAGs__c>();
        
        list<SNAGs__c> listSnagsNew = new list<SNAGs__c>();
        
        map<String, SNAGs__c> mapDefectIdWithSnags = new map<String, SNAGs__c>();

        for (selectedUnits objSelectedUnits : mapBUIdselectedUnits.values()) {
            setLocationId.add(objSelectedUnits.objBU.Unit__c);
        }

        listSnagsAlreadyPrsent = fetchSnagsFromLocation(setLocationId);
        for (SNAGs__c objSnag : listSnagsAlreadyPrsent){
            mapDefectIdWithSnags.put(objSnag.Defect_ID__c, objSnag);
        }

        for (selectedUnits objSelectedUnits : mapBUIdselectedUnits.values()) {
            //testSnagger.createDefectRequest(objSelectedUnits.objBU.Unit__c, objSelectedUnits.objBU.Unit__r.Location_ID__c, mapDefectIdWithSnags);
            /*listSnagsNew.addAll(
                testSnagger.createDefectRequest(
                    objSelectedUnits.objBU.Unit__c,
                    '2',
                    mapDefectIdWithSnags
                )
            );*/
        }

        if (listSnagsNew != null && !listSnagsNew.isEmpty()) {
            for (SNAGs__c obj : listSnagsNew) {
                system.debug('********'+obj);
            }
            upsert listSnagsNew;
            system.debug('------'+listSnagsNew);
        }

        lstSNAGs = fetchSnagsFromLocation(setLocationId);
    }

    private list<SNAGs__c> fetchSnagsFromLocation(set<Id> setLocationId) {
        return [Select Id,
                       Name,
                       SD_Description__c,
                       Defect_Status__c,
                       Defect_ID__c,
                       Due_By__c,
                       Target_Completion_Date__c
                From SNAGs__c
                Where Location__c IN :setLocationId
                Order By Defect_ID__c
               ];
    }

    private void fetchRequiredDocuments() {
        /*objKeyHandover =
            KeyHandoverChecklist.getKeyHandover(
                '12851',
                'Individual',
                'RIYADH',
                'VICTORIA @AKOYA OXYGEN',
                '4567',
                'RESIDENTIAL',
                '3BHK',
                'RR-M',
                'UAE National UAE Resident',
                'Individual',
                'Yes'
            );*/
            
        lstDocs = new list<docInfo>();
        map<String,String> mapKey_Value = new map<String,String>();
        
        /*String strDocumentResponse =
            KeyHandoverChecklist.getKeyHandover(
                '12851',
                'Individual',
                'RIYADH',
                'VICTORIA @AKOYA OXYGEN',
                '4567',
                'RESIDENTIAL',
                '3BHK',
                'RR-M',
                'UAE National UAE Resident',
                'Individual',
                'Yes'
            );*/
            
        
        String strDocumentResponse = '{"allowed":"Yes","message":null,"mortgageNOCfromBank":"NotRequired","ifPoaTakingHandoverColatePoaPassportResidence":"Optional",'
+ '"corporateValidTradeLicence":"Not Required","corporateArticleMemorandumOfAssociation":"Not Required","corporateBoardResolution":"Not Required","corporatePoa":"Not Required","signedForm":"Not Required","clearAndValidPassportCopyOfOwner":"Mandatory","clearAndValidPassportCopyOfJointOwner":"Mandatory","visaOrEntryStampWithUid":"Not Required","copyofValidEmiratesId":"Not Required","copyofValidGccId":"Not Required","handoverChecklistAndLod":"Mandatory","keyReleaseForm":"Mandatory","checkOriginalSpaAndtakeCopyOfFirstFourPagesOfSpa":"Mandatory",'
+ '"areaVariationAddendum":"Mandatory","tempOne":null,"tempTwo":null,"tempThree":null,"handoverNoticeAllowed":null,"approvalQueueOne":null,'
+ '"approvalQueueTwo":null,"approvalQueueThree":null,"eligibleforRentalPool":null}';
        
        if(strDocumentResponse != null && !String.isEmpty(strDocumentResponse)){
            mapKey_Value = parseRuleEngine(strDocumentResponse);
        }
        
        for(String docType: mapKey_Value.keySet()) {
          if(mapKey_Value.get(docType).equalsIgnoreCase('Mandatory')) {
              docInfo objD = new docInfo();
              objD.strType = docType;
              objD.strRequired = 'Yes';
              objD.blnIsValid = false;
              objD.objAttachment = new Attachment();
              lstDocs.add(objD);
          }
        }
        system.debug('lstDocs********'+lstDocs);
    }

    public map<String,String> parseRuleEngine(String ruleEngineResponse) {
        map<String,String> mapKey_Value = new map<String,String>();
        
        ruleEngineResponse = ruleEngineResponse.remove('{');
        ruleEngineResponse = ruleEngineResponse.remove('}');
        ruleEngineResponse = ruleEngineResponse.remove('"');
        system.debug('ruleEngineResponse******'+ruleEngineResponse);
        
        for(String st : ruleEngineResponse.split(',')) {
            system.debug('*****st*****'+st);
            String strPre = st.substringBefore(':').trim();
            String strPost = st.subStringAfter(':').trim();
            
            system.debug('strPre :*******'+strPre);
            system.debug('strPost :*******'+strPost);
            mapKey_Value.put(strPre, strPost);
            
        }
        system.debug('mapKey_Value*************'+mapKey_Value);
        return mapKey_Value;
    }

    public class selectedUnits {
        public boolean isSelect {get;set;}
        public string bookingUnitId {get;set;}
        public String bookingUnitDetail {get;set;}
        public Booking_Unit__c objBU {get;set;}
        
        public selectedUnits() {
        }
    }

    public class docInfo {
        public Attachment objAttachment {get;set;}
        public String strType {get;set;}
        public String strRequired {get;set;}
        public boolean blnIsValid {get;set;}
        
        public docInfo(){
        }
    }
}