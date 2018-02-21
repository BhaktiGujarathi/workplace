/*
Created By : Swapnil Gholap
Use : Controller of 'CRE_Refund_Component'
*/
public class CRE_Refund_Component_Controller {
    public String strAccountID {get;set;}
    public List<Account> lstAccount ;
    public List<Booking_Unit__c> lstBookingUnit {get;set;}
    //public List<wrapper> lstWrapper {get;set;}
    public boolean blnShowRefundSection {get;set;}
    public String strSelectedRefundProcess{get;set;}
    public blob fileBody {get;set;}
    public List<WrapperBookingUnit> lstWrapperBookingUnit{get;set;}
    public Map<String,WrapperBookingUnit> mapWrapperBookingUnit;
    public WrapperBookingUnit objWrapperBookingUnit {get;set;}
    public String strSelectedBookingUnit {get;set;}
    public String strSelectedAccount {get;set;}
    public Case objCase {get;set;}
    public List<Case> lstCase ;
    public List<SR_Booking_Unit__c> lstSRbookingUnit;
    public boolean blnShowBookingUnit {get;set;}
    public boolean blnShowGetRefundBtn {get;set;}
    public boolean blnShowRefundDetails {get;set;}
    public List<SelectOption> lstBookingUnitOptions {get;set;} 
    public List<SelectOption> lstAccountOptions {get;set;} 
    //public List<SelectOption> lstBookingUnitOptions;
    public String strSelectedSection {get;set;}
    public boolean blnShowRefundValues {get;set;}
    public decimal decRefundAmount {get;set;}
    public decimal decExcessAmount {get;set;}
    public decimal decTokenDeposit {get;set;}
    //public String showPowerOfAttorny {get;set;}
    public boolean blnShowNOCdocumentUpload{get;set;}
    private string strCaseID {get;set;}
    public List<SR_Attachments__c> lstSRattachments {get;set;}
    public List<SR_Attachments__c> lstSRattachmentsAll ;
    private List<Attachment> lstAttachment ;
    public String strTypeOfDoc{get;set;}
    public String RemoveSelected {get;set;}
    public boolean blnShowPowerOfAttornyAttachment {get;set;}
    public boolean blnShowNOCattachment {get;set;}
    public boolean blnShowCRFattachment {get;set;}
    private List<SR_Attachments__c> lstPwrAttornyAtt;
    public boolean blnDisableSubmitSRbtn {get;set;}
    public boolean blnShowNOCdataError {get;set;}
    // public boolean blnInValidFiles {get;set;}
    public boolean blnURC_SPA_singed {get;set;}
    public String ExpectedCloseDate{get;set;}
    public Boolean blnIsLitigationFlag {get; set;}
    public String soaUrl {get; set;}
    public transient String crfAttachmentName { get; set; }
    public transient String crfAttachmentBody { get; set; }
    public transient String NocAttachmentName { get; set; }
    public transient String NocAttachmentBody { get; set; }
    public transient String POAAttachmentName { get; set; }
    public transient String POAAttachmentBody { get; set; }
    private Attachment objAttach;  
    public String strPOAExpiryDate {get; set;}
    private boolean blnActiveUnit ;
    private boolean blnBulkDealUnits ;
    private List<Case> lstAllOpenCases;
    public List<Case> lstOpenCasesBU {get;set;}
    public List<Case> lstClosedCasesBU {get;set;}
    private Map<String,String> mapCases ;
    private List<String> lstInactiveStatus;
    private Set <String> setInactiveStatus;
    private String strInactiveUnitIds;  
    private Map<ID,List<Case>> mapOpenSR;
    private Map<ID,List<Case>> mapClosedSR;
    private boolean blnAllowSRInitiation ;
    private map<String,booking_unit__c> mapBookingUnit;
    
    public CRE_Refund_Component_Controller() {
        lstAccountOptions = new List<SelectOption>();
        lstAccountOptions.add(new SelectOption('','--None--' ));    
        
        for(Account objAcc : [Select id,name from Account where name =: 'Swapnil Gholap']){
                                
            lstAccountOptions.add(new SelectOption
                (objAcc.id,objAcc.Name ));
        }
        strAccountID = ApexPages.currentPage().getParameters().get('accID');
        if(String.isNotBlank(strAccountID)){
            Account objAcc = new Account();
            objAcc = [Select id from Account where id=:strAccountID];
            if(objAcc != null){
                strSelectedAccount = objAcc.id;
                init();
            }
        }
        strCaseID = ApexPages.currentPage().getParameters().get('caseID');
        
    }
    
    
    
    public void init(){
        if(String.isNotBlank(strSelectedAccount)){
            blnShowRefundSection = true;
            lstAccount = new List<Account>();
            lstCase = new List<Case>();
            lstSRattachments = new List<SR_Attachments__c>();
            lstBookingUnitOptions = new List<SelectOption>();
            mapBookingUnit = new map<String,booking_unit__c>();       
            
            strAccountID = strSelectedAccount;
            System.debug('---strAccountID 1--'+strAccountID+'--strSelectedAccount--'+strSelectedAccount);
            //if(String.isBlank(strAccountID)){
            //    strAccountID = ApexPages.currentPage().getParameters().get('accID');
            //}       
            //System.debug('---strAccountID 2--'+strAccountID );
            strCaseID = ApexPages.currentPage().getParameters().get('caseID');
            System.debug('--CRE_Refund_Component_Controller---'+strAccountID);       
            lstPwrAttornyAtt = new List<SR_Attachments__c>();
            blnShowPowerOfAttornyAttachment = false;
            blnShowNOCattachment = false;
            blnShowCRFattachment = false;
            blnShowNOCdataError = false;
            lstAllOpenCases = new List<Case>();        
            //blnInValidFiles = false;
            blnActiveUnit = false;
            blnBulkDealUnits = true;
            objCase = new Case();
            lstInactiveStatus = new List<String>();
            mapCases = new Map<String,String>();
            setInactiveStatus = new Set<String>();
            decTokenDeposit = 0;
            decExcessAmount = 0;
            soaUrl = '';
            
            String strInactiveStatus = System.Label.Booking_Unit_Inactive_Registration_Status;
            if(String.isNotBlank(strInactiveStatus)){
                lstInactiveStatus = strInactiveStatus.split(',');
                setInactiveStatus.addAll(lstInactiveStatus);
            }
            System.debug('--lstInactiveStatus--'+lstInactiveStatus.Size()+'--'+lstInactiveStatus);
            System.debug('--strCaseID---'+strCaseID);             
            if(String.isNotBlank(strCaseID)){
                
                lstCase = [Select id,RecordType.name,POA_Name__c,Status,SR_Type__c,
                           POA_Relationship_with_Buyer__c,POA_Expiry_Date__c ,POA_Issued_By__c, Power_of_Attorney__c,
                           Purpose_of_POA__c,Total_Token_Amount__c,Excess_Amount__c,
                           (select id,SR__c,Booking_Unit__c
                           from SR_Booking_Units__r),
                           (Select id,name,SR__c,View__c,Attachment__c,type__c,Case__r.CaseNumber,isValid__c
                           from SR_Attachments__r)
                           from Case where id =: strCaseID ];
                System.debug('--lstCase --'+lstCase .Size()+'--'+lstCase );
                if(lstCase.Size()>0){
                    objCase = lstCase[0];
                    decTokenDeposit = lstCase[0].Total_Token_Amount__c;
                    decExcessAmount = lstCase[0].Excess_Amount__c;
                    if(lstCase[0].POA_Expiry_Date__c != null){
                        strPOAExpiryDate = objCase.POA_Expiry_Date__c.format();                   
                    }                
                }
                
            }
            
            objWrapperBookingUnit = new WrapperBookingUnit();
            
            lstSRbookingUnit = new List<SR_Booking_Unit__c>();
            blnShowBookingUnit = false;
            blnShowGetRefundBtn = false;
            blnShowRefundDetails = false;
            blnShowRefundValues = false;
            //lstWrapper = new List<Wrapper>();
            
            if(String.isNotBlank(strAccountID)){
                lstAccount = [SELECT Id, Name, LastName, FirstName, Salutation, MiddleName,
                              IsPersonAccount,phone,PersonEmail,PersonMobilePhone
                              FROM Account where id =: strAccountID];
                if(lstAccount.Size()>0){                       
                    lstBookingUnit = new List<Booking_Unit__c>();
                    lstBookingUnit = [Select id,name,Property_Name__c,Inventory__c,
                                      Inventory__r.Property__r.Name,
                                      Booking_Unit_Type__c, Inventory__r.Property_Status__c,
                                      Registration_ID__c, Inventory__r.Property_Name_2__c,
                                      Inventory__r.Unit__c, Inventory__r.ACD_Date__c, Unit_Selling_Price_AED__c,
                                      Unit_Details__c,Inventory__r.Construction_Status__c,
                                      Registration_Status__c,Inventory_Area__c ,
                                      Inventory__r.Property_City__c,Inventory__r.Bedroom_Type__c,Inventory__r.Unit_Type__c,
                                      Permitted_Use__c,Unit_Selling_Price__c,Booking_Type__c,Plot_Price__c,
                                      Booking__r.CreatedDate,Agreement_Date__c,Inventory__r.Unit_Plan__c,
                                      Inventory__r.Floor_Plan__c,JOPD_Area__c,DP_OK__c,Doc_OK__c,OQOOD_Reg_Flag__c,
                                      Early_Handover__c,Handover_Flag__c,PCC_Release__c,Area_Varied__c,
                                      Mortgage__c,Booking__r.Account__r.Nationality__c, Inventory__r.Building_Code__c                                
                                      from Booking_Unit__c where Booking__r.Account__c =:
                                      strAccountID AND Registration_ID__c != null
                                      Order By Inventory__r.Property__r.Name ASC ];
                    
                    System.debug('--lstBookingUnit---'+lstBookingUnit.Size()+'---'+lstBookingUnit);
                    List<String> lstBookingUnitID = new List<String>();
                    if(lstBookingUnit.Size()>0){               
                        lstBookingUnitOptions.add(new SelectOption
                                                     ('','--None--' ));
                        for(Booking_Unit__c objBookingUnit : lstBookingUnit){
                            //lstWrapper.add(new wrapper(false,objBookingUnit));
                            lstBookingUnitOptions.add(new SelectOption
                                                     (objBookingUnit.id,objBookingUnit.Unit_Details__c ));
                            mapBookingUnit.put(objBookingUnit.id,objBookingUnit);
                            lstBookingUnitID.add(objBookingUnit.id);                         
                            
                        }
                        
                        mapOpenSR = new Map<ID,List<Case>>();                  
                        mapOpenSR = OpenSRutility.getOpenSR(lstBookingUnitID,strCaseID);
                        System.debug('--mapOpenSR--'+mapOpenSR.Size()+'---'+mapOpenSR);        
    
                        mapClosedSR = new Map<ID,List<Case>>();                  
                        mapClosedSR = OpenSRutility.getClosedSR(lstBookingUnitID,strCaseID);
                        System.debug('--mapClosedSR--'+mapClosedSR.Size()+'---'+mapClosedSR);   
                        
                        
                    }
                    if(lstCase.Size()>0){
                        strSelectedRefundProcess = lstCase[0].RecordType.name;
                        lstSRattachments = lstCase[0].SR_Attachments__r;
                        System.debug('--lstSRattachments ---'+lstSRattachments );   
                        lstSRbookingUnit = lstCase[0].SR_Booking_Units__r;
                        if(lstSRbookingUnit.Size()>0){
                            strSelectedBookingUnit = lstSRbookingUnit[0].booking_unit__c;
                        }
                        blnShowPowerOfAttornyAttachment = checkAttachmentType('Power Of Attorney');
                        blnShowNOCattachment = checkAttachmentType('NOC');
                        blnShowCRFattachment = checkAttachmentType('CRF Form');             
                        
                        /*for(wrapper w : lstWrapper){
                            for(SR_Booking_Unit__c bou : lstCase[0].SR_Booking_Units__r){
                                if(w.WBU.id == bou.Booking_Unit__c){
                                    w.Wselected = true;
                                    break;
                                }
                            }
                        }*/
                        bookingUnitDetails();
                        blnShowRefundValues = true;
                        showDocumentError();
                       
                    }
                }
            }
            System.debug('--CRE_Refund_Component_Controller-2--'+strAccountID);
        
        }
        else{
            blnShowRefundSection = false;
            blnDisableSubmitSRbtn = true;
            blnShowGetRefundBtn = false;
            blnShowRefundValues = false;
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'Please select a customer'));
        }
    }
    
    
    // Check attachment type and its presence
    private boolean checkAttachmentType(string strDocType){
        boolean blnShow = false;       
        for(SR_Attachments__c sr : lstSRattachments ){
            System.debug('---sr--'+sr);
            if(sr.Type__c == strDocType){
                blnShow = true;
                break;
            }
            else if(strDocType == 'DisableCheck' && sr.isValid__C == false){               
                blnShow = true;
                break;
            }                      
        }
        
        return blnShow ;
    }
    
    // delete related attachment if Power of Attorney is not selected
    public void deletePowerAttornyDoc(){
        blnShowNOCdataError = false;
        if(String.isNotBlank(strCaseID) && objCase.Power_of_Attorney__c == 'No'){
            
            lstPwrAttornyAtt = [Select id from SR_Attachments__c
                                where type__c=: 'Power of Attorney' AND  Case__c =: strCaseID];
            if(lstPwrAttornyAtt.Size()>0){
                delete lstPwrAttornyAtt;
                lstSRattachments = [Select id,name,SR__c,View__c,Attachment__c,type__c,Case__r.CaseNumber,isValid__c
                                    from SR_Attachments__c  where Case__c =: strCaseID];            
                
                objCase.POA_Expiry_Date__c = null;
                objCase.POA_Name__c= '';
                objCase.POA_Relationship_with_Buyer__c= '';
                objCase.POA_Issued_By__c= '';
                objCase.Purpose_of_POA__c = '';
            }                                
        }
        else if(objCase.Power_of_Attorney__c == 'Yes'){
            blnShowPowerOfAttornyAttachment = false;
            objCase.POA_Expiry_Date__c = null;
            objCase.POA_Name__c= '';
            objCase.POA_Relationship_with_Buyer__c= '';
            objCase.POA_Issued_By__c= '';
            objCase.Purpose_of_POA__c = '';
            
        }
        showDocumentError();
        
    }
    
    // for checking booking unit is selected or not
    /*private boolean RecordSelection(){
        boolean checkSelected = false;
        for(Wrapper w : lstWrapper){
            if(w.Wselected){
                checkSelected = true;
                break;
            }
        }
        return checkSelected;
    }*/
    
    // IPMS call to get unit details
    public void bookingUnitDetails(){
        System.debug('---strSelectedRefundProcess--'+strSelectedRefundProcess);
        blnShowNOCdataError = false;  
        blnShowRefundDetails = false;
        blnShowRefundValues = false;
        System.debug('--CRE_Refund_Component_Controller- 3--'+strAccountID);
        decRefundAmount = 0;
        //decExcessAmount = 0;
        //decTokenDeposit = 0;
        blnShowNOCdocumentUpload = false;
        blnShowBookingUnit = false;
        blnShowGetRefundBtn = false;
        blnURC_SPA_singed = false;
        blnIsLitigationFlag = false;
        blnActiveUnit = false;
        strInactiveUnitIds = '';
        blnAllowSRInitiation = true;
        
        if(String.isNotBlank(strSelectedRefundProcess)){
            if(String.isBlank(strSelectedBookingUnit)){
                ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'Please select a booking unit'));
                //PageMessages.addMessage(new PageMessages.PageMessage(PageMessages.Severity.Error, 'Please select atleast one booking unit'));
            }
            else{
                lstWrapperBookingUnit = new List<WrapperBookingUnit>();
                                
                integer intCounter = 0;
                blnShowBookingUnit = true;
                blnShowGetRefundBtn = true;
                mapWrapperBookingUnit = new Map<String,WrapperBookingUnit>();
                               
                Booking_unit__c objBookingUnit = new Booking_unit__c();
                if(mapBookingUnit.containsKey(strSelectedBookingUnit)){
                    objBookingUnit = mapBookingUnit.get(strSelectedBookingUnit);
                    //if(w.Wselected){
                        WrapperBookingUnit objWrb = new WrapperBookingUnit();
                        intCounter++;
                        //lstBookingUnitID.add(objBookingUnit.id);
                        //UnitDetailsService.BookinUnitDetailsWrapper objIPMSDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
                        try{
                            objWrb.objIPMSDetailsWrapper = UnitDetailsService.getBookingUnitDetails( objBookingUnit.Registration_ID__c );
                        }
                        catch(exception ex){
                             ApexPages.addMessage(new ApexPages.message(
                             ApexPages.severity.ERROR,ex.getMessage()));
                        }
                        //objWrb.objIPMSDetailsWrapper = objIPMSDetailsWrapper;
                        System.debug('--objWrb.objIPMSDetailsWrapper--'+objWrb.objIPMSDetailsWrapper);                       
                        if(objWrb.objIPMSDetailsWrapper != null){
                            objWrb.intNumber = intCounter;
                            objWrb.objBookingUnit  = objBookingUnit;                            
                            //objWrb.strRentalPool = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strRentalPool) && objWrb.objIPMSDetailsWrapper.strRentalPool != 'null') ? objWrb.objIPMSDetailsWrapper.strRentalPool : '';
                            objWrb.blnDispute = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strDispute) && objWrb.objIPMSDetailsWrapper.strDispute != 'null' && objWrb.objIPMSDetailsWrapper.strDispute.Contains('Y')) ? true: false;
                            objWrb.blnEnforcement = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strEnforcement) && objWrb.objIPMSDetailsWrapper.strEnforcement != 'null' && objWrb.objIPMSDetailsWrapper.strEnforcement.Contains('Y')) ? true: false;
                            objWrb.blnLitigation = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strLitigation) && objWrb.objIPMSDetailsWrapper.strLitigation != 'null' && objWrb.objIPMSDetailsWrapper.strLitigation.Contains('Y')) ? true: false; 
                            objWrb.blnCourtCase = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strCounterCase) && objWrb.objIPMSDetailsWrapper.strCounterCase != 'null' && objWrb.objIPMSDetailsWrapper.strCounterCase.Contains('Y')) ? true: false; 
                            
                            objWrb.blnFTLsent = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strFTLSent) && objWrb.objIPMSDetailsWrapper.strFTLSent != 'null' && objWrb.objIPMSDetailsWrapper.strFTLSent.Contains('Y')) ? true: false; 
                            //objWrb.strAgreementStatus = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strAgreementStatus) && objWrb.objIPMSDetailsWrapper.strAgreementStatus != 'null') ? objWrb.objIPMSDetailsWrapper.strAgreementStatus : '';
                            //objWrb.strUnderTermination = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strUnderTermination) && objWrb.objIPMSDetailsWrapper.strUnderTermination != 'null') ? objWrb.objIPMSDetailsWrapper.strUnderTermination : ''; 
                            objWrb.bln_URC_SPA = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strSPASigned) && objWrb.objIPMSDetailsWrapper.strSPASigned != 'null' && objWrb.objIPMSDetailsWrapper.strSPASigned.Contains('Y')) ? true: false; 
                            if(objWrb.bln_URC_SPA){
                                blnURC_SPA_singed = true;                           
                            }                            
                            //objWrb.strDealStatus = 'Pending'; // ****?   
                            //objWrb.strDefault = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strDefault) && objWrb.objIPMSDetailsWrapper.strDefault != 'null' && objWrb.objIPMSDetailsWrapper.strDefault != 'Y') ? 'Yes' : 'No'; 
                            //objWrb.strIDavailable = 'Yes'; // ****?   
                            //objWrb.intNoOfBookingDay = intCounter * 10; // ****?  
                            //objWrb.intNoOfDefaulted =  (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strNoOfTimesCustomerDefaultedOnInstalments) && objWrb.objIPMSDetailsWrapper.strNoOfTimesCustomerDefaultedOnInstalments != 'null') ? integer.ValueOf(objWrb.objIPMSDetailsWrapper.strNoOfTimesCustomerDefaultedOnInstalments):0 ;
                            //objWrb.intOverdue = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strOverdue) && objWrb.objIPMSDetailsWrapper.strOverdue != 'null') ? integer.ValueOf(objWrb.objIPMSDetailsWrapper.strOverdue):0 ;
                            //objWrb.intPenaltyOverdue = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strPenalty_Overdues) && objWrb.objIPMSDetailsWrapper.strPenalty_Overdues != 'null') ? integer.ValueOf(objWrb.objIPMSDetailsWrapper.strPenalty_Overdues):0 ;   
                            //objWrb.decDuesServiceCharges = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strOverdues_DuesTowardsServiceCharges) && objWrb.objIPMSDetailsWrapper.strOverdues_DuesTowardsServiceCharges != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strOverdues_DuesTowardsServiceCharges):0 ;  
                            //objWrb.decRERAstatus = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strReraConstructionStatus) && objWrb.objIPMSDetailsWrapper.strReraConstructionStatus != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strReraConstructionStatus):0 ; 
                            //objWrb.decPaidPercentage = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strPaidPercent) && objWrb.objIPMSDetailsWrapper.strPaidPercent != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strPaidPercent):0 ;  
                            //objWrb.decDefaultPercentage = 10; // ****?
                            //objWrb.decPenaltyWaiver = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strPenaltyWaivers_PortfolioLevel) && objWrb.objIPMSDetailsWrapper.strPenaltyWaivers_PortfolioLevel != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strPenaltyWaivers_PortfolioLevel):0 ;  
                            //objWrb.decLatePaymentFees = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strPenalties_LatePaymentFeeOnServiceCharges) && objWrb.objIPMSDetailsWrapper.strPenalties_LatePaymentFeeOnServiceCharges != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strPenalties_LatePaymentFeeOnServiceCharges):0 ;  
                            //objWrb.strPromotionScheme  = 'Promotion';// ****?
                            //objWrb.strInvoicesRaised = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strInvoicesRaised) && objWrb.objIPMSDetailsWrapper.strInvoicesRaised != 'null') ? objWrb.objIPMSDetailsWrapper.strInvoicesRaised : '';  
                            //objWrb.decAmountPaid = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strAmountPaid) && objWrb.objIPMSDetailsWrapper.strAmountPaid != 'null') ? decimal.ValueOf(objWrb.objIPMSDetailsWrapper.strAmountPaid):0 ; 
                            //objWrb.strDealTeam = 'Damac Team'; //****?
                            //objWrb.strPaymentPlan = '';//****?
                            objWrb.blnRegistrationFeePaid = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strRegistrationFeePaid) && objWrb.objIPMSDetailsWrapper.strRegistrationFeePaid != 'null' && objWrb.objIPMSDetailsWrapper.strRegistrationFeePaid.Contains('Y')) ? true: false; 
                            //objWrb.strPRCStatus = (String.isNotBlank(objWrb.objIPMSDetailsWrapper.strPRCStatus) && objWrb.objIPMSDetailsWrapper.strPRCStatus != 'null') ? objWrb.objIPMSDetailsWrapper.strPRCStatus : ''; 
                            
                            //objWrb.blnMortage = true; // ****?                       
                            if(objWrb.objBookingUnit.Mortgage__c){
                                blnShowNOCdocumentUpload = true;
                            }                                
                            if((objWrb.blnDispute || objWrb.blnEnforcement
                                 || objWrb.blnLitigation || objWrb.blnCourtCase)
                                 && blnIsLitigationFlag == false  ){
                                 
                                blnIsLitigationFlag = true;
                            }
                        }
                        else{
                            blnDisableSubmitSRbtn = true;
                            blnShowGetRefundBtn = false;
                            blnShowRefundValues = false;
                            ApexPages.addMessage(new ApexPages.message(
                            ApexPages.severity.ERROR,'Problems while getting Booking Unit Details'));
                        }
                        
                        
                        //objWrb.strRegId = objBookingUnit.Registration_Id__c;Is_Mortgage_Unit__c
                        //objWrb.strUnit = objBookingUnit.Inventory__r.Unit__c;
                        //objWrb.strProject = objBookingUnit.Inventory__r.Property__r.Name;
                        //objWrb.strProjectCity = objBookingUnit.Inventory__r.Property_City__c;
                        //objWrb.strBedroomType = objBookingUnit.Inventory__r.Bedroom_Type__c;
                        //objWrb.strUnitType = objBookingUnit.Inventory__r.Unit_Type__c;
                        //objWrb.strPermittedUse = objBookingUnit.Permitted_Use__c;
                        //objWrb.strReady_OffPlan = objBookingUnit.Inventory__r.Property_Status__c;
                        //objWrb.blnEHO = objBookingUnit.Early_Handover__c;
                        //objWrb.strHandoverFlag = objBookingUnit.Handover_Flag__c;
                        //objWrb.blnDOCOK = objBookingUnit.Doc_OK__c;
                        //objWrb.blnDPOK = objBookingUnit.DP_OK__c;                    
                        //objWrb.blnPCC = objBookingUnit.PCC_Release__c;
                        //objWrb.blnOQOODregistered = objBookingUnit.OQOOD_Reg_Flag__c;
                                             
                        
                        //objWrb.intArea = objBookingUnit.Inventory_Area__c != null ? Integer.valueOf(objBookingUnit.Inventory_Area__c) : null;
                        //objWrb.decPrice = objBookingUnit.Unit_Selling_Price__c;
                        
                        //objWrb.strBookingType = objBookingUnit.Booking_Type__c;
                     
                        //objWrb.strStatementofAccount = 'SOA-'+intCounter; //****?
                        //objWrb.strUnitPlan = objBookingUnit.Inventory__r.Unit_Plan__c;
                        //objWrb.strFloorPlan = objBookingUnit.Inventory__r.Floor_Plan__c;                      
                        //objWrb.strFJOPDArea = objBookingUnit.JOPD_Area__c;
                        //objWrb.decBuiltUpPrice  = objBookingUnit.Plot_Price__c;
                        objWrb.dateBookingDate = objBookingUnit.Booking__r.CreatedDate.Date();
                        objWrb.dateAgreementDate = objBookingUnit.Agreement_Date__c;
                    
                        //lstBookingUnitOptions.add(new SelectOption
                        //                          (w.WBU.id,w.WBU.Unit_Details__c ));                        
                        
                        lstWrapperBookingUnit.add(objWrb);                        
                        
                        mapWrapperBookingUnit.put(objBookingUnit.id,objWrb);
                        
                        strSelectedSection= 'Unit Details';
                        objWrapperBookingUnit = objWrb;
                        System.debug('---objWrapperBookingUnit--'+objWrapperBookingUnit);
                        blnShowRefundDetails = true;                        
                        lstOpenCasesBU = new List<Case>();            
                        if(mapOpenSR.Size()>0){
                            if(mapOpenSR.ContainsKey(strSelectedBookingUnit)){
                                lstOpenCasesBU = mapOpenSR.get(strSelectedBookingUnit);
                               
                                Set<String> setSRInitiationRecordType = new Set<String>();
                                setSRInitiationRecordType.add('AOPT');
                                setSRInitiationRecordType.add('Assignment');
                                setSRInitiationRecordType.add('Bounced_Cheque_SR');
                                setSRInitiationRecordType.add('Change_of_Details');
                                setSRInitiationRecordType.add('Customer_Refund');
                                setSRInitiationRecordType.add('Token_Refund');
                                setSRInitiationRecordType.add('Rental_Pool_Assignment');                                
                                
                                blnAllowSRInitiation = OpenSRutility.validateSRInitiation(setSRInitiationRecordType,lstOpenCasesBU,strCaseID);
                                
                                System.debug('--blnAllowSRInitiation --'+blnAllowSRInitiation );
                    
                            }
                        }
                        System.debug('---lstOpenCasesBU--'+lstOpenCasesBU.Size()+'---'+lstOpenCasesBU);
                        
                        lstClosedCasesBU = new List<Case>();            
                        if(mapClosedSR.Size()>0){
                            if(mapClosedSR.ContainsKey(strSelectedBookingUnit)){
                                lstClosedCasesBU = mapClosedSR.get(strSelectedBookingUnit);
                            }
                        }
                        System.debug('---lstClosedCasesBU--'+lstClosedCasesBU.Size()+'---'+lstClosedCasesBU);
                        
                        
                        //decRefundAmount +=  (objWrb.decPrice/2);
                        //decExcessAmount +=  (objWrb.decPrice/2);
                        //decTokenDeposit +=  (objWrb.decPrice/2);
                        
                        if(lstInactiveStatus.Size()>0){                            
                            if(!setInactiveStatus.Contains(objBookingUnit.Registration_Status__c)){
                                blnActiveUnit = true;
                                strInactiveUnitIds += objBookingUnit.id+',';
                            }
                                       
                        }
                        System.debug('---objBookingUnit.Registration_Status__c----'+objBookingUnit.Registration_Status__c);
                        System.debug('---blnActiveUnit---'+blnActiveUnit);
                        System.debug('---strInactiveUnitIds---'+strInactiveUnitIds);
                    //}
                }
                
                
                //blnAllowSRInitiation = true;               
                /*if(lstBookingUnitID.Size()>0){
                                      
                    mapOpenSR = OpenSRutility.getOpenSR(lstBookingUnitID,strCaseID);
                    System.debug('--mapOpenSR--'+mapOpenSR.Size()+'---'+mapOpenSR);                    
                    if(mapOpenSR.Size()>0){
                        Set<String> setSRInitiationRecordType = new Set<String>();
                        setSRInitiationRecordType.add('AOPT');
                        setSRInitiationRecordType.add('Assignment');
                        setSRInitiationRecordType.add('Bounced_Cheque_SR');
                        setSRInitiationRecordType.add('Change_of_Details');
                        setSRInitiationRecordType.add('Customer_Refund');
                        setSRInitiationRecordType.add('Token_Refund');
                        setSRInitiationRecordType.add('Rental_Pool_Assignment');
                        blnAllowSRInitiation = OpenSRutility.validateSRInitiation(setSRInitiationRecordType,mapOpenSR.Values(),strCaseID);
                    }
                }*/
                /*if(lstWrapperBookingUnit.Size()>0){                    
                    strSelectedBookingUnit = lstWrapperBookingUnit[0].objBookingUnit.id;                                    
                    showBookingUnitInfo();
                }*/
                
                //decRefundAmount = (decRefundAmount/3).setScale(3);
                //decExcessAmount = (decExcessAmount/2).setScale(3);
                //decTokenDeposit = (decTokenDeposit/2).setScale(3);
                
                if(!blnAllowSRInitiation){
                    ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.ERROR, 'Open SR present against selected booking unit'));
                    blnDisableSubmitSRbtn = true;
                    blnShowGetRefundBtn = false;
                    blnShowRefundValues = false;
                }
                if(strSelectedRefundProcess == 'Token Refund' ){
                    blnShowNOCdocumentUpload = false; 
                    if(blnURC_SPA_singed ){
                        ApexPages.addmessage(new ApexPages.message(
                        ApexPages.severity.ERROR, 'URC/SPA signed by Customer so cannot Refund Token Amount'));
                        
                        blnDisableSubmitSRbtn = true;
                        blnShowGetRefundBtn = false;
                        blnShowRefundValues = false;
                    }
                }
                
                if(blnIsLitigationFlag){
                    ApexPages.addMessage(new ApexPages.message(
                    ApexPages.severity.ERROR,'Litigation flag has been raised for the selected unit'));
                    
                    blnShowGetRefundBtn = false;
                    blnShowRefundValues = false;
                }
             
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Error,'Please select Type of Refund'));
        }
    }
    
    // document errors showing here
    private void showDocumentError(){
        blnDisableSubmitSRbtn = false;
        if(objCase.Power_of_Attorney__c == 'Yes' && !blnShowPowerOfAttornyAttachment ){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Warning,'POA has not been uploaded'));            
            blnDisableSubmitSRbtn = true;
        }
        if(blnShowNOCdocumentUpload && !blnShowNOCattachment  ){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Warning,'NOC has not been uploaded'));
            
            blnDisableSubmitSRbtn = true;
        }
        if(!blnShowCRFattachment){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Warning,'CRF has not been uploaded'));
            
            blnDisableSubmitSRbtn = true;
        }
        if(!blnAllowSRInitiation){
            blnDisableSubmitSRbtn = true;
            blnShowGetRefundBtn = false;
            blnShowRefundValues = false;
        }
        
        /*if(blnInValidFiles){
ApexPages.addmessage(new ApexPages.message(
apexPages.severity.Warning,'All uploaded files should be validated'));
blnDisableSubmitSRbtn = true;
} */
        if(strSelectedRefundProcess == 'Token Refund' && blnURC_SPA_singed ){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Warning,'URC/SPA has been signed by the customer hence token amount cannot be refunded'));
            
            blnDisableSubmitSRbtn = true;
        }
        
        
    }
    // particular unit info showing
    /*public void showBookingUnitInfo(){
        System.debug('---strSelectedBookingUnit--'+strSelectedBookingUnit);
        System.debug('---mapWrapperBookingUnit--'+mapWrapperBookingUnit);
        blnShowRefundDetails = false;
        if(String.isNotBlank(strSelectedBookingUnit) 
            && mapWrapperBookingUnit.containsKey(strSelectedBookingUnit)){
         
            objWrapperBookingUnit = mapWrapperBookingUnit.get(strSelectedBookingUnit);
            System.debug('---objWrapperBookingUnit--'+objWrapperBookingUnit);
            blnShowRefundDetails = true;
            strSelectedSection = 'Unit Details';
            lstOpenCasesBU = new List<Case>();            
            if(mapOpenSR.Size()>0){
                if(mapOpenSR.ContainsKey(strSelectedBookingUnit)){
                    lstOpenCasesBU = mapOpenSR.get(strSelectedBookingUnit);
                }
            }           
         }
         System.debug('---lstOpenCasesBU--'+lstOpenCasesBU);
    }*/
    
    // IPMS call to get amount details - token and excess amount
    public void showRefundValues() {
        try{
            blnShowRefundValues = true;
            if(mapBookingUnit.containsKey(strSelectedBookingUnit)) {
                 //= mapBookingUnit.get(strSelectedBookingUnit);
                 if(strSelectedRefundProcess.equalsIgnoreCase('Token Refund')) {
                     RefundsService.RefundResponse objResponse  = RefundsService.getTokenRefund(mapBookingUnit.get(strSelectedBookingUnit).Registration_ID__c);
                     System.debug('--objResponse Token--'+objResponse);
                     if(objResponse.strStatus.equalsIgnoreCase('Success')) {
                         decTokenDeposit = objResponse.decAmount;
                         if(decTokenDeposit <= 0 || decTokenDeposit == null) {
                             ApexPages.addmessage(new ApexPages.message(
                             ApexPages.severity.Error, 'Token amount is invalid. Please contact the support team.'));
                             blnShowRefundValues = false; 
                         }
                     }
                     else {
                         ApexPages.addmessage(new ApexPages.message(
                             ApexPages.severity.Error, 'An exception has occurred while processing the request. Please contact the support team.'));
                         blnShowRefundValues = false; 
                         //decTokenDeposit = 155500;
                         //blnShowRefundValues = true; 
                     }
                 }
                 else if(strSelectedRefundProcess.equalsIgnoreCase('Customer Refund')) {
                     RefundsService.RefundResponse objResponse  = RefundsService.getExcessAmount(mapBookingUnit.get(strSelectedBookingUnit).Registration_ID__c);
                     System.debug('--objResponse 2 Customer--'+objResponse);
                     if(objResponse.strStatus.equalsIgnoreCase('Success')) {
                         decExcessAmount = objResponse.decAmount;
                         //decExcessAmount = 155500;
                         if(decExcessAmount <= 0 || decExcessAmount == null) {
                             ApexPages.addmessage(new ApexPages.message(
                             ApexPages.severity.Error, 'Excess amount is invalid. Please contact the support team.'));
                             blnShowRefundValues = false; 
                         }
                     }
                     else {
                         
                         ApexPages.addmessage(new ApexPages.message(
                             ApexPages.severity.Error,'An exception has occurred while processing the request. Please contact the support team.'));
                         blnShowRefundValues = false;
                         //decExcessAmount = 155500; 
                         //blnShowRefundValues = true; 
                     }
                 }
              }            
            
                showDocumentError();
            }
        catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Error, ex.getMessage()));
        }
        
    }
    // add attachment
    /*public pageReference goToAttachmentPage(){    
        //Service_Request__c SR = new Service_Request__c();        
        System.debug('----strTypeOfDoc----'+strTypeOfDoc);
        blnShowNOCdataError = false;  
        try{                
            if(RecordSelection() == false){
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.Error,'Please select atleast one booking unit'));
                return null;
            }
            else{            
                if(strTypeOfDoc == 'PowerOfAttorney' && objCase.Power_of_Attorney__c == 'Yes'){
                    if(objCase.POA_Expiry_Date_Seller__c == null ||
                       String.isBlank(objCase.POA_Name_Seller__c) ||
                       String.isBlank(objCase.Relationship_with_Seller__c ) ||
                       String.isBlank(objCase.POA_Issued_By_Seller__c )                      
                      ){
                          blnShowNOCdataError = true;
                          return null;  
                      }
                }
                if(String.isBlank(strCaseID)){
                    
                    Id devRecordTypeId =
                        Schema.SObjectType.Case.getRecordTypeInfosByName().get(strSelectedRefundProcess).getRecordTypeId();            
                    objCase.AccountID = strAccountID ;
                    objCase.RecordTypeID = devRecordTypeId;
                    objCase.Subject = '--Test--'+System.Now()+'--'+strSelectedRefundProcess ;
                    System.debug('---objCase.AccountID--'+objCase.AccountID);
                    upsert objCase; 
                    
                    strCaseID = objCase.id;
                    System.debug('---strCaseID ---'+strCaseID );
                    List<SR_Booking_Unit__c> lstSRbookingUnit = new List<SR_Booking_Unit__c>();
                    for(Wrapper w : lstWrapper){
                        if(w.Wselected){
                            SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
                            SRB.Case__c = objCase.id;
                            SRB.Booking_Unit__c = w.WBU.id;
                            lstSRbookingUnit.add(SRB);
                        }
                    }
                    insert lstSRbookingUnit;
                }
                else{
                    objCase.id = strCaseID;
                    Id devRecordTypeId =
                        Schema.SObjectType.Case.getRecordTypeInfosByName().get(strSelectedRefundProcess).getRecordTypeId(); 
                    objCase.RecordTypeID = devRecordTypeId;
                    update objCase; // saving details of Case on power of attorny section
                }
                
            }
            pageReference pgr = new pageReference('/apex/UploadAttachment?id='+strCaseID+'&accID='+strAccountID+'&doc='+strTypeOfDoc+'&returnPage=CRE_Refund');
            return pgr;
            
        }
        catch(exception ex){
            ApexPages.AddMessages(ex);
            return null;
        }
    } */
    
    // creating SR attachment and attachment object list
    private void uploadAttachment( String strfileName, Blob objBody, Id parentId, String docType ) {
        
        SR_Attachments__c obj = new SR_Attachments__c ();
        obj.name = strfileName;
        obj.Case__c = objCase.Id;         
        obj.type__c = docType ;
        integer intNum = Crypto.getRandomInteger();       
        System.debug('---intNum--'+intNum);
        obj.Attachment_URL__c = 'http://34.227.23.86:8080/AOPT_Payment_Plan_Addendum_12-10-2017_'+intNum+'.doc';
        System.debug('---obj.Attachment_URL__c--'+obj.Attachment_URL__c);
        //if(docType == 'CRF Form'){
        //    obj.isValid__c = true;
        //}              
        lstSRattachmentsAll.add(obj);
        
        objAttach = new Attachment() ;
        objAttach.Body = objBody ;
        objAttach.Name = strfileName ;
        //objAttach.ParentId = obj.id;
        lstAttachment.add( objAttach );
        
        objAttach = null;      
    }
    
    // file name extracting like
    private String extractName( String strName ) {
        return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }
    private Blob extractBody( String strBody ) {
        strBody = EncodingUtil.base64Decode( strBody ).toString();
        return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }
    
    //Method to fetch SOA from IPMS
    public void insertStatementOfAccount() {
        try {
            //String strRegId = objWrapperBookingUnit.strRegID;
            String strRegId = '41332';
            system.debug('strRegId : '+strRegId);
            GenerateSOAController.soaResponse strResponse = GenerateSOAController.getSOADocument(strRegId);
            system.debug('SOA generated status '+strResponse.status);
            system.debug('SOA generated url'+strResponse.url);
            if(String.isBlank(strResponse.url) || 
               strResponse.url == null ) {
                //strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' SOA was not found'; 
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.Error,'An exception has occurred while processing the request. Please contact the support team.'));
            }else {
                soaUrl = strResponse.url;
            }
            //strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' Statement of account generated successfully.';
        } catch (Exception e) {
            //strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'An exception has occurred while processing the request. Please contact the support team.'));
        }
    }
    
    public pageReference saveDraft(){
        
        try{
            System.debug('---strAccountID SaveDraft--'+strAccountID+'--strSelectedAccount--'+strSelectedAccount);
            System.debug('---strSelectedRefundProcess saveDraft--'+strSelectedRefundProcess);
            if(String.isNotBlank(strSelectedRefundProcess)){
                if(String.isBlank(strSelectedBookingUnit)){
                    ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.Error,'Please Select Booking Unit'));
                }
                else{
                    Id devRecordTypeId =
                    Schema.SObjectType.Case.getRecordTypeInfosByName().get(strSelectedRefundProcess).getRecordTypeId();            
                    if(strSelectedRefundProcess == 'Customer Refund'){
                         objCase.SR_Type__c = 'Customer refunds SR';
                          objCase.Excess_Amount__c = decExcessAmount ;
                          objCase.Refund_Amount__c = decExcessAmount ;
                        }
                        else if(strSelectedRefundProcess == 'Token Refund' ){
                            objCase.SR_Type__c = 'Token Deposit Refunds SR';
                            objCase.Total_Token_Amount__c = decTokenDeposit ;
                            objCase.Refund_Amount__c = decTokenDeposit ;
                        }
                        //objCase.Refund_Amount__c = decRefundAmount;
                        objCase.AccountID = strAccountID ;
                        objCase.RecordTypeID = devRecordTypeId;                       
                        System.debug('---objCase.AccountID--'+objCase.AccountID);
                        if(objCase.Power_of_Attorney__c == 'Yes' && string.isNotBlank(strPOAExpiryDate)){
                            objCase.POA_Expiry_Date__c = Date.parse(strPOAExpiryDate);
                        }
                        
                    if(String.isNotBlank(strCaseID)){                                                                  
                        objCase.id = strCaseID;                        
                        update objCase;                        
                        lstSRbookingUnit = [select id,SR__c,Booking_Unit__c
                                           from SR_Booking_Unit__c where Case__c =: strCaseID];                                          
                        if(lstSRbookingUnit.Size()>0 && mapBookingUnit.containsKey(strSelectedBookingUnit)){              
                            lstSRbookingUnit[0].Booking_Unit__c = mapBookingUnit.get(strSelectedBookingUnit).id;                   
                            update lstSRbookingUnit;
                        }
                    }   
                    if(String.isBlank(strCaseID)){                                            
                        
                        upsert objCase;                         
                        strCaseID = objCase.id;                        
                        if(mapBookingUnit.containsKey(strSelectedBookingUnit)){
                            //objCase.Booking_Unit__c = mapBookingUnit.get(strSelectedBookingUnit).id;
                            SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
                            SRB.Case__c = objCase.id;
                            SRB.Booking_Unit__c = mapBookingUnit.get(strSelectedBookingUnit).id;
                            lstSRbookingUnit.add(SRB);
                        }
                        
                        if(lstSRbookingUnit.Size()>0){
                            insert lstSRbookingUnit;
                        }
                        System.debug('---strCaseID ---'+strCaseID );
                        /*List<SR_Booking_Unit__c> lstSRbookingUnit = new List<SR_Booking_Unit__c>();
                        for(Wrapper w : lstWrapper){
                            if(w.Wselected){
                                SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
                                SRB.Case__c = objCase.id;
                                SRB.Booking_Unit__c = w.WBU.id;
                                lstSRbookingUnit.add(SRB);
                            }
                        }
                        insert lstSRbookingUnit;*/
                    }           
                    objCase = [Select id,RecordType.name,POA_Name__c,Status,SR_Type__c,
                       POA_Relationship_with_Buyer__c,POA_Expiry_Date__c ,POA_Issued_By__c, Power_of_Attorney__c,
                       Purpose_of_POA__c,
                       (select id,SR__c,Booking_Unit__c
                       from SR_Booking_Units__r),
                       (Select id,name,SR__c,View__c,Attachment__c,type__c,Case__r.CaseNumber,isValid__c
                       from SR_Attachments__r)
                       from Case where id =: strCaseID ];
                       
                    System.debug('---crfAttachmentBody --'+crfAttachmentBody );
                    System.debug('---crfAttachmentName --'+crfAttachmentName );
                    
                    lstSRattachmentsAll = new List<SR_Attachments__c>();
                    lstAttachment = new List<Attachment>();
                    
                    /*if(objCase.Power_of_Attorney__c == 'Yes'){
                        if(String.isBlank(objCase.POA_Name__c) ||
                           String.isBlank(objCase.POA_Relationship_with_Buyer__c) ||
                           String.isBlank(objCase.POA_Issued_By__c)                      
                          ){
                              blnShowNOCdataError = true;
                              return null;  
                          }
                    }*/
                    
                    if( String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ) {
                        uploadAttachment( extractName( crfAttachmentName ) , 
                                         extractBody( crfAttachmentBody ) , 
                                         objCase.Id , 
                                         'CRF Form' );                        
                    }
                    crfAttachmentBody = '';
                    crfAttachmentName = '';
                    
                    if( String.isNotBlank(NocAttachmentBody) && String.isNotBlank(NocAttachmentName) ) {
                        uploadAttachment( extractName(NocAttachmentName ) , 
                                         extractBody(NocAttachmentBody ) , 
                                         objCase.Id , 
                                         'NOC' );                        
                    } 
                    NocAttachmentBody = '';
                    NocAttachmentName = '';
                    
                    if( String.isNotBlank(PoaAttachmentBody) && String.isNotBlank(PoaAttachmentName) ) {
                        uploadAttachment(extractName(PoaAttachmentName ) , 
                                         extractBody(PoaAttachmentBody ) , 
                                         objCase.Id , 
                                         'Power Of Attorney' );                        
                    }
                    PoaAttachmentBody = '';
                    PoaAttachmentName = '';
                    
                    System.debug('---lstSRattachmentsAll --'+lstSRattachmentsAll);
                    System.debug('---lstAttachment--'+lstAttachment);
                    if(lstSRattachmentsAll.Size()>0 
                       && lstAttachment.Size()>0 
                       && lstSRattachmentsAll.Size() == lstAttachment.Size()){
                           try{
                               insert lstSRattachmentsAll ;
                               
                               for(integer objInt=0; objInt<lstSRattachmentsAll.Size(); objInt++ ){                          
                                   lstAttachment[objInt].ParentId = lstSRattachmentsAll[objInt].id;
                                   
                                   //String strAttachmentResponse = '';
                                   try{
                                       /*DocumentUploadService.DocumentWrapper objDoc = new DocumentUploadService.DocumentWrapper();
                                       objDoc = 
                                       DocumentUploadService.uploadDocument
                                       (EncodingUtil.base64Encode(lstAttachment[objInt].Body)    ,
                                       strSelectedBookingUnit,lstSRattachmentsAll[objInt].id,lstSRattachmentsAll[objInt].type__c,'123',lstAttachment[objInt].Name);
                                       System.debug('--objDoc--'+objDoc);*/
                                       //callOutDocuments(lstAttachment[objInt].Body,
                                       //strSelectedBookingUnit,'POA','123',lstAttachment[objInt].Name);
                                   }
                                   catch(exception ex){
                                       System.debug('--Callout Document-exception--'+ex.getMessage());
                                       ApexPages.addmessage(new ApexPages.message(
                                       ApexPages.severity.Error,ex.getMessage())); 
                                   }                         
                               }
                               insert lstAttachment;
                               for(integer objInt=0; objInt<lstSRattachmentsAll.Size(); objInt++ ){  
                                   for(integer objIntJ=0; objIntJ<lstAttachment.Size(); objIntJ++ ){
                                       if(lstSRattachmentsAll[objInt].id == lstAttachment[objIntJ].ParentId ){
                                           lstSRattachmentsAll[objInt].Attachment__c = lstAttachment[objIntJ].id;
                                           break;
                                       }
                                   }
                               } 
                               update lstSRattachmentsAll;
                           }
                           catch(exception ex){
                               ApexPages.addmessage(new ApexPages.message(
                                   ApexPages.severity.Error,ex.getMessage())); 
                               return null;      
                           }  
                    }
                    lstAttachment = null;
                    lstSRattachmentsAll = null;
                    
                    lstSRattachments = [Select id,name,SR__c,View__c,Attachment__c,type__c,
                                       Case__r.CaseNumber,isValid__c from SR_Attachments__c
                                       where Case__c =: strCaseID];                        
                    
                    
                    blnShowPowerOfAttornyAttachment = checkAttachmentType('Power Of Attorney');                
                    
                    blnShowNOCattachment = checkAttachmentType('NOC');
                    
                    blnShowCRFattachment = checkAttachmentType('CRF Form');
                    
                    showDocumentError();   
                                        
                    /*list<SR_Booking_Unit__c> lstSRbookingUnitSet = new List<SR_Booking_Unit__c>();
                    lstSRbookingUnitSet = [select id,SR__c,Booking_Unit__c
                                          from SR_Booking_Unit__c
                                          where Case__c =: strCaseID];
                    
                    set<String> setBookingUnitIDs = new set<String>();
                    for(SR_Booking_Unit__c sr : lstSRbookingUnitSet ){
                        setBookingUnitIDs.add(sr.Booking_Unit__c);
                    }
                    
                    List<SR_Booking_Unit__c> lstSRbookingUnitUpdated = new List<SR_Booking_Unit__c>();
                    List<String> lstIDSRbookingUnitDeleted = new List<String>();
                    
                    for(Wrapper w : lstWrapper){
                        if(w.Wselected ){
                            if(setBookingUnitIDs.contains(w.WBU.id)){ // SR Booking Unit Present already
                                
                            }
                            else{
                                SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
                                SRB.Case__c = objCase.id;
                                SRB.Booking_Unit__c = w.WBU.id;
                                lstSRbookingUnitUpdated.add(SRB);
                            }                                                                      
                        }
                        else{ 
                            // not selected record
                            // if user again deselect the booking unit wrapper then remove record from database
                            if(setBookingUnitIDs.contains(w.WBU.id)){
                                lstIDSRbookingUnitDeleted.add(w.WBU.id);
                            }
                        }
                    }
                    if(lstSRbookingUnitUpdated.Size()>0){
                        insert lstSRbookingUnitUpdated;
                    }
                    if(lstIDSRbookingUnitDeleted.Size()>0){
                        List<SR_Booking_Unit__c> lstSRbookingUnitDeleted = new List<SR_Booking_Unit__c>();
                        lstSRbookingUnitDeleted = [Select id from SR_Booking_Unit__c 
                                                   where Case__c =: strCaseID 
                                                   AND Booking_Unit__c IN : lstIDSRbookingUnitDeleted];
                        delete lstSRbookingUnitDeleted ;                    
                    }*/
                    //bookingUnitDetails();
                    blnShowRefundValues = true;
                    ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.confirm,'The details have been saved successfully : '+strCaseID));                                        
                }
            }    
            else{
                ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'Please select Type of Refund'));
                return null;  
            }
        }
        catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,ex.getMessage()));
            return null;              
        }   
        return null;                  
    }
    @Future(callout=true)
    public static void callOutDocuments(blob objBlob,string strBookingUnitID,string strSRattachmentType,string strFileID, string strFileName){
        try{
           DocumentUploadService.DocumentWrapper objDoc = new DocumentUploadService.DocumentWrapper();
           objDoc = 
           DocumentUploadService.uploadDocument
           (EncodingUtil.base64Encode(objBlob),
           strBookingUnitID,strSRattachmentType,strFileID,strFileName);
           System.debug('--objDoc future--'+objDoc);
        }
        catch(exception ex){
           System.debug('--Callout Document future-exception--'+ex.getMessage());          
        }    
    }
    
    public pageReference submitSR(){
        try{
            if(String.isNotBlank(strCaseID)){
                pageReference pgr = new pageReference('/'+strCaseID);
                if(String.isNotBlank(strSelectedRefundProcess)){
                    if(String.isBlank(strSelectedBookingUnit)){
                        ApexPages.addmessage(new ApexPages.message(
                        ApexPages.severity.Error,'Please Select Booking Unit'));
                        return null;
                    }
                    else{
                        Booking_unit__c objBU = new Booking_unit__c();
                        if(mapBookingUnit.containsKey(strSelectedBookingUnit)){
                            objBU = mapBookingUnit.get(strSelectedBookingUnit);
                            String strRefundValue = '0';
                            String strSubProcessName = '';
                            if(strSelectedRefundProcess == 'Token Refund'){
                               strRefundValue = string.ValueOf(decTokenDeposit);
                               strSubProcessName = 'Token Refund'; 
                            }
                            else if(strSelectedRefundProcess == 'Customer Refund'){
                               strRefundValue = string.ValueOf(decExcessAmount);
                               strSubProcessName = 'Customer Refunds';                                 
                            }
                            RefundsService.RefundRuleResponse objRuleResponse = RefundsService.getApprovingAuthorities(
                                objBU.Registration_ID__c,
                                'Refunds',
                                strSubProcessName,
                                objBU.Inventory__r.Property_City__c, 
                                objBU.Inventory__r.Property__r.Name,
                                objBU.Inventory__r.Building_Code__c,
                                objBU.Inventory__r.Bedroom_Type__c,
                                objBU.Inventory__r.Unit_Type__c,
                                objBU.Permitted_Use__c,
                                '',
                                objBU.Inventory__r.Property_Status__c,
                                objBU.Early_Handover__c == true ? 'Yes' : 'NO',
                                objBU.Handover_Flag__c,                               
                                objBU.Booking__r.Account__r.Nationality__c,
                                '',
                                '',
                                strRefundValue                                
                                );
                            System.debug('----objRuleResponse--'+objRuleResponse); 
                            if(objRuleResponse != null){
                                if(objRuleResponse.strAllowed == 'Error'){
                                    ApexPages.addmessage(new ApexPages.message(
                                        ApexPages.severity.Error,'Problems while getting Roles from Rule Engine'));
                                    return null;
                                }
                                 if(objRuleResponse.strAllowed == 'No' && String.isNotBlank(objRuleResponse.strMessage)){
                                    ApexPages.addmessage(new ApexPages.message(
                                        ApexPages.severity.Error,objRuleResponse.strMessage));
                                    return null;
                                }
                                
                                if(String.isNotBlank(objRuleResponse.strApprovingAuthority)){
                                    objCase.Roles_from_Rule_Engine__c = objRuleResponse.strApprovingAuthority;
                                    System.debug('---objRuleResponse.strApprovingAuthority---'+objRuleResponse.strApprovingAuthority);
                                }
                                 
                            }
                            else{
                                ApexPages.addmessage(new ApexPages.message(
                                    ApexPages.severity.Error,'Problems while getting Roles from Rule Engine'));
                                return null;
                            }   
                        }
                        /*list<SR_Booking_Unit__c> lstSRbookingUnitSet = new List<SR_Booking_Unit__c>();
                        lstSRbookingUnitSet = [select id,SR__c,Booking_Unit__c 
                                              from SR_Booking_Unit__c
                                              where Case__c =: strCaseID];
                        
                        for(WrapperBookingUnit objWrb : lstWrapperBookingUnit){
                            for(SR_Booking_Unit__c SRB : lstSRbookingUnitSet ){
                                if(SRB.Booking_Unit__c == objWrb.objBookingUnit.ID){                                   
                                    SRB.Project__c =  objWrb.objBookingUnit.Inventory__r.Property__r.Name; 
                                    SRB.Project_City__c = objWrb.objBookingUnit.Inventory__r.Property_City__c ;
                                    SRB.Bedroom_Type__c = objWrb.objBookingUnit.Inventory__r.Bedroom_Type__c ;
                                    SRB.Unit_Type__c = objWrb.objBookingUnit.Inventory__r.Unit_Type__c ;
                                    SRB.Permitted_Use__c = objWrb.objBookingUnit.Permitted_Use__c ;
                                    SRB.Ready_Off_plan__c = objWrb.objBookingUnit.Inventory__r.Property_Status__c; 
                                    SRB.Rental_Pool__c = objWrb.strRentalPool ;
                                    SRB.Is_Dispute__c = objWrb.blnDispute ;
                                    SRB.Is_Enforcement__c =objWrb.blnEnforcement; 
                                    SRB.Is_Litigation__c = objWrb.blnLitigation ;
                                    SRB.Is_Mortgage_Unit__c = objWrb.objBookingUnit.Mortgage__c ;
                                    SRB.Is_Court_Case__c =  objWrb.blnCourtCase ;
                                    SRB.FTL_Sent__c = objWrb.blnFTLsent;
                                    SRB.EHO__c = objWrb.objBookingUnit.Early_Handover__c ;
                                    SRB.Is_HO__c = objWrb.objBookingUnit.Handover_Flag__c; 
                                    SRB.PCC__c = objWrb.objBookingUnit.PCC_Release__c ;
                                    //SRB.FTL_Sent__c = objWrb.strPCC; 
                                    SRB.OQOOD_registered__c = objWrb.objBookingUnit.OQOOD_Reg_Flag__c ;
                                    SRB.Agreement_Status__c = objWrb.strAgreementStatus ;
                                    SRB.Under_Termination__c = objWrb.strUnderTermination;  
                                    SRB.Is_URC_Signed__c = objWrb.bln_URC_SPA ;
                                    //SRB.Deal_Status__c = objWrb.strDealStatus ;
                                    //SRB.FTL_Sent__c = objWrb.strDefault ;
                                    //SRB.Valid_ID_available__c = objWrb.strIDavailable ;
                                    SRB.Area__c    = objWrb.objBookingUnit.Inventory_Area__c ;
                                    SRB.Price__c = objWrb.objBookingUnit.Unit_Selling_Price__c ;
                                    //SRB.No_of_days_from_booking__c = objWrb.intNoOfBookingDay ;
                                    SRB.No_of_times_customer_defaulted__c = objWrb.intNoOfDefaulted ;
                                    SRB.Overdue__c = objWrb.intOverdue ;
                                    //SRB.Promotion_Scheme_Option_Campaign__c = objWrb.strPromotionScheme ;
                                    SRB.Current_RERA_Construction_Status__c = objWrb.decRERAstatus ;
                                    SRB.Invoices_raised__c = objWrb.strInvoicesRaised ;
                                    SRB.Amount_paid__c = objWrb.decAmountPaid ;
                                    SRB.Penalties__c = '' ;
                                    //SRB.Deal_Team__c = objWrb.strDealTeam ;
                                    SRB.Booking_Type__c = objWrb.objBookingUnit.Booking_Type__c ;
                                    SRB.Built_Up_Price__c = objWrb.objBookingUnit.Plot_Price__c ;
                                    SRB.Plot_Price__c = objWrb.objBookingUnit.Plot_Price__c ;
                                    SRB.Payment_Plan__c = objWrb.strPaymentPlan ;
                                    //SRB.Statement_of_Account__c = objWrb.strStatementofAccount ;
                                    SRB.Booking_Date__c = objWrb.dateBookingDate ;
                                    SRB.Agreement_Date__c = objWrb.dateAgreementDate ;
                                    SRB.Unit_Plan__c = objWrb.objBookingUnit.Inventory__r.Unit_Plan__c ;
                                    SRB.Floor_Plan__c = objWrb.objBookingUnit.Inventory__r.Floor_Plan__c ;
                                    SRB.JOPD_Area__c = objWrb.objBookingUnit.JOPD_Area__c ;
                                    SRB.DP_OK__c = objWrb.objBookingUnit.DP_OK__c ;
                                    SRB.DOC_OK__c = objWrb.objBookingUnit.Doc_OK__c ;
                                    
                                }
                            }                                                                      
                        }
                        update lstSRbookingUnitSet;*/
                        
                        objCase.Status = 'Submitted';
                        objCase.Approved_Amount_Percentage__c = 100;
                                               
                        System.debug('---blnActiveUnit 2---'+blnActiveUnit);
                        System.debug('---Token Refund--'+strSelectedRefundProcess);
                        if(blnActiveUnit && strSelectedRefundProcess == 'Token Refund'){
                             //objCase.Approving_Authorities__c = 'Head of Sales,VP - Operations,General Manager';
                             if(String.isNotBlank(objCase.Roles_from_Rule_Engine__c)){
                                 objCase.Approving_Authorities__c = 'Head of Sales,'+objCase.Roles_from_Rule_Engine__c;
                             }
                             objCase.Approval_Status__c = 'Approval required from Head of Sales';
                             objCase.Submit_for_Approval__c = false;
                             if(strInactiveUnitIds.contains(',')){
                                 strInactiveUnitIds = strInactiveUnitIds.removeEnd(',');
                             }
                             objCase.Active_Unit_Ids__c = strInactiveUnitIds; // only for token refund process
                        }
                        update objCase;
                                             
                        return pgr;
                    }
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(
                        ApexPages.severity.Error,'Please select Type of Refund'));
                    return null;  
                }
                
            }
            else{
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.Error,'Case record not created'));
            } 
            return null;
        }
        catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,ex.getMessage()));
            return null;
        }  
    }
    
    // remove attached file
    public void removeAttachment(){
        blnDisableSubmitSRbtn = false;
        System.debug('--RemoveSelected----'+RemoveSelected);
        if(String.isNotBlank(RemoveSelected)){
            SR_Attachments__c Sr = [Select id,type__c from SR_Attachments__c where id=: RemoveSelected];
            String docType = sr.type__c;
            delete Sr;
            lstSRattachments = [Select id,name,SR__c,View__c,Attachment__c,type__c,
                               Case__r.CaseNumber,isValid__c 
                               from SR_Attachments__c  
                               where Case__c =: strCaseID];            
            
            if(docType == 'Power Of Attorney'){            
                blnShowPowerOfAttornyAttachment = checkAttachmentType(docType);                
            }
            else if(docType == 'NOC'){            
                blnShowNOCattachment = checkAttachmentType(docType);
                
            }
            else if(docType == 'CRF Form'){            
                blnShowCRFattachment = checkAttachmentType(docType);
                
            }
            //blnInValidFiles = checkAttachmentType('DisableCheck');
            showDocumentError();
        }
    }
    
    /*public class Wrapper {
        public boolean Wselected {get;set;}
        public Booking_Unit__c WBU {get;set;}
        
        public wrapper(boolean selected,Booking_Unit__c BU ){
            Wselected = selected ;
            WBU = BU;
        }
    }*/
}