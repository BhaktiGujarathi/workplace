public with sharing class CREBouncedChequeComponentController {
    public Case objCase {get; set;}

    public Map<Id, WrapperBookingUnit> mapWrapperBookingUnit {get; set;}
    
    public Boolean blnIsShowBCAttachment {get; set;}
    public Boolean isShowUnitDetails {get; set;}

    public String strSelectedBookingUnit {get; set;}
    public String strSelectedUnitDetail {get; set;}
    public String RemoveSelected { get;set; }
    public String strSelectedSection {get;set;}
    public transient String strBCAttachmentBody { get; set; }
    public transient String strBCAttachmentName { get; set; }

    public List<SelectOption> lstBookingUnit {get; set;}
    public List<String> lstBU {get; set;}
    public List<SR_Attachments__c> lstSRAttachments {get; set;}
    public List<Case> lstOpenCasesBU {get;set;}

    public WrapperBookingUnit objWrapperBookingUnit {get;set;}

    private Id caseId;
    private Map<ID,List<Case>> mapOpenSR;

    public CREBouncedChequeComponentController() {
        caseId = ApexPages.currentPage().getParameters().get('caseID');
        objCase = new Case();        
        mapOpenSR = new Map<ID,List<Case>>();
        if(caseId != null) {
            init();
        }
    }
    
    //Method for initialization of class members
    private void init() {
        isShowUnitDetails = false;
        lstBookingUnit = new List<SelectOption>();
        mapWrapperBookingUnit = new Map<Id, WrapperBookingUnit>();
        lstBU = new List<String>();
        
        List<Case> lstCase = [Select Id, Status, AccountId,Bounced_Cheque_Date_of_Expiry__c,Bounced_Cheque_Details__c,
                              Bounced_Reason__c,Bounced_Cheque_Status__c,Cheque_Number__c,
                              Cheque_Amount__c ,Cheque_Bank_Name__c ,
                              (Select Id, Booking_Unit__c, Booking_Unit__r.Unit_Details__c,
                              Booking_Unit__r.Registration_ID__c, Booking_Unit__r.Inventory__r.Unit__c,
                              Booking_Unit__r.Inventory__r.Property__r.Name, Booking_Unit__r.Inventory__r.Property_Name_2__c,
                              Booking_Unit__r.Inventory__r.IPMS_Bedrooms__c, Booking_Unit__r.Inventory__r.Selling_Price__c,
                              Booking_Unit__r.Inventory__r.Price_Per_Sqft__c, Booking_Unit__r.Inventory__r.Property_Status__c,
                              Booking_Unit__r.Inventory__r.Anticipated_Completion_Date__c,
                              Booking_Unit__r.Inventory__r.Property__c, Booking_Unit__r.Inventory__r.Property_City__c,
                              Booking_Unit__r.Inventory__r.Unit_Type__c, Booking_Unit__r.Permitted_Use__c, 
                              Booking_Unit__r.Inventory__r.Area_Sqft_2__c,
                              Booking_Unit__r.Inventory__r.Construction_Status__c, Booking_Unit__r.Revised_Price_Area_Variation__c,
                              Booking_Unit__r.Rebate_Given__c, Booking_Unit__r.Rental_Pool_Agreement__c,
                              Booking_Unit__r.RERA_Project__c, Booking_Unit__r.Dispute_Flag__c, 
                              Booking_Unit__r.OQOOD_Reg_Flag__c,
                              Booking_Unit__r.Handover_Flag__c, Booking_Unit__r.PCC_Generate__c,
                              Booking_Unit__r.Early_Handover__c From SR_Booking_Units__r
                              Where Booking_Unit__c != null),
                              (Select Id, Name, View__c, Attachment__c,
                              Type__c, Case__r.CaseNumber, IsValid__c
                              From SR_Attachments__r)
                              From Case
                              Where Id =: caseId];
        if(lstCase != null && !lstCase.isEmpty()) {
            if(lstCase[0].SR_Booking_Units__r != null && !lstCase[0].SR_Booking_Units__r.isEmpty()) {
                objCase = lstCase[0];
            
                //lstBookingUnit = objCase.SR_Booking_Units__r;
                
                if(objCase.SR_Attachments__r != null && !objCase.SR_Attachments__r.isEmpty()) {
                    lstSRAttachments = objCase.SR_Attachments__r;
                    //validateSubmitButton();
                    blnIsShowBCAttachment = checkAttachmentType('Bounced Cheque');
                }
                populateWrapperBookingUnit();
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
        }
        return blnShow;
    }
    
    //Method to populate the WrapperBookingUnit wrapper
    private void populateWrapperBookingUnit() {
        List<String> lstBookingUnitID = new List<String>();
        for(SR_Booking_Unit__c objSRBU: objCase.SR_Booking_Units__r) {
            if(objSRBU.Booking_Unit__c != null && objSRBU.Booking_Unit__r.Unit_Details__c != null) {
                //Perform callout to IPMS to fetch booking unit details
                
                lstBookingUnit.add(new SelectOption(objSRBU.Booking_Unit__c, objSRBU.Booking_Unit__r.Unit_Details__c));
                lstBU.add(objSRBU.Booking_Unit__r.Unit_Details__c);
                
                WrapperBookingUnit objWBU = new WrapperBookingUnit();
                Booking_Unit__c objBU = new Booking_Unit__c(Id = objSRBU.Booking_Unit__c);
                
                objWBU.objBookingUnit = objBU;
                objWBU.strUnit = objSRBU.Booking_Unit__r.Inventory__r.Unit__c;
                objWBU.strProject = objSRBU.Booking_Unit__r.Inventory__r.Property__r.Name;
                objWBU.strProjectCity = objSRBU.Booking_Unit__r.Inventory__r.Property_City__c;
                objWBU.strBedroomType = objSRBU.Booking_Unit__r.Inventory__r.IPMS_Bedrooms__c;
                objWBU.strUnitType = objSRBU.Booking_Unit__r.Inventory__r.Unit_Type__c;
                objWBU.strPermittedUse = 'Yes';
                objWBU.strReady_OffPlan = objSRBU.Booking_Unit__r.Inventory__r.Property_Status__c;
                objWBU.strRentalPool = 'No';
                objWBU.blnDispute = false;
                objWBU.blnEnforcement = false;
                objWBU.blnLitigation = false;
                objWBU.blnMortage = false;
                objWBU.blnCourtCase = false;
                objWBU.blnFTLsent = true;
                objWBU.blnEHO = true;
                objWBU.blnHO = false;
                objWBU.strPCC = 'Test';
                objWBU.strOQOODregistered = 'No';
                objWBU.strAgreementStatus = 'Pending';
                objWBU.strUnderTermination = 'No';
                objWBU.str_URC_SPA  = 'Yes';
                objWBU.strDealStatus = 'Pending';
                objWBU.strDefault = 'Test';
                objWBU.strIDavailable = 'Yes';
                objWBU.intArea = objSRBU.Booking_Unit__r.Inventory__r.Area_Sqft_2__c != null ? Integer.valueOf(objSRBU.Booking_Unit__r.Inventory__r.Area_Sqft_2__c) : 0;
                objWBU.decPrice = objSRBU.Booking_Unit__r.Inventory__r.Selling_Price__c;
                objWBU.intNoOfBookingDay = 10;
                objWBU.intNoOfDefaulted =  1;
                objWBU.intOverdue = 1200;
                objWBU.intRERAstatus = 25;
                objWBU.intPenaltyAmount = 0;
                objWBU.strPC_AgentName = 'Test Agent 1';
                objWBU.intConversationStatus = 2;
                objWBU.strDocsStatus = 'Ok';
                objWBU.decPaidPercentage = 25.00;
                objWBU.decDefaultPercentage = 5.00;
                objWBU.intTotalPenaltyCustomer = 2500;
                objWBU.intTotalPenaltyUnit = 0;
                objWBU.strOriginalACD = '12/06/2019';
                objWBU.strCurrentACD = '15/10/2019';
                objWBU.intPricePerSqFt = objSRBU.Booking_Unit__r.Inventory__r.Price_Per_Sqft__c;
                objWBU.strRegID = objSRBU.Booking_Unit__r.Registration_ID__c;
                objWBU.strConstructionStatus = objSRBU.Booking_Unit__r.Inventory__r.Construction_Status__c;
                
                mapWrapperBookingUnit.put(objSRBU.Booking_Unit__c, objWBU);
                lstBookingUnitID.add(objBU.id);
            }
        }
                
        if(String.isNotBlank(caseId) && !lstBookingUnitID.isEmpty()){
            mapOpenSR = OpenSRutility.getOpenSR(lstBookingUnitID,caseId);
        }
        
        if(lstBookingUnit != null && !lstBookingUnit.isEmpty()) {
            strSelectedBookingUnit = lstBookingUnit[0].getValue();
            strSelectedUnitDetail = 'Unit Details';
            isShowUnitDetails = true;
        }
        if(objCase.SR_Booking_Units__r.Size()>0){            
             strSelectedBookingUnit = objCase.SR_Booking_Units__r[0].Booking_Unit__c;
             getBookingUnitDetails();    
        }
        
        
    }
    // method used to showing particular unit info 
    public void getBookingUnitDetails() {
        System.debug('---strSelectedBookingUnit--'+strSelectedBookingUnit);
        if(String.isNotBlank(strSelectedBookingUnit) 
        && mapWrapperBookingUnit.containsKey(strSelectedBookingUnit)){
            objWrapperBookingUnit = mapWrapperBookingUnit.get(strSelectedBookingUnit);
            strSelectedSection = 'Unit Details';
            List<String> lstOpenCaseID = new List<String>();            
            lstOpenCasesBU = new List<Case>();
            if(mapOpenSR.Size()>0){
                if(mapOpenSR.ContainsKey(strSelectedBookingUnit)){
                    lstOpenCasesBU = mapOpenSR.get(strSelectedBookingUnit);
                }
            }            
        }
    }

    //Method to remove attachment
    public void removeAttachment() {
        SR_Attachments__c Sr = [Select id,type__c from SR_Attachments__c where id=: RemoveSelected];
        try {
            delete Sr;
            lstSRattachments = [select id,name,isValid__c,Type__c,Attachment__c from SR_Attachments__c where Case__c =: objCase.Id AND (Type__c ='Bounced Cheque')];
        }
        catch(Exception exp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Success : Attachment Deleted successfully.'));
        }
    }

    //Method to submit SR
    public Pagereference submitSR() {
        List<Attachment> lstAttachment = new List<Attachment>();
        List<SR_Attachments__c> lstCaseAttachment = new List<SR_Attachments__c>();
        String strStatus;
        Boolean blnIsFlagRaised = false;
        Boolean blnIsOffPlan = false;
        Boolean blnIsEHOCase = false;

        if(objCase!= null && objCase.Id != null)
        {
            try
            {
                if(mapWrapperBookingUnit != null && mapWrapperBookingUnit.size() > 0)
                {
                    for(WrapperBookingUnit objWrapperBU : mapWrapperBookingUnit.values())
                    {
                        if(objWrapperBU.blnDispute || objWrapperBU.blnEnforcement || objWrapperBU.blnLitigation || objWrapperBU.blnCourtCase)
                        {
                            blnIsFlagRaised = true;
                        }
                        if(objWrapperBU.strReady_OffPlan != null && objWrapperBU.strReady_OffPlan.equalsIgnoreCase('Off Plan'))
                        {
                            blnIsOffPlan = true;
                        }
                        if(objWrapperBU.blnEHO)
                        {
                            blnIsEHOCase = true;
                        }
                    }
                }

                objCase.Do_Not_Call__c = blnIsFlagRaised;
                objCase.Off_Plan_Units__c = blnIsOffPlan;
                objCase.Is_EHO_Case__c = blnIsEHOCase;
                objCase.Status = 'Submitted';
                update objCase;

                // write code to insert attachment after case is created
                if(String.isNotBlank(strBCAttachmentBody) && String.isNotBlank(strBCAttachmentName)) 
                {
                    lstAttachment.add(getAttachment(extractName(strBCAttachmentName), extractBody(strBCAttachmentBody)));
                    lstCaseAttachment.add(getCaseAttachment('Bounced Cheque'));
                }

                if(!lstAttachment.isEmpty()) 
                {
                    insertAttachments(lstAttachment, lstCaseAttachment);
                    lstSRattachments = [select id,name,isValid__c,Type__c,Attachment__c from SR_Attachments__c where Case__c =: objCase.Id AND (Type__c ='Bounced Cheque')];
                    blnIsShowBCAttachment = checkAttachmentType('Bounced Cheque');
                }
                strStatus = 'SR submitted successfully.';
                return new Pagereference('/' + objCase.Id);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Success : '+strStatus));
            }
            catch(Exception exp)
            {
                blnIsShowBCAttachment = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error : '+exp.getMessage()));
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error : No Case Record Found'));
        }
        return null;
    }
    
    public void genarateSOA()
    {
      system.debug('Generate SOA method called');
      // this method will call the IPMS and fetch the SOA from there
      // then it will map the SOA to the SR created
    }

    public void genaratePenaltyStat()
    {
      system.debug('Generate Penalty method called');
      // this method will call the IPMS and fetch the SOA from there
      // then it will map the SOA to the SR created
    }

    // all private methods section
    private Attachment getAttachment(String strName, Blob blbBody) 
    {
        Attachment objAttachment = new Attachment();
        objAttachment.Name = strName;
        objAttachment.Body = blbBody;
        return objAttachment;
    }

    private SR_Attachments__c getCaseAttachment(String strDocType) 
    {
        system.debug('objCase.Id '+objCase.Id);
        SR_Attachments__c objCaseAttachment = new SR_Attachments__c();
        objCaseAttachment.Case__c = objCase.Id;
        objCaseAttachment.Type__c = 'Bounced Cheque';
        return objCaseAttachment;
    }

    private String extractName( String strName ) 
    {
        return strName.substring( strName.lastIndexOf('\\')+1 ) ;
    }

    private Blob extractBody( String strBody ) 
    {
        strBody = EncodingUtil.base64Decode( strBody ).toString();
        return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
    }

    //Method to insert attachments and case attachments
    private void insertAttachments(List<Attachment> lstAttachment, List<SR_Attachments__c> lstCaseAttachment) 
    {
        insert lstCaseAttachment;

        Integer intCounter = 0;
        for(SR_Attachments__c objCaseAttachment: lstCaseAttachment) 
        {
            lstAttachment[intCounter].ParentId = objCaseAttachment.Id;
            intCounter++;
        }

        insert lstAttachment;

        intCounter = 0;
        for(Attachment objAttachment: lstAttachment) 
        {
            lstCaseAttachment[intCounter].Name = objAttachment.Name;
            lstCaseAttachment[intCounter].Attachment__c = objAttachment.Id;
            intCounter++;
        }

        update lstCaseAttachment;

        strBCAttachmentBody = null;
        strBCAttachmentName = null;
    }
    
    public Class CheckboxWrapper 
    {
        public Boolean blnIsSelected {get; set;}
        public Id unitId {get; set;}
        public String strUnitName {get; set;}
    }
}