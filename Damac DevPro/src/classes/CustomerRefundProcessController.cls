public class CustomerRefundProcessController{   
    public Booking__c Booking {get;set;}
    public List<Booking_Unit__c> lstBookingUnit {get;set;}
    public Boolean showBooking {get;set;}
    public List<wrapper> lstWrapper {get;set;} 
    public List<Attachment> lstAttachment {get;set;}
    public Attachment ObjAttachment {get;set;}
    //public List<documentWrapper> lstDocumentWrapper{get;set;}
    public integer docCount ;
    public List<Service_request__c> lstObjSR ;
    public Boolean showAttachments {get;set;}
    public List<SR_Attachments__c> lstSRattachments {get;set;}
    public String srID;
    public String RemoveSelected {get;set;}
    public boolean showIPMSValue {get;set;}
    public boolean blnBookingDetails {get;set;}
    public boolean showBookingDetails {get;set;}
    public boolean showApprovers {get;set;}
    public String refundValue {get;set;}
    public Decimal RefundValuecounter = 0;
    public List<ApproverWrapper> lstApproverWrapper {get;set;}
    public List<BookingUnitWrapper> lstBookingUnitWrapper {get;set;}
    
    public CustomerRefundProcessController(){
        Booking = new Booking__c ();
        blnBookingDetails = false;
        showBookingDetails = false;
        showApprovers = false;
        lstObjSR = new List<Service_request__c>();
        lstSRattachments = new List<SR_Attachments__c>();
        srID = ApexPages.currentPage().getParameters().get('SRid')  ;
        refundValue = '0.00';
        if(String.isNotBlank(srID)){
            lstObjSR = [Select id,name,Account__c,(select id,SR__c,Booking_Unit__c
            from SR_Booking_Units__r),
            (Select id,name,SR__c,View__c,Attachment__c,type__c from SR_Attachments__r)
            from Service_request__c where id=:srID];
            if(lstObjSR.Size()>0){
                showAttachments = true;
                lstSRattachments = lstObjSR[0].SR_Attachments__r;
                if(lstSRattachments.Size() <= 0){
                    blnBookingDetails = false;
                }
                else{
                    blnBookingDetails = true;
                }                 
                Booking.Account__c = lstObjSR[0].Account__c;
                showBooking = true;
                showIPMSValue = true;
                showApprovers = true;
                lstWrapper = new List<Wrapper>();
                //Set<String> BookingUnitID = new Set<String>();
                //for(SR_Booking_Unit__c bou : lstObjSR[0].SR_Booking_Units__r){
                //    if(bou.Booking_Unit__c != null){
                //BookingUnitID.add(bou.Booking_Unit__c );
                //    }
                //}
                
                lstBookingUnit = [Select id,name,Property_Name__c,Inventory__c,
                Inventory__r.Property__r.Name,Unit_Selling_Price__c,
                Booking_Unit_Type__c, Inventory__r.Property_Status__c,
                Registration_ID__c, Inventory__r.Property_Name_2__c,
                Inventory__r.Unit__c, Inventory__r.ACD_Date__c, Unit_Selling_Price_AED__c 
                from Booking_Unit__c where Booking__r.Account__c =: Booking.Account__c 
                Order By Inventory__r.Property__r.Name ASC ];
                
                if(lstBookingUnit.Size()>0){
                    showBooking = true;
                    showIPMSValue = true;
                    for(Booking_Unit__c bu : lstBookingUnit){
                        lstWrapper.add(new wrapper(false,bu));
                    }
                }
                
                for(wrapper w : lstWrapper){
                    for(SR_Booking_Unit__c bou : lstObjSR[0].SR_Booking_Units__r){
                        if(w.WBU.id == bou.Booking_Unit__c){
                            w.Wselected = true;
                            break;
                        }
                    }
                }
            
            }
        }
    }
    
    public void bookingUnit(){
        lstBookingUnit = new List<Booking_Unit__c>();
        lstWrapper = new List<Wrapper>();
        List<Attachment> lstAttachment = new List<Attachment>();
        Attachment ObjAttachment = new Attachment();
        docCount = 0;
        //lstDocumentWrapper = new List<documentWrapper>();
        blnBookingDetails = false;
        showBooking = false;
        if(Booking.Account__c != null){       
            lstBookingUnit = [Select id,name,Property_Name__c,Inventory__c,
            Inventory__r.Property__r.Name,Unit_Selling_Price__c,
            Booking_Unit_Type__c, Inventory__r.Property_Status__c,
            Registration_ID__c, Inventory__r.Property_Name_2__c,
            Inventory__r.Unit__c, Inventory__r.ACD_Date__c, Unit_Selling_Price_AED__c 
            from Booking_Unit__c where Booking__r.Account__c =:
            Booking.Account__c Order By Inventory__r.Property__r.Name ASC ];
            
            if(lstBookingUnit.Size()>0){
                showBooking = true;
                showAttachments = true;
                showIPMSValue = true;
                showApprovers = true;
                for(Booking_Unit__c bu : lstBookingUnit){
                    lstWrapper.add(new wrapper(false,bu));
                }
            }
            else{
                showBooking = false;
                showAttachments = false;
                showIPMSValue = false;
                showApprovers = false;
            }
        }
        else{
            showBooking = false;
            showAttachments = false;
            showIPMSValue = false;
            showApprovers = false;
        }
    }

    public boolean RecordSelection(){
        boolean checkSelected = false;
        for(Wrapper w : lstWrapper){
            if(w.Wselected){
                checkSelected = true;
                break;
            }
        }
        return checkSelected;
    }
    
    public pageReference goToAttachmentPage(){    
        Service_Request__c SR = new Service_Request__c();
        try{                
        if(RecordSelection() == false){
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Error,'Please select atleast one booking unit'));
            return null;
        }
        else{
            showBookingDetails = false;
            showApprovers = false;
            if(String.isBlank(srID)){
                Id devRecordTypeId =
                Schema.SObjectType.Service_Request__c.getRecordTypeInfosByName().get('Customer Refund').getRecordTypeId();            
                SR.Account__C = Booking.Account__c;
                SR.RecordTypeID = devRecordTypeId;
                insert SR;
                srID = SR.id;
                System.debug('---SR---'+SR);
                List<SR_Booking_Unit__c> lstSRbookingUnit = new List<SR_Booking_Unit__c>();
                for(Wrapper w : lstWrapper){
                    if(w.Wselected){
                        SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
                        SRB.SR__c = SR.id;
                        SRB.Booking_Unit__c = w.WBU.id;
                        lstSRbookingUnit.add(SRB);
                    }
                }
                insert lstSRbookingUnit;
            }
            else{
                SR.id = srID;
            }
        
        }
        pageReference pgr = new pageReference('/apex/UploadAttachment?id='+srID+'&page=CustomerRefundProcess');
        return pgr;
        
        }
        catch(exception ex){
            ApexPages.AddMessages(ex);
            return null;
        }
    }

    public void removeAttachment(){
        if(String.isNotBlank(RemoveSelected)){
            SR_Attachments__c Sr = [Select id from SR_Attachments__c where id=: RemoveSelected];
            delete Sr;
            lstSRattachments = [Select id,name,SR__c,View__c,Attachment__c,type__C from SR_Attachments__c  where SR__c =: srID];
            if(lstSRattachments.Size() <= 0){
                blnBookingDetails = false;
                showBookingDetails = false;
                showApprovers = false;
            }
        }
    }

    public void BookingUnitDetails(){
        if(RecordSelection() == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select atleast one booking unit'));        
        }
        else{
            if(lstSRattachments.Size()>0){
                boolean mortgageUnit = false;
                lstBookingUnitWrapper = new List<BookingUnitWrapper>();
                showBookingDetails = true;
                showApprovers = true;
                for(Wrapper w : lstWrapper){
                    if(w.Wselected){
                        BookingUnitWrapper objBUW = new BookingUnitWrapper();
                        objBUW.bookingUnitId = w.WBU.Id;
                        objBUW.strPropertyName = w.WBU.Inventory__r.Property_Name_2__c;
                        objBUW.strUnitName = w.WBU.Inventory__r.Unit__c;
                        objBUW.decUnitValue = (w.WBU.Unit_Selling_Price_AED__c).setscale(3);
                        objBUW.strPropertyStatus = w.WBU.Inventory__r.Property_Status__c;
                        objBUW.strACD = w.WBU.Inventory__r.ACD_Date__c;
                        objBUW.regId = w.WBU.Registration_ID__c;
                        objBUW.strUnitStatus = 'Active';
                        objBUW.strPaymentMethod = 'Cash';
                        objBUW.blnMortgage = true;
                        objBUW.decExcessAmt_RefundLiability  = (w.WBU.Unit_Selling_Price__c/3).setscale(3);
                        if(objBUW.blnMortgage ){
                            mortgageUnit = true;
                        }                        
                        lstBookingUnitWrapper.add(objBUW);
                    }
                } 
                
                getApprovers(); 
                getRefundAmount();
                if(mortgageUnit){
                    boolean hasNOC = false;
                    for(SR_Attachments__c srAtt : lstSRattachments){
                        if(srAtt.type__c == 'NOC'){
                            hasNOC = true;
                            break;
                        }
                    }
                    if(hasNOC == false){
                        showApprovers = false; 
                        ApexPages.addmessage(new ApexPages.message
                        (ApexPages.severity.Error,'Please upload NOC document for Mortgage Unit'));
                    }
                }  
            }
            else{
                ApexPages.addmessage(new ApexPages.message
                (ApexPages.severity.Error,'Please upload documents first'));        
            }
        }
    }

    public void getRefundAmount(){
        if(lstSRattachments.Size()>0){
            RefundValuecounter  = 0;
            for(Wrapper bookingUnit : lstWrapper ){
                if(bookingUnit.WBU.Unit_Selling_Price__c != 0 
                && bookingUnit.WBU.Unit_Selling_Price__c != null && bookingUnit.Wselected){
                    RefundValuecounter+= bookingUnit.WBU.Unit_Selling_Price__c/3;
                }
            }
            refundValue = 'AED '+RefundValuecounter.setscale(3);
        }
        else{
            ApexPages.addmessage(new ApexPages.message
            (ApexPages.severity.Error,'Please upload documents first'));
        
        }
    }

    public void getApprovers(){
    
        lstApproverWrapper = new List<ApproverWrapper>();
        lstApproverWrapper.add(new ApproverWrapper('VP', 'Bhandari Gaurav, Kayzad Hiramanek', 1));
        lstApproverWrapper.add(new ApproverWrapper('SVP', 'Jamal Shareef, DAMAC Integration', 2));
        lstApproverWrapper.add(new ApproverWrapper('Chairman', 'Damac Admin, Jamal Shareef', 3));
    
    }

    public PageReference sendApproval(){
        if(String.isNotBlank(srID)){
            Service_Request__c ServiceRequest = [Select id,name from Service_Request__c where id=:srID];
            ServiceRequest.Excess_Amount__c = RefundValuecounter ;
            update ServiceRequest ;
            
            lstObjSR = [Select id,name,Account__c,(select id,SR__c,Booking_Unit__c from SR_Booking_Units__r),
            (Select id,name,SR__c,View__c,Attachment__c,type__c from SR_Attachments__r) from Service_request__c where id=:srID];
            
            for(BookingUnitWrapper w : lstBookingUnitWrapper ){
                for(SR_Booking_Unit__c bou : lstObjSR[0].SR_Booking_Units__r){
                    if(w.bookingUnitId  == bou.Booking_Unit__c){
                    bou.Excess_Amount_Refund_Liability_AED__c = w.decExcessAmt_RefundLiability  ;
                    bou.Unit_Status__c = w.strUnitStatus ;
                    bou.Is_Mortgage_Unit__c = w.blnMortgage ;                   
                    }
                }
            }
            if(lstObjSR[0].SR_Booking_Units__r.Size()>0){
                update lstObjSR[0].SR_Booking_Units__r;
            }
           
            PageReference pgr = new PageReference ('/'+srID);
            return pgr;                
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No service request found'));
            return null;
        }
    }

/*public void uploadDocument(){
ObjAttachment.OwnerId = UserInfo.getUserId();
ObjAttachment.ParentId = 'a0x7E000005d1th'; // the record the file is attached to
docCount ++;
lstDocumentWrapper.add(new documentWrapper(ObjAttachment,docCount)); 

}
*/

    public class wrapper {
    public boolean Wselected {get;set;}
    public Booking_Unit__c WBU {get;set;}
    
        public wrapper(boolean selected,Booking_Unit__c BU ){
            Wselected = selected ;
            WBU = BU;
        }
    }

    public class ApproverWrapper {
    public String WRoleName {get;set;}
    public String WUsers {get;set;}
    public Integer WSequence{get;set;}
    
        public ApproverWrapper (String RoleName,String Users,Integer Sequence ){
        WRoleName = RoleName ;
            WUsers = Users ;
            WSequence= Sequence;
        }
    }

/*public class documentWrapper{
public Attachment WA {get;set;}       
public Integer WAttNumber {get;set;}

public documentWrapper(Attachment Att, Integer AttNumber){
WA = Att;
WAttNumber = AttNumber;
}       
}*/
}