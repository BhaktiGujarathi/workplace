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
                        opportunity.OnDeck_Business_ID__c = businessData.businessID;
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
                    Submission__c s = getSubmission(businessData.applicationNumber);
                    s.Status__c = 'UW';
                    s.Channel__c = 'API';
                    s.Application_Number__c = businessData.applicationNumber;
                    s.Status_Date__c = System.today();
                    s.Date_Submitted__c = System.now();
                    
                    Bank_API_Settings__c settings = Bank_API_Settings__c.getInstance('OnDeck');
                    if (settings != null) {
                        s.Funder__c = settings.Funder_Account__c;
                        s.Program__c = settings.Program__c;
                    }
    
                    if (s.Id == null) {
                        s.Opportunity__c = opportunity.Id;
                    }
                    upsert s;
                    
                    Offer__c o = getOffer(s);
                    o.Amount__c = getDecimalValue(businessData.prequalAmount);
                    o.Funder__c = s.Funder__c;
                    o.Term_Months__c = getDecimalValue(businessData.prequalTerm);
                    o.Status__c = 'Prequal';
                    
                    if (o.Id == null) {
                        o.Opportunity__c = opportunity.Id;  
                        o.Submission__c = s.Id;             
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
                                   , OnDeck_Business_ID__c
                                   , StageName
                                   , Use_of_Proceeds__c
                                                   , Average_Daily_Balance__c
                                                   , Credit_Card_Sales__c
                                   , Account.Federal_Tax_ID_No__c
                                   , Account.Name
                                   , Account.Legal_Name__c
                                   , Account.Industry
                                   , Account.Date_Business_Established__c
                                   , Account.BillingStreet
                                   , Account.BillingCity
                                   , Account.BillingState
                                   , Account.BillingPostalCode
                                   , Account.Phone
                                   , Account.AnnualRevenue
                                   , Account.Monthly_Bank_Deposit_Avg_All__c
                                   , Account.Monthly_CC_Avg_All__c
                                   , Account.Email__c
                                   , Owner_1_Ownership__c
                                   , Owner_2_Ownership__c
                                   , Owner_1__c
                                   , Owner_1__r.Social_Security_Number1__c
                                   , Owner_1__r.Name
                                   , Owner_1__r.Email
                                   , Owner_1__r.HomePhone
                                   , Owner_1__r.Birthdate
                                   , Owner_1__r.MailingStreet
                                   , Owner_1__r.MailingCity
                                   , Owner_1__r.MailingState
                                   , Owner_1__r.MailingPostalCode
                                   , Owner_2__c
                                   , Owner_2__r.Social_Security_Number1__c
                                   , Owner_2__r.Name
                                   , Owner_2__r.Email
                                   , Owner_2__r.HomePhone
                                   , Owner_2__r.Birthdate
                                   , Owner_2__r.MailingStreet
                                   , Owner_2__r.MailingCity
                                   , Owner_2__r.MailingState
                                   , Owner_2__r.MailingPostalCode
                                from Opportunity
                               where Id = :ApexPages.currentPage().getParameters().get('id')]) {
            opportunity = o;            
        }
        if (opportunity != null) {
            //OnDeck Business ID
            
            businessData.businessID = opportunity.OnDeck_Business_ID__c;
            
            //Business Information
            businessData.taxID = opportunity.Account.Federal_Tax_ID_No__c;
            businessData.businessName = opportunity.Account.Legal_Name__c;
            businessData.doingBusinessAs = opportunity.Account.Name;
            businessData.businessIndustry = opportunity.Account.Industry;
            businessData.loanPurpose = opportunity.Use_of_Proceeds__c;
            businessData.businessInceptionDate = opportunity.Account.Date_Business_Established__c;
            businessData.businessPhone = opportunity.Account.Phone;
                        
            //Business Address
            businessData.address.street = opportunity.Account.BillingStreet;
            businessData.address.city = opportunity.Account.BillingCity;
            businessData.address.state = opportunity.Account.BillingState;
            businessData.address.zip = opportunity.Account.BillingPostalCode;
            
            //Financial Information
            businessData.annualRevenue = opportunity.Account.AnnualRevenue;
            businessData.averageBankBalance = opportunity.Average_Daily_Balance__c;
            businessData.averageCreditCardVolume = opportunity.Credit_Card_Sales__c;
            
            //Owner 1 Information       
            businessData.owner1 = null;
            if (opportunity.Owner_1__c != null) {   
                businessData.owner1 = new OnDeckClient.Owner();
                businessData.owner1.ssn = opportunity.Owner_1__r.Social_Security_Number1__c;
                businessData.owner1.name = opportunity.Owner_1__r.Name;
                if ((opportunity.Owner_1__r.Email != null) && (!opportunity.Owner_1__r.Email.Equals(''))){
                    businessData.owner1.email = opportunity.Owner_1__r.Email;
                }
                else {
                    businessData.owner1.email = opportunity.Account.Email__c;
                }
                businessData.owner1.phone = opportunity.Owner_1__r.HomePhone;
                businessData.owner1.dob = opportunity.Owner_1__r.Birthdate;
                businessData.owner1.ownershipPercentage = opportunity.Owner_1_Ownership__c;
                businessData.owner1.address.street = opportunity.Owner_1__r.MailingStreet;
                businessData.owner1.address.city = opportunity.Owner_1__r.MailingCity;
                businessData.owner1.address.state = opportunity.Owner_1__r.MailingState;
                businessData.owner1.address.zip = opportunity.Owner_1__r.MailingPostalCode;
            }
            
            //Owner 2 Information   
            businessData.owner2 = null;
            if (opportunity.Owner_2__c != null) {   
                businessData.owner2 = new OnDeckClient.Owner();
                businessData.owner2.ssn = opportunity.Owner_2__r.Social_Security_Number1__c;
                businessData.owner2.name = opportunity.Owner_2__r.Name;
                //businessData.owner2.email = opportunity.Owner_2__r.Email;
                if ((opportunity.Owner_2__r.Email != null) && (!opportunity.Owner_2__r.Email.Equals(''))){
                    businessData.owner2.email = opportunity.Owner_2__r.Email;
                }
                else {
                    businessData.owner2.email = opportunity.Account.Email__c;
                }
                businessData.owner2.phone = opportunity.Owner_2__r.HomePhone;
                businessData.owner2.dob = opportunity.Owner_2__r.Birthdate;
                businessData.owner2.ownershipPercentage = opportunity.Owner_2_Ownership__c;
                businessData.owner2.address.street = opportunity.Owner_2__r.MailingStreet;
                businessData.owner2.address.city = opportunity.Owner_2__r.MailingCity;
                businessData.owner2.address.state = opportunity.Owner_2__r.MailingState;
                businessData.owner2.address.zip = opportunity.Owner_2__r.MailingPostalCode;
            }   
        }   
    }
    
    
    private Submission__c getSubmission(String applicationNumber) {
        for (Submission__c s : [select Id from Submission__c
                                 where Opportunity__c = :opportunity.Id
                                   and Application_Number__c = :applicationNumber]) {
            return s;
        }
        return new Submission__c();
    }
    
    
    private Offer__c getOffer(Submission__c s) {
        for (Offer__c o : [select Id from Offer__c
                            where Submission__c = :s.Id
                              and Opportunity__c = :opportunity.Id]) {
            return o;
        }
        return new Offer__c();
    }   
    
    
    private Decimal getDecimalValue(String s) {
        try {
            return Decimal.valueOf(s);
        }
        catch (Exception e) {}
        return null;
    }
}