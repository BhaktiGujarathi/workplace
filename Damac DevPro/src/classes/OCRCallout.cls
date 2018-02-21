global class OCRCallout{


    public static void sendDocumentToOCR(List<id> srIds){
        // Perform some operations
        System.debug('OCR CallOut');
        /*List<Service_request__c> srList = new List<Service_request__c>();
for(Id srid : srIds){
Service_request__c sr = new Service_request__c(Id=srid, OCR_verified__c=true);
srList.add(sr);
}
update srList;
*/
        //callIPMSHandler(srIds);
    }

    public static void callIPMSHandler(List<id> srIds){
        IPMSCallout(srIds);
    }

    //@future(callout=true) uncomment it after callourt wsdl is corrected
    public static void IPMSCallout(List<id> srIds){
        List<Case> casesList = new List<Case>();
        for(Id id : srIds){
            casesList.add(new Case(Id=id,IPMS_Updated__c=true));
        }
        update casesList;
        /*
//cocdSR.ContactEmail = accountDetails.PersonEmail;
//cocdSR.Phone_Country_Code__c = customer.Phone_Country_Code__c; ---> create thuis field in Case obj
//cocdSR.ContactPhone = accountDetails.Phone;
*/
        /*List<Case> srList = [SELECT Id,Address__c, Address_Arabic_1__c, Address_2__c, Address_Arabic_2__c,
Address_3__c, Address_Arabic_3__c, Address_4__c, Address_Arabic_4__c, City__c,
City_Arabic__c, State__c, Country__c, Country_Arabic__c, Postal_Code__c, AccountId,
Postal_Code_Arabic__c from Case where Id IN: srIds ];


List<Account> accList = new List<Account>();
for( Case sr : srList ){
Account a = new Account(Id=sr.AccountId,Address_Line_1__pc=sr.Address__c,Address_Line_1_Arabic__pc=sr.Address_Arabic_1__c,
Address_Line_2__pc=sr.Address_2__c,Address_Line_2_Arabic__pc=sr.Address_Arabic_2__c,
Address_Line_3__pc=sr.Address_3__c,Address_Line_3_Arabic__pc=sr.Address_Arabic_3__c,
Address_Line_4__pc=sr.Address_4__c,Address_Line_4_Arabic__pc=sr.Address_Arabic_4__c,
City__pc=sr.City__c,City_Arabic__pc=sr.City_Arabic__c,State__c=sr.State__c,
Country__pc=sr.Country__c,Country_Arabic__pc=sr.Country_Arabic__c,Zip_Postal_Code__c=sr.Postal_Code__c,
Postal_Code_Arabic__pc=sr.Postal_Code_Arabic__c);
accList.add(a);
}
update accList;
NotifyUserAfterUpdate(srList);*/
        /*system.debug(' all sr ids :  '+ srIds);
List<Service_request__c> sreqs = [SELECT Account__c, Address__c, Address_Arabic_1__c, Address_2__c, Address_Arabic_2__c, Address_3__c, Address_Arabic_3__c, Address_4__c,
Address_Arabic_4__c, City__c, City_Arabic__c, Country__c, Country_Arabic__c, Contact_Email__c, Contact_Phone__c, Postal_Code__c, Name,
Postal_Code_Arabic__c, State__c FROM Service_request__c WHERE Id IN: srIds ];
List<String> accIds = new List<String>();
for(Service_request__c s : sreqs){
accIds.add(s.Account__c);
}
system.debug(' all accIds ids :  '+ accIds);
Map<Id, Account> AccountId_AccountMap = new Map<Id, Account>([SELECT CR_Registration_Date__pc, CR_Registration_Place__pc, CR_Number__pc, Fax, PersonMobilePhone,
Mobile_Area_Code__pc, Mobile_Country_Code__pc, Nationality__pc, Passport_Issue_Date__pc,Party_ID__c,
Passport_Number__pc, Passport_Issue_Place__pc FROM Account WHERE Id IN: accIds]);
system.debug(' all AccountId_AccountMap ids :  '+ AccountId_AccountMap);
Map<String, beanDamacgroupCom.Address> srId_Address = new Map<String, beanDamacgroupCom.Address>();
for(Service_request__c sr : sreqs){
beanDamacgroupCom.Address address = new beanDamacgroupCom.Address();
address.addressLine1 = sr.Address__c;
address.addressLine2 = sr.Address_2__c;
address.addressLine3 = sr.Address_3__c;
address.addressLine4 = sr.Address_4__c;
address.addressLineArabic1 = sr.Address_Arabic_1__c;
address.addressLineArabic2 = sr.Address_Arabic_2__c;
address.addressLineArabic3 = sr.Address_Arabic_3__c;
address.addressLineArabic4 = sr.Address_Arabic_4__c;
address.city = sr.City__c;
address.cityArabic = sr.City_Arabic__c;
address.country = sr.Country__c;
address.countryArabic = sr.Country_Arabic__c;
address.crRegDate = String.valueOf(AccountId_AccountMap.get(sr.Account__c).CR_Registration_Date__pc);
address.crRegPlace = AccountId_AccountMap.get(sr.Account__c).CR_Registration_Place__pc;
address.cr_Number = AccountId_AccountMap.get(sr.Account__c).CR_Number__pc;
address.email = sr.Contact_Email__c;
address.fax = AccountId_AccountMap.get(sr.Account__c).Fax;
address.faxAreaCode =  '122';
address.faxCountryCode = '325';
address.mobile =  AccountId_AccountMap.get(sr.Account__c).PersonMobilePhone;
address.mobileAreaCode = AccountId_AccountMap.get(sr.Account__c).Mobile_Area_Code__pc;
address.mobileCountryCode = AccountId_AccountMap.get(sr.Account__c).Mobile_Country_Code__pc;
address.nationality = AccountId_AccountMap.get(sr.Account__c).Nationality__pc;
address.passportIssueDate = String.valueOf(AccountId_AccountMap.get(sr.Account__c).Passport_Issue_Date__pc);
address.passportNumber = AccountId_AccountMap.get(sr.Account__c).Passport_Number__pc;
address.passprotIssuePlace =  AccountId_AccountMap.get(sr.Account__c).Passport_Issue_Place__pc;
address.phone = sr.Contact_Phone__c;
address.postalCode = sr.Postal_Code__c;
address.postalCodeArabic = sr.Postal_Code_Arabic__c;
address.primaryFlag = 'true';
address.state = sr.State__c;
address.workAreaCode = '12';
address.workCountryCode = '23';
address.workNumber = '7894561230';
srId_Address.put(sr.Id, address);
}

actionDamacgroupCom.COCD call = new actionDamacgroupCom.COCD();
call.timeout_x = 120000;
call.clientCert_x = 'SelfSignedCert_10Apr2017';
beanDamacgroupCom.COCDOutputParameters resp = call.updateCOCDRecordInIPMS(AccountId_AccountMap.get(sreqs[0].Account__c).Party_ID__c, sreqs[0].Name, srId_Address.get(sreqs[0].Id), 'test', 'test');
system.debug(resp);
*/
        /*List<Service_request__c> srList = [SELECT Id,Contact_Email__c, Account__c, Contact_Detail_to_update__c, New_Contact_Value__c from Service_request__c where Id IN: srIds ];
NotifyUserAfterUpdate(srList);

List<Account> accList = new List<Account>();
for( Service_request__c sr : srList ){
Account a = new Account(Id=sr.Account__c, PersonEmail=sr.New_Contact_Value__c);
accList.add(a);
}
update accList;*/
    }

    public static void NotifyUserAfterUpdate(List<Case> lstSR){
        List<String> toAddresses = new List<String>();
        for( Case sr : lstSR){
            toAddresses.add('amit.joshi@eternussolutions.com');
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);

        mail.setSubject('Your COCD Service request is completed' );
        String mailBody = 'Hi,<br/>';
        mailBody += '<p>Your request for details change is complete.</p><br/><br/>';
        mailBody += 'Thanks you,<br/>DAMAC Team.';

        mail.setHtmlBody( mailBody );
        system.debug('mail' + mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}