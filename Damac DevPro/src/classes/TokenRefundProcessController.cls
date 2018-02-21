/* Class Functionality: Controller class for TokenRefundProcess vf page
 *
 * Revision History: 
 *
 * Version     Author                Date             Description
 * 1.1         Vivek Shinde          10/08/2017       Initial Draft
 */
public with sharing class TokenRefundProcessController {
    /*public Booking__c objBooking {get; set;}
    public List<BookingUnitWrapper> lstBookingUnit {get; set;}
    public List<BookingUnitWrapper> lstDetailedBookingUnit {get; set;}
    public Boolean blnIsBulkDeal {get; set;}
    public Boolean blnIsURCSigned {get; set;}
    public Boolean blnIsActiveUnit {get; set;}
    public Service_Request__c objSR {get; set;}
    public Boolean isTokenRefundRequestApproved {get; set;}
    public Boolean blnIsRequestApproved {get; set;}
    public Decimal decTotalToken {get; set;}
    public List<SR_Attachments__c> lstSRattachments {get;set;}
    public String RemoveSelected {get;set;}
    public Boolean blnShowAttachments {get; set;}
    public List<ApproverWrapper> lstApproverWrapper {get;set;}*/
    
    /*public TokenRefundProcessController() {
        objBooking = new Booking__c();
        lstBookingUnit = new List<BookingUnitWrapper>();
        objSR = new Service_Request__c();
        objSR.SR_Type__c = 'Token Deposit Refunds SR';
        lstSRattachments = new List<SR_Attachments__c>();
        blnShowAttachments = false;
        
        String srID = ApexPages.currentPage().getParameters().get('SRid');
        if(String.isNotBlank(srID)) {
            List<Service_Request__c> lstSR = [Select Id, name, Account__c,(select id,SR__c,Booking_Unit__c from SR_Booking_Units__r),
              (Select id,name,SR__c,View__c,Attachment__c,type__c from SR_Attachments__r) from Service_request__c where id=:srID];
            if(lstSR.Size()>0) {
                lstSRattachments = lstSR[0].SR_Attachments__r;
                if(lstSRattachments!= null && !lstSRattachments.isEmpty()){
                    blnShowAttachments = true;
                }
                objBooking.Account__c = lstSR[0].Account__c;
                objSR = lstSR[0];
                  
                getBookingUnits();
                
                for(BookingUnitWrapper objBUW: lstBookingUnit) {
                    for(SR_Booking_Unit__c objSRBU: objSR.SR_Booking_Units__r) {
                        if(objBUW.bookingUnitId == objSRBU.Booking_Unit__c) {
                            objBUW.blnIsSelected = true;
                        }
                    }
                }
                
                computeAdditionalDetailsForSelectedUnits();
            }
        }
    }*/
    
    /*public void getBookingUnits() {
        lstBookingUnit = new List<BookingUnitWrapper>();
        if(objBooking.Account__c != null) {
            for(Booking_Unit__c objBookingUnit : 
                [Select Id, Registration_ID__c, Inventory__r.Property_Status__c, Inventory__r.Property_Name_2__c,
                 Inventory__r.Unit__c, Inventory__r.ACD_Date__c, Unit_Selling_Price_AED__c, Token_Amount__c
                 From Booking_Unit__c 
                 Where Booking__r.Account__c =: objBooking.Account__c And
                 Token_Amount__c != null]) {
                BookingUnitWrapper objBUW = new BookingUnitWrapper();
                objBUW.bookingUnitId = objBookingUnit.Id;
                objBUW.strPropertyName = objBookingUnit.Inventory__r.Property_Name_2__c;
                objBUW.strUnitName = objBookingUnit.Inventory__r.Unit__c;
                objBUW.decUnitValue = objBookingUnit.Unit_Selling_Price_AED__c;
                objBUW.strPropertyStatus = objBookingUnit.Inventory__r.Property_Status__c;
                objBUW.strACD = objBookingUnit.Inventory__r.ACD_Date__c;
                objBUW.regId = objBookingUnit.Registration_ID__c;
                objBUW.decToken = objBookingUnit.Token_Amount__c;
                lstBookingUnit.add(objBUW);
            }
        }
    }*/
    
    /*public void computeAdditionalDetailsForSelectedUnits() {
        Set<String> setRegId = new Set<String>();
        lstDetailedBookingUnit = new List<BookingUnitWrapper>();
        
        for(BookingUnitWrapper objBUW: lstBookingUnit) {
            //If the booking unit is selected from the UI
            if(objBUW.blnIsSelected) {
                setRegId.add(objBUW.regId);
                lstDetailedBookingUnit.add(objBUW);
            }
        }
        
        if(setRegId != null && !setRegId.isEmpty()) {
            //Perform callout to fetch unit status (active/rejected), case older than 3 months from deal rejection,
            //is unit part of bulk deal, URC/Digital SPA signed status and payment method opted by the customer at the time of booking
            //for the units selected from the UI (use setRegId)
            
            //Assuming the expected details are available from the callout, populate the details in the wrapper list
            for(BookingUnitWrapper objBUW: lstDetailedBookingUnit) {
                objBUW.strUnitStatus = 'Active';
                objBUW.blnIsBulkDeal = false;
                objBUW.blnIsOlderThan3Months = false;
                objBUW.blnIsURCSigned = false;
                objBUW.strPaymentMethod = 'Cash';
            }
            
            //Iterate over the detailed booking unit wrapper and populate some of the important flags such as
            //1. blnIsURCSigned
            //2. blnIsBulkDeal
            //3. blnIsActiveUnit
            
            decTotalToken = 0;
            for(BookingUnitWrapper objBUW: lstDetailedBookingUnit) {
                //populate the required flags if any of the unit has the flag active
                blnIsURCSigned = false;
                blnIsBulkDeal = false;
                blnIsActiveUnit = true;
                
                decTotalToken +=  objBUW.decToken;
            }
            
            objSR.Total_Token_Amount__c = decTotalToken;
            
            //If URC/SPA is signed by the customer
            if(blnIsURCSigned) {
                //Show message on the page that token cannot be refunded since URC has been signed by the customer
            }
            //If any of the selected unit is active
            if(blnIsActiveUnit) {
                //If any of the unit is active then it has to be first rejected by the Sales Admin
                //Appropriate task needs to be created for the Sales Admin based on the value of this flag later
            }
            
            if(blnIsBulkDeal) {
                //If unit is part of bulk deal, it first needs to be validated by the Sales Admin then needs
                //to be referred to the higher authority
            }
        }
        
        
    }*/
    
    /*public void getAdditionalDetails() {
        computeAdditionalDetailsForSelectedUnits();
            
        objSR.Account__c = objBooking.Account__c;
        objSR.RecordTypeId = Schema.SObjectType.Service_Request__c.getRecordTypeInfosByName().
            get('Token Refund').getRecordTypeId();
        objSR.Is_Bulk_Deal__c = blnIsBulkDeal;
        upsert objSR;
        
        List<SR_Booking_Unit__c> lstSRBUToDelete = [Select Id From SR_Booking_Unit__c Where SR__c =: objSR.Id];
        if(lstSRBUToDelete!= null && !lstSRBUToDelete.isEmpty()) {
            delete lstSRBUToDelete;
        }
        
        List<SR_Booking_Unit__c> lstSRBU = new List<SR_Booking_Unit__c>();
        for(BookingUnitWrapper objBUW: lstDetailedBookingUnit) {
            SR_Booking_Unit__c objSRBU = new SR_Booking_Unit__c();
            objSRBU.SR__c = objSR.Id;
            objSRBU.Booking_Unit__c = objBUW.bookingUnitId;
            objSRBU.Is_Bulk_Deal__c = objBUW.blnIsBulkDeal;
            objSRBU.Is_Case_Older_Than_3_Months__c = objBUW.blnIsOlderThan3Months;
            objSRBU.Is_URC_Signed__c = objBUW.blnIsURCSigned;
            objSRBU.Unit_Status__c = objBUW.strUnitStatus;
            lstSRBU.add(objSRBU);
        }
        
        if(lstSRBU != null && !lstSRBU.isEmpty()) {
            insert lstSRBU;
        }
        
        blnShowAttachments = true;
    }*/
    
    /*public void validateTokenRefund() {
        //Perform callout to get the list of the roles to which the approval needs to be sent if approved
        //else if the request is rejected show the message returned from the response on the page
        
        //Value needs to be set on the outcome of the callout response
        blnIsRequestApproved = true;
        
        if(blnIsRequestApproved) {
            /*objSR.Account__c = objBooking.Account__c;
            objSR.RecordTypeId = Schema.SObjectType.Service_Request__c.getRecordTypeInfosByName().
                get('Token Refund').getRecordTypeId();
            objSR.Is_Bulk_Deal__c = blnIsBulkDeal;
            insert objSR;
            
            List<SR_Booking_Unit__c> lstSRBU = new List<SR_Booking_Unit__c>();
            for(BookingUnitWrapper objBUW: lstDetailedBookingUnit) {
                SR_Booking_Unit__c objSRBU = new SR_Booking_Unit__c();
                objSRBU.SR__c = objSR.Id;
                objSRBU.Booking_Unit__c = objBUW.bookingUnitId;
                objSRBU.Is_Bulk_Deal__c = objBUW.blnIsBulkDeal;
                objSRBU.Is_Case_Older_Than_3_Months__c = objBUW.blnIsOlderThan3Months;
                objSRBU.Is_URC_Signed__c = objBUW.blnIsURCSigned;
                objSRBU.Unit_Status__c = objBUW.strUnitStatus;
                lstSRBU.add(objSRBU);
            }
            
            if(lstSRBU != null && !lstSRBU.isEmpty()) {
                insert lstSRBU;
            }
            */
            
            /*----lstApproverWrapper = new List<ApproverWrapper>();
            lstApproverWrapper.add(new ApproverWrapper('HOS', 'ABC', 1));
            lstApproverWrapper.add(new ApproverWrapper('Sales Admin', 'XYZ', 2));
            lstApproverWrapper.add(new ApproverWrapper('SVP', 'PQR', 3));
                
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Token refund request has been validated and sent to the authorities for further approval'));
        }
    }*/
    
    /*public pageReference goToAttachmentPage(){
        
        //Service_Request__c SR = new Service_Request__c();
        try{
        
        
        /*if(RecordSelection() == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select atleast one booking unit'));
            return null;
        }
        else{*/
            //showBookingDetails = false;
            //showApprovers = false;
            /*----if(objSR.Id != null){
                
            }
            else{
                //SR.id = srID;
            }
            
        //}
        pageReference pgr = new pageReference('/apex/UploadAttachment?id=' + objSR.id + '&page=TokenRefundProcess');
        return pgr;
        
        }
        catch(exception ex){
             ApexPages.AddMessages(ex);
             return null;
        }
    }*/
    
    /*public void removeAttachment(){
        if(String.isNotBlank(RemoveSelected)){
            SR_Attachments__c Sr = [Select id from SR_Attachments__c where id=: RemoveSelected];
            delete Sr;
            lstSRattachments = [Select id,name,SR__c,View__c,Attachment__c,type__C from SR_Attachments__c  where SR__c =: objSR.id];
            if(lstSRattachments.Size() <= 0){
                //blnBookingDetails = false;
                //showBookingDetails = false;
                //showApprovers = false;
            }
        }
    }*/
    
    /*public class ApproverWrapper {
        public String WRoleName {get;set;}
        public String WUsers {get;set;}
        public Integer WSequence{get;set;}
        
        public ApproverWrapper (String RoleName,String Users,Integer Sequence ){
            WRoleName = RoleName ;
            WUsers = Users ;
            WSequence= Sequence;
        }
    }*/
    
    /*public Class BookingUnitWrapper {
        public Id bookingUnitId {get; set;}
        public Boolean blnIsSelected {get; set;}
        public String strPropertyName {get; set;}
        public String strUnitName {get; set;}
        public Decimal decUnitValue {get; set;}
        public String strPropertyStatus {get; set;}
        public String strACD {get; set;}
        public String regId {get; set;}
        public Decimal decToken {get; set;}
        public Boolean blnIsBulkDeal {get; set;}
        public String strUnitStatus {get; set;}
        public Boolean blnIsOlderThan3Months {get; set;}
        public Boolean blnIsURCSigned {get; set;}
        public String strPaymentMethod {get; set;}
        
        
        public BookingUnitWrapper() {
            blnIsSelected = false;
            blnIsBulkDeal = false;
        }
    }*/
}