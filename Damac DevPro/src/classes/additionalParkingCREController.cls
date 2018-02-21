public without sharing class additionalParkingCREController {
    public Case objCase {get;set;}
    public Booking_Unit__c objUnit {get;set;}
    public List<SelectOption> lstUnits {get;set;}
    public List<SelectOption> lstCategories {get;set;}
    public list<Case> lstExistingCase {get;set;}
    public list<parkingWrapper> lstParking {get;set;}
    public list<parkingOffPlanWrapper> lstParkingOffPlan {get;set;}
    public map<String, List<String>> mapPayPlanTerms {get;set;}
    public String paymentPlanName {get;set;}
    public String strSelectedUnit {get;set;}
    public String strSelectedCategory {get;set;}
    String strAccoundId = '0017E00000aqdaS';
    String strBookingId = 'a0y7E000003PAd0';
    map<Id,Booking_Unit__c> mapId_BookingUnit;
    public Account objSeller {get;set;}
    public string errorMessage{get;set;}
    public boolean blnSectionTwo {get;set;}
    public boolean blnSectionThree {get;set;}
    public boolean blnSectionFour {get;set;}
    public boolean blnSectionFive {get;set;}
    public boolean readyBuilding {get;set;}
    public boolean offPlanBuilding {get;set;}
    public Attachment buyerPOA {get;set;}
    public Attachment ParkingReqForm {get;set;}
    public Integer counterValue {get;set;} 
    public Integer counterValueOffPlan {get;set;}
    public Decimal totalPrice {get;set;}
    public Boolean disablePayParking {get;set;}
    public Boolean disablePayPlan {get;set;}
    public Boolean disableParking {get;set;}
    public Boolean disableParkingReq {get;set;}
    public String BuildingLocation;
    public map<String, list<Parking__c>> mapOffPlanParkingType;

    public additionalParkingCREController(){
        init();
    }
    
    public void init(){
        totalPrice = 0.00;
        blnSectionTwo = false;
        blnSectionThree = false;
        blnSectionFour = false;
        blnSectionFive = false;
        disablePayParking = false;
        disablePayPlan = false;
        disableParkingReq = false;
        lstUnits = new List<SelectOption>();
        mapId_BookingUnit = new map<Id,Booking_Unit__c>();
        lstUnits.add(new selectOption('None', '--None--'));
        for(Booking_Unit__c objBU : [Select Id
                                            , Registration_ID__c
                                            , Name
                                            , Booking__c
                                            , Unit_Details__c
                                            , Unit_Type__c
                                            , Permitted_Use__c
                                            , Rental_Pool__c
                                            , Inventory_Area__c
                                            , Unit_Selling_Price__c
                                            , Booking_Undergoing_Termination__c
                                            , NOC_Issued_Date__c
                                            , Dispute__c
                                            , Enforcement__c
                                            , Litigation__c
                                            , Counter_Case__c
                                            , Mortgage__c
                                            , Re_Assigned__c
                                            , Penalty_Amount__c
                                            , Token_Amount_val__c
                                            , Booking_Type__c
                                            , DP_Overdue__c
                                            , Plot_Price__c
                                            , Booking__r.CreatedDate
                                            , Agreement_Date__c
                                            , JOPD_Area__c
                                            , DP_OK__c
                                            , Doc_OK__c
                                            , OQOOD_Reg_Flag__c
                                            , Early_Handover__c
                                            , Handover_Flag__c
                                            , PCC_Release__c
                                            , Construction_Status__c
                                            , Area_Varied__c
                                            , No_of_parking__c
                                            , Booking__r.Account__c
                                            , Inventory__r.Property__r.Name
                                            , Inventory__r.Property_City__c
                                            , Inventory__r.Unit_Type__c
                                            , Inventory__r.Property_Status__c
                                            , Inventory__r.Building_Code__c
                                            , Inventory__r.Bedroom_Type__c
                                            , Inventory__r.Building_Location__c
                                            , Inventory__r.Floor_Plan__c
                                            , Inventory__r.Unit_Plan__c
                                     From Booking_Unit__c
                                     Where Booking__r.Account__c =: strAccoundId
                                     and Re_Assigned__c = false]){
            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
            mapId_BookingUnit.put(objBU.Id, objBU);
        }
        strSelectedUnit = 'None';
        objCase = new Case();
        objCase.Origin = 'CRE';
        List <Recordtype> lstCase_RT = fetchRecordtype('Case', 'Parking');
        objCase.RecordtypeId = lstCase_RT[0].Id;
        objCase.Seller__c = strAccoundId;
        
        buyerPOA = new Attachment();
        ParkingReqForm = new Attachment();
        blnSectionTwo = false;
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        strSelectedCategory = 'Unit Details';
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

    public void fetchParking(Booking_Unit__c bookingUnitObj){
        readyBuilding = false;
        offPlanBuilding = false;
        lstParking = new list<parkingWrapper>();
        lstParkingOffPlan = new list<parkingOffPlanWrapper>();
        map<String, Integer> mapOffPlanParking = new map<String, Integer>();
        map<String, Decimal> mapParkingTypePrice = new map<String, Decimal>();
        map<String, Parking_Type__c> mapParkingType = new map<String, Parking_Type__c>(); 
        mapOffPlanParkingType = new map<String, list<Parking__c>>();
        if(bookingUnitObj.Inventory__c != null) {
            if(bookingUnitObj.Inventory__r.Building_Location__c != null) {
                BuildingLocation = bookingUnitObj.Inventory__r.Building_Location__c;
                for(Parking_Type__c objParkingType: [select Id, Name, Building__c, CoA_Approved_Price__c
                                                     from Parking_Type__c 
                                                     where Building__c =: BuildingLocation]) {
                    mapParkingType.put(objParkingType.Name, objParkingType);
                }
                if(bookingUnitObj.Inventory__r.Property_Status__c == 'Ready') {
                    readyBuilding = true;
                }
                else if(bookingUnitObj.Inventory__r.Property_Status__c == 'Off Plan') {
                    //readyBuilding = true;
                    offPlanBuilding = true;
                }
                for(Parking__c objParking: [select Id, Building__c, Availability__c, Type__c, Name,
                                            Parking_Bay_Floor__c, CoA_Approved_Price__c, Building__r.Status__c,
                                            Parking_Type__r.Name, Parking_Type__r.CoA_Approved_Price__c
                                            from Parking__c 
                                            where Building__c =: bookingUnitObj.Inventory__r.Building_Location__c 
                                            and Availability__c = 'Available for Allocation' and
                                            Allocated_to_Booking_Unit__c = null]) {
                    if(!objParking.Name.startsWithIgnoreCase('TBD')) {
                        parkingWrapper parkingWrapObj = new parkingWrapper();
                        parkingWrapObj.blnSelect = false;
                        parkingWrapObj.objParking = objParking;
                        lstParking.add(parkingWrapObj);
                    }
                    else {
	                    mapParkingTypePrice.put(objParking.Parking_Type__r.Name, 
	                                                objParking.Parking_Type__r.CoA_Approved_Price__c);
	                    if(mapOffPlanParking.containsKey(objParking.Parking_Type__r.Name)) {
	                        mapOffPlanParking.put(objParking.Parking_Type__r.Name, 
	                            mapOffPlanParking.get(objParking.Parking_Type__r.Name)+1);

	                        mapOffPlanParkingType.get(objParking.Parking_Type__r.Name).add(objParking);
	                    }
	                    else {
                            mapOffPlanParking.put(objParking.Parking_Type__r.Name, 1);

                            mapOffPlanParkingType.put(objParking.Parking_Type__r.Name,
                                new list<Parking__c> {objParking});
                        }
                    }
                    system.debug('mapOffPlanParking==='+mapOffPlanParking);
                }
                if((readyBuilding && lstParking.isEmpty()) || offPlanBuilding && mapOffPlanParking.isEmpty()) {
                    errorMessage = 'Error : No Parking Available for this Unit';
                    blnSectionTwo = false;
                }
                else {
                    blnSectionTwo = true;
                }
                if(!mapOffPlanParking.isEmpty()) {
                    for(String strParkingType: mapOffPlanParking.keySet()) {
                        Integer counterVal = mapOffPlanParking.get(strParkingType);
                        List<SelectOption> lstParkingUnits = new List<SelectOption>();
                        lstParkingUnits.add(new selectOption('None', '--None--')); 
                        for(Integer i=1; i<=counterVal && i<=5; i++) {
                            lstParkingUnits.add(new selectOption(''+i,''+i));
                        }
                        parkingOffPlanWrapper objParkingOffPlan = new parkingOffPlanWrapper();
                        //objParkingOffPlan.parkingType = strParkingType;
                        objParkingOffPlan.parkingUnits = lstParkingUnits;
                        //objParkingOffPlan.parkingPrice = mapParkingTypePrice.get(strParkingType);
                        objParkingOffPlan.parkingType = mapParkingType.get(strParkingType);
                        lstParkingOffPlan.add(objParkingOffPlan);
                    }
                    system.debug('lstParkingOffPlan==='+lstParkingOffPlan);
                }
            }
        }
    }

    public void getPaymentPlans() {
        set<Id> setSelectedParkingId = new set<Id>();
        mapPayPlanTerms = new map<String, List<String>>();
        //blnSectionTwo = false;
        blnSectionThree = true;
        disablePayParking = true;
        if(String.isNotBlank(BuildingLocation)) {
            for(Payment_Terms__c objPayTerm: [select Id, Payment_Plan__r.Name, Description__c, 
                                               Milestone_Event__c, Percent_Value__c 
                                               from Payment_Terms__c
                                               where Payment_Plan__r.Building_Location__c =: BuildingLocation]) {
                if(objPayTerm.Payment_Plan__c != null) {
                    if(mapPayPlanTerms.containsKey(objPayTerm.Payment_Plan__r.Name)) {
                        if(String.isNotBlank(objPayTerm.Description__c) && String.isNotBlank(objPayTerm.Milestone_Event__c)
                           && String.isNotBlank(objPayTerm.Percent_Value__c)) {
                            mapPayPlanTerms.get(objPayTerm.Payment_Plan__r.Name).add(
                            objPayTerm.Description__c+'-'+objPayTerm.Milestone_Event__c+'-'+objPayTerm.Percent_Value__c+'%');
                        }
                    }
                    else {
                        if(String.isNotBlank(objPayTerm.Description__c) && String.isNotBlank(objPayTerm.Milestone_Event__c)
                           && String.isNotBlank(objPayTerm.Percent_Value__c)) {
                            mapPayPlanTerms.put(objPayTerm.Payment_Plan__r.Name, 
                                new list<String> { objPayTerm.Description__c+'-'+objPayTerm.Milestone_Event__c+'-'+objPayTerm.Percent_Value__c+'%'});
                        }
                    }
                }
                
            }
            system.debug('mapPayPlanTerms==='+mapPayPlanTerms);
        }
    }

    public void fetchUnitDetails(){
        system.debug('No error*****'+strSelectedUnit);
        system.debug('size*****'+checkExistingSRExists().size());
        if(checkExistingSRExists().size() <= 0){
            //blnSectionOne = true;
            errorMessage = null;
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                String strFlags = '';
                if(objUnit.Dispute__c){
                    strFlags = 'Dispute, ';
                }
                if(objUnit.Enforcement__c){
                    strFlags = strFlags + 'Enforcement, ';
                }
                if(objUnit.Litigation__c){
                    strFlags = strFlags + 'Litigation, ';
                }
                if(objUnit.Counter_Case__c){
                    strFlags = strFlags + 'Counter Case, ';
                }
                if(strFlags != ''){
                    strFlags = strFlags.removeEnd(', ');
                    errorMessage = 'Error : '+ strFlags+' flags exists for the chosen Booking Unit. You will be unable to proceed.';
                }else{
                    if(objUnit.Booking_Undergoing_Termination__c){
                        errorMessage = 'Error : The selected Booking Unit in undergoing Termination. You will be unable to proceed.';
                    }else if(objUnit.Rental_Pool__c){
                        errorMessage = 'Error : The selected Booking Unit in under Rental Pool. You will be unable to proceed. Please raise a Rental Pool Assignment.';
                    }else if(objUnit.NOC_Issued_Date__c != null
                    && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
                        errorMessage = 'Error : NOC for the selected Booking Unit was last issued on '+objUnit.NOC_Issued_Date__c.format()+'. You will be unable to proceed.';
                    }else{
                        fetchParking(objUnit);
                        disablePayParking = false;
                        disablePayPlan = false;
                    }
                }
            }else{
                objUnit = null;
            }
        }else{
            //blnSectionOne = false;
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                errorMessage = 'Error : An open Service Request already exists for the chosen Booking Unit. You will be unable to proceed';
            }else{
                fetchParking(objUnit);
                disablePayParking = false;
                disablePayPlan = false;
            }
            blnSectionTwo = false;
        }
        /*
        if(checkExistingSRExists().size() <= 0){
            errorMessage = null;
            system.debug('No error*****'+strSelectedUnit);
            if(strSelectedUnit != 'None'){
                objUnit = mapId_BookingUnit.get(strSelectedUnit);
                fetchParking(objUnit);
                disablePayParking = false;
                disablePayPlan = false;
                //blnSectionTwo = true;
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
            blnSectionTwo = false;
            system.debug('Raise ERROR*****');
        }
        */
        blnSectionThree = false;
        blnSectionFour = false;
        blnSectionFive = false;
    }

    /*public void fetchSeller(){
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
    }*/
    
    public list<Case> checkExistingSRExists(){
        set<String> setAllowedSRTypes = new set<String>();
        setAllowedSRTypes.add('Parking');
        setAllowedSRTypes.add('Complaint');
        setAllowedSRTypes.add('Early_Handover');
        setAllowedSRTypes.add('Fund_Transfer');
        setAllowedSRTypes.add('Handover');
        setAllowedSRTypes.add('Mortgage');
        setAllowedSRTypes.add('NOC_For_Visa');
        setAllowedSRTypes.add('Penalty_Waiver');
        setAllowedSRTypes.add('Proof_of_Payment_SR');
        setAllowedSRTypes.add('Customer_Refund');
        setAllowedSRTypes.add('Token_Refund');
        setAllowedSRTypes.add('Rental_Pool_Agreement');
        setAllowedSRTypes.add('Rental_Pool_Assignment');
        setAllowedSRTypes.add('Rental_Pool_Termination');
        setAllowedSRTypes.add('Utility_Registration_SR');
        setAllowedSRTypes.add('Plot_Handover');
        setAllowedSRTypes.add('Cheque_Replacement_SR');
        lstExistingCase = new list<Case>();
        map<Id,Case> mapId_Case = new map<Id,Case>([Select c.Id
                                                         , c.Booking_Unit__c
                                                         , c.AccountId
                                                         , c.CaseNumber
                                                         , c.RecordType.DeveloperName
                                                         , c.RecordType.Name
                                                    From Case c
                                                    where c.Booking_Unit__c =: strSelectedUnit
                                                    and c.Status != 'Closed'
                                                    and c.Status != 'Rejected'
                                                    and c.RecordType.DeveloperName NOT IN : setAllowedSRTypes]);
        if(mapId_Case != null && !mapId_Case.isEmpty()){
            lstExistingCase.addAll(mapId_Case.values());
        }
        for(SR_Booking_Unit__c objSBU : [Select s.Id
                                              , s.Case__c
                                              , s.Case__r.Status
                                              , s.Case__r.CaseNumber
                                              , s.Case__r.RecordType.DeveloperName
                                              , s.Case__r.RecordType.Name
                                              , s.Booking_Unit__c 
                                         From SR_Booking_Unit__c s
                                         where s.Booking_Unit__c =:strSelectedUnit
                                         and s.Case__r.Status != 'Closed'
                                         and s.Case__r.Status != 'Rejected'
                                         and s.Case__r.RecordType.DeveloperName = 'AOPT']){
            if(!mapId_Case.containsKey(objSBU.Case__c)){
                Case objCase = objSBU.Case__r;
                //objCase.Id = objSBU.Case__c;
                //objCase.CaseNumber = objSBU.Case__r.CaseNumber;
                lstExistingCase.add(objCase);
            }
        }
        system.debug('lstExistingCase*****'+lstExistingCase);
        return lstExistingCase;
    }
    
    public void submitParking(){
        system.debug('totalPrice=='+totalPrice);
        updateParking();
        objCase.Booking_Unit__c = objUnit.Id;
        objCase.Pending_Amount__c = totalPrice;
        upsert objCase;
        insertPOADocs();
    }

    public void soa(){
        
    }

    public void cashPayment() {
        blnSectionFour = true; 
        disablePayParking = true;
    }

    public void paymentPlanSelected() {
        blnSectionFour = true; 
        disablePayPlan = true;
    }

    public void parkingrequestForm() {
        blnSectionFive = true;
        disableParkingReq = true;
    }

    public void updateParking() {
        system.debug('totalPrice=='+totalPrice);
        list<Parking__c> lstParkingToUpdate = new list<Parking__c>();
        list<Payment_Plan__c> lstPaymentPlan = new list<Payment_Plan__c>(); 
        system.debug('lstParking==='+lstParking);
        system.debug('totalPrice==='+totalPrice);
        system.debug('lstParkingOffPlan==='+lstParkingOffPlan);
        system.debug('paymentPlanName==='+paymentPlanName);
        system.debug('readyBuilding==='+readyBuilding);
        system.debug('offPlanBuilding==='+offPlanBuilding);
        system.debug('mapOffPlanParkingType==='+mapOffPlanParkingType);
        
        if(String.isNotBlank(paymentPlanName)) {
            lstPaymentPlan = [select Id from Payment_Plan__c where Name =: paymentPlanName];
            system.debug('lstPaymentPlan==='+lstPaymentPlan);
        }
        
        if(!lstParking.isEmpty() || !lstParkingOffPlan.isEmpty()) {
            if(readyBuilding) {
	            for(parkingWrapper objParkingWrap: lstParking) {
	                if(objParkingWrap.blnSelect) {
	                    Parking__c parkingObj = new Parking__c();
	                    parkingObj.Id = objParkingWrap.objParking.Id;
	                    if(!lstPaymentPlan.isEmpty()) {
	                        parkingObj.Payment_Plan__c = lstPaymentPlan[0].Id;
	                    }
	                    parkingObj.Availability__c = 'Allocation in Progress (SR)';
	                    parkingObj.Allocated_to_Booking_Unit__c = objUnit.Id;
	                    lstParkingToUpdate.add(parkingObj);
	                }
	            }
            }
            else if(offPlanBuilding) {
                for(parkingOffPlanWrapper objOffPlanParkingWrap: lstParkingOffPlan) {
                    system.debug('objOffPlanParkingWrap.selectedParkingUnits==='+objOffPlanParkingWrap.selectedParkingUnits);
                    if(objOffPlanParkingWrap.selectedParkingUnits != null && objOffPlanParkingWrap.selectedParkingUnits != 'None') {
                        Integer counterVal = Integer.valueOf(objOffPlanParkingWrap.selectedParkingUnits);
                        for(Parking__c objParking: mapOffPlanParkingType.get(objOffPlanParkingWrap.parkingType.Name)) {
                            if(counterVal > 0) {
                                if(!lstPaymentPlan.isEmpty()) {
		                            objParking.Payment_Plan__c = lstPaymentPlan[0].Id;
                                }
	                            objParking.Availability__c = 'Allocation in Progress (SR)';
		                        objParking.Allocated_to_Booking_Unit__c = objUnit.Id;
		                        lstParkingToUpdate.add(objParking);
                            }
                            counterVal--;
                        }
                    }
                }
            }
            if(!lstParkingToUpdate.isEmpty()) {
               update lstParkingToUpdate;
               system.debug('lstParkingToUpdate==='+lstParkingToUpdate);
            }
        }
    }

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
        if(ParkingReqForm.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'Parking Request Form';
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
            if(ParkingReqForm.Body != null){
                ParkingReqForm.ParentId = mapDocName_RecordId.get('Parking Request Form');
                lstAttachmentToInsert.add(ParkingReqForm);
                system.debug('ParkingReqForm==='+ParkingReqForm);
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

    public class parkingWrapper{
        public boolean blnSelect {get;set;}
        public Parking__c objParking {get;set;}
        
        public parkingWrapper(){
            
        }
    }

    public class parkingOffPlanWrapper {
        //public String parkingType {get;set;}
        public List<SelectOption> parkingUnits {get;set;}
        public String selectedParkingUnits {get;set;}
        //public Decimal parkingPrice {get;set;}
        public Parking_Type__c parkingType {get;set;}
        
        public parkingOffPlanWrapper(){
            
        }
    }
}