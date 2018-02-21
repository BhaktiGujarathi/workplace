global class DAMACWebServiceUtils {
     
    
    
    /*************************************************************************************************************************/
    /****************************************Booking Generation Start*********************************************************/
    /*************************************************************************************************************************/
   public static string prepareRegistrationRequest(Booking__c booking, List<Booking_unit__c> units){
        
        
        User loggedInUser = [Select id,Sales_Person_ID__c,Sales_Office__c,HOD_ID__c,HOS_ID__c,DOS_ID__c from User where Id=:UserInfo.getUserId()];
        
         
        string bookingchannel = '';
        if(booking.Booking_channel__c == 'Office')
            bookingchannel = 'OFF';
        if(booking.Booking_channel__c == 'Web') 
            bookingchannel = 'WEB';
        if(booking.Booking_channel__c == 'Mobile')
            bookingchannel = 'MOB';
        
        Map<Id,Joint_Buyer__c> PrimaryBuyers = new Map<Id,Joint_Buyer__c>();
        Map<Id,List<Joint_Buyer__c>> JointBuyers = new Map<Id,List<Joint_Buyer__c>>();
        
        for(Joint_Buyer__c jb: [Select id, Account__r.Salutation, Account__c, Account__r.FirstName,Account__r.MiddleName,Account__r.LastName,Account__r.NATIONALITY__Pc,
                                                            Account__r.Passport_Number__pc,Account__r.CR_Number__pc,Account__r.CR_Registration_Place__pc,Account__r.CR_Registration_Date__pc,
                                                            Account__r.Phone,Account__r.PersonMobilePhone,Account__r.Fax,Account__r.PersonEmail,Account__r.Passport_Issue_Date__pc,
                                                            Account__r.Passport_Issue_Place__pc,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingPostalCode,Account__r.BillingCountry,
                                                            Account__r.Title_Arabic__pc,Account__r.First_Name_Arabic__pc,Account__r.Middle_Name_Arabic__pc,Account__r.Last_Name_Arabic__pc,
                                                            Account__r.Nationality_Arabic__pc,Account__r.Phone_Number_Arabic__pc,Account__r.Mobile_Number_Arabic__pc,Account__r.Fax_Number_Arabic__pc,
                                                            Account__r.Email_Address_Arabic__pc,Account__r.Address1_Arabic__pc,Account__r.Passport_Number_Arabic__pc,Account__r.CR_NUmber_arabic__pc,
                                                            Account__r.Address2_Arabic__pc,Account__r.Address3_Arabic__pc,Account__r.Address4_Arabic__pc,Account__r.City_Arabic__pc,
                                                            Account__r.Postal_Code_Arabic__pc,Account__r.Country_Arabic__pc, Account__r.Passport_Issue_Place_Arabic__pc, Account__r.Passport_Issue_Date_Arabic__pc,
                                                            Account__r.CR_Registration_Place_Arabic__pc, Account__r.CR_Registration_Date_Arabic__pc
                                                            from Joint_Buyer__c where Booking__c =: booking.Id]){
            if(jb.Primary_Buyer__c){
                PrimaryBuyers.put(jb.Booking__c, jb);
            }
            else{
                if(!jointBuyers.containsKey(jb.Booking__c)){
                    JointBuyers.put(jb.Booking__c, new List<Joint_Buyer__c>{jb});
                }
                else{
                    List<Joint_Buyer__c> existing = jointBuyers.get(jb.Booking__c);
                    existing.add(jb);
                    JointBuyers.put(jb.Booking__c, existing);
                }
            }
            
        }
        
        
        if(PrimaryBuyers.containsKey(booking.Id)){
            string body = '';
            string accQuery = getCreatableFieldsSOQL('Account');
            accQuery+=' where Id=:PrimaryBuyers.get(booking.Id)';
            Account acc = database.query(accQuery);
            
            String passportdate = acc.Passport_Issue_Date__pc.day()+'/'+acc.Passport_Issue_Date__pc.month()+'/'+acc.Passport_Issue_Date__pc.year();
            string crRegDate = acc.CR_Registration_Date__pc.day()+'/'+acc.CR_Registration_Date__pc.month()+'/'+acc.CR_Registration_Date__pc.year();
            string mobileCountryCode = acc.MOBILE_COUNTRY_CODE__pc != null ? acc.MOBILE_COUNTRY_CODE__pc.split(' :')[1] : '';
            string partyId = acc.Party_Id__c != null ? acc.party_Id__c :'';
       
            body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_registration_process_ws/" xmlns:reg="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_registration_process_ws/registration_proc/">';
                
                body+='<soapenv:Header>';
                    body+='<xxdc:SOAHeader>';
                        body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
                        body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
                        body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
                        body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
                        body+='<xxdc:Org_Id/>';
                    body+='</xxdc:SOAHeader>';
                        body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                            body+='<wsse:UsernameToken>';
                                body+='<wsse:Username>oracle_user</wsse:Username>';
                                body+='<wsse:Password>crp1user</wsse:Password>';
                            body+='</wsse:UsernameToken>';
                    body+='</wsse:Security>';
                body+='</soapenv:Header>';
                
                body+='<soapenv:Body>';
                    body+='<reg:InputParameters>';
                        
                        body+='<reg:P_CUST_RECORD>';
                            body+='<reg:PARTY_TYPE>Person</reg:PARTY_TYPE>';
                            body+='<reg:PARTY_ID>'+partyId+'</reg:PARTY_ID>';
                            body+='<reg:SIEBEL_CUST_NUMBER></reg:SIEBEL_CUST_NUMBER>'; // Salesforce LEad ID
                            body+='<reg:PARTY_TITLE>'+acc.Salutation+'</reg:PARTY_TITLE>';
                            body+='<reg:PARTY_FIRST_NAME>'+acc.FirstName+'</reg:PARTY_FIRST_NAME>';
                            body+='<reg:PARTY_MIDDLE_NAME>'+acc.MiddleName+'</reg:PARTY_MIDDLE_NAME>';
                            body+='<reg:PARTY_LAST_NAME>'+acc.LastName+'</reg:PARTY_LAST_NAME>';
                            body+='<reg:ORGANIZATION_NAME></reg:ORGANIZATION_NAME>';
                            body+='<reg:WHY_DUBAI></reg:WHY_DUBAI>';
                            body+='<reg:WHY_DAMAC></reg:WHY_DAMAC>';
                            body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                            body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                            body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                            body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                        body+='</reg:P_CUST_RECORD>';
                        
                        body+='<reg:P_CUST_ADDRESS>';
                            body+='<reg:ADDRESS1>'+acc.BillingStreet+'</reg:ADDRESS1>';
                            body+='<reg:ADDRESS2></reg:ADDRESS2>';
                            body+='<reg:ADDRESS3></reg:ADDRESS3>';
                            body+='<reg:ADDRESS4></reg:ADDRESS4>';
                            body+='<reg:CITY>'+acc.BillingCity+'</reg:CITY>';
                            body+='<reg:POSTAL_CODE>'+acc.BillingPostalCode+'</reg:POSTAL_CODE>';
                            body+='<reg:STATE>'+acc.BillingState+'</reg:STATE>';
                            body+='<reg:COUNTRY>'+acc.BillingCountry+'</reg:COUNTRY>';
                            body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                            body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                            body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                            body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                        body+='</reg:P_CUST_ADDRESS>';
                        
                        body+='<reg:P_CUST_CONTACT>';
                            body+='<reg:HOME_COUNTRY_CODE></reg:HOME_COUNTRY_CODE>';
                            body+='<reg:HOME_AREA_CODE></reg:HOME_AREA_CODE>';
                            body+='<reg:HOME_NUMBER></reg:HOME_NUMBER>';
                            body+='<reg:WORK_COUNTRY_CODE></reg:WORK_COUNTRY_CODE>';
                            body+='<reg:WORK_AREA_CODE></reg:WORK_AREA_CODE>';
                            body+='<reg:MOBILE_COUNTRY_CODE>'+acc.Mobile_Country_Code__pc+'</reg:MOBILE_COUNTRY_CODE>';
                            body+='<reg:MOBILE_AREA_CODE>'+acc.Mobile_Area_Code__pc+'</reg:MOBILE_AREA_CODE>';
                            body+='<reg:MOBILE_NUMBER>'+acc.PersonMobilePhone+'</reg:MOBILE_NUMBER>';
                            body+='<reg:FAX_COUNTRY_CODE></reg:FAX_COUNTRY_CODE>';
                            body+='<reg:FAX_AREA_CODE></reg:FAX_AREA_CODE>';
                            body+='<reg:FAX_NUMBER>'+acc.Fax+'</reg:FAX_NUMBER>';
                            body+='<reg:EMAIL_ADDRESS>'+acc.PersonEmail+'</reg:EMAIL_ADDRESS>';
                            body+='<reg:URL></reg:URL>';
                            body+='<reg:NATIONALITY>'+acc.Nationality__pc+'</reg:NATIONALITY>';
                            body+='<reg:PASSPORT_NUMBER>'+acc.Passport_Number__pc+'</reg:PASSPORT_NUMBER>';
                            body+='<reg:PASSPORT_ISSUE_DATE>'+acc.Passport_Issue_Date__pc+'</reg:PASSPORT_ISSUE_DATE>';
                            body+='<reg:PASSPROT_ISSUE_PLACE>'+acc.Passport_Issue_Place__pc+'</reg:PASSPROT_ISSUE_PLACE>';
                            body+='<reg:CR_NUMBER>'+acc.CR_Number__pc+'</reg:CR_NUMBER>';
                            body+='<reg:CR_REG_PLACE>'+acc.CR_Registration_Place__pc+'</reg:CR_REG_PLACE>';
                            body+='<reg:CR_REG_DATE>'+acc.CR_Registration_Date__pc+'</reg:CR_REG_DATE>';
                            body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                            body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                            body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                            body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                        body+='</reg:P_CUST_CONTACT>';
                        
                        body+='<reg:P_CUST_AR_DATA>';
                            body+='<reg:TITLE_NUM_AR>'+acc.Title_Arabic__pc+'</reg:TITLE_NUM_AR>';
                            body+='<reg:FIRST_NAME_AR>'+acc.First_name_arabic__pc+'</reg:FIRST_NAME_AR>';
                            body+='<reg:MIDDLE_NAME_AR>'+acc.Middle_name_arabic__pc+'</reg:MIDDLE_NAME_AR>';
                            body+='<reg:LAST_NAME_AR>'+acc.LAST_NAME_Arabic__pc+'</reg:LAST_NAME_AR>';
                            body+='<reg:NATIONALITY_AR>'+acc.Nationality_Arabic__pc+'</reg:NATIONALITY_AR>';
                            body+='<reg:PASSPORT_NUMBER_AR>'+acc.Passport_Number_Arabic__pc+'</reg:PASSPORT_NUMBER_AR>';
                            body+='<reg:CR_NUMBER_AR>'+acc.CR_NUmber_arabic__pc+'</reg:CR_NUMBER_AR>';
                            body+='<reg:CR_REG_DATE_AR>'+acc.CR_Registration_Date_Arabic__pc+'</reg:CR_REG_DATE_AR>';
                            body+='<reg:CR_REG_PLACE_AR>'+acc.CR_Registration_Place_Arabic__pc+'</reg:CR_REG_PLACE_AR>';
                            body+='<reg:EMAIL_ADDRESS_AR>'+acc.Email_Address_Arabic__pc+'</reg:EMAIL_ADDRESS_AR>';
                            body+='<reg:PASSPORT_ISSUE_DATE_AR>'+acc.Passport_Issue_Date_Arabic__pc+'</reg:PASSPORT_ISSUE_DATE_AR>';
                            body+='<reg:PASSPORT_ISSUE_PLACE_AR>'+acc.Passport_Issue_Place_Arabic__pc+'</reg:PASSPORT_ISSUE_PLACE_AR>';
                            body+='<reg:MOBILE_COUNTRY_CODE_AR>'+acc.MOBILE_COUNTRY_CODE_ARabic__pc+'</reg:MOBILE_COUNTRY_CODE_AR>';
                            body+='<reg:MOBILE_AREA_CODE_AR>'+acc.MOBILE_Area_CODE_ARabic__pc+'</reg:MOBILE_AREA_CODE_AR>';
                            body+='<reg:MOBILE_NUMBER_AR>'+acc.Mobile_Number_Arabic__pc+'</reg:MOBILE_NUMBER_AR>';
                            body+='<reg:PHONE_COUNTRY_CODE_AR>'+acc.PHONE_COUNTRY_CODE_Arabic__pc+'</reg:PHONE_COUNTRY_CODE_AR>';
                            body+='<reg:PHONE_AREA_CODE_AR>'+acc.Phone_Area_Code_Arabic__pc+'</reg:PHONE_AREA_CODE_AR>';
                            body+='<reg:PHONE_NUMBER_AR>'+acc.Phone_Number_Arabic__pc+'</reg:PHONE_NUMBER_AR>';
                            body+='<reg:PHONE_EXTENTION_AR>'+acc.Phone_extension_arabic__pc+'</reg:PHONE_EXTENTION_AR>';
                            body+='<reg:FAX_COUNTRY_CODE_AR>'+acc.FAX_COUNTRY_CODE_ARAbic__pc+'</reg:FAX_COUNTRY_CODE_AR>';
                            body+='<reg:FAX_AREA_CODE_AR>'+acc.FAX_AREA_CODE_ARABIC__pc+'</reg:FAX_AREA_CODE_AR>';
                            body+='<reg:FAX_NUMBER_AR>'+acc.Fax_Number_Arabic__pc+'</reg:FAX_NUMBER_AR>';
                            body+='<reg:FAX_EXTENSION_AR>'+acc.FAX_EXTENSION_ARABIC__pc+'</reg:FAX_EXTENSION_AR>';
                            body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                            body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                            body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                            body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                        body+='</reg:P_CUST_AR_DATA>';
                        
                        body+='<reg:P_CUST_AR_ADDRESS>';
                            body+='<reg:ADDRESS1_AR>'+acc.Address1_Arabic__pc+'</reg:ADDRESS1_AR>';
                            body+='<reg:ADDRESS2_AR>'+acc.Address2_Arabic__pc+'</reg:ADDRESS2_AR>';
                            body+='<reg:ADDRESS3_AR>'+acc.Address3_Arabic__pc+'</reg:ADDRESS3_AR>';
                            body+='<reg:ADDRESS4_AR>'+acc.Address4_Arabic__pc+'</reg:ADDRESS4_AR>';
                            body+='<reg:CITY_AR>'+acc.City_Arabic__pc+'</reg:CITY_AR>';
                            body+='<reg:COUNTRY_AR>'+acc.Country_Arabic__pc+'</reg:COUNTRY_AR>';
                            body+='<reg:POSTAL_CODE_AR>'+acc.Postal_Code_Arabic__pc+'</reg:POSTAL_CODE_AR>';
                            body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                            body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                            body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                            body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                        body+='</reg:P_CUST_AR_ADDRESS>';
                        
                        body+='<reg:P_REGISTRATION_RECORDS>';
                            for(Booking_Unit__c unit: units){
                                string deliveryMode = '';
                                if(booking.Delivery_mode__c == 'Email')
                                    deliveryMode = 'E';
                                if(booking.Delivery_mode__c == 'Dispatch')
                                    deliveryMode = 'D';
                                if(booking.Delivery_mode__c =='Print at Sales office')
                                    deliveryMode = 'S';  
                
                                body+='<reg:P_REGISTRATION_RECORDS_ITEM>';
                                    body+='<reg:SIEBEL_CUST_NUMBER></reg:SIEBEL_CUST_NUMBER>';
                                    body+='<reg:LOCATION>DP</reg:LOCATION>';
                                    body+='<reg:BOOKING_TYPE>Normal</reg:BOOKING_TYPE>';
                                    body+='<reg:PAYMENT_TERM_ID>106393</reg:PAYMENT_TERM_ID>';
                                    body+='<reg:RELEASE_ID>134766</reg:RELEASE_ID>';
                                    body+='<reg:ORG_ID>81</reg:ORG_ID>';
                                    body+='<reg:UNIT_ID>'+unit.Unit_Location_ID__c+'</reg:UNIT_ID>';
                                    body+='<reg:UNIT_NAME></reg:UNIT_NAME>';
                                    body+='<reg:SALES_PERSON_ID>'+loggedInUser.Sales_Person_ID__c+'</reg:SALES_PERSON_ID>';
                                    body+='<reg:DOS_ID>'+loggedInUser.DOS_ID__c+'</reg:DOS_ID>';
                                    body+='<reg:HOS_ID>'+loggedInUser.HOS_ID__c+'</reg:HOS_ID>';
                                    body+='<reg:HEAD_OF_DEPT_ID>'+loggedInUser.HOD_ID__c+'</reg:HEAD_OF_DEPT_ID>';
                                    body+='<reg:AGENT_ID></reg:AGENT_ID>';
                                    body+='<reg:BOOKING_AGENT_ID></reg:BOOKING_AGENT_ID>';
                                    body+='<reg:HOD>Prospecting</reg:HOD>';
                                    body+='<reg:PROMOTER></reg:PROMOTER>';
                                    body+='<reg:BASE_PRICE>'+unit.Selling_Price__c+'</reg:BASE_PRICE>';
                                    body+='<reg:RESERVATION_PRICE></reg:RESERVATION_PRICE>';
                                    body+='<reg:PROMOTION></reg:PROMOTION>';
                                    body+='<reg:SALES_OFFICE>'+loggedInUser.Sales_Office__c+'</reg:SALES_OFFICE>';
                                    body+='<reg:UNPAID_PARKING></reg:UNPAID_PARKING>';
                                    body+='<reg:EXTRA_OPTION_1></reg:EXTRA_OPTION_1>';
                                    body+='<reg:EXTRA_AMOUNT_1></reg:EXTRA_AMOUNT_1>';
                                    body+='<reg:EXTRA_OPTION_2></reg:EXTRA_OPTION_2>';
                                    body+='<reg:EXTRA_AMOUNT_2></reg:EXTRA_AMOUNT_2>';
                                    body+='<reg:REMARKS>Unit Related Remarks</reg:REMARKS>';
                                    body+='<reg:ADDITIONAL_REQUEST></reg:ADDITIONAL_REQUEST>';
                                    body+='<reg:SPECIAL_CONDITION></reg:SPECIAL_CONDITION>';
                                    body+='<reg:SELLER_SOLICITOR></reg:SELLER_SOLICITOR>';
                                    body+='<reg:BUYER_SOLICITOR_NAME></reg:BUYER_SOLICITOR_NAME>';
                                    body+='<reg:BUYER_SOLICITOR_FIRM></reg:BUYER_SOLICITOR_FIRM>';
                                    body+='<reg:BUYER_SOLICITOR_ADDR_1></reg:BUYER_SOLICITOR_ADDR_1>';
                                    body+='<reg:BUYER_SOLICITOR_ADDR_2></reg:BUYER_SOLICITOR_ADDR_2>';
                                    body+='<reg:BUYER_SOLICITOR_POST_CODE></reg:BUYER_SOLICITOR_POST_CODE>';
                                    body+='<reg:BUYER_SOLICITOR_PHONE_NO></reg:BUYER_SOLICITOR_PHONE_NO>';
                                    body+='<reg:BUYER_SOLICITOR_DX_NO></reg:BUYER_SOLICITOR_DX_NO>';
                                    body+='<reg:BUYER_SOLICITOR_EMAIL></reg:BUYER_SOLICITOR_EMAIL>';
                                    body+='<reg:JB_TABLE_REC>';
                                        if(JointBuyers.containsKey(booking.Id)){
                                            for(Joint_Buyer__c jb: JointBuyers.get(booking.Id)){
                                                body+='<reg:JB_TABLE_REC_ITEM>';
                                                    body+='<reg:JB_TITLE_EN>'+jb.Account__r.Salutation+'</reg:JB_TITLE_EN>';
                                                    body+='<reg:JB_FIRST_NAME_EN>'+jb.Account__r.FirstName+'</reg:JB_FIRST_NAME_EN>';
                                                    body+='<reg:JB_MIDDLE_NAME_EN>'+jb.Account__r.MiddleName+'</reg:JB_MIDDLE_NAME_EN>';
                                                    body+='<reg:JB_LAST_NAME_EN>'+jb.Account__r.LastName+'</reg:JB_LAST_NAME_EN>';
                                                    body+='<reg:JB_NATIONALITY_EN>'+jb.Account__r.NATIONALITY__Pc+'</reg:JB_NATIONALITY_EN>';
                                                    body+='<reg:JB_PASSPORT_NO_EN>'+jb.Account__r.Passport_Number__pc+'</reg:JB_PASSPORT_NO_EN>';
                                                    body+='<reg:JB_CR_NO_EN>'+jb.Account__r.CR_Number__pc+'</reg:JB_CR_NO_EN>';
                                                    body+='<reg:JB_CR_REG_PLACE_EN>'+jb.Account__r.CR_Registration_Place__pc+'</reg:JB_CR_REG_PLACE_EN>';
                                                    body+='<reg:JB_CR_REG_DATE_EN>'+jb.Account__r.CR_Registration_Date__pc+'</reg:JB_CR_REG_DATE_EN>';
                                                    body+='<reg:JB_HOME_PHONE_EN>'+jb.Account__r.Phone+'</reg:JB_HOME_PHONE_EN>';
                                                    body+='<reg:JB_WORK_PHONE_EN></reg:JB_WORK_PHONE_EN>';
                                                    body+='<reg:JB_MOBILE_PHONE_EN>'+jb.Account__r.PersonMobilePhone+'</reg:JB_MOBILE_PHONE_EN>';
                                                    body+='<reg:JB_FAX_EN>'+jb.Account__r.Fax+'</reg:JB_FAX_EN>';
                                                    body+='<reg:JB_EMAIL_EN>'+jb.Account__r.PersonEmail+'</reg:JB_EMAIL_EN>';
                                                    body+='<reg:JB_PASSPORT_ISSUE_DATE_EN>'+jb.Account__r.Passport_Issue_Date__pc+'</reg:JB_PASSPORT_ISSUE_DATE_EN>';
                                                    body+='<reg:JB_PASSPORT_ISSUE_PLACE_EN>'+jb.Account__r.Passport_Issue_Place__pc+'</reg:JB_PASSPORT_ISSUE_PLACE_EN>';
                                                    body+='<reg:JB_ADDRESS1_EN>'+jb.Account__r.BillingStreet+'</reg:JB_ADDRESS1_EN>';
                                                    body+='<reg:JB_ADDRESS2_EN></reg:JB_ADDRESS2_EN>';
                                                    body+='<reg:JB_ADDRESS3_EN></reg:JB_ADDRESS3_EN>';
                                                    body+='<reg:JB_ADDRESS4_EN></reg:JB_ADDRESS4_EN>';
                                                    body+='<reg:JB_CITY_EN>'+jb.Account__r.BillingCity+'</reg:JB_CITY_EN>';
                                                    body+='<reg:JB_ZIP_EN>'+jb.Account__r.BillingPostalCode+'</reg:JB_ZIP_EN>';
                                                    body+='<reg:JB_COUNTRY_EN>'+jb.Account__r.BillingCountry+'</reg:JB_COUNTRY_EN>';
                                                    body+='<reg:JB_TITLE_AR>'+jb.Account__r.Title_Arabic__pc+'</reg:JB_TITLE_AR>';
                                                    body+='<reg:JB_FIRST_NAME_AR>'+jb.Account__r.First_Name_Arabic__pc+'</reg:JB_FIRST_NAME_AR>';
                                                    body+='<reg:JB_MIDDLE_NAME_AR>'+jb.Account__r.Middle_Name_Arabic__pc+'</reg:JB_MIDDLE_NAME_AR>';
                                                    body+='<reg:JB_LAST_NAME_AR>'+jb.Account__r.Last_Name_Arabic__pc+'</reg:JB_LAST_NAME_AR>';
                                                    body+='<reg:JB_NATIONALITY_AR>'+jb.Account__r.Nationality_Arabic__pc+'</reg:JB_NATIONALITY_AR>';
                                                    body+='<reg:JB_PASSPORT_NO_AR>'+jb.Account__r.Passport_Number_Arabic__pc+'</reg:JB_PASSPORT_NO_AR>';
                                                    body+='<reg:JB_CR_NO_AR>'+jb.Account__r.CR_NUmber_arabic__pc+'</reg:JB_CR_NO_AR>';
                                                    body+='<reg:JB_CR_REG_PLACE_AR>'+jb.Account__r.CR_Registration_Place_Arabic__pc+'</reg:JB_CR_REG_PLACE_AR>';
                                                    body+='<reg:JB_CR_REG_DATE_AR>'+jb.Account__r.CR_Registration_Date_Arabic__pc+'</reg:JB_CR_REG_DATE_AR>';
                                                    body+='<reg:JB_HOME_PHONE_AR>'+jb.Account__r.Phone_Number_Arabic__pc+'</reg:JB_HOME_PHONE_AR>';
                                                    body+='<reg:JB_WORK_PHONE_AR></reg:JB_WORK_PHONE_AR>';
                                                    body+='<reg:JB_MOBILE_PHONE_AR>'+jb.Account__r.Mobile_Number_Arabic__pc+'</reg:JB_MOBILE_PHONE_AR>';
                                                    body+='<reg:JB_FAX_AR>'+jb.Account__r.Fax_Number_Arabic__pc+'</reg:JB_FAX_AR>';
                                                    body+='<reg:JB_EMAIL_AR>'+jb.Account__r.Email_Address_Arabic__pc+'</reg:JB_EMAIL_AR>';
                                                    body+='<reg:JB_PASSPORT_ISSUE_DATE_AR>'+jb.Account__r.Passport_Issue_Date_Arabic__pc+'</reg:JB_PASSPORT_ISSUE_DATE_AR>';
                                                    body+='<reg:JB_PASSPORT_ISSUE_PLACE_AR>'+jb.Account__r.Passport_Issue_Place_Arabic__pc+'</reg:JB_PASSPORT_ISSUE_PLACE_AR>';
                                                    body+='<reg:JB_ADDRESS1_AR>'+jb.Account__r.Address1_Arabic__pc+'</reg:JB_ADDRESS1_AR>';
                                                    body+='<reg:JB_ADDRESS2_AR>'+jb.Account__r.Address2_Arabic__pc+'</reg:JB_ADDRESS2_AR>';
                                                    body+='<reg:JB_ADDRESS3_AR>'+jb.Account__r.Address3_Arabic__pc+'</reg:JB_ADDRESS3_AR>';
                                                    body+='<reg:JB_ADDRESS4_AR>'+jb.Account__r.Address4_Arabic__pc+'</reg:JB_ADDRESS4_AR>';
                                                    body+='<reg:JB_CITY_AR>'+jb.Account__r.City_Arabic__pc+'</reg:JB_CITY_AR>';
                                                    body+='<reg:JB_ZIP_AR>'+jb.Account__r.Postal_Code_Arabic__pc+'</reg:JB_ZIP_AR>';
                                                    body+='<reg:JB_COUNTRY_AR>'+jb.Account__r.Country_Arabic__pc+'</reg:JB_COUNTRY_AR>';
                                                    body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                                                    body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                                                    body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                                                    body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                                                body+='</reg:JB_TABLE_REC_ITEM>';
                                            }
                                        }
                                    body+='</reg:JB_TABLE_REC>';
                                    body+='<reg:UNIT_SBL_ID></reg:UNIT_SBL_ID>';
                                    body+='<reg:BOOKING_CHANNEL>'+bookingChannel+'</reg:BOOKING_CHANNEL>';
                                    body+='<reg:BOOKING_REFERENCE>'+booking.Id+'</reg:BOOKING_REFERENCE>';
                                    body+='<reg:DELIVERY_MODE>'+deliveryMode+'</reg:DELIVERY_MODE>';
                                    body+='<reg:ATTRIBUTE1></reg:ATTRIBUTE1>';
                                    body+='<reg:ATTRIBUTE2></reg:ATTRIBUTE2>';
                                    body+='<reg:ATTRIBUTE3></reg:ATTRIBUTE3>';
                                    body+='<reg:ATTRIBUTE4></reg:ATTRIBUTE4>';
                                    body+='<reg:DEAL_ID></reg:DEAL_ID>';
                                    body+='<reg:R_B_FLAG></reg:R_B_FLAG>';
                                body+='</reg:P_REGISTRATION_RECORDS_ITEM>';
                            }
                        body+='</reg:P_REGISTRATION_RECORDS>';
                    body+='</reg:InputParameters>';
                body+='</soapenv:Body>';
            body+='</soapenv:Envelope>';
            System.debug('Reg bodybodybody --- '+body);
            return body;
        }
        
        return null;
        
    }
    
    webservice static void sendRegistrationRequest(Booking__c booking, List<Booking_unit__c> units){
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        //String reqXML = DAMACWebServiceUtils.prepareRequest(acc, booking, units, partyId);
        String reqXML = DAMACWebServiceUtils.prepareRegistrationRequest(booking, units);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint('http://83.111.194.181:8045/webservices/SOAProvider/plsql/xxdc_registration_process_ws/');
        req.setHeader('Content-Type','text/xml');
        HTTP http = new HTTP();
        HTTPResponse res = http.send(req);
        
        System.debug('>>>>>Response>>>>>>'+res.getbody());
        
        parseResponse(res.getBody());
    }
    
    
    public static void parseResponse(string body){
        
        string regId,partyId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        Map<string,Account> mpAcc = new Map<string,Account>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            if(child5.getName()=='PARTY_ID'){
                                partyId = child5.getText();
                            }
                            if(child5.getName()=='REGISTRATION_ID'){
                                regId = child5.getText();
                            }
                        }
                    }
                }
            }
        }
        
        //NSIBPM__Service_Request__c req = new NSIBPM__Service_Request__c(Id = 'a0W9E0000004rrw', REGISTRATION_ID__c = regId);
        //update req;
        
        //Account acc = new Account(Id = '0019E000002q5AI',PARTY_ID__c=partyId);
        //update acc;
        
    }
    
    
    /*************************************************************************************************************************/
    /****************************************Receipt Generation Start*********************************************************/
    /*************************************************************************************************************************/
   
    
    webservice static void sendReceipts(Receipt__c rec){
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        //String reqXML = DAMACWebServiceUtils.prepareRequest(acc, booking, units, partyId);
        String reqXML = DAMACWebServiceUtils.prepareReceipt(rec);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint('http://83.111.194.181:8045/webservices/SOAProvider/plsql/xxdc_process_service_ws/');
        req.setHeader('Content-Type','text/xml');
        HTTP http = new HTTP();
        HTTPResponse res = http.send(req);
        
        System.debug('>>>>>Response>>>>>>'+res.getbody());
        
        parseReceiptResponse(res.getBody());
    }
    
    public static void parseReceiptResponse(string body){
        
        string regId,status,recId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<string,Account> mpAcc = new Map<string,Account>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        status = child4.getChildElement('PROC_STATUS',null).getText();
                        recId = child4.getChildElement('PARAM_ID',null).getText();
                        regId = child4.getChildElement('ATTRIBUTE1',null).getText();
                    }
                }
            }
        }
        
    }
    
    public static string prepareReceipt(Receipt__c rec){
        string body = '';
        body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"  xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
            body+='<soapenv:Header>';
                body+='<xxdc:SOAHeader>';
                    body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
                    body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
                    body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
                    body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
                    body+='<xxdc:Org_Id/>';
                body+='</xxdc:SOAHeader>';
                body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                    body+='<wsse:UsernameToken>';
                        body+='<wsse:Username>oracle_user</wsse:Username>';
                        body+='<wsse:Password>crp1user</wsse:Password>';
                    body+='</wsse:UsernameToken>';
                body+='</wsse:Security>';
            body+='</soapenv:Header>';
            body+='<soapenv:Body>';
                body+='<proc:InputParameters>';
                    body+='<!--Optional:-->';
                    body+='<proc:P_REQUEST_NUMBER>'+rec.Request_Number__c+'</proc:P_REQUEST_NUMBER>';
                    body+='<!--Optional:-->';
                    body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
                    body+='<!--Optional:-->';
                    body+='<proc:P_REQUEST_NAME>CREATE RECEIPT</proc:P_REQUEST_NAME>';
                    body+='<!--Optional:-->';
                    body+='<proc:P_REQUEST_MESSAGE>';
                    body+='<!--Zero or more repetitions:-->';
                        body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                            body+='<!--Optional:SFDC ID-->';
                            body+='<proc:PARAM_ID>'+rec.Id+'</proc:PARAM_ID>';
                            body+='<!--Optional:RECEIPT_NUMBER-->';
                            body+='<proc:ATTRIBUTE1>'+rec.Name+'</proc:ATTRIBUTE1>';
                            body+='<!--Optional:REG_ID-->';
                            body+='<proc:ATTRIBUTE2>'+rec.Registration_Number__c+'</proc:ATTRIBUTE2>';
                            body+='<!--Optional:CURRENCY_CODE-->';
                            body+='<proc:ATTRIBUTE3>AED</proc:ATTRIBUTE3>';
                            body+='<!--Optional:AMOUNT-->';
                            body+='<proc:ATTRIBUTE4>'+rec.Card_Amount__c+'</proc:ATTRIBUTE4>';
                            body+='<!--Optional:RECEIPT_METHOD-->';
                            body+='<proc:ATTRIBUTE5>'+rec.Receipt_Method__r.Receipt_method_name__c+'</proc:ATTRIBUTE5>';
                            body+='<!--Optional:BANK_ACCOUNT_NUM-->';
                            body+='<proc:ATTRIBUTE6>'+rec.Bank_Account_Number__c+'</proc:ATTRIBUTE6>';
                        body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                    body+='</proc:P_REQUEST_MESSAGE>';
                body+='</proc:InputParameters>';
            body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';


        return body.trim();
    }
    
    /*************************************************************************************************************************/
    /****************************************SPA Creation Start*********************************************************/
    /*************************************************************************************************************************/
     webservice static void invokeSPAGeneration(){
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        //String reqXML = DAMACWebServiceUtils.prepareRequest(acc, booking, units, partyId);
        String reqXML = DAMACWebServiceUtils.invokeSPA();
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint('http://83.111.194.181:8045/webservices/SOAProvider/plsql/xxdc_process_service_ws/');
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(80000);
        HTTP http = new HTTP();
        HTTPResponse res = http.send(req);
        
        System.debug('>>>>>Response>>>>>>'+res.getbody());
        
        parseSPAResponse(res.getBody());
    }
    
    public static string invokeSPA(){
        
        string body = '';
        body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
            body+='<soapenv:Header>';
                body+='<xxdc:SOAHeader>';
                    body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
                    body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
                    body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
                    body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
                    body+='<xxdc:Org_Id/>';
                body+='</xxdc:SOAHeader>';
                body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                    body+='<wsse:UsernameToken>';
                        body+='<wsse:Username>oracle_user</wsse:Username>';
                        body+='<wsse:Password>crp1user</wsse:Password>';
                    body+='</wsse:UsernameToken>';
                body+='</wsse:Security>';
            body+='</soapenv:Header>';
            body+='<soapenv:Body>';
                body+='<proc:InputParameters>';
                    body+='<proc:P_REQUEST_NUMBER>54321</proc:P_REQUEST_NUMBER>';
                    body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
                    body+='<proc:P_REQUEST_NAME>SPA</proc:P_REQUEST_NAME>';
                    body+='<proc:P_REQUEST_MESSAGE>';
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                    body+='<proc:PARAM_ID>81942</proc:PARAM_ID>';
                    body+='<proc:ATTRIBUTE1></proc:ATTRIBUTE1>';
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                    body+='</proc:P_REQUEST_MESSAGE>';
                body+='</proc:InputParameters>';
            body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    

    public static void parseSPAResponse(string body){
        
        string regId,status,recId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<string,Account> mpAcc = new Map<string,Account>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                       for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            
                       }    
                    }
                }
            }
        }
        
    }
    
     public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
               // if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
              //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }
}