public with sharing class EarlyHandoverCREProcess {

    public Booking_Unit__c objBookingUnit {get;set;}
    public Id accountId {get;set;}
    public list<Case> lstOpenCase {get;set;}
    public list<Case> lstCloseCase {get;set;}
    public list<selectOption> lstModes {get;set;}
    public list<selectOption> lstUnits;
    public string strSelectedUnit {get;set;}
    public string strUnitAvailableDate {get;set;}
    public String strSelectedCategory {get;set;}
    public List<SelectOption> lstCategories {get;set;}
    public string SOAurl {get;set;}
    public string strLeaseStartDate {get;set;}
    public string strLeaseEndDate {get;set;}
    public string strFinalAmount {get;set;}
    public string strTerminationDate {get;set;}
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
    public string agreementAttachmentBody {get;set;}
    public string agreementAttachmentName {get;set;}
    public string strSelectedUnitName {get;set;}
    public string strPenaltyAmount {get;set;}
    public string strNoticePeriod {get;set;}
    public string strCaseID;
    public string strTerminationNoticeDate {get;set;}
    public boolean blnIsCRFGenerated;
    public boolean blnIsAgreementGenerated;
    public boolean blnIsPOAGenerated;
    public boolean blnIsSOAGenerated;
    public boolean blnSubmitCase;
    public Case objCase { get; set; }
    public List<Payment_Terms__c> lstPaymentTerms {get;set;}
    public Decimal percentValueTotalCurPP {get;set;}
    public String strPaymentPlanType { get;set; }
    private Attachment objAttach; 
    private list<Attachment> lstAttachment;
    public Boolean blnShowCurrentPP {get;set;}
    public Boolean blnShowSelectedUnits {get;set;}
    public Boolean blnAOPTExists {get;set;}
    public Boolean blnShowNewCurrentPP {get;set;}
    public List<SelectOption> structureBasedPT {get;set;}
    public List<SelectOption> structureBasedPercent {get;set;}
    public List<SelectOption> ageBasedPT {get;set;}
    public List<SelectOption> ageBasedPercent {get;set;}
    public List<SelectOption> dateBasedPT {get;set;}
    public List<SelectOption> dateBasedPercent {get;set;}
    public List<SelectOption> payoutMethods {get;set;}
    //Map<String,List<NewPaymentTermsWrapper>> mapNewPaymentTermsWrapper = new Map<String,list<NewPaymentTermsWrapper>>();
    public String strNewPaymentPlan { get;set; }
    public Integer percentValueTotalNewPP1 {get;set;}
    public List<SelectedNewPaymentTermsByCRE> lstNewPaymentTermsDisplay {get;set;}
    public string rowToRemove {get;set;}
    public boolean displayPDC {get;set;}
    public string noOfInstallments {get;set;}
    public string selectedPayoutMethod {get;set;}
    public List<Post_Dated_Cheque__c> lstLeasePDC {get;set;}
    public List<Post_Dated_Cheque__c> lstInstallmentPDC {get;set;}
    public string securityAmount {get;set;}
    private string strPaymentPlanId;
    private List<Post_Dated_Cheque__c> allPDC;
    private list<SelectedNewPaymentTermsByCRE> newPaymentTerms;
    public UnitDetailsService.BookinUnitDetailsWrapper objBookinUnitDetailsWrapper {get; set;}
    public List<docInfo> lstAdditionalDocs {get;set;}
    public list<SR_Attachments__c> lstInsertedSupportingDocs {get;set;}
    public list<selectoption> lstOptions {get;set;}
    public list<SR_Attachments__c> lstInsertedPrimaryDocs {get;set;}
    public string errorMessage{get;set;}
    public List<docInfo> lstDocs {get;set;}
    public boolean blnSectionAddDocs {get;set;}
    public Attachment poaAttach {get;set;}
    
    public EarlyHandoverCREProcess(){
        init();
    }//End Constructor 

    public void init(){
    system.debug('1111111');
        poaAttach = new Attachment();
        objBookingUnit = new Booking_Unit__c();
        blnShowSelectedUnits = false;
        blnAOPTExists = false;
        blnShowCurrentPP = false;
        blnShowNewCurrentPP = false;
        accountId = '0017E00000cWKII';
        //lstOpenCase = new list<Case>();
        //lstCloseCase = new list<Case>();
        lstModes = new list<selectOption>();
        //lstUnits = new list<selectOption>();
        blnIsCRFGenerated = false;
        blnIsAgreementGenerated = false;
        blnIsPOAGenerated = false;
        blnIsSOAGenerated = false;
        blnSubmitCase = false;
        displayPDC = false;
        lstAttachment = new list<Attachment>();
        strTerminationNoticeDate = string.valueOf(date.today());
        newPaymentTerms = new list<SelectedNewPaymentTermsByCRE>();
        lstModes.add(new selectOption('Courier', 'Courier'));
        lstModes.add(new selectOption('Collection By Hand', 'Collection By Hand'));
        strSelectedCategory = 'Unit Details';
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        lstCategories.add(new selectOption('Close SRs', 'Close SRs'));
        
        /*structureBasedPT.add(new selectOption('On Or Before Due Date','On Or Before Due Date'));
        structureBasedPT.add(new selectOption('Immediate','Immediate'));
        structureBasedPT.add(new selectOption('Within 60 days of Sales Date','Within 60 days of Sales Date'));
        structureBasedPT.add(new selectOption('Within 180 days of Sales Date','Within 180 days of Sales Date'));
        structureBasedPT.add(new selectOption('Within 360 days of Sales Date','Within 360 days of Sales Date'));
        structureBasedPT.add(new selectOption('On Completion Of basement structure','On Completion Of basement structure'));
        structureBasedPT.add(new selectOption('On Completion Of 40th Floor Structure','On Completion Of 40th Floor Structure'));
        structureBasedPT.add(new selectOption('On Completion Of 50th Floor Structure','On Completion Of 50th Floor Structure'));
        structureBasedPT.add(new selectOption('On Completion of 60th Floor Structure','On Completion of 60th Floor Structure'));
        structureBasedPT.add(new selectOption('On Completion','On Completion'));*/
        
        payoutMethods = new List<SelectOption>();
        payoutMethods.add(new selectOption('--None--', '--None--'));
        payoutMethods.add(new selectOption('Monthly', 'Monthly'));
        payoutMethods.add(new selectOption('Quarterly', 'Quarterly'));
        payoutMethods.add(new selectOption('Biyearly', 'Biyearly'));
        
        /*structureBasedPercent = new List<SelectOption>();
        structureBasedPercent.add(new selectOption('5','5'));
        structureBasedPercent.add(new selectOption('10','10'));
        structureBasedPercent.add(new selectOption('15','15'));
        structureBasedPercent.add(new selectOption('20','20'));
        structureBasedPercent.add(new selectOption('25','25'));
        structureBasedPercent.add(new selectOption('30','30'));
        structureBasedPercent.add(new selectOption('35','35'));
        structureBasedPercent.add(new selectOption('40','40'));
        structureBasedPercent.add(new selectOption('45','45'));
        structureBasedPercent.add(new selectOption('50','50'));
        structureBasedPercent.add(new selectOption('55','55'));
        structureBasedPercent.add(new selectOption('60','60'));
        structureBasedPercent.add(new selectOption('65','65'));
        structureBasedPercent.add(new selectOption('70','70'));
        structureBasedPercent.add(new selectOption('75','75'));
        structureBasedPercent.add(new selectOption('80','80'));
        structureBasedPercent.add(new selectOption('85','85'));
        structureBasedPercent.add(new selectOption('90','90'));
        structureBasedPercent.add(new selectOption('95','95'));*/
        
        objBookinUnitDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
    }//end init
    
    public list < SelectOption > getlstUnits(){
        lstUnits = new list<selectOption>();
        lstUnits.add(new selectOption('', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Unit_Details__c,
                                            Booking__c 
                                     From Booking_Unit__c
                                     Where Booking__r.Account__c =: accountId
                                     And Eligible_For_Early_Handover__c = true
                                     Order By Unit_Details__c
                                     ]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }//End for
        return lstUnits;
    }//end getlstUnits
    public void CheckForPOA(Id objCaseId) {
        String attachmentId = [Select Attachment__c From SR_Attachments__c where case__c=:objCaseId
                                    AND Type__c='Power of Attorney' order by LastModifiedDate desc Limit 1].Attachment__c;
                                    
        Attachment attach = [Select Name, Body, ParentId From Attachment where Id=: Id.valueof(attachmentId)];
        poaAttach = attach;
        //poaAttachmentName = attach.Name;
         //system.debug('4444444'+poaAttachmentName );
    }
    public void autoPopulateBUDetails(){
        ApexPages.getMessages().clear();
        lstOpenCase = new list<Case>();
        lstCloseCase = new list<Case>();
        strPOARelationWithOwner = '';
        strPOAName = '';
        strPOAExpiryDate = '';
        strPOAIssuedBy = '';
        poaAttachmentBody = '';
        poaAttachmentName = '';
        blnPoAValue = false;
         if(strSelectedUnit!= null){
         for(Case objCase : [select ID,
                                    CaseNumber,
                                    Status,
                                    Booking_Unit__c,
                                    Early_Handover_Status__c,
                                    SR_Type__c,
                                    RecordType.DeveloperName,
                                    Purpose_of_POA__c,
                                    POA_Expiry_Date__c,
                                    POA_Issued_By__c,
                                    POA_Name__c
                               from Case
                              where Booking_Unit__c =: strSelectedUnit]){
                if(objCase.Status != 'Closed'){
                    if (objCase.RecordType.DeveloperName == 'Early_Handover') {
                        system.debug('3333333'+objCase.Status+objCase.Purpose_of_POA__c);
                        if(objCase.Status == 'Draft Request') {
                            if(objCase.Purpose_of_POA__c != null) {
                                CheckForPOA(objCase.Id);
                                strPOARelationWithOwner = objCase.Purpose_of_POA__c;
                                strPOAName = objCase.POA_Name__c;
                                strPOAExpiryDate = String.valueOf(objCase.POA_Expiry_Date__c);
                                strPOAIssuedBy = objCase.POA_Issued_By__c;
                                blnPoAValue = true;
                                 system.debug('4444444'+blnPoAValue );
                            }
                        }  
                        system.debug('4444444'+blnPoAValue );   
                        strCaseId =  objCase.Id;                  
                        blnAOPTExists = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Early Handover SR already exists for Selected Booking Units.'));                    
                    } else {
                        lstOpenCase.add(objCase);
                    }
                }else{
                    lstCloseCase.add(objCase);
                }//end if-else
         }//end for
         }//end if
         system.debug('---strSelectedUnit' +strSelectedUnit);
       if(strSelectedUnit != null && strSelectedUnit != ''){
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
                              Booking_Type__c
                         from Booking_Unit__c
                        where ID =: strSelectedUnit];
         strSelectedUnitName = objBookingUnit.Unit_Details__c;
         strPenaltyAmount = '10.00';
         strNoticePeriod = '12 Months';
         blnShowSelectedUnits = true;
         
         objBookinUnitDetailsWrapper = UnitDetailsService.getBookingUnitDetails('91826');
         system.debug('******'+objBookinUnitDetailsWrapper);
         
       } else {
         objBookingUnit = new Booking_Unit__c();
         strPenaltyAmount = '';
         strNoticePeriod = '';
         strSelectedUnitName = '';
         blnShowSelectedUnits = false;
         
         objBookinUnitDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
       }
       //blnShowSelectedUnits = true;
       getCurrentPaymemtTerm();
    }//end autoPopulateBUDetails
    
    public void SOAtobeGenerated() {
        system.debug('!!!!!!!!!!!inside SOA method');
        blnSOAGenerate = true;
        GenerateSOAController.soaResponse objSOA = GenerateSOAController.getSOADocument('41397');
        system.debug('!!!!!objSOA'+objSOA.url);
        SOAurl = objSOA.url;
    }//end SOAtobeGenerated
    
    public void displayPDC() {
        system.debug('!!!!!!!!!!!inside displayPDC');       
        displayPDC = true;
    }
    
    public void calculatePDC() {
        system.debug('!!!!!!Calculate PDC'+lstNewPaymentTermsDisplay);
        system.debug('!!!!!!!!!1strLeaseStartDate'+strLeaseStartDate);
        system.debug('!!!!!!!!!!!!strLeaseEndDate'+strLeaseEndDate);
        Date startDate;
        Date endDate;
        //Integer monthDiff;
        if (strLeaseStartDate != null && !String.isBlank(strLeaseStartDate)) {
            startDate = date.parse(strLeaseStartDate);
        }
        /*if (strLeaseEndDate != null && !String.isBlank(strLeaseEndDate)) {
            endDate = date.parse(strLeaseEndDate);
        }
        if (startDate != null && endDate != null) {
            monthDiff = startDate.monthsBetween(endDate);
            system.debug('!!!!!!!!!!!!monthDiff'+monthDiff);
        }*/
        Decimal completedTerms = 0;
        if (lstNewPaymentTermsDisplay != null && lstNewPaymentTermsDisplay.size() > 0) {
            for (SelectedNewPaymentTermsByCRE objSelectNewPaymentTerm : lstNewPaymentTermsDisplay) {
                completedTerms = completedTerms + decimal.ValueOf(objSelectNewPaymentTerm.percentValue);
            }
        }
        system.debug('!!!!!!!!!!!!completedTerms'+completedTerms);
        
        Double pendingTerms = 100 - completedTerms;
        system.debug('!!!!!!!!pendingTerms'+pendingTerms);
        Double monthlyPayment;
        
        system.debug('!!!!!!!!!!noOfInstallments'+noOfInstallments);
        Decimal noOfmonths = decimal.ValueOf(noOfInstallments);
        
        if (noOfInstallments != null && pendingTerms != null && objBookingUnit.Unit_Selling_Price__c != null){
            monthlyPayment = (pendingTerms * objBookingUnit.Unit_Selling_Price__c)/(100 * noOfmonths);
        }
        system.debug('!!!!!!!!!!!!!!!!!!monthlyPayment'+monthlyPayment);
        
        Double rentalPart;
        if (objBookingUnit.Inventory__r.Building_Location__r.Rental_Index__c != null) {
            rentalPart = objBookingUnit.Inventory__r.Building_Location__r.Rental_Index__c/12;
        }
        system.debug('!!!!!!!!!!!!!!!!!!rentalPart'+rentalPart);
        
        Double leasePart;
        if (rentalPart != null) {
            leasePart = monthlyPayment - rentalPart;
        }
        
        Long noOfTerms;
        Integer noOfDays;
        Integer noCal;
        if (selectedPayoutMethod == 'Monthly') {
            noOfTerms = long.valueOf(noOfInstallments);
            noOfDays = 30;
            noCal = 1;      
        } else if (selectedPayoutMethod == 'Quarterly') {
            Decimal block = noOfmonths/3.0;
            noOfTerms = block.round(System.RoundingMode.UP);
            noOfDays = 90;
            noCal = 3;
        } else if (selectedPayoutMethod == 'Biyearly') {
            Decimal block = noOfmonths/6.0;
            noOfTerms = block.round(System.RoundingMode.UP);
            noOfDays = 180;
            noCal = 6;
        }
        system.debug('!!!!!!!!!noOfTerms'+noOfTerms);
        lstLeasePDC = new List<Post_Dated_Cheque__c>();
        lstInstallmentPDC = new List<Post_Dated_Cheque__c>();
        allPDC = new List<Post_Dated_Cheque__c>();
        
        Long counter = lstNewPaymentTermsDisplay.size() - 1;
        
        Decimal val = 0;
        if (completedTerms < 100) {
        for (integer i=1; i<=noOfTerms; i++) {
            Post_Dated_Cheque__c objLeasePDC = new Post_Dated_Cheque__c();
            objLeasePDC.Booking_Unit__c = objBookingUnit.id;
            objLeasePDC.Amount__c = rentalPart * noCal ;
            objLeasePDC.Cheque_Date__c = system.today() + (noOfDays * i);
            objLeasePDC.Type__c = 'Lease';
            objLeasePDC.Name = 'Lease Cheque ' + i;
            objLeasePDC.Payment_Plan__c = strPaymentPlanId;
            lstLeasePDC.add(objLeasePDC);
            
            Post_Dated_Cheque__c objInstallPDC = new Post_Dated_Cheque__c();
            objInstallPDC.Booking_Unit__c = objBookingUnit.id;
            objInstallPDC.Amount__c = leasePart * noCal ;
            objInstallPDC.Cheque_Date__c = system.today() + (noOfDays * i);
            objInstallPDC.Type__c = 'Installment';
            objInstallPDC.Name = 'Installment Cheque ' + i;
            objInstallPDC.Payment_Plan__c = strPaymentPlanId;
            lstInstallmentPDC.add(objInstallPDC); 
            
            SelectedNewPaymentTermsByCRE objNewPaymentTermWrapper = new SelectedNewPaymentTermsByCRE();
            
            counter = counter + 1;
            
            if (counter == 2) {
                objNewPaymentTermWrapper.description = counter+'ND INSTALLMENT';
            } else if (counter == 3) {
                objNewPaymentTermWrapper.description = counter+'RD INSTALLMENT';
            } else {
                objNewPaymentTermWrapper.description = counter+'TH INSTALLMENT';
            }
            objNewPaymentTermWrapper.Id = '';
            objNewPaymentTermWrapper.installment = 'I00'+counter;
            objNewPaymentTermWrapper.mileStoneEvent = 'On Or Before Due Date';
            system.debug('!!!!!!!!pendingTerms'+pendingTerms);
            system.debug('!!!!!!!!noOfTerms'+noOfTerms);
            objNewPaymentTermWrapper.percentValue = String.valueOf(pendingTerms/noOfTerms);
            Date dueDate = system.today() + (noOfDays * i);
            objNewPaymentTermWrapper.paymentDate = dueDate.format();
            objNewPaymentTermWrapper.isReceiptPresent = false;
            objNewPaymentTermWrapper.lstStructureBasedPP = new List<SelectOption>(structureBasedPT);
            //objNewPaymentTermWrapper.lstStructureBasedPercent = new List<SelectOption>(structureBasedPercent);
            newPaymentTerms.add(objNewPaymentTermWrapper);
             
        }
        allPDC.addAll(lstLeasePDC);
        allPDC.addAll(lstInstallmentPDC);
        lstNewPaymentTermsDisplay.addAll(newPaymentTerms);   
        } else {
            for (SelectedNewPaymentTermsByCRE objNewPaymentTermWrapper : newPaymentTerms) {
                if (objNewPaymentTermWrapper.isReceiptPresent == false) {
                    val = val + decimal.valueOf(objNewPaymentTermWrapper.percentValue);
                    system.debug('!!!!val'+val);
                    Integer rowToRemove = lstNewPaymentTermsDisplay.size() - newPaymentTerms.size();
                    lstNewPaymentTermsDisplay.remove(rowToRemove + 1);
                    //newPaymentTerms.remove(newPaymentTerms.size() - 1);
                }
            }
            if (noOfInstallments != null && pendingTerms != null && objBookingUnit.Unit_Selling_Price__c != null){
                monthlyPayment = (val * objBookingUnit.Unit_Selling_Price__c)/(100 * noOfmonths);
            }
            
            if (rentalPart != null) {
                leasePart = monthlyPayment - rentalPart;
            }
            newPaymentTerms = new list<SelectedNewPaymentTermsByCRE>();
            counter = lstNewPaymentTermsDisplay.size() - 1;
            for (integer i=1; i<=noOfTerms; i++) {
                Post_Dated_Cheque__c objLeasePDC = new Post_Dated_Cheque__c();
                objLeasePDC.Booking_Unit__c = objBookingUnit.id;
                objLeasePDC.Amount__c = rentalPart * noCal ;
                objLeasePDC.Cheque_Date__c = system.today() + (noOfDays * i);
                objLeasePDC.Type__c = 'Lease';
                objLeasePDC.Name = 'Lease Cheque ' + i;
                objLeasePDC.Payment_Plan__c = strPaymentPlanId;
                lstLeasePDC.add(objLeasePDC);
                
                Post_Dated_Cheque__c objInstallPDC = new Post_Dated_Cheque__c();
                objInstallPDC.Booking_Unit__c = objBookingUnit.id;
                objInstallPDC.Amount__c = leasePart * noCal ;
                objInstallPDC.Cheque_Date__c = system.today() + (noOfDays * i);
                objInstallPDC.Type__c = 'Installment';
                objInstallPDC.Name = 'Installment Cheque ' + i;
                objInstallPDC.Payment_Plan__c = strPaymentPlanId;
                lstInstallmentPDC.add(objInstallPDC);
                
                SelectedNewPaymentTermsByCRE objNewPaymentTermWrapper = new SelectedNewPaymentTermsByCRE();
                
                counter = counter + 1;              
            
                if (counter == 2) {
                    objNewPaymentTermWrapper.description = counter+'ND INSTALLMENT';
                } else if (counter == 3) {
                    objNewPaymentTermWrapper.description = counter+'RD INSTALLMENT';
                } else {
                    objNewPaymentTermWrapper.description = counter+'TH INSTALLMENT';
                }
                objNewPaymentTermWrapper.Id = '';
                objNewPaymentTermWrapper.installment = 'I00'+counter;
                objNewPaymentTermWrapper.mileStoneEvent = 'On Or Before Due Date';
                system.debug('!!!!!!!!pendingTerms'+pendingTerms);
                system.debug('!!!!!!!!noOfTerms'+noOfTerms);
                objNewPaymentTermWrapper.percentValue = String.valueOf(val/noOfTerms);
                Date dueDate = system.today() + (noOfDays * i);
                objNewPaymentTermWrapper.paymentDate = dueDate.format();
                objNewPaymentTermWrapper.isReceiptPresent = false;
                objNewPaymentTermWrapper.lstStructureBasedPP = new List<SelectOption>(structureBasedPT);
                //objNewPaymentTermWrapper.lstStructureBasedPercent = new List<SelectOption>(structureBasedPercent);
                newPaymentTerms.add(objNewPaymentTermWrapper);
                }
            allPDC.addAll(lstLeasePDC);
            allPDC.addAll(lstInstallmentPDC);
            lstNewPaymentTermsDisplay.addAll(newPaymentTerms);
        }
        Date leaseDate = system.today() + (noOfDays * noOfTerms);
        
        //strLeaseEndDate = String.valueOf(system.today() + (noOfDays * noOfTerms)); 
        strLeaseEndDate = leaseDate.format();
        if (objBookingUnit.Unit_Selling_Price__c < 2000000) {
            securityAmount = '100000';
        } else {
            securityAmount = '200000';
        }
    }
    
    public void updatePDCPP() {
        
        list<Post_Dated_Cheque__c> updatePDC = new list<Post_Dated_Cheque__c>();
        if (allPDC != null && allPDC.size() > 0) {
            for (Post_Dated_Cheque__c objPDC : allPDC) {
                objPDC.Case__c = strCaseID;
                updatePDC.add(objPDC);
            }
        }
        
        if (updatePDC != null && updatePDC.size() > 0) {
            insert updatePDC;
        }
        
        List<Payment_Terms__c> updatedTerms = new List<Payment_Terms__c>();
        if (lstNewPaymentTermsDisplay != null && lstNewPaymentTermsDisplay.size() > 0) {
            for (SelectedNewPaymentTermsByCRE objSelectNewPaymentTerm : lstNewPaymentTermsDisplay) {
                Payment_Terms__c objPaymentTerm = new Payment_Terms__c();
                if (objSelectNewPaymentTerm.Id != '') {
                    objPaymentTerm.Id = objSelectNewPaymentTerm.Id;
                }
                objPaymentTerm.Installment__c = objSelectNewPaymentTerm.installment;
                objPaymentTerm.Description__c = objSelectNewPaymentTerm.description;
                objPaymentTerm.Milestone_Event__c = objSelectNewPaymentTerm.mileStoneEvent;
                objPaymentTerm.Percent_Value__c = objSelectNewPaymentTerm.percentValue;        
                objPaymentTerm.Payment_Date__c = Date.parse(objSelectNewPaymentTerm.paymentDate);
                //objPaymentTerm.Name = objSelectNewPaymentTerm.name;
                objPaymentTerm.Booking_Unit__c = strSelectedUnit;
                objPaymentTerm.Payment_Plan__c = strPaymentPlanId;
                updatedTerms.add(objPaymentTerm);
            }
        }
        
        if (updatedTerms != null && updatedTerms.size() > 0) {
            upsert updatedTerms;
        }
    }
    
    public PageReference getCurrentPaymemtTerm()
    {
    // here we will perform the Callout to Rule Engine by passing the Booking Unit Details
    // to perform Litigation Flag check,RERA Detail Calculation,ACD Calculation.
    // if Response is success, then fetch the current payment plan and display on UI
    // if response is erorr, i.e validation fails for above mentioned points
    // then we will show that error message on UI and will not proceed further
    structureBasedPT = new List<SelectOption>();
    MileStoneEventsWrapper.MileStoneEvents objMileStone = new MileStoneEventsWrapper.MileStoneEvents();
    objMileStone = AOPTMQService.getMasterMilestone('41397');
    
    for (MileStoneEventsWrapper.MILESTONE_TAB_TYPE objType : objMileStone.MILESTONE_TAB_TYPE ) {
        //system.debug('!!!!!objType'+objType.MILESTONE_EVENT);
        structureBasedPT.add(new selectOption(objType.MILESTONE_EVENT,objType.MILESTONE_EVENT));
    }
    system.debug('!!!!!!!!!!objMileStone'+objMileStone);
    lstPaymentTerms = new List<Payment_Terms__c>();
    lstNewPaymentTermsDisplay = new List<SelectedNewPaymentTermsByCRE>();
    system.debug('strSelectedUnit '+strSelectedUnit);
    percentValueTotalCurPP = 0;
    for(Payment_Terms__c objPaymentTerm : [ Select Id,Name,Payment_Plan__r.Name,Milestone_Event__c
                                            ,Installment__c,Description__c,Percent_Value__c, Payment_Plan__c, Expected_Date__c
                                            ,Payment_Date__c,Milestone_Event_Arabic__c,Payment_Plan__r.Payment_Term__c 
                                            FROM Payment_Terms__c WHERE Booking_Unit__c =:strSelectedUnit order by Name
                                          ])
    {
        system.debug('objPaymentTerm '+objPaymentTerm);
        strPaymentPlanId = objPaymentTerm.Payment_Plan__c;
        lstPaymentTerms.add(objPaymentTerm);
        percentValueTotalCurPP = percentValueTotalCurPP + Decimal.valueOf(objPaymentTerm.Percent_Value__c != null ? objPaymentTerm.Percent_Value__c : '0');
        strPaymentPlanType = objPaymentTerm.Payment_Plan__r.Payment_Term__c ;
        
        /*SelectedNewPaymentTermsByCRE objNewPaymentTerms = new SelectedNewPaymentTermsByCRE();
        objNewPaymentTerms.Id = objPaymentTerm.Id;
        objNewPaymentTerms.installment = objPaymentTerm.Installment__c;
        objNewPaymentTerms.description = objPaymentTerm.Description__c;
        objNewPaymentTerms.mileStoneEvent = objPaymentTerm.Milestone_Event__c;
        objNewPaymentTerms.percentValue = objPaymentTerm.Percent_Value__c;
        Datetime dt = Datetime.newInstance(objPaymentTerm.Payment_Date__c.year(), objPaymentTerm.Payment_Date__c.month(), objPaymentTerm.Payment_Date__c.day());
        objNewPaymentTerms.paymentDate = dt.format('dd/MM/yyyy');
        objNewPaymentTerms.name = objPaymentTerm.Name;
        //objNewPaymentTerms.lstStructureBasedPercent = new List<SelectOption>(structureBasedPercent);
        objNewPaymentTerms.lstStructureBasedPP = new List<SelectOption>(structureBasedPT);
        objNewPaymentTerms.isReceiptPresent = true;
        if (objPaymentTerm.Installment__c == 'I003'){
            objNewPaymentTerms.isReceiptPresent = false;
        }
        lstNewPaymentTermsDisplay.add(objNewPaymentTerms);*/
    }
    system.debug('lstPaymentTerms '+lstPaymentTerms);
    system.debug('strPaymentPlanType '+strPaymentPlanType);
        // if there is error for any flag for units then we will not show current and new payment plans
        
        String planType = PaymentPlanUtility.getPaymentPlanType(lstPaymentTerms);
        system.debug('!!planType'+planType);
        if (planType == 'Date Based Payment Plan') {        
            blnShowCurrentPP = true;
        }
        MileStonePaymentDetailsWrapper.MileStonePaymentDetails  objPayTerms = new MileStonePaymentDetailsWrapper.MileStonePaymentDetails();
        objPayTerms = AOPTMQService.getMilestonePaymentDetails('41397');
        system.debug('!!!!!!!!objPayTerms'+objPayTerms);
        
        for (MileStonePaymentDetailsWrapper.REG_TERM_PYMNT_TABLE objTerm :  objPayTerms.REG_TERM_PYMNT_TABLE ) {
            SelectedNewPaymentTermsByCRE objNewPaymentTerms = new SelectedNewPaymentTermsByCRE();
            objNewPaymentTerms.installment = objTerm.INSTALLMENT;
            objNewPaymentTerms.description = objTerm.DESCRIPTION;
            objNewPaymentTerms.mileStoneEvent = objTerm.MILESTONE_EVENT;
            objNewPaymentTerms.percentValue = objTerm.MILESTEON_PERCENT_VALUE;
            //Datetime dt = Datetime.newInstance(objPaymentTerm.Payment_Date__c.year(), objPaymentTerm.Payment_Date__c.month(), objPaymentTerm.Payment_Date__c.day());
            //objNewPaymentTerms.paymentDate = dt.format('dd/MM/yyyy');
            objNewPaymentTerms.paymentDate = objTerm.DUE_DATE;
            //objNewPaymentTerms.name = objPaymentTerm.Name;
            objNewPaymentTerms.lstStructureBasedPP = new List<SelectOption>(structureBasedPT);
            
            if (integer.valueOf(objTerm.PAID_PERCENTAGE)< 100){
                system.debug('!!!!!objTerm.PAID_PERCENTAGE'+integer.valueOf(objTerm.PAID_PERCENTAGE));
                objNewPaymentTerms.isReceiptPresent = false;
            } else {
                objNewPaymentTerms.isReceiptPresent = true;
            }
            lstNewPaymentTermsDisplay.add(objNewPaymentTerms);
        }
        
        system.debug('blnShowSelectedUnits '+blnShowSelectedUnits);
        system.debug('blnAOPTExists '+blnAOPTExists);
        system.debug('blnShowCurrentPP '+blnShowCurrentPP);
    
    return null;
  }
  
     public void createEarlyHandoverSR(){
      system.debug('22222222'+blnPoAValue );
        system.debug('---inside createRentalPoolSR');
        errorMessage = null;
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Early Handover').getRecordTypeId();
        if(strSelectedUnit!=null && strCaseID == null){
            Case objCase = new Case();
            objCase.RecordTypeID = caseRecordTypeId;
            objCase.Booking_Unit__c = strSelectedUnit;
            objCase.AccountId = accountId;
            if(blnSubmitCase == true)
             objCase.Status = 'Submitted';
            else
             objCase.Status = 'Draft Request';
             objCase.Origin = 'Walk-In';
             objCase.Subject = 'Early Handover SR';
             objCase.Description = 'Early Handover SR';
             objCase.Mode_of_Dispatch_of_Agreement__c = 'Courier';
             objCase.Early_Handover_Status__c = 'Submitted';
             objCase.SR_Type__c = 'Early Handover SR';
             if (strTerminationDate!= null && strTerminationDate!= '')
             objCase.Termination_Date__c= date.parse(strTerminationDate);
             //if (strFinalAmount!= null && strFinalAmount!= '')
             if (securityAmount != null) {
                    objCase.Security_Cheque_Amount__c = decimal.valueOf(securityAmount);
              }
              if (strLeaseStartDate != null){
                    objCase.Lease_Commencement_Date__c = date.parse(strLeaseStartDate);
              }
              if (strLeaseEndDate != null) {
                    objCase.Lease_End_Date__c = date.parse(strLeaseEndDate);

              }

             //objCase.Final_Settlement_Amount__c = Decimal.valueOf(strFinalAmount);
             //objCase.Penalty_Amount__c = integer.valueof(strPenaltyAmount);
             //objCase.Notice_Period__c = strNoticePeriod;
             //objCase.Rental_Pool_Offer__c = 'Offer 1';
            if(blnPoAValue == true){
                objCase.POA_Issued_By__c = strPOAIssuedBy;
                objCase.POA_Name__c = strPOAName;
                if (strPOAExpiryDate != null && strPOAExpiryDate != '')
                objCase.POA_Expiry_Date__c = date.parse(strPOAExpiryDate);
                objCase.Purpose_of_POA__c = strPOARelationWithOwner;
            }
            try{
            system.debug('1111111111'+poaAttachmentBody +'**'+poaAttachmentName);
                 system.debug('1111111111'+String.isBlank( poaAttachmentBody )+'**'+blnSubmitCase+'**'+blnPoAValue );
                 system.debug('1111111111'+String.isBlank( strPOAIssuedBy)+'**'+strPOAName+'**'+strPOAExpiryDate);
             if(objCase!=null){
            if ((String.isBlank( crfAttachmentBody ) || String.isBlank( crfAttachmentName )) && blnSubmitCase == true){
                errorMessage = 'Please upload Signed CRF document. ';
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Signed CRF document.'));
            } else if (blnPoAValue == true  && poaAttach.body!=null) { //&& && String.isBlank( poaAttachmentBody ) && blnSubmitCase == true
                errorMessage = 'Please upload Power of Attorney document.';
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload Power of Attorney document'));
            } else if(blnPoAValue == true  && strPOARelationWithOwner==''){
                errorMessage = 'Please fill Power of Attorney Details.';
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Power of Attorney Details'));
            }else{
                insert objCase;
                strCaseID = objCase.ID;
             //Task For CRE To Generate CRF
             Task objTask  = new Task();
                objTask.Subject = 'Generate and Upload Signed CRF';
                objTask.WhatID = strCaseID ; 
                //objTask.OwnerId = '0050Y000001SBsP';
                objTask.status = 'In Progress';
                objTask.priority= 'Medium';
                objTask.Process_Name__C = 'Early Handover';
                objTask.Assigned_User__c = 'Legal';
             insert objTask;
                //Sent notification to Hospitality Team
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  // Step 2: Set list of people who should get the email
                     List<String> sendTo = new List<String>();
                     sendTo.add('yogeshsharma2391@gmail.com');
                     mail.setToAddresses(sendTo);

                  // Step 2. Set email contents - you can use variables!
                  mail.setSubject('Review termination request and overdues');
                  String body = 'Hello Yogesh, ';
                  body += 'Rental Pool Termination SR is created for this booking Unit:' + strSelectedUnitName;
                  body += 'Please Review termination request and overdues related to this booking unit';

                  mail.setHtmlBody(body);

                  // Step 5. Add your email to the master list
                  mails.add(mail);

                  // Step 6: Send all emails in the master list
                  Messaging.sendEmail(mails);

                if (blnSubmitCase == false)
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Early Handover SR is Created  ' + strCaseID));
                else
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Early Handover SR is Submitted  ' + strCaseID));
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
             //if (strRPEndDate != null && strRPEndDate!= '')
             //objCase.Rental_Pool_Contract_End_Date__c = date.parse(strRPEndDate);
             if (strTerminationDate!= null && strTerminationDate!= '')
             objCase.Termination_Date__c= date.parse(strTerminationDate);
             //objCase.Final_Settlement_Amount__c = Decimal.valueOf(strFinalAmount);
             objCase.Mode_of_Collection__c = 'Courier';
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
            
            /* Task objTask  = new Task();
                objTask.Subject = 'Generate and Upload Signed CRF';
                objTask.WhatID = strCaseID ; 
                objTask.OwnerId = '0050Y000001SBsP';
                objTask.status = 'In Progress';
                objTask.priority= 'Medium';
                objTask.Process_Name__C = 'Early Handover';
             insert objTask;*/
             
             /*Case objCRFCase = [Select ID, Status from Case where ID =: strCaseID];
             objCRFCase.Status = 'CRF Generated';
             update objCRFCase;*/
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
        /*if (String.isNotBlank( agreementAttachmentBody ) && String.isNotBlank( agreementAttachmentName ) && strCaseID != null && blnIsAgreementGenerated == false) {
                system.debug('inside if');
                generateAgreementDoc();
                Task objCRFTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Generate and Upload Signed Agreement'
                              and OwnerId =: '0050Y000001SBsP'
                              and WhatID =: strCaseID
                              and Process_Name__C =: 'Rental Pool Termination'];
                objCRFTask.Status = 'Completed';
                update objCRFTask;
                
                Case objAgreementCase = [Select ID, Status from Case where ID =: strCaseID];
                //objAgreementCase.Rental_Pool_Agreement_Signed__c = true;
                objAgreementCase.Status = 'Agreement Generated';
                update objAgreementCase;
                
                blnIsAgreementGenerated = true;
        }*/
        if (lstAttachment != null && lstAttachment.size()>0 && strCaseID != null) {
            createAttach();
        }
    }//end createRentalPoolSR
    
    public void createCRF() {
         if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ) {
          uploadAttachments( extractName( 'Early Handover CRF.pdf' ) , 
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
            }  else {
                objCase.Status = 'Submitted';
                if (securityAmount != null) {
                    objCase.Security_Cheque_Amount__c = decimal.valueOf(securityAmount);
                }
                if (strLeaseStartDate != null){
                    objCase.Lease_Commencement_Date__c = date.parse(strLeaseStartDate);
                }
                if (strLeaseEndDate != null) {
                    //objCase.Lease_End_Date__c = date.parse(strLeaseEndDate);
                }
                update objCase;
                createEarlyHandoverSR();
                updatePDCPP();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Early Handover SR is Submitted'));
            }
        } else {
            createEarlyHandoverSR();
            updatePDCPP();
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
     system.debug('55555555'+poaAttach);
         lstAttachment.add( poaAttach );
         /* uploadAttachments( extractName('POA.pdf') ,
                    extractBody( poaAttachmentBody ) , 
                    strCaseID ,
                    'POA' );*/
    }//end generatePoADoc
    
    /*public void generateAgreementDoc(){
          uploadAttachments( extractName('Rental Pool Agreement.pdf') ,
                    extractBody( agreementAttachmentBody ) , 
                    strCaseID ,
                    'Agreement' );
    }*///end generateAgreementDoc
    
     public void uploadAttachments( String strfileName, Blob objBody, Id parentId, String strType ) {
      
      objAttach = new Attachment() ;
      objAttach.Body = objBody ;
      objAttach.Name = strType + strfileName ;
      objAttach.ParentId = parentId ;
      lstAttachment.add( objAttach );
    }//end uploadAttachments
    
    private String extractName( String strName ) {
      return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    
    private Blob extractBody( String strBody ) {
      //strBody = EncodingUtil.base64Decode( strBody ).toString();
      //return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
      return Blob.valueOf(strBody.substring( strBody.lastIndexOf(',')+1 ) );
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
    
    
    private void updateCustomAttachment( list<Attachment> lstAttachment, list<SR_Attachments__c> lstCustomAttachment ) {
      integer counter = 0;
      for( Attachment objAttach : lstAttachment ) {
      SR_Attachments__c objCustAttach = lstCustomAttachment[ counter ];
          objCustAttach.Attachment__c = objAttach.Id ;
          String strType = objAttach.Name.subString( 0, 3);
          objCustAttach.isValid__c = true;
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
    
    public void addNewInstallment()
  {

    Integer counter = 1;

    for(integer i=0 ; i < lstNewPaymentTermsDisplay.size() ; i++)
    {
      if(i > 0)
      {
        lstNewPaymentTermsDisplay[i].installment = 'I00'+i;
        if(i == 1)
        {
          lstNewPaymentTermsDisplay[i].description = i+'ST INSTALLMENT';
        }
        else if(i == 2)
        {
          lstNewPaymentTermsDisplay[i].description = i+'ND INSTALLMENT';
        }
        else if(i == 3)
        {
          lstNewPaymentTermsDisplay[i].description = i+'RD INSTALLMENT';
        }
        else
        {
          lstNewPaymentTermsDisplay[i].description = i+'TH INSTALLMENT';
        }
        counter ++;
      }
    }
    // creating new object of wrapper to add new Payment Term
    SelectedNewPaymentTermsByCRE objNewPaymentTermWrapper = new SelectedNewPaymentTermsByCRE();
    if(counter == 1)
    {
      objNewPaymentTermWrapper.description = counter+'ST INSTALLMENT';
    }
    else if(counter == 2)
    {
      objNewPaymentTermWrapper.description = counter+'ND INSTALLMENT';
    }
    else if(counter == 3)
    {
      objNewPaymentTermWrapper.description = counter+'RD INSTALLMENT';
    }
    else
    {
      objNewPaymentTermWrapper.description = counter+'TH INSTALLMENT';
    }        
        //objNewPaymentTermWrapper.name = 'Structure Based Payment Plan';
        objNewPaymentTermWrapper.Id = '';
        objNewPaymentTermWrapper.installment = 'I00'+counter;
        objNewPaymentTermWrapper.mileStoneEvent = 'On Or Before Due Date';
        objNewPaymentTermWrapper.percentValue = '10';
        //Date todayDate = Date.today();
        //objNewPaymentTermWrapper.paymentDate = Date.today();
        objNewPaymentTermWrapper.paymentDate = String.valueOf( Date.today());
        
        objNewPaymentTermWrapper.isReceiptPresent = false;
        objNewPaymentTermWrapper.lstStructureBasedPP = new List<SelectOption>(structureBasedPT);
        //objNewPaymentTermWrapper.lstStructureBasedPercent = new List<SelectOption>(structureBasedPercent);
        lstNewPaymentTermsDisplay.add(objNewPaymentTermWrapper);
    
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
    public void insertAdditionalDocument(){
        try{
          //insertDocuments(lstAdditionalDocs);
          //blnSectionThree = true;
          //createJointBuyers();
          //fetchInsertedDocs();
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
    }
        public void addAdditionalDocument(){
        Integer currentSize = lstAdditionalDocs.size()+1;
        docInfo objWrap = new docInfo();
        objWrap.strType = 'Supporting Document '+currentSize;
        objWrap.objAttachment = new Attachment();
        objWrap.strRequired = 'No';
        objWrap.blnIsValid = false;
        lstAdditionalDocs.add(objWrap);
    }
        public void skipAdditionalDocs(){
        //blnSectionThree = true;
        //createJointBuyers();
    }
    
    public void removeInstallment()
  {
    system.debug('rowToRemove '+rowToRemove);
    
    lstNewPaymentTermsDisplay.remove(integer.valueOf(rowToRemove));
    for(integer i=0 ; i < lstNewPaymentTermsDisplay.size() ; i++)
    {
      if(i > 0)
      {
        lstNewPaymentTermsDisplay[i].installment = 'I00'+i;
        if(i == 1)
        {
          lstNewPaymentTermsDisplay[i].description = i+'ST INSTALLMENT';
        }
        else if(i == 2)
        {
          lstNewPaymentTermsDisplay[i].description = i+'ND INSTALLMENT';
        }
        else if(i == 3)
        {
          lstNewPaymentTermsDisplay[i].description = i+'RD INSTALLMENT';
        }
        else
        {
          lstNewPaymentTermsDisplay[i].description = i+'TH INSTALLMENT';
        }
      }
    }
  }
   public class docInfo {
        public Attachment objAttachment {get;set;}
        public String strType {get;set;}
        public String strRequired {get;set;}
        public boolean blnIsValid {get;set;}
        
        public docInfo(){
            
        }
    } // end of docInfo
    
    public class SelectedNewPaymentTermsByCRE {
        public String installment {get;set;}
        public String Id {get;set;}
        public Boolean isReceiptPresent {get;set;}
        public String description {get;set;}
        public String mileStoneEvent {get;set;}
        public String percentValue {get;set;}
        //public Date paymentDate {get;set;}
        public String paymentDate {get;set;}
        public String name {get;set;}
        public List<SelectOption> lstStructureBasedPercent {get;set;}
        public List<SelectOption> lstStructureBasedPP {get;set;}
    }
}