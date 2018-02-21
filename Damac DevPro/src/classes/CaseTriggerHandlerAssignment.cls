public without sharing class CaseTriggerHandlerAssignment {
    
    public void afterInsert(list<Case> listCase) {

        Id AssignmentRecordType = getRecordTypeId('Case', 'Assignment');
        Set<Id> setUpdateRegStatusSubmitted = new Set<Id>(); 
        Integer counterRegUpdate = 1;
        for(Case caseInst: listCase) {
            if(caseInst.Booking_Unit__c != null && caseInst.RecordTypeId == AssignmentRecordType) {
                if(counterRegUpdate <= 100) {
                    setUpdateRegStatusSubmitted.add(caseInst.Booking_Unit__c);
                }
                else {
                    updateRegStatus(setUpdateRegStatusSubmitted, 'SR submitted');
                    counterRegUpdate = 1;
                    setUpdateRegStatusSubmitted = new Set<Id>();
                    setUpdateRegStatusSubmitted.add(caseInst.Booking_Unit__c);
                }
                counterRegUpdate++;
            }
            system.debug('setUpdateRegStatusSubmitted==='+setUpdateRegStatusSubmitted);
        }
        
        if(!setUpdateRegStatusSubmitted.isEmpty()) {
            updateRegStatus(setUpdateRegStatusSubmitted, 'SR submitted');
        }
    }

    //get Record Type Id
    public Id getRecordTypeId(String SObjectType, String RecordTypeName) {
        List<RecordType> lstRecordType = [select Id, DeveloperName from RecordType where
                                                     SobjectType =: SObjectType and DeveloperName =: RecordTypeName];
        return lstRecordType[0].Id;
    }

    public void afterUpdate(map<Id,Case> newMap, map<Id,Case> oldMap){
        Id AssignmentRecordType = getRecordTypeId('Case', 'Assignment');
        set<Id> setAccountIds = new set<Id>();
        Set<Id> setUpdateRegStatusProcess = new Set<Id>();
        Set<Id> setUpdateRegStatusApproved = new Set<Id>();
        Set<Id> setUpdateRegStatusRejected = new Set<Id>();
        Integer intCount = 1;
        Integer counterRegUpdateProcess = 1;
        Integer counterRegUpdateApproved = 1;
        Integer counterRegUpdateRejected = 1;
        for(Case objC : newMap.values()){
            if(objC.AccountId != null && objC.RecordTypeId == AssignmentRecordType
            && objC.AccountId != oldMap.get(objC.Id).AccountId){
                if(intCount <= 100){
                    setAccountIds.add(objC.AccountId);
                }else{
                    createCustomer(setAccountIds);
                    intCount = 1;
                    setAccountIds = new set<Id>();
                    setAccountIds.add(objC.AccountId);
                }
                intCount++;
            }
            if(objC.RecordTypeId == AssignmentRecordType && objC.Document_Verified__c 
                && objC.Payment_Verified__c && (objC.Document_Verified__c != oldMap.get(objC.Id).Document_Verified__c
                || objC.Payment_Verified__c != oldMap.get(objC.Id).Payment_Verified__c) 
                && objC.Booking_Unit__c != null) {
                if(counterRegUpdateProcess <= 100) {
                    setUpdateRegStatusProcess.add(objC.Booking_Unit__c);
                }
                else {
                    updateRegStatus(setUpdateRegStatusProcess, 'SR processing');
                    counterRegUpdateProcess = 1;
                    setUpdateRegStatusProcess = new Set<Id>();
                    setUpdateRegStatusProcess.add(objC.Booking_Unit__c);
                }
                counterRegUpdateProcess++;
            }
            if(objC.RecordTypeId == AssignmentRecordType && objC.Status == 'Closed' 
                && objC.Status != oldMap.get(objC.Id).Status && objC.Booking_Unit__c != null) {
                if(counterRegUpdateApproved <= 100) {
                    setUpdateRegStatusApproved.add(objC.Booking_Unit__c);
                }
                else {
                    updateRegStatus(setUpdateRegStatusApproved, 'SR approved and closed');
                    counterRegUpdateApproved = 1;
                    setUpdateRegStatusApproved = new Set<Id>();
                    setUpdateRegStatusApproved.add(objC.Booking_Unit__c);
                }
                counterRegUpdateApproved++;
            }
            if(objC.RecordTypeId == AssignmentRecordType && objC.Status == 'Rejected' 
                && objC.Status != oldMap.get(objC.Id).Status && objC.Booking_Unit__c != null) {
                if(counterRegUpdateRejected <= 100) {
                    setUpdateRegStatusRejected.add(objC.Booking_Unit__c);
                }
                else {
                    updateRegStatus(setUpdateRegStatusRejected, 'SR rejected and closed');
                    counterRegUpdateRejected = 1;
                    setUpdateRegStatusRejected = new Set<Id>();
                    setUpdateRegStatusRejected.add(objC.Booking_Unit__c);
                }
                counterRegUpdateRejected++;
            }
        }
        if(!setAccountIds.isEmpty()){
            createCustomer(setAccountIds);
        }
        if(!setUpdateRegStatusProcess.isEmpty()) {
            updateRegStatus(setUpdateRegStatusProcess, 'SR processing');
        }
        if(!setUpdateRegStatusApproved.isEmpty()) {
            updateRegStatus(setUpdateRegStatusApproved, 'SR approved and closed');
        }
        if(!setUpdateRegStatusRejected.isEmpty()) {
            updateRegStatus(setUpdateRegStatusRejected, 'SR rejected and closed');
        }
        system.debug('setAccountIds==='+setAccountIds);
    }

    @future(callout=true)
    public static void updateRegStatus(set<Id> setBookingUnit, String regStatus) {
        for(Booking_Unit__c bookingInst: [select Id, Registration_ID__c from Booking_Unit__c
                where Id IN: setBookingUnit and Registration_ID__c != null]) {
            AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
            objClass.timeout_x = 120000;
            String strRegStatusResponse = objClass.UpdateRegistrationStatus(String.valueOf(System.currentTimeMillis()), 'UPDATE_REG_STATUS', 'SFDC', bookingInst.Registration_ID__c, regStatus);
            system.debug('strRegStatusResponse==='+strRegStatusResponse);
        }
    }

    @future(callout=true)
    public static void createCustomer(set<Id> setAccountIds){
        list<Account> lstUpdateAccount = new list<Account>(); 
        list<Account> lstA = [Select a.Zip_Postal_Code__c, a.Work_Phone__c, a.Work_Phone_Country_Code__c
                                   , a.Title__c, a.Title_Arabic__pc, a.Title_Arabic__c, a.State__c
                                   , a.State_Arabic__c, a.Salutation, a.Record_Type_Name__c, a.RecordTypeId
                                   , a.Postal_Code_Arabic__pc, a.Postal_Code_Arabic__c, a.Phone_Number_Arabic__pc
                                   , a.Phone_Extension_Arabic__pc, a.Phone_Country_Code__c, a.Cust_Account_ID__c
                                   , a.Phone_Country_Code_Arabic__pc, a.Phone_Area_Code_Arabic__pc, a.Phone
                                   , a.PersonTitle, a.PersonOtherPhone, a.PersonMobilePhone, a.PersonHomePhone
                                   , a.PersonEmail, a.PersonBirthdate, a.Passport_Number__pc, a.Passport_Number__c
                                   , a.Passport_Number_Arabic__pc, a.Passport_Number_Arabic__c
                                   , a.Passport_Issue_Place__pc, a.Passport_Issue_Place__c
                                   , a.Passport_Issue_Place_Arabic__pc, a.Passport_Issue_Place_Arabic__c
                                   , a.Passport_Issue_Date__pc, a.Passport_Issue_Date__c
                                   , a.Passport_Issue_Date_Arabic__pc, a.Passport_Expiry_Date__pc, a.Party_Type__c
                                   , a.Party_ID__c, a.P_O_Box_Zip_Postal_Code__c, a.P_O_Box_No__c, a.Nationality__pc
                                   , a.Nationality__c, a.Nationality_Arabic__pc, a.Nationality_Arabic__c
                                   , a.Name_Arabic__c, a.Name, a.Mobile__c, a.Mobile_Number_Arabic__pc
                                   , a.Mobile_Country_Code__pc, a.Mobile_Country_Code__c
                                   , a.Mobile_Country_Code_Arabic__pc, a.Mobile_Area_Code__pc, a.Mobile_Area_Code__c
                                   , a.Mobile_Area_Code_Arabic__pc, a.Middle_Name__c, a.Middle_Name_Arabic__pc
                                   , a.Middle_Name_Arabic__c, a.MiddleName, a.Last_Name__c, a.Last_Name_Arabic__pc
                                   , a.Last_Name_Arabic__c, a.LastName, a.IsPersonAccount, a.Id, a.IPMS_Status__c
                                   , a.Home_Phone__c, a.Home_Phone_Encrypt__c, a.Home_Phone_Country_Code__c
                                   , a.First_Name__c, a.First_Name_Arabic__pc, a.First_Name_Arabic__c, a.FirstName
                                   , a.Fax__c, a.Fax_Number_Arabic__pc, a.Fax_Extension_Arabic__pc
                                   , a.Fax_Country_Code_Arabic__pc, a.Fax_Area_Code_Arabic__pc, a.Fax, a.Email__c
                                   , a.Email_Address_Arabic__pc, a.Date_of_Incorporation__c, a.Date_of_Birth__pc
                                   , a.Date_Of_Birth__c, a.Country_of_Incorporation__c, a.Country_of_Incorporation_New__c
                                   , a.Country__pc, a.Country__c, a.Country_Arabic__pc, a.Country_Arabic__c
                                   , a.City_of_Incorporation__c, a.City__pc, a.City__c, a.City_Of_Incorporation_New__c
                                   , a.City_Arabic__pc, a.City_Arabic__c, a.CR_Registration_Place__pc
                                   , a.CR_Registration_Place__c, a.CR_Registration_Place_Arabic__pc
                                   , a.CR_Registration_Place_Arabic__c, a.CR_Registration_Expiry_Date__c
                                   , a.CR_Registration_Date__pc, a.CR_Registration_Date_Arabic__pc, a.CR_Number__pc
                                   , a.CR_Number__c, a.CR_Number_Arabic__pc, a.Address__pc, a.Address_Line_4__pc
                                   , a.Address_Line_4_Arabic__pc, a.Address_Line_3__pc, a.Address_Line_3_Arabic__pc
                                   , a.Address_Line_2__pc, a.Address_Line_2_Arabic__pc, a.Address_Line_1__pc
                                   , a.Address_Line_1_Arabic__pc  
                                   From Account a where Id IN: setAccountIds];

        for(Account objA : lstA){
            system.debug('objA==='+objA);

            AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
            customerCreationUnitRegistration.APPSXXDC_SFDC_REGISTX1809884X1X1 objCust 
            = new customerCreationUnitRegistration.APPSXXDC_SFDC_REGISTX1809884X1X1();
            objCust.ATTRIBUTE1 = '';
            objCust.ATTRIBUTE2 = '';
            objCust.ATTRIBUTE3 = '';
            objCust.ATTRIBUTE4 = '';
            objCust.ATTRIBUTE5 = '';
            objCust.ATTRIBUTE6 = '';
            objCust.ATTRIBUTE7 = '';
            objCust.ATTRIBUTE8 = '';
            objCust.ATTRIBUTE9 = '';
            objCust.ATTRIBUTE10 = '';
            objCust.EXT_CUST_NUMBER = objA.Cust_Account_ID__c != null ? objA.Cust_Account_ID__c : '';
            objCust.INTRODUCED_BY = '';
            objCust.ORGANIZATION_NAME = objA.isPersonAccount == true ? '' : objA.Name;
            objCust.PARTY_FIRST_NAME = objA.FirstName != null ? objA.FirstName : '';
            objCust.PARTY_ID = objA.Party_ID__c != null ? objA.Party_ID__c : '';
            objCust.PARTY_LAST_NAME = objA.LastName != null ? objA.LastName : '';
            objCust.PARTY_MIDDLE_NAME = objA.MiddleName != null ? objA.MiddleName : '';
            objCust.PARTY_TITLE = objA.PersonTitle != null ? objA.PersonTitle : '';
            objCust.PARTY_TYPE = objA.isPersonAccount == true ? 'Person' : 'Organization';
            objCust.WHY_DAMAC = '';
            objCust.WHY_DUBAI = '';
            system.debug('objCust==='+objCust);

            customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X23 objCustAddr
            = new customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X23();
            objCustAddr.ADDRESS1 = objA.Address_Line_1__pc != null ? objA.Address_Line_1__pc : '';
            objCustAddr.ADDRESS2 = objA.Address_Line_2__pc != null ? objA.Address_Line_2__pc : '';
            objCustAddr.ADDRESS3 = objA.Address_Line_3__pc != null ? objA.Address_Line_3__pc : '';
            objCustAddr.ADDRESS4 = objA.Address_Line_4__pc != null ? objA.Address_Line_4__pc : '';
            objCustAddr.ATTRIBUTE1 = '';
            objCustAddr.ATTRIBUTE2 = '';
            objCustAddr.ATTRIBUTE3 = '';
            objCustAddr.ATTRIBUTE4 = '';
            objCustAddr.ATTRIBUTE5 = '';
            objCustAddr.ATTRIBUTE6 = '';
            objCustAddr.ATTRIBUTE7 = '';
            objCustAddr.ATTRIBUTE8 = '';
            objCustAddr.ATTRIBUTE9 = '';
            objCustAddr.ATTRIBUTE10 = '';
            objCustAddr.CITY = objA.City__pc != null ? objA.City__pc : '';
            objCustAddr.COUNTRY = objA.Country__pc != null ? objA.Country__pc : '';
            objCustAddr.POSTAL_CODE = objA.P_O_Box_Zip_Postal_Code__c != null ? objA.P_O_Box_Zip_Postal_Code__c : '';
            objCustAddr.STATE = objA.State__c != null ? objA.State__c : '';
            system.debug('objCustAddr==='+objCustAddr);
            
            customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X42 custContact
            = new customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X42();
            custContact.ATTRIBUTE1 = '';
            custContact.ATTRIBUTE2 = '';
            custContact.ATTRIBUTE3 = '';
            custContact.ATTRIBUTE4 = '';
            custContact.ATTRIBUTE5 = '';
            Datetime dt = objA.Date_of_Birth__pc;
            custContact.BIRTH_DATE = dt != null ? dt.format('dd-MMM-yyyy') : '';
            custContact.BIRTH_PLACE = '';
            custContact.CR_NUMBER = objA.CR_Number__pc != null ? objA.CR_Number__pc : '';
            Datetime regDate = objA.CR_Registration_Date__pc;
            custContact.CR_REG_DATE = regDate != null ? regDate.format('dd-MMM-yyyy') : '';
            custContact.CR_REG_PLACE = objA.CR_Registration_Place__pc != null ? objA.CR_Registration_Place__pc : '';
            custContact.EID_EXP_DATE = '';
            custContact.EID_NUMBER = '';
            custContact.EMAIL_ADDRESS = objA.PersonEmail != null ? objA.PersonEmail : '';
            custContact.FAX_AREA_CODE = '';
            custContact.FAX_COUNTRY_CODE = '';
            custContact.FAX_NUMBER = objA.Fax != null ? objA.Fax : '';
            custContact.GENDER = '';
            custContact.HOME_AREA_CODE = '';
            custContact.HOME_COUNTRY_CODE = '';
            custContact.HOME_NUMBER = '';
            custContact.MOBILE_AREA_CODE = objA.Mobile_Area_Code__c != null ? objA.Mobile_Area_Code__c : '';
            String MobileCode = objA.Mobile_Country_Code__c;
            if(MobileCode != null) {
                MobileCode = MobileCode.subStringAfter(':').trim();
                MobileCode = String.valueOf(Integer.valueOf(MobileCode));
            }
            custContact.MOBILE_COUNTRY_CODE = MobileCode != null ? MobileCode : '';
            custContact.MOBILE_NUMBER = objA.Mobile__c != null ? objA.Mobile__c : '';
            custContact.NATIONALITY = objA.Nationality__pc != null ? objA.Nationality__pc : '';
            Datetime passExpDate = objA.Passport_Expiry_Date__pc;
            custContact.PASSPORT_EXP_DATE = passExpDate != null ? passExpDate.format('dd-MMM-yyyy') : '';
            Datetime passIssueDate = objA.Passport_Issue_Date__pc;
            custContact.PASSPORT_ISSUE_DATE = passIssueDate != null ? passIssueDate.format('dd-MMM-yyyy') : '';
            custContact.PASSPORT_NUMBER = objA.Passport_Number__pc != null ? objA.Passport_Number__pc : '';
            custContact.PASSPROT_COUNTRY = '';
            custContact.PASSPROT_ISSUE_PLACE = objA.Passport_Issue_Place__pc != null ? objA.Passport_Issue_Place__pc : '';
            custContact.PRIMARY_FLAG = '';
            custContact.URL = '';
            custContact.WORK_AREA_CODE = '';
            String workCode = objA.Work_Phone_Country_Code__c;
            if(workCode != null) {
                workCode = workCode.subStringAfter(':').trim();
                workCode = String.valueOf(Integer.valueOf(workCode));
            }
            custContact.WORK_COUNTRY_CODE = workCode != null ? workCode : '';
            custContact.WORK_NUMBER = objA.Work_Phone__c != null ? objA.Work_Phone__c : '';
            system.debug('custContact==='+custContact);

            customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X77 objCusAr
            = new customerCreationUnitRegistration.APPSXXDC_SFDC_REGISX1809884X1X77();
            objCusAr.ATTRIBUTE1 = '';
            objCusAr.ATTRIBUTE2 = '';
            objCusAr.ATTRIBUTE3 = '';
            objCusAr.ATTRIBUTE4 = '';
            objCusAr.ATTRIBUTE5 = '';
            objCusAr.CR_NUMBER_AR = objA.CR_Number_Arabic__pc != null ? objA.CR_Number_Arabic__pc : '';
            objCusAr.CR_REG_DATE_AR = objA.CR_Registration_Date_Arabic__pc != null ? objA.CR_Registration_Date_Arabic__pc : '';
            objCusAr.CR_REG_PLACE_AR = objA.CR_Registration_Place_Arabic__pc != null ? objA.CR_Registration_Place_Arabic__pc : '';
            objCusAr.EMAIL_ADDRESS_AR = objA.Email_Address_Arabic__pc != null ? objA.Email_Address_Arabic__pc : '';
            objCusAr.FAX_AREA_CODE_AR = objA.Fax_Area_Code_Arabic__pc != null ? objA.Fax_Area_Code_Arabic__pc : '';
            objCusAr.FAX_COUNTRY_CODE_AR = objA.Fax_Country_Code_Arabic__pc != null ? objA.Fax_Country_Code_Arabic__pc : '';
            objCusAr.FAX_EXTENSION_AR = objA.Fax_Extension_Arabic__pc != null ? objA.Fax_Extension_Arabic__pc : '';
            objCusAr.FAX_NUMBER_AR = objA.Fax_Number_Arabic__pc != null ? objA.Fax_Number_Arabic__pc : '';
            objCusAr.FIRST_NAME_AR = objA.First_Name_Arabic__pc != null ? objA.First_Name_Arabic__pc : '';
            objCusAr.LAST_NAME_AR = objA.Last_Name_Arabic__pc != null ? objA.Last_Name_Arabic__pc : '';
            objCusAr.MIDDLE_NAME_AR = objA.Middle_Name_Arabic__pc != null ? objA.Middle_Name_Arabic__pc : '';
            objCusAr.MOBILE_AREA_CODE_AR = objA.Mobile_Area_Code_Arabic__pc != null ? objA.Mobile_Area_Code_Arabic__pc : '';
            objCusAr.MOBILE_COUNTRY_CODE_AR = objA.Mobile_Country_Code_Arabic__pc != null ? objA.Mobile_Country_Code_Arabic__pc : '';
            objCusAr.MOBILE_NUMBER_AR = objA.Mobile_Number_Arabic__pc != null ? objA.Mobile_Number_Arabic__pc : '';
            objCusAr.NATIONALITY_AR = objA.Nationality_Arabic__pc != null ? objA.Nationality_Arabic__pc : '';
            objCusAr.PASSPORT_ISSUE_DATE_AR = objA.Passport_Issue_Date_Arabic__pc != null ? objA.Passport_Issue_Date_Arabic__pc : '';
            objCusAr.PASSPORT_ISSUE_PLACE_AR = objA.Passport_Issue_Place_Arabic__pc != null ? objA.Passport_Issue_Place_Arabic__pc : '';
            objCusAr.PASSPORT_NUMBER_AR = objA.Passport_Number_Arabic__pc != null ? objA.Passport_Number_Arabic__pc : '';
            objCusAr.PHONE_AREA_CODE_AR = objA.Phone_Area_Code_Arabic__pc != null ? objA.Phone_Area_Code_Arabic__pc : '';
            objCusAr.PHONE_COUNTRY_CODE_AR = objA.Phone_Country_Code_Arabic__pc != null ? objA.Phone_Country_Code_Arabic__pc : '';
            objCusAr.PHONE_EXTENTION_AR = objA.Phone_Extension_Arabic__pc != null ? objA.Phone_Extension_Arabic__pc : '';
            objCusAr.PHONE_NUMBER_AR = objA.Phone_Number_Arabic__pc != null ? objA.Phone_Number_Arabic__pc : '';
            objCusAr.TITLE_NUM_AR = objA.Title_Arabic__pc != null ? objA.Title_Arabic__pc : '';
            system.debug('objCusAr==='+objCusAr);

            customerCreationUnitRegistration.APPSXXDC_SFDC_REGIX1809884X1X106 objCustArAddr
            = new customerCreationUnitRegistration.APPSXXDC_SFDC_REGIX1809884X1X106();
            objCustArAddr.ADDRESS1_AR = objA.Address_Line_1_Arabic__pc != null ? objA.Address_Line_1_Arabic__pc : '';
	        objCustArAddr.ADDRESS2_AR = objA.Address_Line_2_Arabic__pc != null ? objA.Address_Line_2_Arabic__pc : '';
	        objCustArAddr.ADDRESS3_AR = objA.Address_Line_3_Arabic__pc != null ? objA.Address_Line_3_Arabic__pc : '';
	        objCustArAddr.ADDRESS4_AR = objA.Address_Line_4_Arabic__pc != null ? objA.Address_Line_4_Arabic__pc : '';
	        objCustArAddr.ATTRIBUTE1 = '';
	        objCustArAddr.ATTRIBUTE2 = '';
	        objCustArAddr.ATTRIBUTE3 = '';
	        objCustArAddr.ATTRIBUTE4 = '';
	        objCustArAddr.ATTRIBUTE5 = '';
	        objCustArAddr.CITY_AR = objA.City_Arabic__pc != null ? objA.City_Arabic__pc : '';
	        objCustArAddr.COUNTRY_AR = objA.Country_Arabic__pc != null ? objA.Country_Arabic__pc : '';
	        objCustArAddr.POSTAL_CODE_AR = objA.Postal_Code_Arabic__pc != null ? objA.Postal_Code_Arabic__pc : '';
	        system.debug('objCustArAddr==='+objCustArAddr);

            String createCustomerResponse = objClass.customerCreation(objCust,objCustAddr,custContact,objCusAr,objCustArAddr);
            system.debug('createCustomerResponse==='+createCustomerResponse);
            if(String.isNotBlank(createCustomerResponse)) {
                map<String,Object> mapDeserializeCreateCustomer = (map<String,Object>)JSON.deserializeUntyped(createCustomerResponse);
                if(mapDeserializeCreateCustomer.get('STATUS') == 'S') {
                    objA.Party_ID__c = String.valueOf(mapDeserializeCreateCustomer.get('X_PARTY_ID'));
                    objA.Cust_Account_ID__c = String.valueOf(mapDeserializeCreateCustomer.get('X_CUST_ACCOUNT_ID'));
                    lstUpdateAccount.add(objA);
                }
            }
        }
        if(!lstUpdateAccount.isEmpty()) {
            update lstUpdateAccount;
            system.debug('lstUpdateAccount==='+lstUpdateAccount);
        }
    }
}