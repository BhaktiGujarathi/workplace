/*
Version     Author      Last Modified       Description
1.0         Vivian      18th Sept 2017      Initial Draft
1.1         Vivian      18th Sept 2017      Added functionality to insert supporting docs
1.2         Vivian      18th Sept 2017      Added functionality to fetch inserted docs
*/
public without sharing class assignmentProcessCREController {
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
    public List<SelectOption> lstCategories {get;set;}
    public List<SelectOption> lstTotalJointBuyers {get;set;}
    public list<selectoption> lstOptions {get;set;}
    public list<Case> lstExistingCase {get;set;}
    public String strSelectedUnit {get;set;}
    public String strSelectedCategory {get;set;}
    public String strJBCount {get;set;}
    String strAccoundId = '';
    String strCaseNumber = '';
    String strBookingId;
    public List<docInfo> lstDocs {get;set;}
    public List<paymentInfo> lstPayments {get;set;}
    public List<docInfo> lstAdditionalDocs {get;set;}
    public List<pdcDetailsWrapper> lstPDCDetails {get;set;}
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
    public list<SR_Attachments__c> lstInsertedPrimaryDocs {get;set;}
    public list<SR_Attachments__c> lstInsertedSupportingDocs {get;set;}
    map<String,String> mapRuleEngine_Error;
    public string strSoAURL {get;set;}
    public boolean nocIssuedInLast15Days {get;set;}
    public UnitDetailsService.BookinUnitDetailsWrapper objWrap {get;set;}
    
    public assignmentProcessCREController(){
        strAccoundId = apexpages.currentpage().getparameters().get('id');
        strCaseNumber = apexpages.currentpage().getparameters().get('caseno');
        system.debug('strCaseNumber****************'+strCaseNumber);
        init();
    }
    
    public void init(){
        objUnit = new Booking_Unit__c();
        blnSectionOne = false;
        blnSectionTwo = false;
        blnSectionThree = false;
        blnSectionFour = false;
        blnSectionFive = false;
        blnSectionAddDocs = false;
        nocIssuedInLast15Days = false;
        
        mapId_BookingUnit = new map<Id,Booking_Unit__c>();
        if(strAccoundId == null) {
            strAccoundId = '0017E00000aqdaS';
        }
        lstUnits = new List<SelectOption>();
        if(String.isNotBlank(strCaseNumber)){
            system.debug('aya kya re andara******');
            /*
            , Seller__c
            , Seller__r.Nationality__pc
            , Seller__r.PersonMobilePhone
            , Seller__r.PersonEmail
            , Seller__r.Salutation
            , Seller__r.FirstName
            , Seller__r.LastName
            , Seller__r.IsPersonAccount
            */
            list<Case> lstC = [Select Id
                                    , CaseNumber
                                    , Buyer_Type__c
                                    , Relationship_with_Seller__c
                                    , Case_Type__c
                                    , Seller_POA__c
                                    , POA_Name_Seller__c
                                    , Purpose_of_POA_Seller__c
                                    , POA_Issued_By_Seller__c
                                    , Buyer_POA__c
                                    , POA_Name__c
                                    , Purpose_of_POA__c
                                    , POA_Issued_By__c
                                    , POA_Expiry_Date__c
                                    , POA_Expiry_Date_Seller__c
                                    , Seller__c
                                    , Buyer__c
                                    , Buyer__r.Organisation_Name__c
                                    , Buyer__r.CR_Registration_Expiry_Date__c
                                    , Buyer__r.CR_Registration_Place__c
                                    , Buyer__r.Organisation_Name_Arabic__c
                                    , Buyer__r.CR_Number__c
                                    , Buyer__r.CR_Registration_Place_Arabic__c
                                    , Buyer__r.Title__c
                                    , Buyer__r.First_Name__c
                                    , Buyer__r.Last_Name__c
                                    , Buyer__r.Nationality__c
                                    , Buyer__r.Passport_Number__c
                                    , Buyer__r.Place_of_Issue__c
                                    , Buyer__r.Address_Line_1__c
                                    , Buyer__r.Address_Line_2__c
                                    , Buyer__r.Address_Line_3__c
                                    , Buyer__r.Address_Line_4__c
                                    , Buyer__r.Country__c
                                    , Buyer__r.City__c
                                    , Buyer__r.Date_of_Birth__c
                                    , Buyer__r.Title_Arabic__c
                                    , Buyer__r.First_Name_Arabic__c
                                    , Buyer__r.Last_Name_Arabic__c
                                    , Buyer__r.Nationality_Arabic__c
                                    , Buyer__r.Passport_Expiry_Date__c
                                    , Buyer__r.Place_of_Issue_Arabic__c
                                    , Buyer__r.Address_Line_1_Arabic__c
                                    , Buyer__r.Address_Line_2_Arabic__c
                                    , Buyer__r.Address_Line_3_Arabic__c
                                    , Buyer__r.Address_Line_4_Arabic__c
                                    , Buyer__r.Country_Arabic__c
                                    , Buyer__r.City_Arabic__c
                                    , Buyer__r.Phone_Country_Code__c
                                    , Buyer__r.Phone__c
                                    , Buyer__r.Email__c
                                    , Booking_Unit__c
                                    , Booking_Unit__r.Registration_ID__c
                                    , Booking_Unit__r.Name
                                    , Booking_Unit__r.Booking__c
                                    , Booking_Unit__r.Unit_Details__c
                                    , Booking_Unit__r.Unit_Type__c
                                    , Booking_Unit__r.Booking__r.Account__c
                                    , Booking_Unit__r.Inventory__r.Property__r.Name
                                    , Booking_Unit__r.Inventory__r.Property_City__c
                                    , Booking_Unit__r.Inventory__r.Unit_Type__c
                                    , Booking_Unit__r.Inventory__r.Property_Status__c
                                    , Booking_Unit__r.Inventory__r.Building_Code__c
                                    , Booking_Unit__r.Inventory__r.Bedroom_Type__c
                                    , Booking_Unit__r.Permitted_Use__c
                                    , Booking_Unit__r.Rental_Pool__c
                                    , Booking_Unit__r.Inventory_Area__c
                                    , Booking_Unit__r.Unit_Selling_Price__c
                                    , Booking_Unit__r.Booking_Undergoing_Termination__c
                                    , Booking_Unit__r.NOC_Issued_Date__c
                                    , Booking_Unit__r.Dispute__c
                                    , Booking_Unit__r.Enforcement__c
                                    , Booking_Unit__r.Litigation__c
                                    , Booking_Unit__r.Counter_Case__c
                                    , Booking_Unit__r.Mortgage__c
                                    , Booking_Unit__r.Re_Assigned__c
                                    , Booking_Unit__r.Penalty_Amount__c
                                    , Booking_Unit__r.Token_Amount_val__c
                                    , Booking_Unit__r.Booking_Type__c
                                    , Booking_Unit__r.DP_Overdue__c
                                    , Booking_Unit__r.Plot_Price__c
                                    , Booking_Unit__r.Booking__r.CreatedDate
                                    , Booking_Unit__r.Agreement_Date__c
                                    , Booking_Unit__r.JOPD_Area__c
                                    , Booking_Unit__r.DP_OK__c
                                    , Booking_Unit__r.Doc_OK__c
                                    , Booking_Unit__r.OQOOD_Reg_Flag__c
                                    , Booking_Unit__r.Early_Handover__c
                                    , Booking_Unit__r.Handover_Flag__c
                                    , Booking_Unit__r.PCC_Release__c
                                    , Booking_Unit__r.Construction_Status__c
                                    , Booking_Unit__r.Area_Varied__c
                                    , Booking_Unit__r.Inventory__r.Floor_Plan__c
                                    , Booking_Unit__r.Inventory__r.Unit_Plan__c
                                    from Case 
                                    where CaseNumber =: strCaseNumber 
                                    limit 1];
            system.debug('lstC****************'+lstC);
            if(lstC != null && !lstC.isEmpty()){
                objCase = lstC[0];
                objBuyer = lstC[0].Buyer__r;
                if(lstC[0].Seller__c != null){
                    strAccoundId = lstC[0].Seller__c;
                    //fetchSeller();
                }
                if(lstC[0].Booking_Unit__c != null){
                    objUnit = lstC[0].Booking_Unit__r;
                    system.debug('objUnit*******objUnit*****'+objUnit);
                    strSelectedUnit = objUnit.Id;
                    lstUnits.add(new selectOption(objUnit.Id, objUnit.Unit_Details__c));
                    mapId_BookingUnit.put(objUnit.Id, objUnit);
                }
                if(objCase.POA_Expiry_Date__c != null){
                    Time myTime = Time.newInstance(0, 0, 0, 0);
                    DateTime dt = DateTime.newInstanceGMT(objCase.POA_Expiry_Date__c, myTime);
                    buyerPoaDate = String.valueOf(dt.format('dd/mm/yyyy'));
                }
                if(objCase.POA_Expiry_Date_Seller__c != null){
                    Time myTime = Time.newInstance(0, 0, 0, 0);
                    DateTime dt = DateTime.newInstanceGMT(objCase.POA_Expiry_Date_Seller__c, myTime);
                    sellerPoaDate = String.valueOf(dt.format('dd/mm/yyyy'));
                }
            }
            blnSectionOne = true;
        }else{
	        objCase = new Case();
	        objCase.Origin = 'CRE';
	        objBuyer = new Buyer__c();
	        lstUnits.add(new selectOption('None', '--None--'));
	        for(Booking_Unit__c objBU : [Select Id
	                                            , Registration_ID__c
	                                            , Name
	                                            , Booking__c
	                                            , Unit_Details__c
	                                            , Unit_Type__c
	                                            , Booking__r.Account__c
	                                            , Inventory__r.Property__r.Name
	                                            , Inventory__r.Property_City__c
	                                            , Inventory__r.Unit_Type__c
	                                            , Inventory__r.Property_Status__c
	                                            , Inventory__r.Building_Code__c
	                                            , Inventory__r.Bedroom_Type__c
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
	                                            , Regular_Bulk_Flag__c
	                                            , Title_Deed__c
	                                            , Under_Assignment__c
	                                            , Inventory__r.Floor_Plan__c
	                                            , Inventory__r.Unit_Plan__c
	                                     From Booking_Unit__c
	                                     Where Booking__r.Account__c =: strAccoundId
	                                     and Re_Assigned__c = false]){
	            lstUnits.add(new selectOption(objBU.Id, objBU.Unit_Details__c));
	            mapId_BookingUnit.put(objBU.Id, objBU);
	        }
	        strSelectedUnit = 'None';
	        system.debug('mapId_BookingUnit*********'+mapId_BookingUnit);
        }
        //fetchUnitDetails();
        fetchSeller();
        buyerPOA = new Attachment();
        sellerPOA = new Attachment();
        //objCase.Status = 'New';
        List <Recordtype> lstCase_RT = fetchRecordtype('Case', 'Assignment');
        objCase.RecordtypeId = lstCase_RT[0].Id;
        objCase.Seller__c = strAccoundId;
        
        system.debug('objUnit***************'+objUnit);
        lstOptions = new list<selectoption>();
        lstOptions.add(new SelectOption('true','Yes'));
        lstOptions.add(new SelectOption('false','No'));
        
        lstTotalJointBuyers = new list<SelectOption>();
        strJBCount = '0';
        for(Integer i = 0; i<=10; i++){
            lstTotalJointBuyers.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
        strSelectedCategory = 'Unit Details';
        strSoAURL = '';
    }
    
    public void fetchSeller(){
        list<Account> lstA = [Select a.PersonMobilePhone
                                   , a.PersonHomePhone
                                   , a.PersonEmail
                                   , a.Nationality__pc
                                   , a.LastName
                                   , a.MiddleName
                                   , a.IsPersonAccount
                                   , a.Id
                                   , a.Salutation
                                   , a.FirstName 
                                   , a.Party_ID__c
                                   , a.Passport_Number__c
                                   , a.CR_Number__c
                                   , a.Party_Type__c
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
                                                    and c.RecordType.DeveloperName NOT IN : setAllowedSRTypes
                                                    and c.CaseNumber !=: strCaseNumber]);
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
                                         and s.Case__r.RecordType.DeveloperName = 'AOPT'
                                         and s.Case__r.CaseNumber !=: strCaseNumber]){
            if(!mapId_Case.containsKey(objSBU.Case__c)){
                Case objCase = objSBU.Case__r;
                //objCase.Id = objSBU.Case__c;
                //objCase.CaseNumber = objSBU.Case__r.CaseNumber;
                lstExistingCase.add(objCase);
            }
        }
        return lstExistingCase;
    }
    
    public void checkSRFlags(){
        
    }
    
    public void fetchUnitDetails(){
        system.debug('No error*****'+strSelectedUnit);
        if(strSelectedUnit != 'None'){
	        objUnit = mapId_BookingUnit.get(strSelectedUnit);
	        objWrap = UnitDetailsService.getBookingUnitDetails(objUnit.Registration_ID__c);
	        system.debug('*****objWrap*****'+objWrap);
	        if(checkExistingSRExists().size() <= 0 ){
	            blnSectionOne = true;
	            errorMessage = null;
                //objUnit = mapId_BookingUnit.get(strSelectedUnit);
                if(objWrap != null) {
	                String strFlags = '';
	                if(String.isNotBlank(objWrap.strDispute)
	                && objWrap.strDispute.equalsIgnoreCase('Y')){
	                    strFlags = 'Dispute, ';
	                    objUnit.Dispute__c = true;
	                }else{
	                    objUnit.Dispute__c = false;
	                }
	                if(String.isNotBlank(objWrap.strEnforcement)
	                && objWrap.strEnforcement.equalsIgnoreCase('Y')){
	                    strFlags = strFlags + 'Enforcement, ';
	                    objUnit.Enforcement__c = true;
	                }else{
	                    objUnit.Enforcement__c = false;
	                }
	                if(String.isNotBlank(objWrap.strLitigation)
	                && objWrap.strLitigation.equalsIgnoreCase('Y')){
	                    strFlags = strFlags + 'Litigation, ';
	                    objUnit.Litigation__c = true;
	                }else{
	                    objUnit.Litigation__c = false;
	                }
	                if(String.isNotBlank(objWrap.strCounterCase)
	                && objWrap.strCounterCase.equalsIgnoreCase('Y')){
	                    strFlags = strFlags + 'Counter Case, ';
	                    objUnit.Counter_Case__c = true;
	                }else{
	                    objUnit.Counter_Case__c = false;
	                }
	                if(strFlags != ''){
	                    strFlags = strFlags.removeEnd(', ');
	                    errorMessage = 'Error : '+ strFlags+' flags exists for the chosen Booking Unit. You will be unable to proceed.';
	                }else{
	                    if(String.isNotBlank(objWrap.strUnderTermination)
	                    && objWrap.strUnderTermination.equalsIgnoreCase('Y')){
	                        errorMessage = 'Error : The selected Booking Unit in undergoing Termination. You will be unable to proceed.';
	                    }else if(String.isNotBlank(objWrap.strRentalPool)
	                    && objWrap.strRentalPool.equalsIgnoreCase('Y')){
	                        errorMessage = 'Error : The selected Booking Unit in under Rental Pool. You will be unable to proceed. Please raise a Rental Pool Assignment.';
	                    }else if(objUnit.NOC_Issued_Date__c != null
	                    && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
	                        nocIssuedInLast15Days = true;
	                        errorMessage = 'Error : NOC for the selected Booking Unit was last issued on '+objUnit.NOC_Issued_Date__c.format()+'. You will be unable to proceed.';
	                    }
		            }
                }
	        }else{
	            blnSectionOne = false;
                errorMessage = 'Error : An open Service Request already exists for the chosen Booking Unit. You will be unable to proceed';
	        }
        }else{
            objUnit = null;
            errorMessage = null;
        }
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

    public void viewPaymentDetails(){
        system.debug('View reqn called***************');
        fetchDocumentsList();
        fetchPDCDetails();
        //fetchPaymentsList();
        String strDueResponse = assignmentEndpoints.fetchAssignmentDues(objUnit);
        system.debug('strDueResponse==='+strDueResponse);
        map<String,Object> mapDeserializeDue = (map<String,Object>)JSON.deserializeUntyped(strDueResponse);
        //String strDueResponse = '{"Test1":"2","Test3":"2"}';
        if(strDueResponse != null && !String.isEmpty(strDueResponse) && mapDeserializeDue.get('status') == 'S'){
            decTotal = 0.0;
            strDueResponse = strDueResponse.remove('{');
            strDueResponse = strDueResponse.remove('}');
            strDueResponse = strDueResponse.remove('"');
            lstPayments = new List<paymentInfo>();
            system.debug('after all replacements******'+strDueResponse);
            for(String st : strDueResponse.split(',')){
                String strKey = st.substringBefore(':').trim();
                if(!strKey.equalsIgnoreCase('Status')) {
	                system.debug('st*****'+st);
	                paymentInfo objP = new paymentInfo();
	                objP.strType = strKey;
	                if(Decimal.valueOf(st.subStringAfter(':').trim()) > 0) {
	                   objP.decAmount = Decimal.valueOf(st.subStringAfter(':').trim());
	                }
	                else {
	                   objP.decAmount = 0.0;
	                }
	                decTotal = decTotal + objP.decAmount;
	                system.debug('objP*************88'+objP);
	                lstPayments.add(objP);
                }
            }
        }
        
        String strFeeResponse = assignmentEndpoints.fetchAssignmentFees(objUnit, objCase, 'Assignment');
        system.debug('strFeeResponse==='+strFeeResponse);
        //map<String,Object> mapDeserializeFee = (map<String,Object>)JSON.deserializeUntyped(strFeeResponse);
        if(strFeeResponse != null && !String.isEmpty(strFeeResponse) ){
            map<String,String> mapKey_Value = new map<String,String>();
            mapKey_Value = parseRuleEngine(strFeeResponse, 'Fees');
            system.debug('mapKey_Value==='+mapKey_Value);
            if(mapRuleEngine_Error.containsKey('message')
	        && mapRuleEngine_Error.get('message') == null
	        || mapRuleEngine_Error.get('message') == 'null'){
	            if(!mapKey_Value.isEmpty()){
		            paymentInfo objP = new paymentInfo();
		            objP.strType = 'Admin Fee for Assignment';
		            if(mapKey_Value.containsKey('adminFeeFlat')
		            && mapKey_Value.get('adminFeeFlat') != 'null'){
		                integer intVal = integer.valueOf(mapKey_Value.get('adminFeeFlat').remove('AED').trim());
		                objP.decAmount = intVal;
		                
		            }else if(mapKey_Value.containsKey('adminFeePsf') 
		            && mapKey_Value.get('adminFeePsf') != 'null'){
		                integer intVal = integer.valueOf(mapKey_Value.get('adminFeePsf').remove('AED').trim());
		                objP.decAmount = intVal * objUnit.Inventory_Area__c;
		            }else if(mapKey_Value.containsKey('adminFeePercentage')
		            && mapKey_Value.get('adminFeePercentage') != 'null'){
		                integer intVal = integer.valueOf(mapKey_Value.get('adminFeePercentage').remove('AED').trim());
		                objP.decAmount = intVal * objUnit.Unit_Selling_Price__c;
		            }
		            if(objP.decAmount != null) {
		                decTotal = decTotal + objP.decAmount;
		            }
		            else {
		                decTotal = decTotal;
		                objP.decAmount = 0.0;
		            }
		            system.debug('objP*****'+objP);
		            system.debug('decTotal*****'+decTotal);
		            lstPayments.add(objP);
	            }
	        }
        }
        blnSectionTwo = true;
    }

    public map<String,String> parseRuleEngine(String ruleEngineResponse, String processFunctionality) {
        mapRuleEngine_Error = new map<String,String>();
        ruleEngineResponse = ruleEngineResponse.remove('{');
        ruleEngineResponse = ruleEngineResponse.remove('}');
        ruleEngineResponse = ruleEngineResponse.remove('"');
        system.debug('ruleEngineResponse==='+ruleEngineResponse);
        map<String,String> mapKey_Value = new map<String,String>();
        system.debug('ruleEngineResponse******'+ruleEngineResponse);
        Integer indexVal = 0;
        boolean blnAllow = false;
        for(String st : ruleEngineResponse.split(',')){
            system.debug('*****st*****'+st);
            String strPre = st.substringBefore(':').trim();
            String strPost = st.subStringAfter(':').trim();
            if(!blnAllow && strPre.equalsIgnoreCase('allowed')
            && strPost.equalsIgnoreCase('Yes')){
                blnAllow = true;
            }
            mapRuleEngine_Error.put(strPre,strPost);
            
            system.debug('strPre :*******'+strPre);
            system.debug('strPost :*******'+strPost);
            if(processFunctionality == 'Fees' && indexVal >=12 && indexVal <= 14) {
                mapKey_Value.put(strPre,strPost);
            }
            else if(processFunctionality == 'Documents' && indexVal >=15 && indexVal <= 50) {
                mapKey_Value.put(strPre,strPost);
            }
            else if(processFunctionality == 'Approvers' && indexVal >=6 && indexVal <= 8){
                mapKey_Value.put(strPre,strPost);
            }
            if(!blnAllow && indexVal == 1){
                break;
            }
            indexVal++;
        }
        system.debug('mapKey_Value*************'+mapKey_Value);
        return mapKey_Value;
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
        map<String,String> mapKey_Value = new map<String,String>();
        String strDocumentResponse = assignmentEndpoints.fetchAssignmentDocs(objUnit, objCase, 'Assignment');
        system.debug('strDocumentResponse==='+strDocumentResponse);
        if(strDocumentResponse != null && !String.isEmpty(strDocumentResponse)){
            mapKey_Value = parseRuleEngine(strDocumentResponse, 'Documents');
        }
        
        system.debug('message*****'+mapRuleEngine_Error.get('message'));
        if(mapRuleEngine_Error.containsKey('message')
        && mapRuleEngine_Error.get('message') == null
        || mapRuleEngine_Error.get('message') == 'null'){
	        for(String docType: mapKey_Value.keySet()) {
	            if(mapKey_Value.get(docType) == 'Mandatory') {
	                docInfo objD = new docInfo();
	                objD.strType = docType;
	                objD.strRequired = 'Yes';
	                objD.blnIsValid = false;
	                objD.objAttachment = new Attachment();
	                lstDocs.add(objD);
	            }
	        }
        }
        system.debug('lstDocs********'+lstDocs);
    }

    public void fetchPDCDetails() {
        lstPDCDetails = new list<pdcDetailsWrapper>();
        String strPDCResponse = assignmentEndpoints.fetchPDCDetails(objUnit);
        if(String.isNotBlank(strPDCResponse)) {
            map<String,Object> mapDeserializePDC = (map<String,Object>)JSON.deserializeUntyped(strPDCResponse);
            if(mapDeserializePDC.get('status') == 'S') {
                String StringPDCData = JSON.serialize(mapDeserializePDC.get('data'));
                lstPDCDetails = 
                    (List<pdcDetailsWrapper>)JSON.deserialize(StringPDCData, List<pdcDetailsWrapper>.class);
                system.debug('lstPDCDetails==='+lstPDCDetails);
            }
        }
    }

    /*public void fetchApprovers() {
        map<String,String> mapKey_Value = new map<String,String>();
        String strApprover;
        String strApprovalResponse = assignmentEndpoints.fetchAssignmentApprovers(objUnit, objCase, 'Assignment');
        if(strApprovalResponse != null && !String.isEmpty(strApprovalResponse)){
            mapKey_Value = parseRuleEngine(strApprovalResponse, 'Approvers');
        }
        if(mapRuleEngine_Error.containsKey('message')
        && mapRuleEngine_Error.get('message') == null
        || mapRuleEngine_Error.get('message') == 'null'){
	        for(String approveAuth: mapKey_Value.keySet()) {
	            if(mapKey_Value.get(approveAuth) != 'null') {
	                strApprover = strApprover+''+mapKey_Value.get(approveAuth)+',';
	            }
	        }
        }

        if(strApprover != null) {
            objCase.Approving_Authorities__c = strApprover.removeEnd(',');
            objCase.Submit_for_Approval__c = true;
        }
    }*/

    public void submitCRF(){
        try{
	        system.debug('buyerPoaDate*****'+buyerPoaDate);
	        system.debug('sellerPoaDate*****'+sellerPoaDate);
	        objCase.Booking_Unit__c = strSelectedUnit;
	        objCase.Pending_Amount__c = decTotal;
	        if(!String.isBlank(buyerPoaDate)){
	            //List<String> parts = buyerPoaDate.split('/');
	            //objCase.POA_Expiry_Date__c = date.newinstance(integer.valueOf(parts[2]), integer.valueOf(parts[1]), integer.valueOf(parts[0]));
	            objCase.POA_Expiry_Date__c = generateDateFromString(buyerPoaDate);
	        }
	        if(!String.isBlank(sellerPoaDate)){
	            //List<String> parts = sellerPoaDate.split('/');
	            //objCase.POA_Expiry_Date_Seller__c = date.newinstance(integer.valueOf(parts[2]), integer.valueOf(parts[1]), integer.valueOf(parts[0]));
	            objCase.POA_Expiry_Date_Seller__c = generateDateFromString(sellerPoaDate);
	        }
	        upsertCase();
	        insertDocuments(lstDocs);
	        lstDocs = null;
	        lstAdditionalDocs = new List<docInfo>();
	        insertPOADocs();
	        fetchInsertedDocs();
	        blnSectionAddDocs = true;
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
    }
    
    public date generateDateFromString(String strDate){
        List<String> parts = strDate.split('/');
        return date.newinstance(integer.valueOf(parts[2]), integer.valueOf(parts[1]), integer.valueOf(parts[0]));
    }
    
    public void generateSoA(){
        GenerateSOAController.soaResponse strResponse = GenerateSOAController.getSOADocument(objUnit.Registration_ID__c);
        system.debug('SOA generated status '+strResponse.status);
        system.debug('SOA generated url'+strResponse.url);
        strSoAURL = strResponse.url;
    }
    
    public void skipAdditionalDocs(){
        blnSectionThree = true;
        createJointBuyers();
    }
    
    public void insertPOADocs(){
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>();
        if(objCase.Buyer_POA__c && buyerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'BUYER POA';
            objSR.isValid__c = false;
            objSR.IsRequired__c = true;
            objSR.Case__c = objCase.Id;
            lstSrAttachment.add(objSR);
        }
        if(objCase.Seller_POA__c && sellerPOA.Body != null){
            SR_Attachments__c objSR = new SR_Attachments__c();
            objSR.Name = 'SELLER POA';
            objSR.isValid__c = false;
            objSR.IsRequired__c = true;
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
        try{
            strBookingId = mapId_BookingUnit.get(strSelectedUnit).Booking__c;
            objBuyer.Booking__c = strBookingId;
            objBuyer.Buyer_Type__c = objCase.Buyer_Type__c;
            upsert objBuyer;
            list<Buyer__c> lstJB = new list<Buyer__c>();
            for(jointBuyer objJB : lstJointBuyer){
                Buyer__c newJB = objJB.objJointBuyer;
                newJB.Buyer_Type__c = objCase.Buyer_Type__c;
                newJB.Booking__c = strBookingId;
                lstJB.add(newJB);
            }
            if(!lstJB.isEmpty()){
                upsert lstJB;
                list<Joint_Buyer_New__c> lstNewJB = new list<Joint_Buyer_New__c>(); 
                for(Buyer__c objJB : lstJB){
                    Joint_Buyer_New__c newJB = new Joint_Buyer_New__c();
                    newJB.Booking_Unit__c = strSelectedUnit;
                    newJB.Buyer__c = objBuyer.Id;
                    newJB.Joint_Buyer__c = objJB.Id;
                    newJB.Case__c = objCase.Id;
                    lstNewJB.add(newJB);
                }
                if(!lstNewJB.isEmpty()){
                    upsert lstNewJB;
                }
            }
            objCase.Buyer__c = objBuyer.Id;
            //fetchApprovers();
            upsertCase();
            signedCRF = new Attachment();
            uploadLOA = new Attachment();
            blnSectionFour = true;
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
    }
    
    public void generateLOA(){
        try{
	        /*
	        SR_Attachments__c objSR = new SR_Attachments__c();
	        objSR.Name = 'Signed CRF';
	        objSR.isValid__c = true;
	        objSR.IsRequired__c = true;
	        objSR.Case__c = objCase.Id;
	        insert objSR;
	        
	        signedCRF.ParentId = objSR.Id;
	        insert signedCRF;
	        
	        objSR.Attachment__c = signedCRF.Id;
	        update objSR;
	        signedCRF = null;
	        blnSectionFive = true;
	        */
	        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
	        DocumentExtension objC = new DocumentExtension(sc);
	        objC.loaVerification();
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
    }
    
    public pageReference viewCRF(){
        Pagereference pg = Page.CRF;
        pg.getParameters().put('Id',objCase.Id);
        pg.getParameters().put('recTypeName','Assignment');
        pg.setRedirect(true);
        return pg;
    }
    
    public pagereference printNOC(){
        Pagereference pgRef = new Pagereference('/'+objCase.Id);
        try{
	        SR_Attachments__c objSR = new SR_Attachments__c();
	        objSR.Name = 'Signed LOA';
	        objSR.isValid__c = false;
	        objSR.IsRequired__c = true;
	        objSR.Case__c = objCase.Id;
	        insert objSR;
	        
	        uploadLOA.ParentId = objSR.Id;
	        insert uploadLOA;
	        
	        objSR.Attachment__c = uploadLOA.Id;
	        update objSR;
	        uploadLOA = null;
	        
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
        pgRef.setRedirect(true);
        return pgRef;
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
    
    public void insertAdditionalDocument(){
        try{
	        insertDocuments(lstAdditionalDocs);
	        blnSectionThree = true;
	        createJointBuyers();
	        fetchInsertedDocs();
        }catch(Exception ex){
            errorMessage = 'Error : '+ ex.getMessage();
        }
    }
    
    public void createJointBuyers(){
        lstJointBuyer = new list<jointBuyer>();
        system.debug('strJBCount***************'+strJBCount);
        Integer cnt = integer.valueOf(strJBCount);
        for(Integer i = 0; i< cnt; i++){
	        jointBuyer newJB = new jointBuyer();
	        newJB.objJointBuyer = new Buyer__c ();
	        newJB.objJointBuyer.Country__c = 'United Arab Emirates';
	        newJB.intIndex = lstJointBuyer.size();
	        lstJointBuyer.add(newJB);
        }
    }
    
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
        system.debug('lstSrAttachment==='+lstSrAttachment);
        if(!lstSrAttachment.isEmpty()){
            insert lstSrAttachment;
            system.debug('after lstSrAttachment==='+lstSrAttachment);
	        map<String,Id> mapName_Id = new map<String,Id>();
	        for(SR_Attachments__c objSR : lstSrAttachment){
	            mapName_Id.put(objSR.Name, objSR.Id);
	        }
	        system.debug('mapName_Id==='+mapName_Id);
	        list<Attachment> lstAttachmentToInsert = new list<Attachment>();
	        for(docInfo objDI : lstDocs){
                if(objDI.objAttachment.Body != null){
	               objDI.objAttachment.ParentId = mapName_Id.get(objDI.strType);
	               lstAttachmentToInsert.add(objDI.objAttachment);
	          }
	        }
	        system.debug('lstAttachmentToInsert==='+lstAttachmentToInsert);
	        if(!lstAttachmentToInsert.isEmpty()){
	            insert lstAttachmentToInsert;
	            system.debug('after lstAttachmentToInsert==='+lstAttachmentToInsert);
	            map<Id,Id> mapParent_Id = new map<Id,Id>();
	            for(Attachment objA : lstAttachmentToInsert){
	                mapParent_Id.put(objA.ParentId, objA.Id);
	            }
	            system.debug('mapParent_Id==='+mapParent_Id);
	            lstSrAttachment = null;
	            lstSrAttachment = new list<SR_Attachments__c>();
	            for(Id objId : mapParent_Id.keySet()){
	                SR_Attachments__c objSR = new SR_Attachments__c();
	                objSR.Id = objId;
	                objSR.Attachment__c = mapParent_Id.get(objId);
	                lstSrAttachment.add(objSR);
	                system.debug('objSR==='+objSR);
	            }
	            system.debug('before update lstSrAttachment==='+lstSrAttachment);
	            update lstSrAttachment;
	            system.debug('after update lstSrAttachment==='+lstSrAttachment);
	            lstSrAttachment = null;
	        }
        }
    }
    
    public void fetchInsertedDocs(){
        lstInsertedSupportingDocs = new list<SR_Attachments__c>();
        lstInsertedPrimaryDocs = new list<SR_Attachments__c>();
        
        for(SR_Attachments__c objAt : [Select s.isValid__c
                                            , s.Name
                                            , s.Id
                                            , s.Case__c
                                            , s.Attachment__c 
                                            From SR_Attachments__c s
                                            where s.Case__c =: objCase.Id
                                            and s.Attachment__c != null]){
            if(objAt.Name.contains('Supporting')){
                lstInsertedSupportingDocs.add(objAT);
            }else{
                lstInsertedPrimaryDocs.add(objAt);
            }
        } // end of for
    } // end of fetchInsertedDocs
    
    public void upsertCase(){
        //update registration status
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

    public class pdcDetailsWrapper {
        public String ATTRIBUTE1 {get;set;}
        public String ATTRIBUTE2 {get;set;}
        public String ATTRIBUTE3 {get;set;}
        public String ATTRIBUTE4 {get;set;}
        public String ATTRIBUTE5 {get;set;}
        public String ATTRIBUTE6 {get;set;}
        public String ATTRIBUTE7 {get;set;}
        public String ATTRIBUTE8 {get;set;}

        public pdcDetailsWrapper(){
            
        }
    }
}