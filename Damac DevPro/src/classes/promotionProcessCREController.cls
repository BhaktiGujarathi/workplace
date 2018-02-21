public without sharing class promotionProcessCREController {
    public Case objCase {get;set;}
    public Booking_Unit__c objUnit {get;set;}
    public Attachment buyerPOA {get;set;}
    public Attachment uploadAgreement {get;set;}
    public List<SelectOption> lstUnits {get;set;}
    public List<SelectOption> lstCategories {get;set;}
    public list<Case> lstExistingCase {get;set;}
    public list<promotionInnerClass> lstpromotion {get;set;}
    public String strSelectedUnit {get;set;}
    public String strSelectedCategory {get;set;}
    String strAccoundId = '0017E00000aqdaS';
    String strBookingId = 'a0y7E000003PAd0';
    map<Id,Booking_Unit__c> mapId_BookingUnit;
    public Account objSeller {get;set;}
    public string errorMessage{get;set;}
    public boolean blnSectionOne {get;set;}
    public boolean blnSectionTwo {get;set;}
    public boolean disablePromotion {get;set;}
    
    public promotionProcessCREController(){
        init();
    }
    
    public void init(){
        disablePromotion = false;
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
                                            , Inventory__r.Building_Location__c
                                            , Inventory__r.Building_Location__r.Status__c
                                            , Permitted_Use__c
                                            , Rental_Pool__c
                                            , Inventory_Area__c
                                            , Unit_Selling_Price__c
                                     From Booking_Unit__c
                                     Where Booking__r.Account__c =: strAccoundId]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
            mapId_BookingUnit.put(objBU.Id, objBU);
        }
        strSelectedUnit = 'None';
        objCase = new Case();
        objCase.Origin = 'CRE';
        List <Recordtype> lstCase_RT = fetchRecordtype('Case', 'Promotion_Package');
        objCase.RecordtypeId = lstCase_RT[0].Id;
        //objCase.Buyer__c = strAccoundId;
        objCase.AccountId = strAccoundId;
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        strSelectedCategory = 'Unit Details';
        blnSectionOne = false;
        blnSectionTwo = false;
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
    
    public void fetchUnitDetails(){
        if(checkExistingSRExists().size() <= 0){
            errorMessage = null;
            system.debug('No error*****'+strSelectedUnit);
            if(strSelectedUnit != 'None'){
                blnSectionOne = true;
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
            }else{
                objUnit = null;
            }
        }else{
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                errorMessage = 'Error : A Service Request already exists for the chosen Booking Unit. You will be unable to proceed';
            }else{
                errorMessage = null;
            }
            system.debug('Raise ERROR*****');
        }
        buyerPOA = new Attachment();
        uploadAgreement = new Attachment();
        fetchPromotionPackages();
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
        set<String> setNotAllowedSRTypes = new set<String>();
        setNotAllowedSRTypes.add('AOPT');
        setNotAllowedSRTypes.add('Assignment');
        setNotAllowedSRTypes.add('Bounced_Cheque_SR');
        setNotAllowedSRTypes.add('Change_of_Details');//Plot_Handover
        setNotAllowedSRTypes.add('Plot_Handover');
        
        lstExistingCase = [Select c.Id
                                , c.Booking_Unit__c
                                , c.AccountId
                                , c.CaseNumber
                                , c.RecordType.DeveloperName
                                From Case c
                                where c.Booking_Unit__c =: strSelectedUnit
                                and c.Status != 'Closed'
                                and c.Status != 'Rejected'
                                and c.RecordType.DeveloperName IN : setNotAllowedSRTypes];
        return lstExistingCase;
    }
    
    public void fetchPromotionPackages(){
        lstPromotion = new list<promotionInnerClass>();
        for(Promotion_Package__c objFN : [Select Id, Name, Type__c, Total_Units__c, Available_Units__c,
                                            Price__c, Allocated_Units__c, Payment_Plan__c, Blocked_Units__c
                                            from Promotion_Package__c where Available_Units__c > 0]){
            system.debug('objFN=='+objFN);
            promotionInnerClass objC = new promotionInnerClass();
            objC.blnSelect = false;
            objC.objPromotion = objFN;
            lstPromotion.add(objC);
        }
        if(lstPromotion.isEmpty()) {
            errorMessage = 'Error : No Promotion Package Available';
            blnSectionOne = false;
        }
        system.debug('lstPromotion=='+lstPromotion);
    }

    public void uploadPromotionAgreement() {
        blnSectionTwo = true;
        disablePromotion = true;
    }

    public void createPromotionAllocation(){
        
        system.debug('objCase.POA_Expiry_Date__c*****'+objCase.POA_Expiry_Date__c);
        ObjCase.Booking_Unit__c = strSelectedUnit;
        
        system.debug('objCase=='+objCase);
        Promotion_Package__c promotionObj = new Promotion_Package__c();
        Promotion_Package_Allocation__c objFA = new Promotion_Package_Allocation__c();
        objFA.Booking_Unit__c = strSelectedUnit;
        
        
        for(promotionInnerClass obj : lstPromotion){
            if(obj.blnSelect){
                objFA.Promotion_Package__c = obj.objPromotion.Id;
                if(obj.objPromotion.Price__c != null) {
                    objCase.Pending_Amount__c = obj.objPromotion.Price__c;
                }
                promotionObj.Id = obj.objPromotion.Id;
                if(obj.objPromotion.Blocked_Units__c != null) {
                    promotionObj.Blocked_Units__c = obj.objPromotion.Blocked_Units__c + 1;
                } else {
                    promotionObj.Blocked_Units__c = 1;
                }
            }
        }
        insert objCase;
        objFA.Case__c = objCase.Id;
        insert objFA;
        update promotionObj;
        //insertPOADocs();
    }

    /*public void insertPOADocs(){
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();
        system.debug('buyerPOA.Body*********'+buyerPOA.Body);
        if(buyerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'BUYER POA';
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
    }*/
    
    public void submitCase(){
        createPromotionAllocation();
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();
        if(uploadAgreement.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'Promotion Package Agreement';
            objSR.isValid__c = true;
            objSR.IsRequired__c = false;
            objSR.Case__c = objCase.Id;
            lstSrAttachment.add(objSR);
        }
        if(buyerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'BUYER POA';
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
            if(uploadAgreement.Body != null){
                uploadAgreement.ParentId = mapDocName_RecordId.get('Promotion Package Agreement');
                lstAttachmentToInsert.add(uploadAgreement);
                system.debug('uploadAgreement==='+uploadAgreement);
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
        blnSectionTwo = true;
    }
    
    /*public void submitCase(){
        //objCase.Status = 'Submitted';
        update objCase;
    }*/
    
    public void soa(){
        
    }
    
    public class promotionInnerClass{
        public boolean blnSelect {get;set;}
        public Promotion_Package__c objPromotion {get;set;}
        
        public promotionInnerClass(){
            
        }
    }
}