/* 
*  Apex controller for Dynamic FundingApplication Page using Field sets.
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0               Ripal Patel            7-July 2015           Initial Draft 
*  Version           Author                 Date                 Description 
*  2.0               Yogesh Mahajan        8-Dec 2015           Remove combination key logic and picklist 
                                                                    to select the contact
*  2.1               Yogesh Mahajan        10-Dec 2015           
*  2.2               Yogesh Mahajan        11-Dec 2015
*/
public with sharing class DemoFundingApplicationController{ 
    public static final String FAX_ERROR = 'Fax Number Should Not be Greater Than 10 Digit';
    public static final String Error_FOR_NUMBER = ' Should Not be Greater Than 10 Digit';
    public static final String Date_ERROR = ' Is Invalid. Future Dates Are not Accepted';
    public static final String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
    public static final String SPECIAL_CHAR_ERROR = 'Special Characters Not Allowed In ';
    public static final String DATE_OF_BUSINESS = 'Date of Business ';
    public static final String OWNER1_BIRTHDATE = 'Owner 1 Birthdate ';
    public static final String OWNER2_BIRTHDATE = 'Owner 2 Birthdate ';
    public static final String POST_CODE_ERROR = 'Should Not be 20 Digit';
    public static final String BILLING_POSTCODE = 'Billing Zip/Postal Code ';
    public static final String SHIPPING_POSTCODE = 'Shipping Zip/Postal Code ';
    public static final String OWNER1_POSTCODE = 'Owner 1 Mailing Zip/Postal Code ';
    public static final String OWNER2_POSTCODE = 'Owner 2 Mailing Zip/Postal Code ';
    public static final String ACCOUNT_FAX = 'Fax Field';
    public static final String SHIPPINGPOSTALCODE = 'Account Shipping Postal Code ';
    public static final String BILLINGPOSTALCODE = 'Account Billing Postal Code ';
    public static final String ACCOUNT_PHONE = 'Account Phone ';
    public static final String Account_MOBILE_PHONE = 'Account Phone';
    public static final String OWNER1_ZIP_CODE = 'Owner 1 Zip Code ';
    public static final String OWNER2_ZIP_CODE = 'Owner 1 Zip Code ';
    public static final String OWNER1_DRIVERS_LICENSE = 'Owner 1 Driver License ';
    public static final String OWNER2_DRIVERS_LICENSE = 'Owner 2 Driver License ';
    public static final String OWNER1_HOME_PHONE = 'Owner 1 Home Phone';
    public static final String OWNER1_Mobile_PHONE = 'Owner 1 Mobile Phone';
    public static final String OWNER2_HOME_PHONE = 'Owner 2 Home Phone';
    public static final String OWNER2_Mobile_PHONE = 'Owner 2 Mobile Phone';
    public static final String OWNER1_MOBILEPHONE = 'Owner 1 MobilePhone ';
    public static final String OWNER2_MOBILEPHONE = 'Owner 2 MobilePhone ';
    public static final String OWNER1_CELLULAR = 'Owner 1 Cellular ';
    public static final String OWNER2_CELLULAR = 'Owner 2 Cellular ';
    public static final String OWNER1_SOCIAL_SECURITY_NUMBER = 'Owner 1 Social Security Number ';
    public static final String OWNER2_SOCIAL_SECURITY_NUMBER = 'Owner 2 Social Security Number ';
    public static final String WEBSITE_CHAR_PATTERN = '((http://|https://)|((w){3})(.))[a-zA-Z0-9]+(.)[a-z]+'; 
    public static final String WEBSITE_CHAR_ERROR = 'Website Name is not in an Appropriate Format.';
    //public static final String POST_CODE_ERROR = 'Should Not be 20 Digit';
    public static final String Social_Security_Number_Error_Message_Owner1 = 'Please enter the Social Security Number in the format of XXX-XX-XXXX for Owner 1';
    public static final String Social_Security_Number_Error_Message_Owner2 = 'Please enter the Social Security Number in the format of XXX-XX-XXXX for Owner 2'; 
    
    private String AccId;
    private String OppId;
    public Boolean isError;
    public String Owner1LastName                {get;set;}
    public String Owner2LastName                {get;set;}
    public String Owner1FirstName               {get;set;}
    public String Owner2FirstName               {get;set;}
    public Account objAccount                   {get;set;}
    public Opportunity opportunity              {get;set;}
    public list <Contact> contactForMappingLst  {get;set;}
    public list <Contact> contactForMappingtoUpdateLst;
    public list <Opportunity> opportunitytoUpdateLst;
    public CongaButtonUrl__c createPDF          {get;set;}
    public CongaButtonUrl__c emailPDF           {get;set;}
    public CongaButtonUrl__c faxPDF             {get;set;}
    public CongaButtonUrl__c docusign           {get;set;}
    public String selectedContactOwner1         {get;set;}
    public String selectedContactOwner2         {get;set;}
    public Contact conForOwner1{get;set;}
    public Contact conForOwner2{get;set;}
    public String isConsole{get;set;}
    public list<Contact> oldContactOwner1;
    public list<Contact> oldContactOwner2;
    private ApexPages.StandardController stdController; 
    private final String selectAccountError = 'Please select Account on opportunity';
    private String CheckWhereCondition;
    public string FedralTaxId { get; set; }      
    public Opportunity oppListToUpdateBusiInfo { get; set; }  //list holds fields for BUSINESS INFORMATION section
    public Opportunity oppListToUpdateOwnerOfficerInfo    { get; set; }  //list holds fields for OWNER/OFFICER INFORMATION section
    public Opportunity oppListToUpdate2ndOwnerOfficerInfo { get; set; }  //list holds fields for 2nd OWNER/OFFICER INFORMATION (if applicable) section
    public Opportunity oppListToUpdateBankTradeInfo       { get; set; }  //list holds fields for BANK/TRADE INFORMATION section
    public Opportunity oppListToUpdatePropertyInfo        { get; set; }  //list holds fields for PROPERTY INFORMATION section
    public Opportunity oppListToUpdateOtherInfo           { get; set; }  //list holds fields for OTHER INFORMATION section
    public Contact Contacta { get; set; } 
    public FundingApplicationUtility objUtility;
    public String query1;
    public Boolean flag; 
    public String errorMessage {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapBusiInfoRowIndex {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapOwner1RowIndex   {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapOwner2RowIndex   {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapBankTradeRowIndex   {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapProInfoRowIndex   {get;set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapOtherInfoRowIndex   {get;set;}
    
    public DemoFundingApplicationController(ApexPages.StandardController stdController){
        isConsole = ApexPages.currentPage().getParameters().get('console');
        contactForMappingtoUpdateLst = new List<Contact>();
        opportunitytoUpdateLst = new List<Opportunity>();
        this.stdController = stdController;
        objAccount = new Account();
        opportunity = new Opportunity();
        conForOwner1 = new Contact();
        conForOwner2 = new Contact();
        oldContactOwner1 = new list<Contact>();
        oldContactOwner2 = new list<Contact>();
        oppListToUpdateBusiInfo = new Opportunity();
        Owner1LastName = ''; 
        Owner2LastName = '';
        FedralTaxId = null;
        emailPDF = CongaButtonUrl__c.getInstance('Email PDF');
        createPDF = CongaButtonUrl__c.getInstance('Create PDF');
        faxPDF = CongaButtonUrl__c.getInstance('Fax PDF');
        docusign = CongaButtonUrl__c.getInstance('Docusign');                
        contactForMappingLst = new list<Contact>();
        flag = true;
        isError = false;
        objUtility = new FundingApplicationUtility();
        
        createSectionMaps();
    }

    public void init(){
               
        try{
            AccId = ApexPages.currentPage().getParameters().get('id');
            OppId = ApexPages.currentPage().getParameters().get('oppId');
            FundingApplicationUtility objUtility = new FundingApplicationUtility();
            this.oppListToUpdateBusiInfo= objUtility.getOpportunityListBusiInfo(OppId);
            this.oppListToUpdateOwnerOfficerInfo= objUtility.getOpportunityListOwnerOfficerInfo(OppId);
            
            this.oppListToUpdate2ndOwnerOfficerInfo= objUtility.getOpportunityList2ndOwnerOfficerInfo(OppId);
            this.oppListToUpdateBankTradeInfo= objUtility.getOpportunityListBankTradeInfo(OppId);
            this.oppListToUpdatePropertyInfo= objUtility.getOpportunityPropertyInfo(OppId);
            this.oppListToUpdateOtherInfo= objUtility.getOpportunityOtherInfo(OppId); 
            system.debug('oppListToUpdateBusiInfo---->'+oppListToUpdateBusiInfo.amount);
            list<Account> listAccount = new list<Account>();
            listAccount = [SELECT Id, Name, McaApp__Legal_Name__c, McaApp__Type_of_Entity__c, McaApp__Federal_Tax_ID_No__c, BillingStreet, BillingCity, BillingState,billingcountry,
                                    BillingPostalCode, ShippingStreet, ShippingCity, ShippingState,shippingCountry, ShippingPostalCode, Phone, McaApp__Cellular_No__c,
                                    Fax, McaApp__Date_Business_Established__c, McaApp__Years_in_Business__c, Industry, Website, McaApp__Email__c, McaApp__Bank_Name__c, McaApp__Bank_Contact__c,
                                    McaApp__Bank_Phone__c, McaApp__Business_Name__c, McaApp__Business_Contact_Account__c, McaApp__Business_Phone__c, McaApp__Landlord_Mortgagee__c,
                                    McaApp__Landlord_Contact_Name__c, McaApp__Landlord_Phone__c, McaApp__Lease_start_date__c, McaApp__Time_Left_On_Lease__c, McaApp__Monthly_Payment__c,
                                    McaApp__Square_Footage__c, McaApp__Gross_monthly_Sales__c, McaApp__Monthly_CC_Avg_All__c, 
                                    AccountNumber 
                            FROM Account 
                            WHERE Id =: AccId limit 1];
            if(!listAccount.isEmpty())
                objAccount = listAccount[0];


            opportunity = [SELECT McaApp__Balance__c ,McaApp__Cash_Advance_Company__c,AccountId,McaApp__Use_of_Proceeds__c,McaApp__Gross_monthly_Sales__c,McaApp__Credit_Card_Sales__c,
                                    McaApp__Ever_used_a_Business_Cash_Advance__c,McaApp__Owner_1_Ownership__c,McaApp__Owner_2_Ownership__c,
                                    McaApp__Amount_Requested__c,McaApp__Owner_1__c,McaApp__Owner_2__c,McaApp__Application__c,
                                    McaApp__Credit_Card_Statements__c,McaApp__Bank_Statements__c,StageName
                            FROM Opportunity 
                            WHERE Id =: OppId ];

            if(opportunity.McaApp__Owner_1__c <> null) {
                conForOwner1 = oppContact(' WHERE Id =\'' + opportunity.McaApp__Owner_1__c + '\' ');
                selectedContactOwner1 = opportunity.McaApp__Owner_1__c;
             }//End If
             
             if(opportunity.McaApp__Owner_2__c <> null) {
                conForOwner2 = oppContact(' WHERE Id =\'' + opportunity.McaApp__Owner_2__c + '\' ');
                selectedContactOwner2 = opportunity.McaApp__Owner_2__c;
             }//End If

            for(Account acc : listAccount){
                FedralTaxId = acc.McaApp__Federal_Tax_ID_No__c;
            }
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage())); 
        }
    }
    
    public void createSectionMaps() {
        // create map structure for business information section
        mapBusiInfoRowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFieldsBusiInfo();
        
        // create map structure for owner 1 section
        mapOwner1RowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFieldsOwnerOfficerInfo();
        
        // create map structure for owner 2 section
        mapOwner2RowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFields2ndOwnerOfficerInfo();
        
        // create map structure for Bank Trad information section
        mapBankTradeRowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFieldsBankTradeInfo();
        
        // create map structure for property information section
        mapProInfoRowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFieldsPropertyInfo();
        
        // create map structure for other information section
        mapOtherInfoRowIndex = new Map<Integer, List<Schema.FieldSetMember>>();
        getFieldsOtherInfo();
        
    }
    
    // create business inforamtion section map
    public void getFieldsBusiInfo() {
       
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_BUSINESS_INFORMATION.getFields()) {
            if(count < 5 && mapBusiInfoRowIndex.get(mapKey) == null) {
                mapBusiInfoRowIndex.put(mapKey , new List<Schema.FieldSetMember>{businessField});
            } else if(count < 5) {
                mapBusiInfoRowIndex.get(mapKey).add(businessField); 
                if(count == 4) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For    
    }// End getFieldsBusiInfo()
    
    // create owner 1 section map
    public void getFieldsOwnerOfficerInfo() {
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_OWNER_OFFICER_INFORMATION.getFields()) {
            if(count < 5 && mapOwner1RowIndex.get(mapKey) == null) {
                mapOwner1RowIndex.put(mapKey , new List<Schema.FieldSetMember>{businessField});
            } else if(count < 5) {
                mapOwner1RowIndex.get(mapKey).add(businessField); 
                if(count == 4) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For    
    }// end getFieldsOwnerOfficerInfo()
    
    // create owner 2 section map
    public void getFields2ndOwnerOfficerInfo() {
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_2nd_OWNER_OFFICER_INFORMATION.getFields()) {
            if(count < 5 && mapOwner2RowIndex.get(mapKey) == null) {
                mapOwner2RowIndex.put(mapKey, new List<Schema.FieldSetMember>{businessField});
            } else if(count < 5) {
                mapOwner2RowIndex.get(mapKey).add(businessField); 
                if(count == 4) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For
        
        system.debug('----->'+mapOwner2RowIndex);
    }// End getFields2ndOwnerOfficerInfo()
    
    public void getFieldsBankTradeInfo() {
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_BANK_TRADE_INFORMATION.getFields()) {
            if(count < 4 && mapBankTradeRowIndex.get(mapKey) == null) {
                mapBankTradeRowIndex.put(mapKey, new List<Schema.FieldSetMember>{businessField});
            } else if(count < 4) {
                mapBankTradeRowIndex.get(mapKey).add(businessField); 
                if(count == 3) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For
    }// End getFieldsBankTradeInfo()
    
    public void getFieldsPropertyInfo() {
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_PROPERTY_INFORMATION.getFields()) {
            if(count < 4 && mapProInfoRowIndex.get(mapKey) == null) {
                mapProInfoRowIndex.put(mapKey, new List<Schema.FieldSetMember>{businessField});
            } else if(count < 4) {
                mapProInfoRowIndex.get(mapKey).add(businessField); 
                if(count == 3) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For
    }//End getFieldsPropertyInfo()
    
    public void getFieldsOtherInfo() {
        Integer mapKey = 1, mapValue = 1, count = 1;
        for(Schema.FieldSetMember businessField :SObjectType.Opportunity.FieldSets.ADDITIONAL_OTHER_INFORMATION.getFields()) {
            if(count < 4 && mapOtherInfoRowIndex.get(mapKey) == null) {
                mapOtherInfoRowIndex.put(mapKey, new List<Schema.FieldSetMember>{businessField});
            } else if(count < 4) {
                mapOtherInfoRowIndex.get(mapKey).add(businessField); 
                if(count == 3) {
                    count = 0;
                    mapKey++;
                }
            }//End else - if
            
            count++;
            mapValue++;
        }// End For
    }// End getFieldsOtherInfo()


    public PageReference Save(){
        try{
        
                this.QuickSave1();
                PageReference pageRef = new PageReference('/'+OppId);
                pageRef.setRedirect(true);
                if(flag == true && !isError)
                    return pageRef;
                else
                    return null;
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Got An Error'+e.getMessage()));
            return null;    
        }
    }
    
    public PageReference QuickSave1(){
        system.debug('oppListToUpdateBusiInfo---->'+oppListToUpdateBusiInfo.amount);
        system.debug('oppListToUpdateBusiInfo---->'+oppListToUpdateBusiInfo);
        List<Account> accountInstance = new List<Account>();
        flag = true;
        isError = false;
        
        contactForMappingtoUpdateLst.clear();
        
        // Check website Validation
        websiteCheck(objAccount.Website);
        
        // Check postcode Validation
        postCodeFieldValidation(objAccount.BillingPostalCode, BILLING_POSTCODE);
        postCodeFieldValidation(objAccount.ShippingPostalCode, SHIPPING_POSTCODE);
        postCodeFieldValidation(conForOwner1.MailingPostalCode, OWNER1_POSTCODE);
        postCodeFieldValidation(conForOwner2.MailingPostalCode, OWNER2_POSTCODE);
        
        // Check phone and mobile validation(10 digit)
        numberFieldValidation(removeExtraChara(objAccount.Phone), Account_MOBILE_PHONE);
        numberFieldValidation(removeExtraChara(conForOwner1.HomePhone), OWNER1_HOME_PHONE);
        numberFieldValidation(removeExtraChara(conForOwner2.HomePhone), OWNER2_HOME_PHONE);
        numberFieldValidation(removeExtraChara(conForOwner1.MobilePhone), OWNER1_Mobile_PHONE);
        numberFieldValidation(removeExtraChara(conForOwner2.MobilePhone), OWNER2_Mobile_PHONE);
        numberFieldValidation(removeExtraChara(objAccount.Fax), ACCOUNT_FAX);
        
        //check date field validations
        dateFieldValidation(objAccount.McaApp__Date_Business_Established__c, DATE_OF_BUSINESS);
        dateFieldValidation(conForOwner1.Birthdate, OWNER1_BIRTHDATE);
        dateFieldValidation(conForOwner2.Birthdate, OWNER2_BIRTHDATE);
        
        // Check Validation
        System.debug('>>>check validations'+objAccount.Fax);
        faxFieldValidation(removeExtraChara(objAccount.Fax));
        specialCharaterCheck(removeExtraChara(objAccount.Fax), 'Account Fax ');
        checkNumericValue(removeExtraChara(objAccount.Fax), 'Account Fax ');
        specialCharaterCheck(objAccount.ShippingPostalCode, SHIPPINGPOSTALCODE);
        specialCharaterCheck(objAccount.BillingPostalCode, BILLINGPOSTALCODE);
        specialCharaterCheck(removeExtraChara(objAccount.Phone), ACCOUNT_PHONE);
        checkNumericValue(removeExtraChara(objAccount.Phone), ACCOUNT_PHONE);
        specialCharaterCheck(string.ValueOf(conForOwner1.McaApp__Drivers_License__c), OWNER1_DRIVERS_LICENSE);
        specialCharaterCheck(string.ValueOf(conForOwner2.McaApp__Drivers_License__c), OWNER2_DRIVERS_LICENSE);
        specialCharaterCheck(conForOwner1.MailingPostalCode, OWNER1_ZIP_CODE);
        specialCharaterCheck(conForOwner2.MailingPostalCode, OWNER2_ZIP_CODE);
        specialCharaterCheck(removeExtraChara(conForOwner1.HomePhone), OWNER1_MOBILEPHONE);
        checkNumericValue(removeExtraChara(conForOwner1.HomePhone), OWNER1_MOBILEPHONE);
        specialCharaterCheck(removeExtraChara(conForOwner2.HomePhone), OWNER2_MOBILEPHONE);
        checkNumericValue(removeExtraChara(conForOwner2.HomePhone), OWNER1_MOBILEPHONE);
        specialCharaterCheck(removeExtraChara(conForOwner1.MobilePhone), OWNER1_CELLULAR );
        checkNumericValue(removeExtraChara(conForOwner1.MobilePhone), OWNER1_CELLULAR);
        specialCharaterCheck(removeExtraChara(conForOwner2.MobilePhone), OWNER2_CELLULAR );
        checkNumericValue(removeExtraChara(conForOwner2.MobilePhone), OWNER2_CELLULAR);
        specialCharaterCheck(removeExtraChara(conForOwner1.McaApp__Social_Security_Number1__c), OWNER1_SOCIAL_SECURITY_NUMBER);
        specialCharaterCheck(removeExtraChara(conForOwner2.McaApp__Social_Security_Number1__c), OWNER2_SOCIAL_SECURITY_NUMBER);
        errorMessage ='';
         
            
        if((conForOwner1.McaApp__Social_Security_Number1__c <> null) && (!Pattern.matches('[0-9]{3}-[0-9]{2}-[0-9]{4}', conForOwner1.McaApp__Social_Security_Number1__c) && (conForOwner1.McaApp__Social_Security_Number1__c.length() > 0))) {
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Social_Security_Number_Error_Message_Owner1));
        }
        
        if((conForOwner2.McaApp__Social_Security_Number1__c <> null) && (!Pattern.matches('[0-9]{3}-[0-9]{2}-[0-9]{4}', conForOwner2.McaApp__Social_Security_Number1__c) && (conForOwner2.McaApp__Social_Security_Number1__c.length() > 0))) {
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Social_Security_Number_Error_Message_Owner2));
        }
        
        if((FedralTaxId <> null) && (!Pattern.matches('[0-9]{2}-[0-9]{7}', FedralTaxId) &&(FedralTaxId.length() > 0) ) ){
             //errorMessage = 'Please enter the Federal Tax ID in the format of XX-XXXXXXX'; 
             isError = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The required format for Federal tax ID is  XX-XXXXXXX'));

            return null;
        }
        if(!isError){
            
            // It is used to upsert the contact
            List<Contact> listContact = new List<Contact>();
            if( (conForOwner1 <> null && conForOwner1 != (new Contact()) && selectedContactOwner1 != '-None-'))
                listContact.add(conForOwner1);
                
            if(conForOwner2 <> null && conForOwner2 != (new Contact()) && selectedContactOwner2 != '-None-')
                listContact.add(conForOwner2);
            
            try {
                if(listContact.size() > 0)
                    upsert listContact;
            }catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }// End Catch
            system.debug('oppListToUpdateBusiInfo---->'+oppListToUpdateBusiInfo.amount);
            // Update BUSINESS INFORMATION
            if(oppListToUpdateBusiInfo != null){
                try {
                    update oppListToUpdateBusiInfo;  //DML Statement
                    Database.update(oppListToUpdateBusiInfo.Account);  //DML database method
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If 
            
                       
            // Update BANK/TRADE INFORMATION
            if(oppListToUpdateBankTradeInfo != null){
                try {
                    update oppListToUpdateBankTradeInfo;
                    Database.update(oppListToUpdateBankTradeInfo.Account);
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If
            
            // Update PROPERTY INFORMATION
            if(oppListToUpdatePropertyInfo != null){
                try {
                    update oppListToUpdatePropertyInfo;
                    Database.update(oppListToUpdatePropertyInfo.Account);
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If
            // Update OTHER INFORMATION
            if(oppListToUpdateOtherInfo != null){
                try {
                    update oppListToUpdateOtherInfo;
                    Database.update(oppListToUpdateOtherInfo.Account);
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If
            
            //update opportunity
            if(conForOwner1 <> null && conForOwner1 != (new Contact()) 
                && listContact.size() != 0 && selectedContactOwner1 != '-None-') {
                if(oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r <> null){
                    oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r.id = listContact[0].Id;
                    try {
                        update oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r;
                    }catch (Exception ex) {
                        isError = true;
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                        //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                    }// End Catch
                }//End IF
                opportunity.McaApp__Owner_1__c = listContact[0].Id;
                opportunity.McaApp__Owner_1_Ownership__c = listContact[0].McaApp__Of_Ownership__c;
            } else if ( conForOwner2 <> null 
            && conForOwner2 != (new Contact()) && selectedContactOwner2 != '-None-'){
                opportunity.McaApp__Owner_1__c = null;
                if(oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r <> null) {
                    oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r.id = listContact[0].Id;
                    try {
                        update oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r;
                    }catch (Exception ex) {
                        isError = true;
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                        //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                    }// End Catch
                }// End If
                opportunity.McaApp__Owner_2__c = listContact[0].Id;
                opportunity.McaApp__Owner_2_Ownership__c = listContact[0].McaApp__Of_Ownership__c;
            }//End else -If
            if(selectedContactOwner1 == '-None-') {
                opportunity.McaApp__Owner_1__c = null;
                opportunity.McaApp__Owner_1_Ownership__c  = null;
            }//End If
            
            if(conForOwner2 <> null && conForOwner2 != (new Contact()) 
                && listContact.size() != 1 && selectedContactOwner2 != '-None-') {
                if(oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r <> null){
                    oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r.id = conForOwner1 == null  ? 
                                    listContact[0].Id : listContact[1].Id;
                    try {
                        update oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r;
                    }catch (Exception ex) {
                        isError = true;
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                        //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                    }// End Catch
                }
                opportunity.McaApp__Owner_2__c = conForOwner1 == null  ? 
                                listContact[0].Id : listContact[1].Id;
                opportunity.McaApp__Owner_2_Ownership__c = conForOwner1 == null  ? 
                                listContact[0].McaApp__Of_Ownership__c : listContact[1].McaApp__Of_Ownership__c; 
            }//End If
            
            // Update OWNER/OFFICER INFORMATION
            if(oppListToUpdateOwnerOfficerInfo != null){
                try {
                    if(selectedContactOwner1 == '-None-') {
                        oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r = null;
                    }
                    update oppListToUpdateOwnerOfficerInfo;
                    if(oppListToUpdateOwnerOfficerInfo.Account <> null)
                        Database.update(oppListToUpdateOwnerOfficerInfo.Account);
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If
                        
            // Update 2nd OWNER/OFFICER INFORMATION
            if(oppListToUpdate2ndOwnerOfficerInfo != null){
                try {
                    if(selectedContactOwner2 == '-None-') {
                        oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r = null;
                    }
                    update oppListToUpdate2ndOwnerOfficerInfo;
                    if(oppListToUpdate2ndOwnerOfficerInfo.Account <> null)
                        Database.update(oppListToUpdate2ndOwnerOfficerInfo.Account);
                }catch (Exception ex) {
                    isError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
                }// End Catch
            }// End If
            
            if(selectedContactOwner2 == '-None-') {
                opportunity.McaApp__Owner_2__c = null;
                opportunity.McaApp__Owner_2_Ownership__c = null;
            }//End If

            try{
                update opportunity;
            }catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//End try -catch
            // Account Update 
            objAccount.McaApp__Gross_monthly_Sales__c = opportunity.McaApp__Gross_monthly_Sales__c;
            objAccount.McaApp__Federal_Tax_ID_No__c = FedralTaxId;
            try{
                update objAccount;
            } catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
                flag = false;
            }// End Catch         
        }
       return null; 
    }//End QuickSave1()
    
    // Picklist to show all contact reltaed to opportunity account.
    public List<SelectOption> getConatactOptions() {
        List<SelectOption> contactOptions = new List<SelectOption>();
        contactOptions.add(new SelectOption('-None-','-None-'));
        contactOptions.add(new SelectOption('New','-New-'));
        for(Contact objContact: relatedContact()) {
            contactOptions.add(new SelectOption(objContact.id, objContact.name));
        }
        return contactOptions;
    }// getCountriesOptions()
    
    //get list of contact related to account
    public List<Contact> relatedContact() {
        return ([SELECT id,
                        Name
                FROM Contact
                WHERE AccountId =: AccId]);
    }//End relatedContact()
    
    public PageReference cancel(){
        return new PageReference('/'+OppId);
    }

    public PageReference cancel1(){
        return new PageReference('/'+OppId);
    }


    public PageReference docuSign(){
        return new PageReference('/'+OppId);
    }

    public void docuSign1(){
    }

    public PageReference SendCongaPDF1(){
        try{
            this.QuickSave1();
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        return new PageReference('/'+OppId);
    }

    public PageReference submissionWizard1(){
        try{
            this.QuickSave1();
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        return new PageReference('/'+OppId);
    }

    public PageReference openConga1(){
        try{
            this.QuickSave1();
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        return new PageReference('/'+OppId);
    }

    public PageReference editPage(){
        PageReference pageRef = new PageReference(Page.FundingApplication.getUrl()+'?id='+AccId+'&oppId='+OppId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    // Check special charater into string 
    public void specialCharaterCheck(String strValue, String fieldName) {
        if(strValue <> null) {
            Pattern patternVal = Pattern.compile(SPECIAL_CHAR_PATTERN);
            Matcher patternMatcher = patternVal.matcher(strValue);
            if(patternMatcher.find()){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, SPECIAL_CHAR_ERROR + fieldName));
                isError = true;
            }//End IF
        }// End If
    }//End specialCharaterCheck()    
    
    //Check fax field length not more then 10 digit
    public void numberFieldValidation(String faxValue, String fieldName) {
        if(faxValue <> null) {
            if(faxValue.length() > 10){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + Error_FOR_NUMBER));
                isError = true;
            }//End If
        }//End If
    }//End numberFieldValidation()
    
    // Check special charater into string 
    public void websiteCheck(String strValue) {
        if(strValue <> null) {
            Pattern patternVal = Pattern.compile(WEBSITE_CHAR_PATTERN);
            Matcher patternMatcher = patternVal.matcher(strValue);
            if(!patternMatcher.find()){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, WEBSITE_CHAR_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End websiteCheck()
    
    //Check zip/ posta;l code validations
    public void postCodeFieldValidation(String postCodeValue, String fieldName) {
        if(postCodeValue <> null) {
            if(postCodeValue.length() > 19){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + POST_CODE_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End postCodeFieldValidation()
    
    
    //Check date is not future
    public void dateFieldValidation(Date dateVal, String fieldName) {
        if(dateVal<> null) {
            if(dateVal > date.today()){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + Date_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End dateFieldValidation()
    
    public String removeExtraChara(String strValue) {
        if(strValue <> null) {
            strValue= strValue.replace('(','');
            strValue= strValue.replace(')','');
            strValue= strValue.replace(' ','');
            strValue= strValue.replace('-','');
        }//End If
        return strValue;
    }//End removeExtraChara()
    
    //change the owner1 values
    public void changeOwner1() {
        
        if( selectedContactOwner1 <> null && selectedContactOwner1 != '-None-' 
            && selectedContactOwner1 != 'New' && AccId != null) {
            conForOwner1 = oppContact(' WHERE Id =\'' + selectedContactOwner1 + '\' ');
            
            oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r = objUtility.getContact1Value(selectedContactOwner1);
                //oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__c = oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r.Id;
        } else if(selectedContactOwner1 <> null && selectedContactOwner1 == 'New' && AccId != null){
            conForOwner1 = new contact(AccountId = AccId);
            oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r = new contact(AccountId = AccId);
        } else if( selectedContactOwner1 == '-None-') {
            conForOwner1 = new contact();
            oppListToUpdateOwnerOfficerInfo.McaApp__Owner_1__r = new contact();
        }// End Else - If
    }// End changeOwner1()
    
    //change the owner2 values
    public void changeOwner2() {
        
        if( selectedContactOwner2 <> null 
        && selectedContactOwner2 != '-None-' 
        && selectedContactOwner2 != 'New'){
            conForOwner2 = oppContact(' WHERE Id =\'' + selectedContactOwner2 + '\' ');
            oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r = objUtility.getContact2Value(selectedContactOwner2);
            //oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__c = oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r.Id;
        } else if(selectedContactOwner2 <> null && selectedContactOwner2 == 'New'){
            conForOwner2 = new contact(AccountId = AccId);
                oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r = new contact(AccountId = AccId);            
        } else if( selectedContactOwner2 == '-None-') {
            conForOwner2 = new contact();
            oppListToUpdate2ndOwnerOfficerInfo.McaApp__Owner_2__r = new contact();
        }// End Else - If
    }//end changeOwner2()
    
    // get contact value
    public contact oppContact(String whereClause) {
        String baseQuery = 'SELECT Id,Title,Name,'
                                +'McaApp__Social_Security_Number1__c,'
                                +'McaApp__Of_Ownership__c,'
                                +'MobilePhone,'
                                +'Email,'
                                +'LastName,'
                                +'FirstName,'
                                +'MailingStreet,'
                                +'MailingState,'
                                +'MailingPostalCode,'
                                +'MailingCountry,'
                                +'MailingCity,'
                                +'Phone,'
                                +'HomePhone,'
                                +'OtherPhone,'
                                +'McaApp__Drivers_License__c,'
                                +'Birthdate'
                            + ' FROM Contact'
                            + whereClause;
        return Database.query(baseQuery);
    }//End oppContact()
    
    //Check number field 
    public void checkNumericValue(String numberValue, String fieldName) {
        if(numberValue <> null) {
            if(!numberValue.isNumeric()) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + Date_ERROR));
                isError = true;
            }//End If
        }//End If
    }// End checkNumericValue()
    
    //Check fax field length not more then 10 digit
    public void faxFieldValidation(String faxValue) {
        if(faxValue<> null) {
            if(faxValue.length() > 10){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, FAX_ERROR));
                isError = true;
            }// End If
        }//End If
    }// End faxFieldValidation()
}