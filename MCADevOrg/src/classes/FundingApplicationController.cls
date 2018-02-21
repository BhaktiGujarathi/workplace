/* 
 *  Apex controller for FundingApplication Page.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Sneha P.               17-02-2014           Initial Draft 
 *  1.1               Shraddha P.            18-10-2014           updated style
 *  1.2               Nachiket Deshpande     22 Dec 2014          Added Validation to Check fedral Tax in Proper Format.
 *                                                                e.g ##-####### (12-1234567)
 *  1.3               Nachiket Deshpande     11 May 2015          Updated query for ownere using like operator to avoid error of 
 *                                                                unique combination key for owner 
 *  1.4               Yogesh Mahajan        19-10-2015            Added valiadtion and create seprate contact creation or updation function
 *  1.5               Yogesh Mahajan        21-10-2015            Added picklist to select owner1 and owner2
 */
 
public with sharing class FundingApplicationController {
    public static final String Error_FOR_NUMBER = ' Should Not be Greater Than 10 Digit';
    public static final String Account_MOBILE_PHONE = 'Account Phone';
    public static final String OWNER1_HOME_PHONE = 'Owner 1 Home Phone';
    public static final String OWNER1_Mobile_PHONE = 'Owner 1 Mobile Phone';
    public static final String OWNER2_HOME_PHONE = 'Owner 2 Home Phone';
    public static final String OWNER2_Mobile_PHONE = 'Owner 2 Mobile Phone';
    public static final String ACCOUNT_FAX = 'Fax Field';
    public static final String POST_CODE_ERROR = 'Should Not be 20 Digit';
    public static final String BILLING_POSTCODE = 'Billing Zip/Postal Code ';
    public static final String SHIPPING_POSTCODE = 'Shipping Zip/Postal Code ';
    public static final String OWNER1_POSTCODE = 'Owner 1 Mailing Zip/Postal Code ';
    public static final String OWNER2_POSTCODE = 'Owner 2 Mailing Zip/Postal Code ';
    public static final String Date_ERROR = ' Is Invalid. Future Dates Are not Accepted';
    public static final String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
    public static final String WEBSITE_CHAR_PATTERN = '((http://|https://)|((w){3})(.))[a-zA-Z0-9]+(.)[a-z]+'; 
    public static final String WEBSITE_CHAR_ERROR = 'Website Name is not in an Appropriate Format.';
    public static final String SPECIAL_CHAR_ERROR = 'Special characters are not allowed In ';
    public static final String DATE_OF_BUSINESS = 'Date of Business ';
    public static final String OWNER1_BIRTHDATE = 'Owner 1 Birthdate ';
    public static final String OWNER2_BIRTHDATE = 'Owner 2 Birthdate ';
    public static final String SHIPPINGPOSTALCODE = 'Account Shipping Postal Code ';
    public static final String BILLINGPOSTALCODE = 'Account Billing Postal Code ';
    public static final String ACCOUNT_PHONE = 'Account Phone ';
    public static final String OWNER1_DRIVERS_LICENSE = 'Owner 1 Driver License ';
    public static final String OWNER2_DRIVERS_LICENSE = 'Owner 2 Driver License ';
    public static final String OWNER1_MOBILEPHONE = 'Owner 1 MobilePhone ';
    public static final String OWNER2_MOBILEPHONE = 'Owner 2 MobilePhone ';
    public static final String OWNER1_SOCIAL_SECURITY_NUMBER = 'Owner 1 Social Security Number ';
    public static final String OWNER2_SOCIAL_SECURITY_NUMBER = 'Owner 2 Social Security Number ';
    public static final String SOCIAL_SECURITY_NUMBER_ERROR = 'Is Invalid.';
    public static final String Social_Security_Number_Error_Message_Owner1 = 'Please enter the Social Security Number in the format of XXX-XX-XXXX for Owner 1'; 
    public static final String Social_Security_Number_Error_Message_Owner2 = 'Please enter the Social Security Number in the format of XXX-XX-XXXX for Owner 2'; 
    
    public String SSN                           {get;set;}
    public Boolean isError;
    public Account objAccount                   {get;set;}
    public Opportunity opportunity              {get;set;}
    public list <Contact> contactForMappingLst  {get;set;}
    public CongaButtonUrl__c createPDF          {get;set;}
    public CongaButtonUrl__c emailPDF           {get;set;}
    public CongaButtonUrl__c faxPDF             {get;set;}
    public CongaButtonUrl__c docusign           {get;set;}
    public Contact conForOwner1                 {get;set;}
    public Contact conForOwner2                 {get;set;}
    public String isConsole                     {get;set;}
    public String FedralTaxId                   {get;set;}
    public String selectedContactOwner1         {get;set;}
    public String selectedContactOwner2         {get;set;}
    public String errorMessage                  {get;set;}
    
    private ApexPages.StandardController stdController; 
    
    public list <Contact> contactForMappingtoUpdateLst;
    public list <Opportunity> opportunitytoUpdateLst;
    public list<Contact> oldContactOwner1;
    public list<Contact> oldContactOwner2;
    public list<Contact> listContactToUpsert;
    
    private final String selectAccountError = 'Please select Account on opportunity';
    private String AccId;
    private String OppId;
    private String CheckWhereCondition;
    
    public Boolean flag;
                
    public FundingApplicationController (ApexPages.StandardController stdController){
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
        FedralTaxId = null;
        SSN = null;
        emailPDF = CongaButtonUrl__c.getInstance('Email PDF');
        createPDF = CongaButtonUrl__c.getInstance('Create PDF');
        faxPDF = CongaButtonUrl__c.getInstance('Fax PDF');
        docusign = CongaButtonUrl__c.getInstance('Docusign');
        contactForMappingLst =  new list<Contact>();
        listContactToUpsert = new List<Contact>();
        flag = true;
        isError = false;
        
        try{
            AccId = ApexPages.currentPage().getParameters().get('id');
            
            list<Account> listAccount = new list<Account>();
            listAccount = [SELECT Id, Name, Legal_Name__c, Type_of_Entity__c, Federal_Tax_ID_No__c, BillingStreet, BillingCity, BillingState,
                                    BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Cellular_No__c,
                                    Fax, Date_Business_Established__c, Years_in_Business__c, Industry, Website, Email__c, Bank_Name__c, Bank_Contact__c,
                                    Bank_Phone__c, Business_Name__c, Business_Contact_Account__c, Business_Phone__c, Landlord_Mortgagee__c,
                                    Landlord_Contact_Name__c, Landlord_Phone__c, Lease_start_date__c, Time_Left_On_Lease__c, Monthly_Payment__c,
                                    Square_Footage__c, Gross_monthly_Sales__c, Monthly_CC_Avg_All__c 
                            FROM Account 
                            WHERE Id =: AccId limit 1];
            if(!listAccount.isEmpty())
                objAccount = listAccount[0];
            
            OppId = ApexPages.currentPage().getParameters().get('oppId');
            opportunity = [SELECT Balance__c ,Cash_Advance_Company__c,AccountId,Use_of_Proceeds__c,Gross_monthly_Sales__c,Credit_Card_Sales__c,
                                  Ever_used_a_Business_Cash_Advance__c,Owner_1_Ownership__c,Owner_2_Ownership__c,
                                  Amount_Requested__c,Owner_1__c,Owner_2__c,Application__c,
                                  Credit_Card_Statements__c,Bank_Statements__c,StageName
                          FROM Opportunity 
                          WHERE Id =: OppId ];
             
            if(opportunity.Owner_1__c <> null) {
                conForOwner1 = oppContact(' WHERE Id =\'' + opportunity.Owner_1__c + '\' ');
                selectedContactOwner1 = opportunity.Owner_1__c;
            }//End If
             
            if(opportunity.Owner_2__c <> null) {
                conForOwner2 = oppContact(' WHERE Id =\'' + opportunity.Owner_2__c + '\' ');
                selectedContactOwner2 = opportunity.Owner_2__c;
            }//End If
            
           for(Account acc : listAccount){
              FedralTaxId = acc.Federal_Tax_ID_No__c;
           }//End For
           
        }catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }// End Try - catch
            
    }// End FundingApplicationController()
    
    public PageReference doSave(){
        try{
            this.quickSave1();
            //PageReference pageRef = new PageReference(Page.FundingApplicationView.getURL()+'?id='+AccId+'&oppId='+OppId);
            PageReference pageRef = new PageReference('/'+OppId);
            pageRef.setRedirect(true);
            if(flag == true && !isError)
                return pageRef;
            else
                return null;
           
        }catch(Exception ex){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            return null;
        }//End Try- Catch
    }//End save()
        
    public PageReference quickSave1(){
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
        // Check date field not contains future validation
        dateFieldValidation(objAccount.Date_Business_Established__c, DATE_OF_BUSINESS);
        dateFieldValidation(conForOwner1.Birthdate, OWNER1_BIRTHDATE);
        dateFieldValidation(conForOwner2.Birthdate, OWNER2_BIRTHDATE);
        // Check special charater
        specialCharaterCheck(removeExtraChara(objAccount.Fax), ACCOUNT_FAX);
        specialCharaterCheck(objAccount.ShippingPostalCode, SHIPPINGPOSTALCODE);
        specialCharaterCheck(objAccount.BillingPostalCode, BILLINGPOSTALCODE);
        specialCharaterCheck(removeExtraChara(objAccount.Phone), ACCOUNT_PHONE);
        specialCharaterCheck(string.ValueOf(conForOwner1.Drivers_License__c), OWNER1_DRIVERS_LICENSE);
        specialCharaterCheck(string.ValueOf(conForOwner2.Drivers_License__c), OWNER2_DRIVERS_LICENSE);
        specialCharaterCheck(removeExtraChara(conForOwner1.MobilePhone), OWNER1_MOBILEPHONE);
        specialCharaterCheck(removeExtraChara(conForOwner2.MobilePhone), OWNER2_MOBILEPHONE);
        specialCharaterCheck(removeExtraChara(conForOwner1.HomePhone), OWNER1_HOME_PHONE);
        specialCharaterCheck(removeExtraChara(conForOwner2.HomePhone), OWNER2_HOME_PHONE);
        checkNumericValue(removeExtraChara(conForOwner1.Social_Security_Number1__c), OWNER1_SOCIAL_SECURITY_NUMBER);
        checkNumericValue(removeExtraChara(conForOwner2.Social_Security_Number1__c), OWNER2_SOCIAL_SECURITY_NUMBER);
        Contact contactHolder = new Contact();
        errorMessage ='';
        system.debug('>>>before fedralId check');
        
        if((conForOwner1.Social_Security_Number1__c <> null) && (!Pattern.matches('[0-9]{3}-[0-9]{2}-[0-9]{4}', conForOwner1.Social_Security_Number1__c) && (conForOwner1.Social_Security_Number1__c.length() > 0))) {
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Social_Security_Number_Error_Message_Owner1));
        }
        
        if((conForOwner2.Social_Security_Number1__c <> null) && (!Pattern.matches('[0-9]{3}-[0-9]{2}-[0-9]{4}', conForOwner2.Social_Security_Number1__c) && (conForOwner2.Social_Security_Number1__c.length() > 0))) {
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Social_Security_Number_Error_Message_Owner2));
        }
        
        if((FedralTaxId <> null) && (!Pattern.matches('[0-9]{2}-[0-9]{7}', FedralTaxId) &&(FedralTaxId.length() > 0) ) ){
           //errorMessage = 'Please enter the Federal Tax ID in the format of XX-XXXXXXX';  
            system.debug('>>>after fedralId check');
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter the Federal Tax ID in the format of XX-XXXXXXX')); 
            return null;
        }//End If
        
        if(!isError){
            List<Contact> listContact = new List<Contact>();
            if(conForOwner1 <> null && conForOwner1 != (new Contact()) && selectedContactOwner1 != '-None-')
                listContact.add(conForOwner1);
            if(conForOwner2 <> null && conForOwner2 != (new Contact()) && selectedContactOwner2 != '-None-')
                listContact.add(conForOwner2);
            try {
                upsert listContact;
            }catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//end try - catch
            system.debug('------------>'+listContact.size());
            //update opportunity
            if(conForOwner1 <> null && conForOwner1 != (new Contact()) 
                && listContact.size() != 0 && selectedContactOwner1 != '-None-') { 
                opportunity.Owner_1__c = listContact[0].Id;
                opportunity.Owner_1_Ownership__c = listContact[0].Of_Ownership__c;
            } else if ( conForOwner2 <> null 
            && conForOwner2 != (new Contact()) && selectedContactOwner2 != '-None-'){
                opportunity.Owner_1__c = null;
                opportunity.Owner_2__c = listContact[0].Id;
                opportunity.Owner_2_Ownership__c = listContact[0].Of_Ownership__c;
            }//End else -If
            
            if(selectedContactOwner1 == '-None-') {
                opportunity.Owner_1__c = null;
                opportunity.Owner_1_Ownership__c  = null;
            }//End If
            
            if(conForOwner2 <> null && conForOwner2 != (new Contact()) 
                && listContact.size() != 1 && selectedContactOwner2 != '-None-') {
                opportunity.Owner_2__c = conForOwner1 == null  ? 
                                listContact[0].Id : listContact[1].Id;
                opportunity.Owner_2_Ownership__c = conForOwner1 == null  ? 
                                listContact[0].Of_Ownership__c : listContact[1].Of_Ownership__c; 
            }//End If
            
            if(selectedContactOwner2 == '-None-') {
                opportunity.Owner_2__c = null;
                opportunity.Owner_2_Ownership__c = null;
            }//End If
            
            opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
            if((opportunity.Application__c == true) 
                && (opportunity.StageName == 'Prospecting' 
                || opportunity.StageName == 'Application Sent' 
                || opportunity.StageName == 'Application Missing Info' 
                || opportunity.StageName == 'Renewal Prospecting' 
                || opportunity.StageName == 'Renewal Requested' 
                || opportunity.StageName == 'Declined' 
                || opportunity.StageName == 'Closed Lost')) {
                
                    opportunity.StageName = 'Application In';
            }// End If 
           
           try{
                update opportunity;
            }catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//End try -catch
            
            objAccount.Gross_monthly_Sales__c = opportunity.Gross_monthly_Sales__c;
            
            objAccount.Federal_Tax_ID_No__c = FedralTaxId;
            try{
                update objAccount;
            } catch (DMLException ex) {
                isError = true;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//End try - catch
        }//End If
        return null;
    }//End quickSave1()
      
    public PageReference cancel(){
        system.debug('***OppId***'+OppId);
        return new PageReference('/'+OppId);
    }//End cancel()
    
    public PageReference cancel1(){
        return new PageReference('/'+OppId);
    }//End cancel1()
    
    public PageReference docuSign(){
        return new PageReference('/'+OppId);
    }//End docuSign()
    
    public void docuSign1(){
        //return new PageReference('/'+OppId);
    }//End docuSign1()
        
    public PageReference sendCongaPDF1(){
        try{
            this.quickSave1();
        }
        catch(Exception ex){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }//End try -catch
        return new PageReference('/'+OppId);
    }//End sendCongaPDF1()
    
    public PageReference submissionWizard1(){
        system.debug('***submissionWizard1**');
        try{
            //pageRef = new PageReference();
            this.quickSave1();
            //redirectOpp();
            //pageRef = '/'+OppId;
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//End try-catch
        return new PageReference('/'+OppId);
        //return new PageReference('/apex/SubmissionWizard?id='+OppId+'&accId='+opportunity.AccountId);
    }//End submissionWizard1()
        
    public PageReference openConga1(){
        try{
            this.quickSave1();
        }
        catch(Exception ex){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }//End try-catch
        return new PageReference('/'+OppId);
    }//End openConga1()
    
    public PageReference editPage(){
        PageReference pageRef = new PageReference(Page.FundingApplication.getUrl()+'?id='+AccId+'&oppId='+OppId);
        pageRef.setRedirect(true);
        return pageRef;
    }//End editPage()
    
    // Check special charater into string 
    public void specialCharaterCheck(String strValue, String fieldName) {
        if(strValue <> null) {
            Pattern patternVal = Pattern.compile(SPECIAL_CHAR_PATTERN);
            Matcher patternMatcher = patternVal.matcher(strValue);
            if(patternMatcher.find()){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, SPECIAL_CHAR_ERROR + fieldName));
                isError = true;
            }//End If
        }//End If
    }//End specialCharaterCheck()
    
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
    
    //Check date is not future
    public void dateFieldValidation(Date dateVal, String fieldName) {
        if(dateVal <> null) {
            if(dateVal >= date.today()){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + Date_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End dateFieldValidation()
    
    //Check fax field length not more then 10 digit
    public void numberFieldValidation(String faxValue, String fieldName) {
        if(faxValue <> null) {
            if(faxValue.length() > 10){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + Error_FOR_NUMBER));
                isError = true;
            }//End If
        }//End If
    }//End numberFieldValidation()
    
    //Check fax field length not more then 20 digit
    public void postCodeFieldValidation(String postCodeValue, String fieldName) {
        if(postCodeValue <> null) {
            if(postCodeValue.length() > 19){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + POST_CODE_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End postCodeFieldValidation()
    
    //Check number field 
    public void checkNumericValue(String numberValue, String fieldName) {
        if(numberValue <> null) {
            if(!numberValue.isNumeric()) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, fieldName + SOCIAL_SECURITY_NUMBER_ERROR));
                isError = true;
            }//End If
        }//End If
    }//End checkNumericValue()
    
    //change the owner1 values
    public void changeOwner1() {
        if( selectedContactOwner1 <> null 
        && selectedContactOwner1 != '-None-' 
        && selectedContactOwner1 != 'New' && AccId != null){
            conForOwner1 = oppContact(' WHERE Id =\'' + selectedContactOwner1 + '\' ');
        } else if(selectedContactOwner1 <> null 
        && selectedContactOwner1 == 'New' && AccId != null){
            conForOwner1 = new contact(AccountId = AccId);
        } else if( selectedContactOwner1 == '-None-') {
            conForOwner1 = new contact();
        }// End Else - If
    }// End changeOwner1()
    
    //change the owner2 values
    public void changeOwner2() {
        if( selectedContactOwner2 <> null 
        && selectedContactOwner2 != '-None-' 
        && selectedContactOwner2 != 'New'){
            conForOwner2 = oppContact(' WHERE Id =\'' + selectedContactOwner2 + '\' ');
        } else if(selectedContactOwner2 <> null 
        && selectedContactOwner2 == 'New'){
            conForOwner2 = new contact(AccountId = AccId);
        } else if( selectedContactOwner2 == '-None-') {
            conForOwner2 = new contact();
        }// End Else - If
    }//end changeOwner2()
    
    // get contact value
    public contact oppContact(String whereClause) {
        String baseQuery = 'SELECT Id,Title,Name,'
                                + 'Social_Security_Number1__c,'
                                +'Of_Ownership__c,'
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
                                +'Drivers_License__c,'
                                +'Birthdate'
                            + ' FROM Contact'
                            + whereClause;
        return Database.query(baseQuery);
    }//End oppContact()
    
    public List<Contact> contactCheck(Contact pcontactInstance, string pCondition) {
        List<Contact> contactListInstance = [Select Name, 
                                          AccountId, 
                                          Title,
                                          MailingStreet,
                                          MailingState,
                                          MailingPostalCode,
                                          MailingCountry,
                                          MailingCity,
                                          Phone,
                                          HomePhone,
                                          OtherPhone,
                                          Drivers_License__c,
                                          Birthdate,
                                          Social_Security_Number1__c
                                   From Contact
                                   Where Combination_Key_For_Owner__c like : '%'+pCondition+'%'];
        System.debug('>>>contactInstance' +contactListInstance );
        return contactListInstance ;      
        
    }//End contactCheck()
    
    //Remove extra characters
    public String removeExtraChara(String strValue) {
        if(strValue <> null) {
            strValue= strValue.replace('(','');
            strValue= strValue.replace(')','');
            strValue= strValue.replace(' ','');
            strValue= strValue.replace('-','');
        }
        return strValue;
    }//End removeExtraChara()

    // Picklist to show all contact reltaed to opportunity account.
    public List<SelectOption> getConatactOptions() {
        List<SelectOption> contactOptions = new List<SelectOption>();
        contactOptions.add(new SelectOption('-None-','-None-'));
        contactOptions.add(new SelectOption('New','-New-'));
        for(Contact objContact: relatedContact()) {
            contactOptions.add(new SelectOption(objContact.id, objContact.name));
        }
        return contactOptions;
    }//End getCountriesOptions()
    
    //get list of contact related to account
    public List<Contact> relatedContact() {
        return ([SELECT id,
                        Name
                FROM Contact
                WHERE AccountId =: AccId]);
    }//End relatedContact()
}//End controller class FundingApplicationController