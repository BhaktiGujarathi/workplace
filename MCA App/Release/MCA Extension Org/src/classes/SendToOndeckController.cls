public with sharing class SendToOndeckController {
    public Opportunity opportunity { get; set; }
    public OnDeckClient.BusinessData businessData { get; set; }
    public Boolean enableSubmit { get; set; }
    public Boolean showPrequal { get; set; }
    public Boolean showLoader { get; set; }

    
    public SendToOndeckController() {
        businessData = new OnDeckClient.BusinessData();
        showLoader = true;
        queryOpportunity();
    }


    public PageReference doPrequal() {
        queryOpportunity();
        
        enableSubmit = false;
        showPrequal = false;
        showLoader = false;
        
        if (opportunity != null) {
            boolean errors = checkPreQualDataErrors();
            system.debug(errors);
            if (errors) {
                
                return null;
            }
            else {
                OnDeckClient client = new OnDeckClient();
                client.sendPrequal(businessData);
                
                if (businessData.getIsSystemError() && businessData.businessID != null && businessData.businessID != '') {
                    businessData.errorCodes.clear();
                    businessData.errorDescriptions.clear();
                    enableSubmit = true;
                    return submitToOnDeck();
                }
                else{
                    
                    if (businessData.businessID != null && opportunity.OnDeck_Business_ID__c != businessData.businessID) {
                        opportunity.McaFundingApp__OnDeck_Business_ID__c = businessData.businessID;
                        update opportunity;
                    } 
                    else if (businessData.businessId == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The Prequalification failed due to a System Error on the API endpoint'));
                    }
                    
                    if (businessData.getIsSuccess()) {
                        if (businessData.prequalified == 'true') {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Your Deal has been Prequalified! You can review the offer and submit it to OnDeck'));
                            enableSubmit = true;
                        }
                        else {
                            
                            String errorMessage = 'This deal does not meet the Prequalification guidelines, you can still submit it to OnDeck';
                            
                            if (businessData.annualRevenue == null || businessData.averageBankBalance != null
                                                                   || businessData.averageCreditCardVolume != null) {

                                errorMessage += ', or provide the following missing information and try again';                             
                            }

                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, errorMessage));
                            showPrequal = true; 
                            enableSubmit = true;
                            
                            if (businessData.annualRevenue == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Missing Account Annual Revenue'));
                            }
                            
                            if (businessData.averageBankBalance == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Missing Average Daily Balance'));                           
                            }
                            
                            if (businessData.averageCreditCardVolume == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Monthly Credit Card Sales'));
                            }                           
                        }
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The Prequalification failed due to a System Error on the API endpoint'));
                    }
                }
                return null;
            }
        }   
        else {
            return new PageReference('/006');
        }
        
    }
    
    public boolean checkPreQualDataErrors(){
        boolean errors = false;
        
        if (businessData.businessName == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Legal Name cannot be empty'));
            errors = true;
        }
            
        if (businessData.address.city == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing City cannot be empty'));
            errors = true;
        }
        
        if (businessData.address.state == null || (businessData.address.state.length() != 2)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing State/Province cannot be empty and must be exactly two character in length'));
            errors = true;
        }
        
        if (businessData.taxID != null) {
            businessData.taxID = businessData.taxID.replace('-', '');
        }
        
        if (businessData.taxID == null || businessData.taxID.length() != 9) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Federal Tax ID# cannot be empty and must be a numeric string of length 9'));
            errors = true;
        }
        
                
        if (businessData.owner1 == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner cannot be empty'));
            errors = true;
        }
        else {
            if (businessData.owner1.name == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Name cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.address.city == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing City cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.address.state == null || businessData.owner1.address.state.length() != 2) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing State/Province cannot be empty and must be exactly two character in length'));
                errors = true;
            }
            
            if (businessData.owner1.phone == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Home Phone cannot be empty'));
                errors = true;
            }
            
        }
        
        return errors;
    }

    public boolean checkSubmitDataErrors(){
        boolean errors = false;
        
        
        if (businessData.businessName == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Legal Name cannot be empty'));
            errors = true;
        }
        
        if (businessData.address.street == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing Street cannot be empty'));
            errors = true;
        }
        
        if (businessData.address.city == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing City cannot be empty'));
            errors = true;
        }
        
        if (businessData.address.state == null || businessData.address.state.length() != 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing State/Province cannot be empty and must be exactly two character in length'));
            errors = true;
        }
        
        if (businessData.address.zip == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Billing Zip/Postal Code cannot be empty'));
            errors = true;
        }
        
        if (businessData.businessPhone == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Phone cannot be empty'));
            errors = true;
        }
        
        if (businessData.annualRevenue == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Annual Revenue cannot be empty'));
            errors = true;
        }
        
        if (businessData.averageCreditCardVolume == null) {
            businessData.averageCreditCardVolume = 0;
        }
        
        if (businessData.averageBankBalance == null) {
            businessData.averageBankBalance = 0;
        }       
        
        if (businessData.taxID != null) {
            businessData.taxID = businessData.taxID.replace('-', '');
        }
        
        if (businessData.taxID == null || businessData.taxID.length() != 9) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Federal Tax ID# cannot be empty and must be a numeric string of length 9'));
            errors = true;
        }        
        
        if (businessData.owner1 == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner cannot be empty'));
            errors = true;
        }
        else {
        
            if (businessData.owner1.email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner email cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.name == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Name cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.address.street == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing Street cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.address.city == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing City cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.address.state == null || businessData.owner1.address.state.length() != 2) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing State/Province cannot be empty and must be exactly two character in length'));
                errors = true;
            }
            
            if (businessData.owner1.address.zip == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Mailing Zip/Postal Code cannot be empty'));
                errors = true;
            }
            
            //if (businessData.owner1.ssn == null || businessData.owner2.ssn == null) {
            //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Social Security Number cannot be empty'));
            //    errors = true;
            //}
            
            if (businessData.owner1.phone == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Home Phone cannot be empty'));
                errors = true;
            }
            
            if (businessData.owner1.dob == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner Birthdate cannot be empty'));
                errors = true;
            }
        }
        
        return errors;
    }
    
    public void showSubmitLoader() {
       showLoader = true;
    }
    
    
    public PageReference submitToOnDeck() {
        queryOpportunity();
        showLoader = false;
        
        businessData.errorCodes.clear();
        businessData.errorDescriptions.clear();
        
        if (opportunity != null && enableSubmit) {
            
            if (checkSubmitDataErrors()) {
                return null;
            }
            
            OnDeckClient client = new OnDeckClient();
            client.sendSubmit(businessData);
            
            if (businessData.getIsSuccess()) {
                try {
                    McaApp__Submission__c s = getSubmission(businessData.applicationNumber);
                    s.McaApp__Status__c = 'UW';
                    s.McaApp__Channel__c = 'API';
                    s.McaApp__Application_Number__c = businessData.applicationNumber;
                    s.McaApp__Status_Date__c = System.today();
                    s.McaApp__Date_Submitted__c = System.now();
                    
                    McaFundingApp__Bank_API_Settings__c settings = McaFundingApp__Bank_API_Settings__c.getInstance('OnDeck');
                    if (settings != null) {
                        s.McaApp__Funder__c = settings.McaFundingApp__Funder_Account__c;
                        s.McaApp__Program__c = settings.McaFundingApp__Program__c;
                    }
    
                    if (s.Id == null) {
                        s.McaApp__Opportunity__c = opportunity.Id;
                    }
                    upsert s;
                    
                    McaApp__Offer__c o = getOffer(s);
                    o.McaApp__Amount__c = getDecimalValue(businessData.prequalAmount);
                    o.McaApp__Funder__c = s.McaApp__Funder__c;
                    o.McaApp__Term_Months__c = getDecimalValue(businessData.prequalTerm);
                    o.McaApp__Status__c = 'Prequal';
                    
                    if (o.Id == null) {
                        o.McaApp__Opportunity__c = opportunity.Id;  
                        o.McaApp__Submission__c = s.Id;             
                    }
                    
                    upsert o;
                    
                    System.debug('value>>> ' + opportunity.StageName);
                    opportunity.StageName = 'Underwriting';
                    update opportunity;
                    
                    return new PageReference('/' + s.Id);                   
                
                }
                catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
                }                   
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There was an error trying to Submit your deal, please review'));
            }
            return null;
        }
        else if (opportunity != null) {
            return null;
        }
        else {
            return new PageReference('/006');
        }
    }
    
    
    private void queryOpportunity() {
        for (Opportunity o : [select Name
                                   , McaFundingApp__OnDeck_Business_ID__c
                                   , StageName
                                   , McaApp__Use_of_Proceeds__c
                                                   , McaApp__Average_Daily_Balance__c
                                                   , McaApp__Credit_Card_Sales__c
                                   , Account.McaApp__Federal_Tax_ID_No__c
                                   , Account.Name
                                   , Account.McaApp__Legal_Name__c
                                   , Account.Industry
                                   , Account.McaApp__Date_Business_Established__c
                                   , Account.BillingStreet
                                   , Account.BillingCity
                                   , Account.BillingState
                                   , Account.BillingPostalCode
                                   , Account.Phone
                                   , Account.AnnualRevenue
                                   , Account.McaApp__Monthly_Bank_Deposit_Avg_All__c
                                   , Account.McaApp__Monthly_CC_Avg_All__c
                                   , Account.McaApp__Email__c
                                   , McaApp__Owner_1_Ownership__c
                                   , McaApp__Owner_2_Ownership__c
                                   , McaApp__Owner_1__c
                                   , McaApp__Owner_1__r.McaApp__Social_Security_Number__c
                                   , McaApp__Owner_1__r.Name
                                   , McaApp__Owner_1__r.Email
                                   , McaApp__Owner_1__r.HomePhone
                                   , McaApp__Owner_1__r.Birthdate
                                   , McaApp__Owner_1__r.MailingStreet
                                   , McaApp__Owner_1__r.MailingCity
                                   , McaApp__Owner_1__r.MailingState
                                   , McaApp__Owner_1__r.MailingPostalCode
                                   , McaApp__Owner_2__c
                                   , McaApp__Owner_2__r.McaApp__Social_Security_Number__c
                                   , McaApp__Owner_2__r.Name
                                   , McaApp__Owner_2__r.Email
                                   , McaApp__Owner_2__r.HomePhone
                                   , McaApp__Owner_2__r.Birthdate
                                   , McaApp__Owner_2__r.MailingStreet
                                   , McaApp__Owner_2__r.MailingCity
                                   , McaApp__Owner_2__r.MailingState
                                   , McaApp__Owner_2__r.MailingPostalCode
                                from Opportunity
                               where Id = :ApexPages.currentPage().getParameters().get('id')]) {
            opportunity = o;        
                
        }
        if (opportunity != null) {
            //OnDeck Business ID
            
            businessData.businessID = opportunity.McaFundingApp__OnDeck_Business_ID__c;
            
            //Business Information
            businessData.taxID = opportunity.Account.McaApp__Federal_Tax_ID_No__c;
            businessData.businessName = opportunity.Account.McaApp__Legal_Name__c;
            businessData.doingBusinessAs = opportunity.Account.Name;
            businessData.businessIndustry = opportunity.Account.Industry;
            businessData.loanPurpose = opportunity.McaApp__Use_of_Proceeds__c;
            businessData.businessInceptionDate = opportunity.Account.McaApp__Date_Business_Established__c;
            businessData.businessPhone = opportunity.Account.Phone;
                        
            //Business Address
            businessData.address.street = opportunity.Account.BillingStreet;
            businessData.address.city = opportunity.Account.BillingCity;
            businessData.address.state = opportunity.Account.BillingState;
            businessData.address.zip = opportunity.Account.BillingPostalCode;
            
            //Financial Information
            businessData.annualRevenue = opportunity.Account.AnnualRevenue;
            businessData.averageBankBalance = opportunity.McaApp__Average_Daily_Balance__c;
            businessData.averageCreditCardVolume = opportunity.McaApp__Credit_Card_Sales__c;
            
            //Owner 1 Information       
            businessData.owner1 = null;
            if (opportunity.McaApp__Owner_1__c != null) {   
                businessData.owner1 = new OnDeckClient.Owner();
                businessData.owner1.ssn = opportunity.McaApp__Owner_1__r.McaApp__Social_Security_Number__c;
                businessData.owner1.name = opportunity.McaApp__Owner_1__r.Name;
                if ((opportunity.McaApp__Owner_1__r.Email != null) && (!opportunity.McaApp__Owner_1__r.Email.Equals(''))){
                    businessData.owner1.email = opportunity.McaApp__Owner_1__r.Email;
                }
                else {
                    businessData.owner1.email = opportunity.Account.McaApp__Email__c;
                }
                businessData.owner1.phone = opportunity.McaApp__Owner_1__r.HomePhone;
                businessData.owner1.dob = opportunity.McaApp__Owner_1__r.Birthdate;
                businessData.owner1.ownershipPercentage = opportunity.McaApp__Owner_1_Ownership__c;
                businessData.owner1.address.street = opportunity.McaApp__Owner_1__r.MailingStreet;
                businessData.owner1.address.city = opportunity.McaApp__Owner_1__r.MailingCity;
                businessData.owner1.address.state = opportunity.McaApp__Owner_1__r.MailingState;
                businessData.owner1.address.zip = opportunity.McaApp__Owner_1__r.MailingPostalCode;
            }
            
            //Owner 2 Information   
            businessData.owner2 = null;
            if (opportunity.McaApp__Owner_2__c != null) {   
                businessData.owner2 = new OnDeckClient.Owner();
                businessData.owner2.ssn = opportunity.McaApp__Owner_2__r.McaApp__Social_Security_Number__c;
                businessData.owner2.name = opportunity.McaApp__Owner_2__r.Name;
                //businessData.owner2.email = opportunity.Owner_2__r.Email;
                if ((opportunity.McaApp__Owner_2__r.Email != null) && (!opportunity.McaApp__Owner_2__r.Email.Equals(''))){
                    businessData.owner2.email = opportunity.McaApp__Owner_2__r.Email;
                }
                else {
                    businessData.owner2.email = opportunity.Account.McaApp__Email__c;
                }
                businessData.owner2.phone = opportunity.McaApp__Owner_2__r.HomePhone;
                businessData.owner2.dob = opportunity.McaApp__Owner_2__r.Birthdate;
                businessData.owner2.ownershipPercentage = opportunity.McaApp__Owner_2_Ownership__c;
                businessData.owner2.address.street = opportunity.McaApp__Owner_2__r.MailingStreet;
                businessData.owner2.address.city = opportunity.McaApp__Owner_2__r.MailingCity;
                businessData.owner2.address.state = opportunity.McaApp__Owner_2__r.MailingState;
                businessData.owner2.address.zip = opportunity.McaApp__Owner_2__r.MailingPostalCode;
            }   
        }   
    }
    
    
    private McaApp__Submission__c getSubmission(String applicationNumber) {
        for (McaApp__Submission__c s : [select Id from McaApp__Submission__c
                                 where McaApp__Opportunity__c = :opportunity.Id
                                   and McaApp__Application_Number__c = :applicationNumber]) {
            return s;
        }
        return new McaApp__Submission__c();
    }
    
    
    private McaApp__Offer__c getOffer(McaApp__Submission__c s) {
        for (McaApp__Offer__c o : [select Id from McaApp__Offer__c
                            where McaApp__Submission__c = :s.Id
                              and McaApp__Opportunity__c = :opportunity.Id]) {
            return o;
        }
        return new McaApp__Offer__c();
    }   
    
    
    private Decimal getDecimalValue(String s) {
        try {
            return Decimal.valueOf(s);
        }
        catch (Exception e) {}
        return null;
    }
}