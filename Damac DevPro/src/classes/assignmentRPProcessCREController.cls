public without sharing class assignmentRPProcessCREController {
    public Booking_Unit__c objUnit {get;set;}
    public Case objCase {get;set;}
    public Buyer__c objBuyer {get;set;}
    public Account objSeller {get;set;}
    public Event objEvent {get;set;}
    public Attachment buyerPOA {get;set;}
    public Attachment sellerPOA {get;set;}
    public Attachment signedCRF {get;set;}
    public Attachment uploadLOA {get;set;}
    public List<SelectOption> lstUnits {get;set;}
    public List<SelectOption> lstTotalJointBuyers {get;set;}
    public list<selectoption> lstOptions {get;set;}
    public list<Case> lstExistingCase {get;set;}
    public String strSelectedUnit {get;set;}
    public String strJBCount {get;set;}
    String strAccoundId = '0017E00000cWKII'; 
    String strBookingId = 'a0y7E000001bZOH'; 
    public List<docInfo> lstDocs {get;set;}
    public List<docInfo> lstDocsNOC {get; set;}
    public List<paymentInfo> lstPayments {get;set;}
    public List<docInfo> lstAdditionalDocs {get;set;}
    public List<jointBuyer> lstJointBuyer {get;set;}
    map<Id,Booking_Unit__c> mapId_BookingUnit;
    public string buyerPoaDate {get;set;}
    public string sellerPoaDate {get;set;}
    public Decimal decTotal {get;set;}
    public boolean blnSectionOne {get;set;}
    public boolean blnSectionTwo {get;set;}
    public boolean blnSectionThree {get;set;}
    public boolean blnSectionFour {get;set;}
    public boolean blnSectionFive {get;set;}
    public boolean blnSectionAddDocs {get;set;}
    public string errorMessage{get;set;}
    public integer intDelIndex {get;set;}
    
    public assignmentRPProcessCREController (){
        init();
    }
    
    public void init(){
        lstUnits = new List<SelectOption>();
        mapId_BookingUnit = new map<Id,Booking_Unit__c>();
        lstUnits.add(new selectOption('None', '--None--'));
        for(Booking_Unit__c objBU : [Select Id
                                            , Name
                                            , Booking__c
                                            , Unit_Details__c 
                                            , Booking__r.Account__c
                                            , Inventory__r.Property__r.Name
                                            , Inventory__r.Property_City__c
                                            , Inventory__r.Bedroom_Type__c
                                            , Inventory__r.Unit_Type__c
                                            , Inventory__r.Property_Status__c
                                            , Permitted_Use__c
                                            , Rental_Pool__c
                                            , Inventory_Area__c
                                            , Unit_Selling_Price__c
                                            , Rental_Pool_End_Date__c
                                            , Rental_Pool_Start_Date__c
                                     From Booking_Unit__c
                                     Where Booking__r.Account__c =: strAccoundId 
                                     And Rental_Pool__c = true]){
            //strSelectedUnit = strSelectedUnit != null ? strSelectedUnit : objBU.Unit_Details__c;
            //strSelectedUnit = strSelectedUnit != null ? strSelectedUnit : objBU.Id;
            //objUnit = objUnit != null ? objUnit : objBU; 
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
            mapId_BookingUnit.put(objBU.Id, objBU);
        }
        strSelectedUnit = 'None';
        system.debug('mapId_BookingUnit*********'+mapId_BookingUnit);
        fetchUnitDetails();
        fetchSeller();
        
        blnSectionOne = false;
        blnSectionTwo = false;
        blnSectionThree = false;
        blnSectionFour = false;
        blnSectionFive = false;
        blnSectionAddDocs = false;
        objCase = new Case();
        objCase.Origin = 'CRE';
        
        buyerPOA = new Attachment();
        sellerPOA = new Attachment();
        //objCase.Status = 'New';
        List <Recordtype> lstCase_RT = fetchRecordtype('Case', 'Rental_Pool_Assignment');
        objCase.RecordtypeId = lstCase_RT[0].Id;
        objCase.Seller__c = strAccoundId;
        objCase.AccountId = strAccoundId;
        system.debug('objUnit***************'+objUnit);
        lstOptions = new list<selectoption>();
        lstOptions.add(new SelectOption('true','Yes'));
        lstOptions.add(new SelectOption('false','No'));
        
        lstTotalJointBuyers = new list<SelectOption>();
        strJBCount = '0';
        for(Integer i = 0; i<10; i++){
            lstTotalJointBuyers.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
    }
    
    public void fetchSeller(){
        list<Account> lstA = [Select a.PersonMobilePhone
                                   , a.PersonHomePhone
                                   , a.PersonEmail
                                   , a.Nationality__pc
                                   , a.LastName
                                   , a.IsPersonAccount
                                   , a.Id
                                   , a.Salutation
                                   , a.FirstName 
                                   From Account a
                                   where a.Id =: strAccoundId];
        if(lstA != null && !lstA.isEmpty()){
            objSeller = lstA[0];
        }
    }
    
    public list<Case> checkExistingSRExists(){
        set<String> setAllowedSRTypes = new set<String>();
        setAllowedSRTypes.add('Complaint');
        setAllowedSRTypes.add('POP');
        setAllowedSRTypes.add('Bounced_Cheque_SR');
        
        lstExistingCase = [Select c.Id
                                , c.Booking_Unit__c
                                , c.AccountId
                                , c.CaseNumber
                                , c.RecordType.DeveloperName
                                From Case c
                                where c.Booking_Unit__c =: strSelectedUnit
                                and c.Status != 'Closed'
                                and c.Status != 'Rejected'
                                and c.RecordType.DeveloperName NOT IN : setAllowedSRTypes];
        return lstExistingCase;
    }
    
    public void checkSRFlags(){
        
    }
    
    public void fetchUnitDetails(){
        if(checkExistingSRExists().size() <= 0){
            blnSectionOne = true;
            errorMessage = null;
            system.debug('No error*****'+strSelectedUnit);
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                checkSRFlags();
            }else{
                objUnit = null;
            }
        }else{
            blnSectionOne = false;
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                errorMessage = 'Error : A Service Request already exists for the chosen Booking Unit. You will be unable to proceed';
            }else{
                errorMessage = null;
            }
            system.debug('Raise ERROR*****');
        }
    }
    
    public list<Recordtype> fetchRecordtype(String strObject, String strDeveloperName){
      return [Select r.SobjectType
           , r.Name
           , r.Id
           , r.DeveloperName 
         From RecordType r 
         where SobjectType =: strObject 
         and DeveloperName =: strDeveloperName];
    }
    
    public void viewPaymentDetails(){
        system.debug('View reqn called***************');
        fetchDocumentsList();
        fetchPaymentsList();
        blnSectionTwo = true;
    }
    
    public void fetchPaymentsList(){
        lstPayments = new List<paymentInfo>();
        Long IntRandom = System.currentTimeMillis();
        decTotal = 0;
        paymentInfo objP1 = new paymentInfo();
        objP1.strType = 'Invoices which are due in 30 days';
        objP1.decAmount = 100;
        decTotal = decTotal + objP1.decAmount;
        lstPayments.add(objP1);
        paymentInfo objP2 = new paymentInfo();
        objP2.strType = 'Admin Fee for Assignment';
        objP2.decAmount = 250;
        decTotal = decTotal + objP2.decAmount;
        lstPayments.add(objP2);
        paymentInfo objP4 = new paymentInfo();
        objP4.strType = 'Penalties';
        objP4.decAmount = 200;
        decTotal = decTotal + objP4.decAmount;
        lstPayments.add(objP4);
        paymentInfo objP5 = new paymentInfo();
        objP5.strType = 'Other dues';
        objP5.decAmount = 150;
        decTotal = decTotal + objP5.decAmount;
        lstPayments.add(objP4);
        if(math.mod(IntRandom, 2) == 0){
            paymentInfo objP3 = new paymentInfo();
            objP3.strType = 'Overdues/dues towards Service Charges';
            objP3.decAmount = 300;
            decTotal = decTotal + objP3.decAmount;
            lstPayments.add(objP3);
        }
        system.debug('lstPayments********'+lstPayments);
    }
    
    public void fetchDocumentsList(){
        lstDocs = new List<docInfo>();
        //lstPayments = new list<paymentInfo>();
        Long IntRandom = System.currentTimeMillis();
        docInfo objD = new docInfo();
        objD.strType = 'PASSPORT COPY OF SELLER';
        objD.strRequired = 'Yes';
        objD.blnIsValid = true;
        objD.objAttachment = new Attachment();
        lstDocs.add(objD);
        
        docInfo objD1 = new docInfo();
        objD1.strType = 'PASSPORT COPY OF BUYER';
        objD1.strRequired = 'Yes';
        objD1.blnIsValid = true;
        objD1.objAttachment = new Attachment();
        lstDocs.add(objD1);
        
        docInfo objD2 = new docInfo();
        objD2.strType = 'COURT ORDER & SUCCESSION CERTIFICATE';
        objD2.strRequired = 'Yes';
        objD2.blnIsValid = false;
        objD2.objAttachment = new Attachment();
        lstDocs.add(objD2);
        system.debug('lstDocs********'+lstDocs);
    }
    
    public void submitCRF(){
        system.debug('buyerPoaDate*****'+buyerPoaDate);
        system.debug('sellerPoaDate*****'+sellerPoaDate);
        objCase.Booking_Unit__c = strSelectedUnit;
        objCase.Pending_Amount__c = decTotal;
        objCase.SR_Type__c = 'Rental Pool Assignment SR';
        objCase.Description = 'Rental Pool Assignment SR';
        objCase.Subject = 'Rental Pool Assignment SR';
        objCase.Mode_of_Collection__c = 'Courier';
        objCase.Rental_Pool_Contract_Start_Date__c	= objUnit.Rental_Pool_Start_Date__c;
        objCase.Rental_Pool_Contract_End_Date__c = objUnit.Rental_Pool_End_Date__c;
        if(!String.isBlank(buyerPoaDate)){
            List<String> parts = buyerPoaDate.split('/');
            objCase.POA_Expiry_Date__c = date.newinstance(integer.valueOf(parts[2]), integer.valueOf(parts[1]), integer.valueOf(parts[0]));
            //objCase.Buyer_POA__c = true;
        }
        if(!String.isBlank(sellerPoaDate)){
            List<String> parts = sellerPoaDate.split('/');
            objCase.POA_Expiry_Date_Seller__c = date.newinstance(integer.valueOf(parts[2]), integer.valueOf(parts[1]), integer.valueOf(parts[0]));
            //objCase.Seller_POA__c = true;
        }
        upsertCase();
        insertDocuments(lstDocs);
        createTask();
        lstDocs = null;
        lstAdditionalDocs = new List<docInfo>();
        objBuyer = new Buyer__c();
        insertPOADocs();
        //  //temporarily commented
        blnSectionThree = true;
        lstJointBuyer = new list<jointBuyer>();
    }
    
    /*public void skipAdditionalDocs(){
        blnSectionThree = true;
        lstJointBuyer = new list<jointBuyer>();
    }*/
    
    public void insertPOADocs(){
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();
        if(buyerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'BUYER POA';
            objSR.isValid__c = true;
            objSR.IsRequired__c = false;
            objSR.Case__c = objCase.Id;
            lstSrAttachment.add(objSR);
        }
        if(sellerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'SELLER POA';
            objSR.isValid__c = true;
            objSR.IsRequired__c = false;
            objSR.Case__c = objCase.Id;
            lstSrAttachment.add(objSR);
        }
        
        if(!lstSrAttachment.isEmpty()){
            insert lstSrAttachment;
          map<String,Id> mapDocName_RecordId = new map<String,Id>();
          for(SR_Attachments__c objSR : lstSrAttachment){
              mapDocName_RecordId.put(objSR.Name, objSR.Id);
          }
          system.debug('mapDocName_RecordId==='+mapDocName_RecordId);
          list<Attachment> lstAttachmentToInsert = new list<Attachment>();
          if(sellerPOA.Body != null){
              sellerPOA.ParentId = mapDocName_RecordId.get('SELLER POA');
              lstAttachmentToInsert.add(sellerPOA);
              system.debug('sellerPOA==='+sellerPOA);
          }
          if(buyerPOA.Body != null){
              buyerPOA.ParentId = mapDocName_RecordId.get('BUYER POA');
              lstAttachmentToInsert.add(buyerPOA);
              system.debug('buyerPOA==='+buyerPOA);
          }
          if(!lstAttachmentToInsert.isEmpty()){
              insert lstAttachmentToInsert;
              system.debug('lstAttachmentToInsert==='+lstAttachmentToInsert);
              map<Id,Id> mapParentId_AttachmentId = new map<Id,Id>(); 
              for(Attachment objAT : lstAttachmentToInsert){
                  mapParentId_AttachmentId.put(objAT.ParentId, objAT.Id);
              }
              
              for(SR_Attachments__c objSR : lstSrAttachment){
                  objSR.Attachment__c = mapParentId_AttachmentId.get(objSR.Id);
              }
              update lstSrAttachment;
              lstAttachmentToInsert = null;
              lstSrAttachment = null;
          }
        }
    }
    
    public void upsertBuyer(){
      objBuyer.Booking__c = strBookingId;
      objBuyer.Buyer_Type__c = objCase.Buyer_Type__c;
      //objBuyer.Date_of_Birth__c = String.valueOf('12/08/1980'); //objBuyer.DOB__c
      //objBuyer.Passport_Expiry_Date__c = String.valueOf('12/08/2050'); //
      /*objBuyer.Organisation_Name__c = 'Organization Name TEMP';
      objBuyer.Organisation_Name_Arabic__c = 'Organization Name Arabic TEMP';
      objBuyer.CR_Registration_Place_Arabic__c = 'CR Reg Arabic TEMP';
      objBuyer.CR_Number__c = 'CR NUMBER TEMP';
      objBuyer.CR_Registration_Expiry_Date__c  = '12/12/2025';
      objBuyer.CR_Registration_Place__c  = 'CR REG PLACE TEMP';*/
      upsert objBuyer;
      objCase.Buyer__c = objBuyer.Id;
      upsertCase();
      signedCRF = new Attachment();
      uploadLOA = new Attachment();
      blnSectionFour = true;
    }
    
    public void generateLOA(){
        SR_Attachments__c objSR = new SR_Attachments__c();
        objSR.Name = 'Signed CRF';
        objSR.isValid__c = false;
        objSR.IsRequired__c = false;
        objSR.Case__c = objCase.Id;
        insert objSR;
        
        signedCRF.ParentId = objSR.Id;
        insert signedCRF;
        
        objSR.Attachment__c = signedCRF.Id;
        update objSR;
        signedCRF = null;
        blnSectionFive = true;

        List<String> listDocTypeNOC = new list<String> {
            'Signed LOA',
            'Signed Undertaking Letter',
            'RP Agreement'
        };

        fetchDocumentsListNOC(listDocTypeNOC);
    }
    
    public void fetchDocumentsListNOC(List<String> listDocType){
        lstDocsNOC = new List<docInfo>();

        for (String strDocType : listDocType) {
            docInfo objDocInfo = new docInfo();
            objDocInfo.strType = strDocType;
            objDocInfo.strRequired = 'Yes';
            objDocInfo.blnIsValid = false;
            objDocInfo.objAttachment = new Attachment();
            lstDocsNOC.add(objDocInfo);
        }
    }

    public pageReference viewCRF(){
        Pagereference pg = Page.CRF;
        pg.getParameters().put('Id',objCase.Id);
        pg.getParameters().put('recTypeName','Assignment');
        pg.setRedirect(true);
        return pg;
    }
    
    public void printNOC(){
        /*SR_Attachments__c objSR = new SR_Attachments__c();
        objSR.Name = 'Signed LOA';
        objSR.isValid__c = false;
        objSR.IsRequired__c = false;
        objSR.Case__c = objCase.Id;
        insert objSR;
        
        uploadLOA.ParentId = objSR.Id;
        insert uploadLOA;
        
        objSR.Attachment__c = uploadLOA.Id;
        update objSR;
        uploadLOA = null;*/
        
        insertDocuments(lstDocsNOC);
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
    
    /*public void insertAdditionalDocument(){
        insertDocuments(lstAdditionalDocs);
        blnSectionThree = true;
        lstJointBuyer = new list<jointBuyer>();
    }*/
    
    public void addJointBuyer(){
        jointBuyer newJB = new jointBuyer();
        newJB.objJointBuyer = new Buyer__c ();
        newJB.objJointBuyer.Country__c = 'United Arab Emirates';
        newJB.intIndex = lstJointBuyer.size();
        lstJointBuyer.add(newJB);
        system.debug('lstJointBuyer**********'+lstJointBuyer);
    }
    
    public void removeJointBuyer(){
        system.debug('intDelIndex*********'+intDelIndex);
        if(intDelIndex != null){
            lstJointBuyer.remove(intDelIndex);
            Integer intInd = 0;
            for(jointBuyer objJB : lstJointBuyer){
                objJB.intIndex = intInd;
                intInd++;
            }
        }
    }
    
    public void createTask() {
    	Task objTask  = new Task();
            objTask.Subject = 'Verify Documents';
            objTask.WhatID = objCase.Id ; 
            objTask.OwnerId = '0050Y000001SBsP';
            objTask.status = 'In Progress';
            objTask.priority= 'Medium';
            objTask.Process_Name__c = 'Rental Pool Assignment';
            insert objTask;
    }
    
    public void insertDocuments(list<docInfo> lstDocs){
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();
        for(docInfo objDI : lstDocs){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = objDI.strType;
            objSR.isValid__c = objDI.blnIsValid;
            objSR.IsRequired__c = objDI.strRequired == 'Yes' ? true: false;
            objSR.Case__c = objCase.Id;
            lstSrAttachment.add(objSR);
        }
        if(!lstSrAttachment.isEmpty()){
            insert lstSrAttachment;
          map<String,Id> mapName_Id = new map<String,Id>();
          for(SR_Attachments__c objSR : lstSrAttachment){
              mapName_Id.put(objSR.Name, objSR.Id);
          }
          
          list<Attachment> lstAttachmentToInsert = new list<Attachment>();
          for(docInfo objDI : lstDocs){
                if(objDI.objAttachment.Body != null){
                 objDI.objAttachment.ParentId = mapName_Id.get(objDI.strType);
                 lstAttachmentToInsert.add(objDI.objAttachment);
            }
          }
          if(!lstAttachmentToInsert.isEmpty()){
              insert lstAttachmentToInsert;
              map<Id,Id> mapParent_Id = new map<Id,Id>();
              for(Attachment objA : lstAttachmentToInsert){
                  mapParent_Id.put(objA.ParentId, objA.Id);
              }
              lstSrAttachment = null;
              lstSrAttachment = new list<SR_Attachments__c>();
              for(Id objId : mapParent_Id.keySet()){
                  SR_Attachments__c objSR = new SR_Attachments__c();
                  objSR.Id = objId;
                  objSR.Attachment__c = mapParent_Id.get(objId);
                  lstSrAttachment.add(objSR);
              }
              update lstSrAttachment;
              lstSrAttachment = null;
          }
        }
    }
    
    public void upsertCase(){
        upsert objCase;
    }
    
    public class paymentInfo {
        public String strType {get;set;}
        public Decimal decAmount {get;set;}
        
        public paymentInfo(){
        
        }
    } //end of paymentInfo
    
    public class docInfo {
        public Attachment objAttachment {get;set;}
        public String strType {get;set;}
        public String strRequired {get;set;}
        public boolean blnIsValid {get;set;}
        
        public docInfo(){
            
        }
    } // end of docInfo
    
    public class attachmentWrapper {
        public Attachment objA {get;set;}
        public string strName {get;set;}
        public boolean blnIsValid {get;set;}
        public attachmentWrapper(){
            
        }
    }
    
    public class jointBuyer {
        public Integer intIndex {get;set;}
        public Buyer__c objJointBuyer {get;set;}
        
        public jointBuyer(){
            
        }
    }
}