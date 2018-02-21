public without sharing class assignmentProcessController{
    public Attachment objBuyerPassport {get;set;}
    public Case objCase {get;set;}
    public Buyer__c objBuyer {get;set;}
    public Account objSeller {get;set;}
    public Event objEvent {get;set;}
    
    public List<SelectOption> lstUnits {get;set;}
    public List<SelectOption> lstPOA {get;set;}
    public String strSelectedUnit {get;set;}
    
    public List<docInfo> lstDocs {get;set;}
    public List<paymentInfo> lstPayments {get;set;}
    
    public Decimal decTotal {get;set;}
    String strAccoundId = '0017E00000aqdaS';
    String strBookingId = 'a0y7E000003PAd0';
    public string buyerPoaDate {get;set;}
    public string sellerPoaDate {get;set;}
    public string scheduledDate {get;set;}
    public boolean sellerPOA {get;set;}
    public boolean buyerPOA {get;set;}
    public boolean blnStep1 {get;set;}
    public boolean blnReqn {get;set;}
    public boolean blnStep2 {get;set;}
    public boolean blnPOA {get;set;}
    public boolean blnStep3 {get;set;}
    public boolean blnStep4 {get;set;}
    public boolean blnStep5 {get;set;}
    
    public assignmentProcessController(){
        blnStep1 = true;
        blnReqn = false;
        blnStep2 = false;
        blnPOA = false;
        blnStep3 = false;
        blnStep4 = false;
        blnStep5 = false;
        init();
    } // end of assignmentProcessController
    
    public list<Recordtype> fetchRecordtype(String strObject, String strDeveloperName){
      return [Select r.SobjectType
           , r.Name
           , r.Id
           , r.DeveloperName 
         From RecordType r 
         where SobjectType =: strObject 
         and DeveloperName =: strDeveloperName];
  	}
  	
    public void init(){
        decTotal = 0;
        objCase = new Case();
        objCase.Origin = 'Community';
        lstDocs = new List<docInfo>();
        lstPayments = new List<paymentInfo>();
        objCase.Status = 'New';
        List <Recordtype> lstCase_RT = fetchRecordtype('Case', 'Assignment');
        objCase.RecordtypeId = lstCase_RT[0].Id;
        objCase.Seller__c = strAccoundId;
        
        decTotal = 0;
        lstUnits = new List<SelectOption>();
        lstPOA = new List<SelectOption>();
        for(Booking_Unit__c objBU : [Select Id
                                            , Name
                                            , Booking__c
                                            , Unit_Details__c 
                                            , Booking__r.Account__c
                                     From Booking_Unit__c
                                     Where Booking__r.Account__c =: strAccoundId]){
            strSelectedUnit = strSelectedUnit != null ? strSelectedUnit : objBU.Unit_Details__c; 
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
        }
        lstPOA.add(new selectOption('true','Yes'));
        lstPOA.add(new selectOption('false','No'));
        sellerPOA = false;
        buyerPOA = false;
    } // end of init
    
    public void viewRequirements(){
        system.debug('View reqn called***************');
        fetchDocumentsList();
        fetchPaymentsList();
        blnReqn = true;
    }
    
    public void fetchDocumentsList(){
        lstDocs = new List<docInfo>();
        //lstPayments = new list<paymentInfo>();
        Long IntRandom = System.currentTimeMillis();
        docInfo objD = new docInfo();
        objD.strType = 'PASSPORT COPY OF SELLER';
        objD.strRequired = 'Yes';
        objD.blnIsValid = false;
        objD.objAttachment = new Attachment();
        lstDocs.add(objD);
        
        docInfo objD1 = new docInfo();
        objD1.strType = 'PASSPORT COPY OF BUYER';
        objD1.strRequired = 'Yes';
        objD1.blnIsValid = false;
        objD1.objAttachment = new Attachment();
        lstDocs.add(objD1);
        docInfo objD2 = new docInfo();
        objD2.strType = 'COMPANY DOCUMENT';
        objD2.strRequired = 'Yes';
        objD2.blnIsValid = false;
        objD2.objAttachment = new Attachment();
        lstDocs.add(objD2);
        if(math.mod(IntRandom, 4) == 0){
            docInfo objD3 = new docInfo();
            objD3.strType = 'MINOR DECLARATION FORM';
            objD3.strRequired = 'No';
            objD3.blnIsValid = false;
            objD3.objAttachment = new Attachment();
            lstDocs.add(objD3);
        }
        system.debug('lstDocs********'+lstDocs);
    }
    
    public void fetchPaymentsList(){
        lstPayments = new List<paymentInfo>();
        Long IntRandom = System.currentTimeMillis();
        decTotal = 0;
        paymentInfo objP1 = new paymentInfo();
        objP1.strType = 'INVOICES WHICH ARE DUE IN 30 DAYS';
        objP1.decAmount = 100;
        decTotal = decTotal + objP1.decAmount;
        lstPayments.add(objP1);
        paymentInfo objP2 = new paymentInfo();
        objP2.strType = 'ADMIN CHARGES';
        objP2.decAmount = 250;
        decTotal = decTotal + objP2.decAmount;
        lstPayments.add(objP2);
        if(math.mod(IntRandom, 2) == 0){
            paymentInfo objP3 = new paymentInfo();
            objP3.strType = 'OVERDUES TOWARDS INSTALMENTS';
            objP3.decAmount = 300;
            decTotal = decTotal + objP3.decAmount;
            lstPayments.add(objP3);
        }
        system.debug('lstPayments********'+lstPayments);
    }
    
    //public pageReference redAssignmentReq(){
    public void insertCase(){
        objCase.Booking_Unit__c = strSelectedUnit;
        objCase.Payment_Verified__c = true;
        objCase.Seller_POA__c = sellerPOA;
        objCase.Buyer_POA__c = buyerPOA;
        upsertCase();
        insertPayments();
        blnStep2 = true;
    }
    
    public void insertPayments(){
    	List<Payment_Detail__c> lstPay = new List<Payment_Detail__c>(); 
        for(paymentInfo objP : lstPayments){
          Payment_Detail__c objPay = new Payment_Detail__c();
          objPay.Case__c = objCase.Id;
          objPay.Amount_Paid__c = objP.decAmount;
          objPay.Pending_Amount__c = objP.decAmount;
          objPay.Payment_Detail__c = objP.strType;
          lstPay.add(objPay);
        }
        insert lstPay;
    }
    
    public void saveAsDraft(){
      upsertCase();
    } // end of save as draft
    
    public void upsertCase(){
      upsert objCase;
    } // end of upsertCase
    
    public void insertAttachment(){
        list<Attachment> lstAttachmentToInsert = new list<Attachment>(); 
        for(docInfo objDI : lstDocs){
          if(objDI.objAttachment.Body != null){
            objDI.objAttachment.ParentId = objCase.Id;
            lstAttachmentToInsert.add(objDI.objAttachment);
          }
        }
        insert lstAttachmentToInsert;
        lstAttachmentToInsert = null;
        lstDocs = null;
        system.debug('lstAttachmentToInsert*************'+lstAttachmentToInsert);
        objBuyerPassport = new Attachment();
        blnPOA = true;
    }
    
    public void upsertBuyer(){
      objBuyer.Booking__c = strBookingId;
      objBuyer.Buyer_Type__c = objCase.Buyer_Type__c;
      //objBuyer.Date_of_Birth__c = String.valueOf('12/08/1980'); //objBuyer.DOB__c
      //objBuyer.Passport_Expiry_Date__c = String.valueOf('12/08/2050'); //
      objBuyer.Phone_Country_Code__c = 'India: 0091';
      upsert objBuyer;
      objCase.Buyer__c = objBuyer.Id;
      upsertCase();
    }
    
    public void updatePOA(){
        system.debug('update poa called*****');
        objBuyer = new Buyer__c();
        upsertCase();
        blnStep3 = true;
        system.debug('blnStep3*****'+blnStep3);
    }
    
    public void submit(){
      objCase.Status = 'Submitted';
      upsertBuyer();
      blnStep4 = true;
    } // end of submit
    
    public void scheduleEvent(){
    	system.debug('scheduledDate************'+scheduledDate);
    	objEvent = new Event();
    	objEvent.OwnerId = UserInfo.getUserId();
    	objEvent.Subject = 'Appointment Scheduled for '+objBuyer.First_Name__c + objBuyer.Last_Name__c;
    	objEvent.Type = 'Meeting';
    	objEvent.WhatId = objCase.Id;
        String stmth = scheduledDate.subString(0,2);
        String stdt = scheduledDate.subString(3,5);
        String styr = scheduledDate.subString(6,10);
        system.debug(styr);
        system.debug(stmth);
        system.debug(stdt);
    	objEvent.StartDateTime = Datetime.newInstance(integer.valueOf(styr), integer.valueOf(stmth), integer.valueOf(stdt), 10, 00, 00);
    	objEvent.DurationInMinutes = 30;
    	insert objEvent;
    	blnStep5 = true;
    }
    
    public void view(){
        
    }
    
    public void generateLOA(){
      
    }
    
    public class docInfo {
        public String strType {get;set;}
        public String strRequired {get;set;}
        public Attachment objAttachment {get;set;}
        public boolean blnIsValid {get;set;}
        public docInfo (){
            
        }
    } // end of docInfo
    
    public class paymentInfo {
        public String strType {get;set;}
        public Decimal decAmount {get;set;}
        public paymentInfo (){
        
        }
    } //end of paymentInfo
}