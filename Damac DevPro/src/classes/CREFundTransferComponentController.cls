public with sharing class CREFundTransferComponentController {
    public List<TransferWrapper> lstTransferWrapper {get; set;}
    public Integer intTransferUnit {get; set;}
    public Map<String, String> mapUnitNames {get; set;}
    public Boolean blnIsShowPOA {get; set;}
    public Case objCase {get; set;}
    public Boolean blnDisableSubmitSRBtn {get; set;}
    public String strDocType {get; set;}
    public Boolean blnIsShowPOAAttachment {get; set;}
    public Boolean blnIsShowCRFAttachment {get; set;}
    public List<SR_Attachments__c> lstSRAttachments {get; set;}
    public String SRAttachmentToRemove {get; set;}
    public Boolean blnIsLitigationFlag {get; set;}
    public String strPOAExpiryDate {get; set;}
    public Boolean blnIsExistingTransfer {get; set;}
    public transient String strCRFAttachmentBody { get; set; }
    public transient String strCRFAttachmentName { get; set; }
    public transient String strPOAAttachmentBody { get; set; }
    public transient String strPOAAttachmentName { get; set; }
    
    private Id accountId;
    private Id caseId;
    
    private List<Booking_Unit__c> lstBookingUnit;
    private Map<Id, Booking_Unit__c> mapBookingUnit;
    private Map<Id, Decimal> mapSourceUnitAvailableAmount;
    private Map<Id, WrapperBookingUnit> mapWrapperBookingUnit;
    
    public CREFundTransferComponentController() {
        //accountId = '0017E00000cL5Ly';
        accountId = ApexPages.currentPage().getParameters().get('accID');
        caseId = ApexPages.currentPage().getParameters().get('caseID');
        if(accountId != null) {
            init();
        }
    }
    
    //Method for initialization purpose
    private void init() {
        objCase = new Case();
        objCase.SR_Type__c = 'Fund Transfer SR';
        objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().
            get('Fund Transfer').getRecordTypeId();
        objCase.AccountId = accountId;
        blnIsShowPOA = false;
        blnDisableSubmitSRBtn = true;
        blnIsLitigationFlag = false;
        blnIsExistingTransfer = false;
        blnIsShowPOAAttachment = false;
        blnIsShowCRFAttachment = false;
        lstSRAttachments = new List<SR_Attachments__c>();
        lstTransferWrapper = new List<TransferWrapper>();
        mapSourceUnitAvailableAmount = new Map<Id, Decimal>();
        mapWrapperBookingUnit = new Map<Id, WrapperBookingUnit>();
        
        lstBookingUnit = [Select Id, Registration_ID__c, Name, Inventory__r.Unit__c,
                          Inventory__r.Property__r.Name,Inventory__r.Property_Name_2__c,
                          Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c,
                          Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c,
                          Inventory__r.Anticipated_Completion_Date__c,
                          Inventory__r.Property__c,Inventory__r.Property_City__c,
                          Inventory__r.Unit_Type__c,Permitted_Use__c,Inventory__r.Area_Sqft_2__c,
                          Inventory__r.Construction_Status__c,Revised_Price_Area_Variation__c,
                          Rebate_Given__c,Rental_Pool_Agreement__c,RERA_Project__c,
                          Dispute_Flag__c,OQOOD_Reg_Flag__c,Handover_Flag__c,PCC_Generate__c,
                          Early_Handover__c, Unit_Details__c
                          From Booking_Unit__c
                          Where Booking__r.Account__c =: accountId];
                          
        if(lstBookingUnit != null && !lstBookingUnit.isEmpty()) {
            mapBookingUnit = new Map<Id, Booking_Unit__c>();
            mapUnitNames = new Map<String, String>();
            for(Booking_Unit__c objBU: lstBookingUnit) {
                mapBookingUnit.put(objBU.Id, objBU);
                mapUnitNames.put(objBU.Id, objBU.Unit_Details__c);
            }
        }
        
        if(caseId != null) {
            List<Case> lstCase = [Select Id, AccountId, Status, Power_of_Attorney__c, POA_Name__c, 
                                  POA_Relationship_with_Buyer__c,
                                  POA_Expiry_Date__c, POA_Issued_By__c,
                                  (Select Id, Name, View__c, Attachment__c,
                                  Type__c, Case__r.CaseNumber, IsValid__c
                                  From SR_Attachments__r),
                                  (Select Id, Source_Booking_Unit__c, Target_Booking_Unit__c,
                                  Source_Unit_Available_Amount__c, Target_Unit_Allocated_Amount__c,
                                  Credit_Note__c, EOI_Amount__c, Amount_Allocated_Against__c
                                  From Fund_Transfer_Details__r)
                                  From Case Where Id =: caseId];
            if(lstCase != null && !lstCase.isEmpty()) {
                objCase = lstCase[0];
                
                if(objCase.SR_Attachments__r != null && !objCase.SR_Attachments__r.isEmpty()) {
                    lstSRAttachments = objCase.SR_Attachments__r;
                    
                    validateSubmitButton();
                }
                
                if(objCase.Power_of_Attorney__c != null && objCase.Power_of_Attorney__c.equalsIgnoreCase('Yes')) {
                    if(objCase.POA_Expiry_Date__c != null) {
                        strPOAExpiryDate = objCase.POA_Expiry_Date__c.format();
                    }
                }
                
                if(objCase.Fund_Transfer_Details__r != null && !objCase.Fund_Transfer_Details__r.isEmpty()) {
                    intTransferUnit = 0;
                    for(Fund_Transfer_Details__c objFT: objCase.Fund_Transfer_Details__r) {
                        populateTransferWrapper();
                        blnIsExistingTransfer = true;
                        
                        lstTransferWrapper[intTransferUnit].strSelectedSourceUnit = objFT.Source_Booking_Unit__c;
                        lstTransferWrapper[intTransferUnit].strSelectedTargetUnit = objFT.Target_Booking_Unit__c;
                        lstTransferWrapper[intTransferUnit].decSourceUnitAmount = objFT.Source_Unit_Available_Amount__c;
                        lstTransferWrapper[intTransferUnit].decTargetUnitAmount = objFT.Target_Unit_Allocated_Amount__c;
                        lstTransferWrapper[intTransferUnit].strCreditNote = objFT.Credit_Note__c;
                        lstTransferWrapper[intTransferUnit].decEOIAmount = objFT.EOI_Amount__c;
                        lstTransferWrapper[intTransferUnit].strSelectedAllocation = objFT.Amount_Allocated_Against__c;
                        
                        getUnitDetails();
                        
                        intTransferUnit++;
                    }
                }
                computeAvailableSourceAmount();
            }
        }
        else {
            populateTransferWrapper();
        }
    }
    
    //Method to populate details in TransferWrapper
    private void populateTransferWrapper() {
        TransferWrapper objTransferWrapper = new TransferWrapper();
        objTransferWrapper.lstSourceUnits = new List<SelectOption>();
        objTransferWrapper.lstTargetUnits = new List<SelectOption>();
        objTransferWrapper.lstUnitDetails = new List<SelectOption>();
        objTransferWrapper.lstSourceUnits.add(new SelectOption('None', '--None--'));
        objTransferWrapper.lstTargetUnits.add(new SelectOption('None', '--None--'));
        
        if(lstBookingUnit != null && !lstBookingUnit.isEmpty()) {
            for(Booking_Unit__c objBU: lstBookingUnit) {
                system.debug('------objBU.Inventory__r.Unit__c-----'+objBU.Unit_Details__c);
                system.debug('------objBU.Id-----'+objBU.Id);
                if(objBU.Unit_Details__c != null) {
                    objTransferWrapper.lstSourceUnits.add(new SelectOption(objBU.Id, objBU.Unit_Details__c));
                    objTransferWrapper.lstTargetUnits.add(new SelectOption(objBU.Id, objBU.Unit_Details__c));
                }
            }
            objTransferWrapper.lstUnitDetails.add(new SelectOption('Unit Details', 'Unit Details'));
            objTransferWrapper.lstUnitDetails.add(new SelectOption('Flags', 'Flags'));
            objTransferWrapper.lstUnitDetails.add(new SelectOption('Unit Status', 'Unit Status'));
            objTransferWrapper.lstUnitDetails.add(new SelectOption('Open SRs', 'Open SRs'));
            
            objTransferWrapper.isShowUnitDetails = false;
            lstTransferWrapper.add(objTransferWrapper);
        }
    }
    
    private void checkLitigationFlags() {
        if(lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnDispute ||
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnEnforcement ||
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnLitigation ||
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnMortage ||
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnCourtCase ||
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnDispute ||
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnEnforcement ||
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnLitigation ||
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnMortage ||
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnCourtCase) {
            blnIsLitigationFlag = true;
        }
    }
    
    //Method to get details of the source and target booking units
    public void getUnitDetails() {
        system.debug('-----intTransferUnit-------'+intTransferUnit);
        if(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit == null ||
            lstTransferWrapper[intTransferUnit].strSelectedSourceUnit.equalsIgnoreCase('None') ||
            lstTransferWrapper[intTransferUnit].strSelectedTargetUnit == null ||
            lstTransferWrapper[intTransferUnit].strSelectedTargetUnit.equalsIgnoreCase('None') ||
            lstTransferWrapper[intTransferUnit].strSelectedSourceUnit == lstTransferWrapper[intTransferUnit].strSelectedTargetUnit) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Source and Target unit must be selected and cannot be same'));
            return;
        }
        if(intTransferUnit != null) {
            blnIsLitigationFlag = false;
            
            //Perform callout and fetch details for source and target units
            
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU = new WrapperBookingUnit();
            Booking_Unit__c objBU = mapBookingUnit.get(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit);
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.objBookingUnit = objBU;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strUnit = objBU.Inventory__r.Unit__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strProject = objBU.Inventory__r.Property__r.Name;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strProjectCity = objBU.Inventory__r.Property_City__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strBedroomType = objBU.Inventory__r.IPMS_Bedrooms__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strUnitType = objBU.Inventory__r.Unit_Type__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strPermittedUse = 'Yes';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strReady_OffPlan = objBU.Inventory__r.Property_Status__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strRentalPool = 'No';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnDispute = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnEnforcement = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnLitigation = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnMortage = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnCourtCase = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnFTLsent = true;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnEHO = true;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.blnHO = false;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strPCC = 'Test';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strOQOODregistered = 'No';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strAgreementStatus = 'Pending';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strUnderTermination = 'No';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.str_URC_SPA  = 'Yes';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strDealStatus = 'Pending';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strDefault = 'Test';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strIDavailable = 'Yes';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intArea = objBU.Inventory__r.Area_Sqft_2__c != null ? Integer.valueOf(objBU.Inventory__r.Area_Sqft_2__c) : 0;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.decPrice = objBU.Inventory__r.Selling_Price__c;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intNoOfBookingDay = 10;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intNoOfDefaulted =  1;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intOverdue = 1200;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intRERAstatus = 25;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intPenaltyAmount = 0;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strPC_AgentName = 'Test Agent 1';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intConversationStatus = 2;
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.strDocsStatus = 'Ok';
            lstTransferWrapper[intTransferUnit].objSourceUnitWBU.intPricePerSqFt = objBU.Inventory__r.Price_Per_Sqft__c;
            
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU = new WrapperBookingUnit();
            objBU = mapBookingUnit.get(lstTransferWrapper[intTransferUnit].strSelectedTargetUnit);
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.objBookingUnit = objBU;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strUnit = objBU.Inventory__r.Unit__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strProject = objBU.Inventory__r.Property__r.Name;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strProjectCity = objBU.Inventory__r.Property_City__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strBedroomType = objBU.Inventory__r.IPMS_Bedrooms__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strUnitType = objBU.Inventory__r.Unit_Type__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strPermittedUse = 'Yes';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strReady_OffPlan = objBU.Inventory__r.Property_Status__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strRentalPool = 'No';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnDispute = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnEnforcement = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnLitigation = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnMortage = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnCourtCase = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnFTLsent = true;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnEHO = true;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.blnHO = false;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strPCC = 'Test';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strOQOODregistered = 'No';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strAgreementStatus = 'Pending';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strUnderTermination = 'No';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.str_URC_SPA  = 'Yes';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strDealStatus = 'Pending';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strDefault = 'Test';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strIDavailable = 'Yes';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intArea = objBU.Inventory__r.Area_Sqft_2__c != null ? Integer.valueOf(objBU.Inventory__r.Area_Sqft_2__c) : 0;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.decPrice = objBU.Inventory__r.Selling_Price__c;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intNoOfBookingDay = 10;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intNoOfDefaulted =  2;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intOverdue = 2400;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intRERAstatus = 40;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intPenaltyAmount = 0;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strPC_AgentName = 'Test Agent 2';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intConversationStatus = 2;
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.strDocsStatus = 'Ok';
            lstTransferWrapper[intTransferUnit].objTargetUnitWBU.intPricePerSqFt = objBU.Inventory__r.Price_Per_Sqft__c;
            
            checkLitigationFlags();
            
            if(!blnIsLitigationFlag || blnIsExistingTransfer) {
                blnIsShowPOA = true;
                
                lstTransferWrapper[intTransferUnit].lstAllocations = new List<SelectOption>();
                lstTransferWrapper[intTransferUnit].lstAllocations.add(new SelectOption('Instalment', 'Instalment'));
                lstTransferWrapper[intTransferUnit].lstAllocations.add(new SelectOption('Service Charge', 'Service Charge'));
                
                if(!blnIsExistingTransfer) {
                    lstTransferWrapper[intTransferUnit].strCreditNote = 'Test Credit Note'; //Populated from IPMS for customer
                    lstTransferWrapper[intTransferUnit].decEOIAmount = 0; //Populated from IPMS
                    
                    lstTransferWrapper[intTransferUnit].strSelectedAllocation = 'Instalment';
                    
                    computeAvailableSourceAmount();
                
                    //Available amount from source unit
                    lstTransferWrapper[intTransferUnit].decSourceUnitAmount = 
                        mapSourceUnitAvailableAmount.containsKey(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit) ? 
                        mapSourceUnitAvailableAmount.get(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit) : 75000;
                        
                    lstTransferWrapper[intTransferUnit].decTargetUnitAmount = 0;
                }
                
                lstTransferWrapper[intTransferUnit].isShowUnitDetails = true;
                
                system.debug('--lstTransferWrapper--'+lstTransferWrapper);
                
                lstTransferWrapper[intTransferUnit].strCurrentUnit = lstTransferWrapper[intTransferUnit].strSelectedSourceUnit;
                
                mapWrapperBookingUnit.put(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit, 
                    lstTransferWrapper[intTransferUnit].objSourceUnitWBU);
                mapWrapperBookingUnit.put(lstTransferWrapper[intTransferUnit].strSelectedTargetUnit, 
                    lstTransferWrapper[intTransferUnit].objTargetUnitWBU);
                
                setCurrentUnit();
            }
            else {
                blnIsShowPOA = false;
                lstTransferWrapper[intTransferUnit].objSourceUnitWBU = null;
                lstTransferWrapper[intTransferUnit].objTargetUnitWBU = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Litigation flag has been raised for the selected unit(s)'));
            }
        }
    }
    
    public void setCurrentUnit() {
        system.debug('--strCurrentUnit--'+lstTransferWrapper[intTransferUnit].strCurrentUnit);
        system.debug('--mapUnitNames strCurrentUnit--'+mapUnitNames.get(lstTransferWrapper[intTransferUnit].strCurrentUnit));
        system.debug('--intTransferUnit--'+intTransferUnit);
        if(lstTransferWrapper[intTransferUnit].strCurrentUnit != null && intTransferUnit != null) {
            lstTransferWrapper[intTransferUnit].objCurrentWBU = 
                lstTransferWrapper[intTransferUnit].strCurrentUnit.equals(lstTransferWrapper[intTransferUnit].strSelectedSourceUnit) ? 
                lstTransferWrapper[intTransferUnit].objSourceUnitWBU : 
                lstTransferWrapper[intTransferUnit].objTargetUnitWBU;
            lstTransferWrapper[intTransferUnit].strSelectedUnitDetail = 'Unit Details';
        }
    }
    
    //Method to calculate the available amount for the source unit after allocation to target unit
    private void computeAvailableSourceAmount() {
        for(TransferWrapper objTW: lstTransferWrapper) {
            if(objTW.decSourceUnitAmount != null && objTW.decTargetUnitAmount != null) {
                Decimal decSourceUnitAvailableAmount = objTW.decSourceUnitAmount - objTW.decTargetUnitAmount;
                mapSourceUnitAvailableAmount.put(objTW.strSelectedSourceUnit, decSourceUnitAvailableAmount);
            }
        }
    }
    
    //Method to add a new transfer wrapper
    public void addTransferWrapperElement() {
        populateTransferWrapper();
    }
    
    //Method to redirect to the UploadAttachment page to upload an attachment
    public Pagereference goToAttachmentPage() {
        try {
            if(strDocType != null) {
                /*if(objCase.Power_of_Attorney__c != null && objCase.Power_of_Attorney__c.equalsIgnoreCase('Yes')){
                    if(strPOAExpiryDate != null) {
                        objCase.POA_Expiry_Date__c = Date.parse(strPOAExpiryDate);
                    }
                }
                system.debug('--record type id--'+objCase.RecordTypeId);
                upsert objCase;*/
                saveDetailsAsDraft();
                PageReference objPageref = new pageReference('/apex/UploadAttachment?id='+objCase.Id+'&accID='+objCase.AccountId+'&doc='+strDocType+'&returnPage=CREFundTransfer');
                return objPageref;
            }
        }
        catch(Exception genException) {
            ApexPages.addMessages(genException);
        }
        return null;
    }
    
    //Method to remove the uploaded attachment
    public void removeAttachment() {
        //blnDisableSubmitSRbtn = false;
        if(String.isNotBlank(SRAttachmentToRemove)) {
            List<SR_Attachments__c> lstSRAttachment = [Select Id, type__c From SR_Attachments__c Where id=: SRAttachmentToRemove];
            if(lstSRAttachment != null && !lstSRAttachment.isEmpty()) {
                String strDocType = lstSRAttachment[0].Type__c;
                delete lstSRAttachment;
                lstSRattachments = [Select Id, Name, Case__c, View__c, Attachment__c, Type__c, Case__r.CaseNumber, IsValid__c 
                    From SR_Attachments__c  where Case__c =: objCase.Id];
                
                if(strDocType != null && strDocType.equalsIgnoreCase('Power Of Attorney')) {
                    blnIsShowPOAAttachment = checkAttachmentType(strDocType);
                }
                else if(strDocType != null && strDocType.equalsIgnoreCase('CRF Form')) {
                    blnIsShowCRFAttachment = checkAttachmentType(strDocType);
                }
            }
        }
    }
    
    //Method to check attachment type and it's presence
    private boolean checkAttachmentType(String strDocType) {
        Boolean blnShow = false;       
        for(SR_Attachments__c objSRAttachment: lstSRAttachments) {
            System.debug('---sr--'+objSRAttachment);
            if(objSRAttachment.Type__c == strDocType){
                blnShow = true;
                break;
            }
            /*else if(strDocType == 'DisableCheck' && sr.isValid__C == false){               
                blnShow = true;
                break;
            }*/                      
        }
        return blnShow ;
    }
    
    public void computePOADetails() {
        system.debug('---objCase.Power_of_Attorney__c--'+objCase.Power_of_Attorney__c);
        if(objCase.Power_of_Attorney__c == null || objCase.Power_of_Attorney__c.equalsIgnoreCase('No')) {
            objCase.POA_Name__c = null;
            objCase.POA_Relation_With_Owner__c = null;
            objCase.POA_Expiry_Date__c = null;
            objCase.POA_Issued_By__c = null;
            strPOAAttachmentBody = null;
            strPOAAttachmentName = null;
            strPOAExpiryDate = '';
            
            system.debug('--objCase.POA_Name__c--'+objCase.POA_Name__c);
            system.debug('--objCase.POA_Relation_With_Owner__c--'+objCase.POA_Relation_With_Owner__c);
            system.debug('--objCase.POA_Expiry_Date__c--'+objCase.POA_Expiry_Date__c);
            system.debug('--objCase.POA_Issued_By__c--'+objCase.POA_Issued_By__c);
            
            List<SR_Attachments__c> lstAttachment = [Select Id From SR_Attachments__c 
                                                     Where Case__c =: objCase.Id
                                                     And Type__c = 'Power Of Attorney'];
            if(lstAttachment != null && !lstAttachment.isEmpty()) {
                delete lstAttachment;
            }
            blnIsShowPOAAttachment = false;
        }
        else if(objCase.Power_of_Attorney__c != null && objCase.Power_of_Attorney__c.equalsIgnoreCase('Yes')){
            if(String.isNotBlank(strPOAExpiryDate)) {
                objCase.POA_Expiry_Date__c = Date.parse(strPOAExpiryDate);
            }
        }
    }
    
    //Method to view the CRF
    public Pagereference viewCRF() {
        return new Pagereference('/apex/CRF?Id='+objCase.Id+'&recTypeName=Fund Transfer');
        
    }
    
    //Method to save the details provided on the page
    public Pagereference saveDetailsAsDraft() {
        try {
            computePOADetails();
            upsert objCase;
            
            List<Attachment> lstAttachment = new List<Attachment>();
            List<SR_Attachments__c> lstCaseAttachment = new List<SR_Attachments__c>();
            
            if(String.isNotBlank(strCRFAttachmentBody) && String.isNotBlank(strCRFAttachmentName)) {
                lstAttachment.add(getAttachment(extractName(strCRFAttachmentName), extractBody(strCRFAttachmentBody)));
                lstCaseAttachment.add(getCaseAttachment('CRF Form'));
            }
            
            if(objCase.Power_of_Attorney__c != null && objCase.Power_of_Attorney__c.equalsIgnoreCase('Yes')) {
                if(String.isNotBlank(strPOAAttachmentBody) && String.isNotBlank(strPOAAttachmentName)) {
                    lstAttachment.add(getAttachment(extractName(strPOAAttachmentName), extractBody(strPOAAttachmentBody)));
                    lstCaseAttachment.add(getCaseAttachment('Power Of Attorney'));
                }
            }
            
            system.debug('--lstAttachment--'+lstAttachment);
            system.debug('--lstCaseAttachment--'+lstCaseAttachment);
            
            if(!lstAttachment.isEmpty()) {
                insertAttachments(lstAttachment, lstCaseAttachment);
            }
            
            List<Fund_Transfer_Details__c> lstFTToDelete = 
                [Select Id From Fund_Transfer_Details__c
                 Where Case__c =: objCase.Id];
            if(lstFTToDelete != null && !lstFTToDelete.isEmpty()) {
                delete lstFTToDelete;
            }
            
            List<SR_Booking_Unit__c> lstSRBUToDelete = 
                [Select Id From SR_Booking_Unit__c
                 Where Case__c =: objCase.Id];
            if(lstSRBUToDelete != null && !lstSRBUToDelete.isEmpty()) {
                delete lstSRBUToDelete;
            }
            
            List<Fund_Transfer_Details__c> lstFTToInsert = new List<Fund_Transfer_Details__c>();
            List<SR_Booking_Unit__c> lstSRBUToInsert = new List<SR_Booking_Unit__c>();
            
            system.debug('--lstTransferWrapper--'+lstTransferWrapper);
            
            for(TransferWrapper objTW: lstTransferWrapper) {
                if(objTW.decSourceUnitAmount != null && objTW.decTargetUnitAmount != null) {
                    Fund_Transfer_Details__c objFT = new Fund_Transfer_Details__c();
                    objFT.Case__c = objCase.Id;
                    objFT.Source_Booking_Unit__c = objTW.strSelectedSourceUnit;
                    objFT.Target_Booking_Unit__c = objTW.strSelectedTargetUnit;
                    objFT.Source_Unit_Available_Amount__c = objTW.decSourceUnitAmount;
                    objFT.Target_Unit_Allocated_Amount__c = objTW.decTargetUnitAmount;
                    objFT.Credit_Note__c = objTW.strCreditNote;
                    objFT.EOI_Amount__c = objTW.decEOIAmount;
                    objFT.Amount_Allocated_Against__c = objTW.strSelectedAllocation;
                    
                    lstFTToInsert.add(objFT);
                }
            }
            
            insert lstFTToInsert;
            
            validateSubmitButton();
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The details have been saved successfully: ' + objCase.Id));
            
            Pagereference objPageref = new Pagereference('/apex/' + Page.CREFundTransfer + '?accID=' + objCase.AccountId + '&caseID=' + objCase.Id);
            objPageref.setRedirect(true);
            return null;
        }
        catch(Exception genException) {
            ApexPages.addMessages(genException);
        }
        return null;
    }
    
    //Method to submit the service request
    public Pagereference submitSR() {
        saveDetailsAsDraft();
        Boolean blnIsValid = checkAttachmentUploads();
        if(!blnIsValid) {
            return null;
        }
        
        try {
            objCase.Status = 'Submitted';
            objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
            objCase.Submit_for_Approval__c = true ;
            upsert objCase;
        
            return new Pagereference('/' + objCase.Id);
        }
        catch(Exception genException) {
            ApexPages.addMessages(genException);
        }
        return null;
    }
    
    //Method to check the required attachment uploads
    private Boolean checkAttachmentUploads() {
        Boolean blnIsValid = true;
        Boolean blnIsPOARequired = false;
        
        if(objCase.Power_of_Attorney__c != null && objCase.Power_of_Attorney__c.equalsIgnoreCase('Yes')) {
            blnIsShowPOAAttachment = checkAttachmentType('Power Of Attorney');
            blnIsPOARequired = true;
        }
        
        blnIsShowCRFAttachment = checkAttachmentType('CRF Form');
        
        if(blnIsPOARequired && !blnIsShowPOAAttachment) {
            blnIsValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'POA has not been uploaded'));
        }
        
        if(!blnIsShowCRFAttachment) {
            blnIsValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'CRF has not been uploaded'));
        }
        
        return blnIsValid;
    }
    
    private String extractName( String strName ) {
        return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    
    private Blob extractBody( String strBody ) {
        strBody = EncodingUtil.base64Decode( strBody ).toString();
        return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }
    
    private Attachment getAttachment(String strName, Blob blbBody) {
        Attachment objAttachment = new Attachment();
        objAttachment.Name = strName;
        objAttachment.Body = blbBody;
        return objAttachment;
    }
    
    private SR_Attachments__c getCaseAttachment(String strDocType) {
        SR_Attachments__c objCaseAttachment = new SR_Attachments__c();
        objCaseAttachment.Case__c = objCase.Id;
        objCaseAttachment.Type__c = strDocType;
        return objCaseAttachment;
    }
    
    //Method to insert attachments and case attachments
    private void insertAttachments(List<Attachment> lstAttachment, List<SR_Attachments__c> lstCaseAttachment) {
        insert lstCaseAttachment;
        
        Integer intCounter = 0;
        for(SR_Attachments__c objCaseAttachment: lstCaseAttachment) {
            lstAttachment[intCounter].ParentId = objCaseAttachment.Id;
            intCounter++;
        }
        
        insert lstAttachment;
        
        intCounter = 0;
        for(Attachment objAttachment: lstAttachment) {
            lstCaseAttachment[intCounter].Name = objAttachment.Name;
            lstCaseAttachment[intCounter].Attachment__c = objAttachment.Id;
            intCounter++;
        }
        
        update lstCaseAttachment;
        
        strCRFAttachmentBody = null;
        strCRFAttachmentName = null;
        strPOAAttachmentBody = null;
        strPOAAttachmentName = null;
        
        lstSRattachments = [Select Id, Name, Case__c, View__c, Attachment__c, Type__c, Case__r.CaseNumber, IsValid__c 
                    From SR_Attachments__c  where Case__c =: objCase.Id];
        
        blnIsShowPOAAttachment = checkAttachmentType('Power Of Attorney');
        blnIsShowCRFAttachment = checkAttachmentType('CRF Form');
        
        
    }
    
    private void validateSubmitButton() {
        Boolean blnIsValid = checkAttachmentUploads();
        if(!blnIsValid) {
            blnDisableSubmitSRBtn = true;
        }
        else {
            blnDisableSubmitSRBtn = false;
        }
    }
    
    public class TransferWrapper {
        public List<SelectOption> lstSourceUnits {get; set;}
        public List<SelectOption> lstTargetUnits {get; set;}
        public String strSelectedSourceUnit {get; set;}
        public String strSelectedTargetUnit {get; set;}
        public Decimal decSourceUnitAmount {get; set;}
        public Decimal decTargetUnitAmount {get; set;}
        public List<SelectOption> lstUnitDetails {get; set;}
        public String strSelectedUnitDetail {get; set;}
        public Boolean isShowUnitDetails {get; set;}
        public String strCurrentUnit {get; set;}
        public List<SelectOption> lstAllocations {get; set;}
        public String strSelectedAllocation {get; set;}
        public String strCreditNote {get; set;}
        public Decimal decEOIAmount {get; set;}
        public WrapperBookingUnit objSourceUnitWBU {get; set;}
        public WrapperBookingUnit objTargetUnitWBU {get; set;}
        public WrapperBookingUnit objCurrentWBU {get; set;}
    }
}