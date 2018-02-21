public class DedupeProspectProcessServiceForAccounts{

    public static Boolean isApplicantRunning = false;

    public  static final Set<String> APPLICANT_CATEGORIES             = new Set<String>{'Submitted Opp', 'Contracted Opp' };
    private static final String      FUNDED_DUP_REASON                = 'Funded Opportunity paid off for more than 60 days';
    private static final String      APPLICANT_FUNDED_DUP_REASON      = 'Matched to Funded Opportunity';
    private static final String      APPLICANT_CONTRACTED_DUP_REASON  = 'Matched to Contracted Opportunity';
    private static final String      APPLICATION_SUBMITTED_DUP_REASON = 'Matched to Existing Submitted Opportunity';
    private static final String      APPD_OPP_DUP_REASON              = 'Matched to New Submitted Opportunity';
    private static final String      DEAD_DUP_REASON                  = 'Matched to New Submitted Opportunity';
    private static final String      CUSTOMER_UNQUALIFIED             = 'Closed - Unqualified';
    private static final String      REASON_LOST_DUPLICATE            = 'Duplicate';
    private static final Map<Id, Contact> contactCache = new Map<Id, Contact>();

    private String opportunitiesAuxQuery;
    private String contactsAuxQuery;
    private String accountsAuxQuery;
    private Account[] accounts;
    private Map<Id, Opportunity> opportunitiesToUpdate;
    private Map<Id, Lead> leadsToUpdate;
    private Map<Id, List<Contact>> contactsForDuplicatedAccount = new Map<Id, List<Contact>>();
    private List<Contact> contactsToUpdate = new List<Contact>();
    private List<Account> accountsToUpdate = new List<Account>();
    private Deduplication_Settings__c settings;
    private Set<String> accountPhones;    
    private Set<String> contactPhones;
    private Set<String> accountCopyFields;
    private Set<String> contactCopyFields;
    private Set<String> opportunityCopyFields;


    public DedupeProspectProcessServiceForAccounts(List<Account> newAccounts){

        settings = Deduplication_Settings__c.getOrgDefaults();
        accountPhones = new Set<String>();
        contactPhones = new Set<String>();

        if (settings.Account_Phones__c != null) {
            for (String accountPhone : settings.Account_Phones__c.split(',')) {
                accountPhones.add(accountPhone.toLowerCase());
            }
        }

        if (settings.Contact_Phones__c != null) {
            for (String contactPhone : settings.Contact_Phones__c.split(',')) {
                contactPhones.add(contactPhone.toLowerCase());
            }
        }

        accountCopyFields = new Set<String>();
        contactCopyFields = new Set<String>();
        opportunityCopyFields = new Set<String>();

        for (Deduplication_Field__c dedupeField : [SELECT Field_API_Name__c,
                                                          Object__c
                                                     FROM Deduplication_Field__c
                                                    WHERE Object__c IN ('Account', 'Contact', 'Opportunity')
                                                      AND Field_API_Name__c <> NULL]) {
            
            if (dedupeField.Object__c == 'Account') {
                accountCopyFields.add(dedupeField.Field_API_Name__c.toLowerCase());             
            }
            else if (dedupeField.Object__c == 'Contact') {
                contactCopyFields.add(dedupeField.Field_API_Name__c.toLowerCase());             
            }
            else if (dedupeField.Object__c == 'Opportunity') {
                opportunityCopyFields.add(dedupeField.Field_API_Name__c.toLowerCase());             
            }
        }


        Set<Id> accountIds = new Set<Id>();    

        for (Account account : newAccounts) {
            accountIds.add(account.Id);            
        }  

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        String opportunitiesAuxQuery = opptiesQueryAux();
        String contactsAuxQuery      = contactsQueryAux();

        String query = 'select Id, Account_Dedupe_Key__c, Account_Phones__c, Opportunity_Stage_Category__c, ' + opportunitiesAuxQuery + ',' + contactsAuxQuery + ',' + String.join(phoneFields, ',') + ' from Account where Id in :accountIds and Flagged_for_Duplicate_Review__c = false';

        System.debug('###QUERY:    ' + query);

        accounts = (Account[]) Database.query(query);

        for (Account account : accounts) {

            if (account.getSObjects('Contacts') != null) {

                contactsForDuplicatedAccount.put(account.Id, (Contact[]) account.getSObjects('Contacts'));
            }
        }   

        opportunitiesToUpdate = new Map<Id, Opportunity>();
        leadsToUpdate = new Map<Id, Lead>(); 
    }


    // Query for all the fields in the Opportunity to avoid errors.
    private String opptiesQueryAux(){
        Map<String, Schema.SObjectField> opportunityFields = Schema.SObjectType.Opportunity.fields.getMap();

        String opportunitiesAuxQuery = '(select Primary_Campaign__r.Name, Account.Name, Account.McaApp__Gross_monthly_Sales__c,Account.McaApp__Years_in_Business__c, Account.Business_Main_Phone__c, Account.McaApp__Monthly_CC_Avg_All__c, Account.McaApp__Business_Contact_Account__c, Account.Business_Contact_Account_2__c, Account.Business_Contact_Account_3__c, Account.McaApp__Business_Phone__c, Account.Business_Phone_2__c, Account.Business_Phone_3__c, Account.McaApp__ConvertedAccount__c, Account.McaApp__Date_Business_Established__c, Account.McaApp__Federal_Tax_ID_No__c, Account.McaApp__Landlord_Mortgagee__c, Account.McaApp__Landlord_Contact_Name__c, Account.McaApp__Landlord_Phone__c, Account.McaApp__Monthly_Payment__c, Account.McaApp__NumberofLocations__c, Account.State_of_Incorporation__c ';

        Set<String>  opportunitiesFieldsSet  = opportunityFields.keySet();

        List<String> opportunitiesFieldsList = new List<String>(opportunitiesFieldsSet);

        for (Schema.SObjectField fld: opportunityFields.values()) {
                
            opportunitiesAuxQuery += ', ' + fld.getDescribe().getName();
        }

        opportunitiesAuxQuery += ' from Opportunities order by CreatedDate desc limit 200)';

        system.debug('OPPORTUNITIES AUX QUERY:  ' + opportunitiesAuxQuery);

        return opportunitiesAuxQuery;
    }


    // Query for all the fields in the Contact to avoid errors.
    private String contactsQueryAux(){
        String contactsAuxQuery = '(' + contactFieldsString() + ' from Contacts order by CreatedDate desc limit 200)';

        system.debug('CONTACTS AUX QUERY:   ' + contactsAuxQuery);

        return contactsAuxQuery;
    }


    public void initDedupe() {

        initDedupe(false);
    }


    // Initiates the deduplication process
    public void initDedupe(Boolean forceRun) {

        if (settings.Enable_Prospect_for_Accounts_Process__c || Test.isRunningTest()) {

            if (CustomLeadConversion.runOnce() || forceRun) {
                
                if (!isApplicantRunning || forceRun) {

                    isApplicantRunning = true;

                    if (!compareAccountsWithPhones()) {

                        compareLeadsWithPhones();
                    }

                    if (!opportunitiesToUpdate.isEmpty()) {
                        
                        //System.assert(false, opportunitiesToUpdate);

                        update opportunitiesToUpdate.values();
                    }

                    if (!leadsToUpdate.isEmpty()) {
                        update leadsToUpdate.values();
                    }

                    if (!contactsToUpdate.isEmpty()) {
                        update contactsToUpdate;
                    }

                    if (!accountsToUpdate.isEmpty()) {
                        update accountsToUpdate;
                    }

                    isApplicantRunning = false;
                }
            }
        }
    }


    // Sets the duplicate Opportunity values for update
    private void setDuplicateOpportunity(Opportunity original, Opportunity duplicate, Account originalAccount, Account duplicateAccount, String reasonLost) {

        System.debug('###Original: ' + original);
        System.debug('###Duplicate: ' + duplicate);

        if (original != null && duplicate != null) {

            opportunitiesToUpdate.put(duplicate.Id, duplicate);
            opportunitiesToUpdate.put(original.Id, original);

            copyInfoToWinningRecord(original, duplicate); 
            copyInfoToWinningRecord(originalAccount, duplicateAccount);

            if (!isPaidOff(duplicateAccount)) {
                duplicate.StageName = 'Closed Lost - Duplicate';
            }

            // Set original record to the dup one
            duplicate.DupRefOppId__c      = original.Id;            
            duplicate.Duplicate_Reason__c = reasonLost;
            duplicate.ForecastCategoryName = 'Omitted';
            duplicate.DupRefOppLink__c     = duplicate.SalesforceInstance__c + original.Id;
            duplicate.DupRefOppCampaign__c = original.Campaign_Source__c;
            duplicate.DupRefOppAccount__c  = original.Account.Name;

            System.debug('\n\n###originalAccount: '  + originalAccount);
            System.debug('\n\n###duplicateAccount: ' + duplicateAccount);
            System.debug('\n\n###: ' + contactsForDuplicatedAccount.get(duplicate.AccountId));

            if (contactsForDuplicatedAccount.containsKey(duplicate.AccountId)){
                
                List<Contact> winningContactsList = originalAccount.getSObjects('Contacts');
                List<Contact> loosingContacts     = contactsForDuplicatedAccount.get(duplicate.AccountId);

                //Create a map to look for First and last name duplicates
                Map<String, Contact> winningContactsMap = new Map<String, Contact>();

                if (winningContactsList != null && !winningContactsList.isEmpty()) {
                    
                    for (Contact myContact : winningContactsList) {
                        
                        winningContactsMap.put(myContact.FirstName + ' ' + myContact.LastName, myContact);
                    }                    
                }

                if (loosingContacts != null && !loosingContacts.isEmpty()) {
                    
                    for (Contact myContact : loosingContacts) {
                        
                        if (winningContactsMap != null && !winningContactsMap.isEmpty()) {
                            
                            //If there is a contact with the same first and last name.                        
                            if (winningContactsMap.containsKey(myContact.FirstName + ' ' + myContact.LastName)) {
                                
                                //Copy the information form duplicate to the empty fields on the original.
                                copyInfoToWinningRecord(winningContactsMap.get(myContact.FirstName + ' ' + myContact.LastName), myContact);
                            }
                            else{
                            
                                myContact.AccountId = original.AccountId;
                                contactsToUpdate.add(myContact);
                            }    

                        }
                        else{
                        
                            myContact.AccountId = original.AccountId;
                            contactsToUpdate.add(myContact);
                        }
                    }                    
                }
            }            
        }                               
    }

    // Sets the duplicate Lead values for update
    private void setDuplicateOpportunity(Lead original, Opportunity duplicate, String reason) {

        if (original != null && duplicate != null) {
            
            // Set original record to the dup one
            duplicate.DupRefLeadId2__c      = original.Id;
            duplicate.DupRefLeadLink__c     = duplicate.SalesforceInstance__c + original.Id;
            duplicate.DupRefLeadCampaign__c = original.Campaign_Source__c;
            duplicate.DupRefLeadCompany__c  = original.Company;

            duplicate.StageName             = 'Closed Lost - Duplicate';
            duplicate.Duplicate_Reason__c   = reason;
            duplicate.ForecastCategoryName  = 'Omitted';
            
            leadsToUpdate.put(original.Id, original);

            opportunitiesToUpdate.put(duplicate.Id, duplicate);
        }         
    }


    // Sets the duplicate Lead values for update
    private void setDuplicateLead(Opportunity original, Lead duplicate, String reason) {

        if (original != null && duplicate != null) {
        
            copyInfoToWinningRecord(original, duplicate);

            // Set original record to the dup one
            duplicate.DupRefOppId__c = original.Id;
            duplicate.Status = CUSTOMER_UNQUALIFIED;
            duplicate.McaApp__Sub_Status__c = 'Duplicate';
            duplicate.Duplicate_Reason__c   = reason;
                
            leadsToUpdate.put(duplicate.Id, duplicate);
        }         
    }


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Opportunity winner, Opportunity looser){

        Map<String, Schema.SObjectField> opportunityFields = Schema.SObjectType.Opportunity.fields.getMap();

        String query = 'select Primary_Campaign__r.Name, ';

        Set<String>  fieldsSet  = opportunityFields.keySet();

        List<String> fieldsList = new List<String>(fieldsSet);

        Integer index = 1;
        
        for (Schema.SObjectField fld: opportunityFields.values()) {
            
            if (index < fieldsSet.size()) {
                
                query += fld.getDescribe().getName() + ',';
                index++;
            }
            else{
                
                query += fld.getDescribe().getName();
            }
        }

        query += ' from Opportunity where id = \'' + winner.Id + '\' or Id = \'' + looser.Id + '\' limit 2';

        system.debug('OPPORTUNITIES TO COMPARE: ' + query);        

        Opportunity[] opportunitiesToCompare = (Opportunity[]) Database.query(query);        

        for (Opportunity oppty : opportunitiesToCompare) {
            
            if (oppty.id == winner.Id) {
                
                winner = oppty;
            }
            else {
                
                looser = oppty;
            }
        }

        for (String fieldName : opportunityFields.keySet()) {
            
            if (fieldName != 'DupRefOppId__c' && opportunityCopyFields.contains(fieldName.toLowerCase())){

                if (opportunityFields.get(fieldName).getDescribe().isUpdateable() && (winner.get(fieldName) == null  || winner.get(fieldName) == '') 
                                                                              && (looser.get(fieldName) != null && looser.get(fieldName) != '')){
               
                    winner.put(fieldName, looser.get(fieldName));            
                }
            }
        }

        opportunitiesToUpdate.put(winner.Id, winner);
    }


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Account winner, Account looser){

        Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();

        String query = 'select ';

        Set<String>  fieldsSet  = accountFields.keySet();

        Integer index = 1;
        
        for (Schema.SObjectField fld: accountFields.values()) {
        
            if (index < fieldsSet.size()) {
                
                query += fld.getDescribe().getName() + ',';
                index++;
            }
            else {
                
                query += fld.getDescribe().getName();
            }
        }

        query += ' from Account where id = \'' + winner.Id + '\' or Id = \'' + looser.Id + '\' limit 2';

        system.debug('QUERY:    ' + query);

        Account[] accountsToCompare = (Account[]) Database.query(query);

        for (Account myAccount : accountsToCompare) {
            
            if (myAccount.id == winner.Id) {
                
                winner = myAccount;
            }
            else{
            
                looser = myAccount;
            }
        }

        for (String fieldName : accountFields.keySet()) {
            
            if (accountCopyFields.contains(fieldName.toLowerCase())) {

                if (accountFields.get(fieldName).getDescribe().isUpdateable() && (winner.get(fieldName) == null  || winner.get(fieldName) == '') 
                                                                              && (looser.get(fieldName) != null && looser.get(fieldName) != '')) {
                    winner.put(fieldName, looser.get(fieldName));            
                }
            }
        }

        accountsToUpdate.add(winner);
    }


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Contact winner, Contact looser){

        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();

        winner = queryContact(winner);
        looser = queryContact(looser);
        
        for (String fieldName : contactFields.keySet()) {

            if (contactCopyFields.contains(fieldName.toLowerCase())) {

                if (contactFields.get(fieldName).getDescribe().isUpdateable() && (winner.get(fieldName) == null  || winner.get(fieldName) == '')  && (looser.get(fieldName) != null && looser.get(fieldName) != '')) {
            
                    winner.put(fieldName, looser.get(fieldName));            
                }
            }
        }

        contactsToUpdate.add(winner);
    }


    private Contact queryContact(Contact record) {

        if (contactCache.containsKey(record.Id)) {
            return contactCache.get(record.Id);
        }


        String query = contactFieldsString();

        query += ' from Contact where id = \'' + record.Id + '\' limit 1';

        system.debug('OPPORTUNITIES TO COMPARE: ' + query);

        Contact[] opportunitiesToCompare = (Contact[]) Database.query(query);

        for (Contact myContact : opportunitiesToCompare) {
            
            if (myContact.id == record.Id) {
                
                contactCache.put(myContact.Id, myContact);

                return myContact;
            }
        }

        return record;
    }    


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Opportunity winner, Lead looser){
        
        if (winner.Account.McaApp__Monthly_CC_Avg_All__c == null && looser.McaApp__Average_Monthly_CC_Sale__c != null ){
            winner.Account.McaApp__Monthly_CC_Avg_All__c = looser.McaApp__Average_Monthly_CC_Sale__c;
        }

        if (winner.Account.Business_Main_Phone__c == null && looser.Business_Main_Phone__c != null ){
            winner.Account.Business_Main_Phone__c = looser.Business_Main_Phone__c;
        }

        if (winner.Account.McaApp__Gross_monthly_Sales__c == null && looser.McaApp__Monthly_Gross_Sales__c != null ){
            winner.Account.McaApp__Gross_monthly_Sales__c = looser.McaApp__Monthly_Gross_Sales__c;
        }

        if (winner.Account.McaApp__Years_in_Business__c == null && looser.McaApp__Years_in_Business__c != null ){
            winner.Account.McaApp__Years_in_Business__c = looser.McaApp__Years_in_Business__c;
        }   

        if (winner.Account.McaApp__Business_Contact_Account__c == null && looser.Business_Contact_Account__c != null ){
            winner.Account.McaApp__Business_Contact_Account__c = looser.Business_Contact_Account__c;
        } 

        if (winner.Account.Business_Contact_Account_2__c == null && looser.Business_Contact_Account_2__c != null ){
            winner.Account.Business_Contact_Account_2__c = looser.Business_Contact_Account_2__c;
        }

        if (winner.Account.Business_Contact_Account_3__c == null && looser.Business_Contact_Account_3__c != null ){
            winner.Account.Business_Contact_Account_3__c = looser.Business_Contact_Account_3__c;
        }

        if (winner.Account.McaApp__Business_Phone__c == null && looser.Business_Phone__c != null ){
            winner.Account.McaApp__Business_Phone__c = looser.Business_Phone__c;
        }

        if (winner.Account.Business_Phone_2__c == null && looser.Business_Phone_2__c != null ){
            winner.Account.Business_Phone_2__c = looser.Business_Phone_2__c;
        }

        if (winner.Account.Business_Phone_3__c == null && looser.Business_Phone_3__c != null ){
            winner.Account.Business_Phone_3__c = looser.Business_Phone_3__c;
        }

        if (winner.Account.Business_Phone_3__c == null && looser.Business_Phone_3__c != null ){
            winner.Account.Business_Phone_3__c = looser.Business_Phone_3__c;
        }

        if (winner.Account.McaApp__ConvertedAccount__c == null && looser.McaApp__Convert__c != null ){
            winner.Account.McaApp__ConvertedAccount__c = looser.McaApp__Convert__c;
        }

        if (winner.Account.McaApp__Date_Business_Established__c == null && looser.Date_Business_Established__c != null ){
            winner.Account.McaApp__Date_Business_Established__c = looser.Date_Business_Established__c;
        }
        if (winner.Account.McaApp__Federal_Tax_ID_No__c == null && looser.Federal_Tax_ID__c != null ){
            winner.Account.McaApp__Federal_Tax_ID_No__c = looser.Federal_Tax_ID__c;
        }
        if (winner.Account.McaApp__Landlord_Mortgagee__c == null && looser.Landlord_Mortgagee__c != null ){
            winner.Account.McaApp__Landlord_Mortgagee__c = looser.Landlord_Mortgagee__c;
        }
        if (winner.Account.McaApp__Landlord_Contact_Name__c == null && looser.Landlord_Contact_Name__c != null ){
            winner.Account.McaApp__Landlord_Contact_Name__c = looser.Landlord_Contact_Name__c;
        }
        if (winner.Account.McaApp__Landlord_Phone__c == null && looser.Landlord_Phone__c != null ){
            winner.Account.McaApp__Landlord_Phone__c = looser.Landlord_Phone__c;
        }
        if (winner.Account.McaApp__Monthly_Payment__c == null && looser.Monthly_Payment__c != null ){
            winner.Account.McaApp__Monthly_Payment__c = looser.Monthly_Payment__c;
        }
        if (winner.Account.McaApp__NumberofLocations__c == null && looser.McaApp__NumberofLocations__c != null ){
            winner.Account.McaApp__NumberofLocations__c = looser.McaApp__NumberofLocations__c;
        }
        if (winner.Account.State_of_Incorporation__c == null && looser.State_of_Incorporation__c != null ){
            winner.Account.State_of_Incorporation__c = looser.State_of_Incorporation__c;
        }

        // Take all fields from lead and copy to Opportunity where Opportunity field == null
        if (winner.McaApp__Credit_Score__c  == null && looser.McaApp__Credit_Score__c != null) {
            winner.McaApp__Credit_Score__c = looser.McaApp__Credit_Score__c;
        }

        if (winner.McaApp__Amount_Requested__c  == null && looser.McaApp__Desired_Amount__c != null) {
            winner.McaApp__Amount_Requested__c = looser.McaApp__Desired_Amount__c;
        }

        if (winner.McaApp__ISO__c  == null && looser.McaApp__ISO__c != null) {
            winner.McaApp__ISO__c = looser.McaApp__ISO__c;
        }

        if (winner.Primary_Campaign__c == null && looser.Original_Campaign__c != null) {
            winner.Primary_Campaign__c = looser.Original_Campaign__c;
        }

        if (winner.McaApp__Set_Opportunity_Status__c  == null && looser.McaApp__Set_Opportunity_Status__c != null) {
            winner.McaApp__Set_Opportunity_Status__c = looser.McaApp__Set_Opportunity_Status__c;
        }

        if (winner.Lead_ID__c == null && looser.Lead_ID__c != null) {
            winner.Lead_ID__c  = looser.Lead_ID__c;
        }

        if (winner.McaApp__Lead_Created_Date__c == null && looser.McaApp__Lead_Created_Date_Copy_for_Mapping__c != null) {
            winner.McaApp__Lead_Created_Date__c  = looser.McaApp__Lead_Created_Date_Copy_for_Mapping__c;
        }  

        if (winner.Monthly_Bank_Deposits__c == null && looser.Monthly_Bank_Deposits__c != null) {
            winner.Monthly_Bank_Deposits__c  = looser.Monthly_Bank_Deposits__c;
        } 

        if (winner.Monthly_CC_Batches__c == null && looser.Monthly_CC_Batches__c != null) {
            winner.Monthly_CC_Batches__c  = looser.Monthly_CC_Batches__c;
        } 

        if (winner.Monthly_CC_Tickets__c == null && looser.Monthly_CC_Tickets__c != null) {
            winner.Monthly_CC_Tickets__c  = looser.Monthly_CC_Tickets__c;
        } 


        if (winner.Monthly_CC_Transactions__c == null && looser.Monthly_CC_Transactions__c != null) {
            winner.Monthly_CC_Transactions__c  = looser.Monthly_CC_Transactions__c;
        } 

        if (winner.Monthly_NDBs__c == null && looser.Monthly_NDBs__c != null) {
            winner.Monthly_NDBs__c  = looser.Monthly_NDBs__c;
        } 

        if (winner.Monthly_NSFs__c == null && looser.Monthly_NSFs__c != null) {
            winner.Monthly_NSFs__c  = looser.Monthly_NSFs__c;
        } 

        if (winner.Collateral__c == null && looser.Collateral__c != null) {
            winner.Collateral__c  = looser.Collateral__c;
        } 

        if (winner.Collateral_Amount__c == null && looser.Collateral_Amount__c != null) {
            winner.Collateral_Amount__c  = looser.Collateral_Amount__c;
        } 

        if (winner.Collateral_Type__c == null && looser.Collateral_Type__c != null) {
            winner.Collateral_Type__c  = looser.Collateral_Type__c;
        } 

        if (winner.McaApp__Credit_Score__c == null && looser.McaApp__Credit_Score__c != null) {
            winner.McaApp__Credit_Score__c  = looser.McaApp__Credit_Score__c;
        } 

        if (winner.McaApp__Amount_Requested__c == null && looser.McaApp__Desired_Amount__c != null) {
            winner.McaApp__Amount_Requested__c  = looser.McaApp__Desired_Amount__c;
        }
        if (winner.McaApp__ISO__c == null && looser.McaApp__ISO__c != null) {
            winner.McaApp__ISO__c  = looser.McaApp__ISO__c;
        }
        if (winner.MCACE__ISO_1_Lead_Source_Sales_Rep__c == null && looser.MCACE__ISO_1_salesRep__c != null) {
            winner.MCACE__ISO_1_Lead_Source_Sales_Rep__c  = looser.MCACE__ISO_1_salesRep__c;
        }
        if (winner.MCACE__ISO_2__c == null && looser.MCACE__ISO_2__c != null) {
            winner.MCACE__ISO_2__c  = looser.MCACE__ISO_2__c;
        }
        if (winner.MCACE__ISO_2_Sales_Rep__c == null && looser.MCACE__ISO_2_Sales_Rep__c != null) {
            winner.MCACE__ISO_2_Sales_Rep__c  = looser.MCACE__ISO_2_Sales_Rep__c;
        }

        if (winner.MCACE__ISO_3__c == null && looser.MCACE__ISO_3__c != null) {
            winner.MCACE__ISO_3__c  = looser.MCACE__ISO_3__c;
        } 

        if (winner.MCACE__ISO_3_Sales_Rep__c == null && looser.MCACE__ISO_3_Sales_Rep__c != null) {
            winner.MCACE__ISO_3_Sales_Rep__c  = looser.MCACE__ISO_3_Sales_Rep__c;
        } 

        if (winner.MCACE__ISO_4__c == null && looser.MCACE__ISO_4__c != null) {
            winner.MCACE__ISO_4__c  = looser.MCACE__ISO_4__c;
        } 

        if (winner.MCACE__ISO_4_Sales_Rep__c == null && looser.MCACE__ISO_4_Sales_Rep__c != null) {
            winner.MCACE__ISO_4_Sales_Rep__c  = looser.MCACE__ISO_4_Sales_Rep__c;
        } 

        if (winner.McaApp__Sales_Rep__c == null && looser.McaApp__Sales_Rep__c != null) {
            winner.McaApp__Sales_Rep__c  = looser.McaApp__Sales_Rep__c;
        } 

        if (winner.Judgements_Liens__c == null && looser.Judgements_Liens__c != null) {
            winner.Judgements_Liens__c  = looser.Judgements_Liens__c;
        } 

        if (winner.McaApp__Lead_Created_Date__c == null && looser.McaApp__Lead_Created_Date_Copy_for_Mapping__c != null) {
            winner.McaApp__Lead_Created_Date__c  = looser.McaApp__Lead_Created_Date_Copy_for_Mapping__c;
        }
        if (winner.McaApp__Credit_Card_Sales__c == null && looser.McaApp__Average_Monthly_CC_Sale__c != null) {
            winner.McaApp__Credit_Card_Sales__c  = looser.McaApp__Average_Monthly_CC_Sale__c;
        }
        if (winner.Monthly_Debt_Service__c == null && looser.Monthly_Debt_Service__c != null) {
            winner.Monthly_Debt_Service__c  = looser.Monthly_Debt_Service__c;
        }
        if (winner.Monthly_Online_Sales__c == null && looser.Monthly_Online_Sales__c != null) {
            winner.Monthly_Online_Sales__c  = looser.Monthly_Online_Sales__c;
        }
        if (winner.Online_Sales__c == null && looser.Online_Sales__c != null) {
            winner.Online_Sales__c  = looser.Online_Sales__c;
        }

        if (winner.Open_BK__c == null && looser.Open_BK__c != null) {
            winner.Open_BK__c  = looser.Open_BK__c;
        } 

        if (winner.Peak_Months__c == null && looser.Peak_Months__c != null) {
            winner.Peak_Months__c  = looser.Peak_Months__c;
        } 

        if (winner.Previous_Financing_Type__c == null && looser.Previous_Financing_Type__c != null) {
            winner.Previous_Financing_Type__c  = looser.Previous_Financing_Type__c;
        }
        if (winner.Profitable_last_year__c == null && looser.Profitable_last_year__c != null) {
            winner.Profitable_last_year__c  = looser.Profitable_last_year__c;
        }
        if (winner.McaApp__Use_of_Proceeds__c == null && looser.McaApp__Purpose_of_Funding__c != null) {
            winner.McaApp__Use_of_Proceeds__c  = looser.McaApp__Purpose_of_Funding__c;
        }
        if (winner.Seasonal_Business__c == null && looser.Seasonal_Business__c != null) {
            winner.Seasonal_Business__c  = looser.Seasonal_Business__c;
        }
        if (winner.McaApp__Term_Requested__c == null && looser.McaApp__Term_Requested__c != null) {
            winner.McaApp__Term_Requested__c  = looser.McaApp__Term_Requested__c;
        }

        List<Contact> winningContactList = new List<Contact>();

        // Query account for contact with earliest created date where first and last name matches the first and last name of the lead. If match found, copy fields over to contact where contact field == null
        winningContactList = [select id, Title, Email, Authorize_Run_Credit__c, Birthdate_for_Workflow__c, Home_Address_City_for_Workflow__c, Home_Address_for_Workflow__c, Home_Address_State_for_Workflow__c, Home_Address_Zip_for_Workflow__c, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, pi__campaign__c, pi__comments__c, pi__conversion_date__c, pi__conversion_object_name__c, pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, pi__first_touch_url__c, pi__first_search_term__c, pi__first_search_type__c, pi__grade__c, pi__pardot_hard_bounced__c, pi__last_activity__c, pi__notes__c, pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Opportunity_Id__c  from Contact where AccountId =: winner.AccountId and FirstName =: looser.FirstName and LastName =: looser.LastName order by CreatedDate desc limit 1];

        if(winningContactList != null && !winningContactList.isEmpty()){
            Contact winningContact = winningContactList[0];

            if(winningContact != null){
                if(winningContact.Authorize_Run_Credit__c == null && looser.Authorize_Run_Credit__c != null){
                    winningContact.Authorize_Run_Credit__c = looser.Authorize_Run_Credit__c;
                }

                if(winningContact.Birthdate_for_Workflow__c == null && looser.Owner_1_Birthdate__c != null){
                    winningContact.Birthdate_for_Workflow__c = looser.Owner_1_Birthdate__c;
                }

                if(winningContact.Home_Address_City_for_Workflow__c == null && looser.Owner_1_Home_Address_City__c != null){
                    winningContact.Home_Address_City_for_Workflow__c = looser.Owner_1_Home_Address_City__c;
                }

                if(winningContact.Home_Address_for_Workflow__c == null && looser.Owner_1_Home_Address__c != null){
                    winningContact.Home_Address_for_Workflow__c = looser.Owner_1_Home_Address__c;
                }

                if(winningContact.Home_Address_State_for_Workflow__c == null && looser.Owner_1_Home_Address_State__c != null){
                    winningContact.Home_Address_State_for_Workflow__c = looser.Owner_1_Home_Address_State__c;
                }

                if(winningContact.Home_Address_Zip_for_Workflow__c == null && looser.Owner_1_Home_Address_Zip__c != null){
                    winningContact.Home_Address_Zip_for_Workflow__c  = looser.Owner_1_Home_Address_Zip__c;
                }

                if(winningContact.McaApp__Of_Ownership__c == null && looser.Owner_1_Ownership__c != null){
                    winningContact.McaApp__Of_Ownership__c = looser.Owner_1_Ownership__c;
                }

                if(winningContact.McaApp__Social_Security_Number1__c == null && looser.McaApp__Social_Security_Number__c != null){
                    winningContact.McaApp__Social_Security_Number1__c = looser.McaApp__Social_Security_Number__c;
                }

                contactsToUpdate.add(winningContact);
            }
        }
        
    }


    // Returns the Funded Opp for the specified Account
    private Opportunity getFundedOpportunity(Account account) {

        if (account.Opportunities != null) {

            for (Opportunity opp : account.Opportunities) {

                if (opp.McaApp__Funded__c) {

                    return opp;
                }
            }
        }

        return null;
    }


    // Returns the Opportunity with any of the specified Stages
    private Opportunity getOpportunityWithStage(Account account, Set<String> stages) {

        if (account.Opportunities != null) {

            for (Opportunity opp : account.Opportunities) {

                if (stages.contains(opp.StageName)) {

                    return opp;
                }
            }
        }

        return null;
    }


    // Returns the Opportunity with Contracted Category
    private Opportunity getContractedOpportunity(Account account) {
        return getOpportunityWithStage(account, new Set<String>{ 'Agreement Sent', 'Agreement Signed' });
    }


    // Returns the Opportunity with Submitted Category
    private Opportunity getSubmittedOpportunity(Account account) {
        return getOpportunityWithStage(account, new Set<String>{ 'Application In', 'Underwriting', 'Approved', 'Agreement Requested' });
    }


    // Returns the Opportunity with App'd Opp Category
    private Opportunity getAppdOpportunity(Account account) {
        return getOpportunityWithStage(account, new Set<String>{ 'Application Sent', 'Application Missing Info' });
    }


    // Returns the Opportunity with Dead Category
    private Opportunity getDeadOpportunity(Account account) {
        return getOpportunityWithStage(account, new Set<String>{ 'Declined', 'Closed Lost', 'Closed Lost - Merchant', 'Closed Lost - Funding Source' });
    }


    // Returns true if the specified Account has a Funded and PaidOff Opportunity 
    private Boolean isPaidOff(Account matchingAccount) {

        Opportunity fundedOpportunity = getFundedOpportunity(matchingAccount);

        if (fundedOpportunity != null) {

            if (fundedOpportunity.Paid_Off__c && fundedOpportunity.Paid_Off_60_Days_Ago__c)  {

                return true;
            }
        }

        return false;
    }    


    // Returns the Applicant Opp for the specified Account
    private Opportunity getProspectOpportunity(Account account) {

        if (account.Opportunities != null) {

            for (Opportunity opp : account.Opportunities) {

                return opp;
            }
        }

        return null;
    }

    private String getAccountsQuery(Set<Id> accountIdsSet) {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());
        String opportunitiesAuxQuery = opptiesQueryAux();
        String contactsAuxQuery      = contactsQueryAux();

        String query = 'select Id, Account_Dedupe_Key__c, Account_Phones__c, Opportunity_Stage_Category__c, ' + opportunitiesAuxQuery + ',' + contactsAuxQuery + ',' + String.join(phoneFields, ',') + ' from Account where Flagged_for_Duplicate_Review__c = false and (Opportunity_Stage_Category__c = \'Apped Opp\' or Opportunity_Stage_Category__c = \'Dead Opp\' or Opportunity_Stage_Category__c = \'Submitted Opp\' or Opportunity_Stage_Category__c = \'Contracted Opp\'or Opportunity_Stage_Category__c = \'Funded Opp\') AND (Id = null';

        for (Account account : accounts) {

            for (String phoneField : phoneFields) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));
                    
                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');

                        
                        query += ' OR Account_Phones__c like \'%' + phone + '%\'';
                    }
                }

                if (account.Contacts != null) {

                    for (Contact contact : account.Contacts) {

                        for (String contactPhoneField : contactPhoneFields) {

                            if (contact.get(contactPhoneField) != null) {

                                String contactPhone = String.valueOf(contact.get(contactPhoneField));
                                
                                if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                                    contactPhone = contactPhone.replace(' ', '')
                                                               .replace(')', '')
                                                               .replace('(', '')
                                                               .replace('-', '')
                                                               .replace('+', '');

                                    query += ' OR Account_Phones__c like \'%' + contactPhone + '%\'';
                                }
                            }                            
                        }
                    }
                }                
            }
        }

        if (!accountIdsSet.isEmpty()) {
            
            for (String myAccountId : accountIdsSet) {
                
                query += ' OR id =\'' + myAccountId + '\'';
            }
        }        

        query += ')';    

        system.debug('ACCOUNTS QUERY:   ' + query);

        return query;
    }


    private String getLeadsQuery() {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();

        String query = 'select Original_Campaign__r.Name, ' ;

        Set<String>  leadsFieldsSet  = leadFields.keySet();

        List<String> leadsFieldsList = new List<String>(leadsFieldsSet);

        Integer index = 1;
        
        for (Schema.SObjectField fld: leadFields.values()) {
            
            if (index < leadsFieldsSet.size()) {
                
                query += fld.getDescribe().getName() + ',';
                index++;
            }
            else{
                
               query += fld.getDescribe().getName();
            }   
        }

        query += ' from Lead where IsConverted = false AND McaApp__Sub_Status__c <> ' + '\'' +  REASON_LOST_DUPLICATE + '\''  + 'AND (Id = null ';

        for (String phoneField : phoneFields) {

            for (Account account : accounts) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));

                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');


                        query += ' OR Lead_Phones__c like \'%' + phone + '%\'';
                    }
                }

                if (account.Contacts != null) {

                    for (Contact contact : account.Contacts) {

                        for (String contactPhoneField : contactPhoneFields) {

                            if (contact.get(contactPhoneField) != null) {

                                String contactPhone = String.valueOf(contact.get(contactPhoneField));

                                if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                                    contactPhone = contactPhone.replace(' ', '')
                                                               .replace(')', '')
                                                               .replace('(', '')
                                                               .replace('-', '')
                                                               .replace('+', '');

                                    query += ' OR Lead_Phones__c like \'%' + contactPhone + '%\'';

                                }
                            }                            
                        }
                    }
                }                
            }
        }

        query += ')';

        system.debug('LEADS QUERY:  ' + query);

        return query;
    }    


    private String[] getObjectPhoneFields(Map<String,Schema.SObjectField> objectFields) {

        String[] phoneFields = new String[]{};

        for (String fieldName : objectFields.keySet()) {
            
            Schema.DescribeFieldResult fieldInfo = objectFields.get(fieldName).getDescribe();
            
            if (fieldInfo.getType() == Schema.DisplayType.PHONE) {
                
                phoneFields.add(fieldName);
            }
        }

        return phoneFields;
    }


    private static Map<String, String[]> objectPhonesCache = new Map<String, String[]>();


    private Boolean containsAnyPhone(Account account, Account matchingAccount) {
        boolean result = false;
        
        String[] phoneFields; 

        if (objectPhonesCache.containsKey('Account')) {
            phoneFields = objectPhonesCache.get('Account');
        }
        else {
            phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
            objectPhonesCache.put('Account', phoneFields);
        }
        
        String[] contactPhoneFields;

        if (objectPhonesCache.containsKey('Contact')) {
            contactPhoneFields = objectPhonesCache.get('Contact');
        }
        else {
            contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());
            objectPhonesCache.put('Contact', contactPhoneFields);
        }


        //Check if there is an Account with the same phone.
        for (String phoneField : phoneFields) {

            if (phoneField != null && matchingAccount.Account_Phones__c != null) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));
                    
                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');

                        if (matchingAccount.Account_Phones__c != null && matchingAccount.Account_Phones__c.contains(phone)) {

                            System.debug('\n\n###account: ' + account.Id);
                            System.debug('\n\n###account: ' + phone);
                            System.debug('\n\n###matchingAccount: ' + matchingAccount.Id);
                            System.debug('\n\n###matchingAccount: ' + matchingAccount.Account_Phones__c);
                            System.debug('\n\n###matchingAccount: ' + matchingAccount.Opportunity_Stage_Category__c);

                            return true;
                        }
                    }
                }
            }
        }

        //Check only if was is no match already 
        if (!result) {

            // As there is no matching Account will have to check with the Contacts.
            List<Contact> myContactsList = matchingAccount.getSObjects('Contacts');

            // Check matchingAcocunbts.Contacts to check the phone
            for (String phoneField : phoneFields) {
                
                if (myContactsList != null && !myContactsList.isEmpty()){
                    
                    for (Contact myContact : myContactsList) {
                        
                        if (!String.isEmpty(phoneField) && !String.isEmpty(myContact.Contact_Phones__c)) {
                            
                            if (account.get(phoneField) != null) {

                                String phone = String.valueOf(account.get(phoneField));

                                if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                                    phone = phone.replace(' ', '')
                                                 .replace(')', '')
                                                 .replace('(', '')
                                                 .replace('-', '')
                                                 .replace('+', '');

                                    if (myContact.Contact_Phones__c.contains(phone)) {
                                       
                                       result = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (!result) {

            // Compare triggering account Contacts with matchingAccount
            for (Contact contact : account.Contacts) {

                for (String contactPhoneField : contactPhoneFields) {

                    if (contact.get(contactPhoneField) != null) {

                        String contactPhone = String.valueOf(contact.get(contactPhoneField));

                        if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                            contactPhone = contactPhone.replace(' ', '')
                                                       .replace(')', '')
                                                       .replace('(', '')
                                                       .replace('-', '')
                                                       .replace('+', '');

                            if (matchingAccount.Account_Phones__c != null && matchingAccount.Account_Phones__c.contains(contactPhone)) {
                                
                                result = true;
                            }
                        }
                    }
                }
            }
        }        

        if (!result) {

            // Compare trigger account Contacts with matchingAccount Contacts
            for (Contact contact : account.Contacts) {

                for (String contactPhoneField : contactPhoneFields) {

                    if (contact.get(contactPhoneField) != null) {

                        String contactPhone = String.valueOf(contact.get(contactPhoneField));

                        if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                            contactPhone = contactPhone.replace(' ', '')
                                                       .replace(')', '')
                                                       .replace('(', '')
                                                       .replace('-', '')
                                                       .replace('+', '');

                            
                            List<Contact> matchingContacts = matchingAccount.getSObjects('Contacts');

                            if (matchingContacts != null) {

                                for (Contact matchingContact : matchingContacts) {                                                   

                                    if (matchingContact.Contact_Phones__c != null && matchingContact.Contact_Phones__c.contains(contactPhone)) {
                                        
                                        result = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }            
        }           

        return result;
    }


    private Boolean containsAnyPhone(Account account, Lead matchingLead) {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        for (String phoneField : phoneFields) {

            if (phoneField != null && matchingLead.Lead_Phones__c != null) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));

                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');

                        if (matchingLead.Lead_Phones__c.contains(phone)) {

                            return true;
                        }
                    }
                }
            }
        }


        // Compare triggering account Contacts with matchingLead
        if (account.Contacts != null) {
            
            for (Contact contact : account.Contacts) {

                for (String contactPhoneField : contactPhoneFields) {

                    if (contactPhoneField != null && matchingLead.Lead_Phones__c != null) {

                        String contactPhone = String.valueOf(contact.get(contactPhoneField));

                        if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                            contactPhone = contactPhone.replace(' ', '')
                                                       .replace(')', '')
                                                       .replace('(', '')
                                                       .replace('-', '')
                                                       .replace('+', '');

                            if (matchingLead.Lead_Phones__c.contains(contactPhone)) {

                                return true;
                            }         
                        }               
                    }                    
                }
            }
        }         

        return false;
    }


    // Compares Accounts against Funded Accounts/Opportunities in the system
    private Boolean compareFundedOpp(Account[] matchingAccounts) {

        for (Account account : accounts) {
            
            for (Account matchingAccount : matchingAccounts) {
            
                if (account.Id != matchingAccount.Id) {
                        
                    System.debug('###containsAnyPhone: ' + containsAnyPhone(account, matchingAccount));
                    System.debug('###Opportunity_Stage_Category__c: ' + matchingAccount.Opportunity_Stage_Category__c);
                    System.debug('###Opportunity_Stage_Category__c: ' + (matchingAccount.Opportunity_Stage_Category__c == 'Funded Opp'));

                    if (containsAnyPhone(account, matchingAccount) && matchingAccount.Opportunity_Stage_Category__c == 'Funded Opp') {

                        System.debug('###Account: ' + account);
                        System.debug('###MatchingAccount: ' + matchingAccount);

                        //System.assert(false, new String[]{ account.Id, matchingAccount.Id });

                        System.debug('###isPaidOff: ' + isPaidOff(matchingAccount));

                        if (isPaidOff(matchingAccount)) {

                            System.debug('#Funded Duplicate');

                            // Set the Funded Opp as duplicate to the Applicant Opp
                            setDuplicateOpportunity(getProspectOpportunity(account), getFundedOpportunity(matchingAccount), account, matchingAccount, 'Funded Opportunity paid off for more than 60 days.');
                        }
                        else {

                            System.debug('#App Duplicate');

                            // Set the Applicant Opp as duplicate to the Funded Opp
                            setDuplicateOpportunity(getFundedOpportunity(matchingAccount), getProspectOpportunity(account), matchingAccount, account, 'Matched to Funded Opportunity');
                        }

                        return true;                    
                    }
                }
            }
        }

        return false;
    }

    
    private Boolean compareContractedOpp(Account[] matchingAccounts) {

        for (Account account : accounts) {
            
            for (Account matchingAccount : matchingAccounts) {
            
                if (account.Id != matchingAccount.Id) {
            
                    if (containsAnyPhone(account, matchingAccount) && matchingAccount.Opportunity_Stage_Category__c == 'Contracted Opp') {

                        // Flag Applicant Opp as Duplicate to the Contracted Opp
                        setDuplicateOpportunity(getContractedOpportunity(matchingAccount), getProspectOpportunity(account), matchingAccount, account, 'Matched to Contracted Opportunity');

                        return true;                    
                    }
                }
            }
        }

        return false;
    }


    private Boolean compareSubmittedOpp(Account[] matchingAccounts) {

        for (Account account : accounts) {

            for (Account matchingAccount : matchingAccounts) {

                if (account.Id != matchingAccount.Id) {
                
                    if (containsAnyPhone(account, matchingAccount) && matchingAccount.Opportunity_Stage_Category__c == 'Submitted Opp') {

                        // Flag Applicant Opp as Duplicate to the Submitted Opp
                        setDuplicateOpportunity(getSubmittedOpportunity(matchingAccount), getProspectOpportunity(account), matchingAccount, account, 'Matched to Submitted Opportunity');

                        return true;  
                    }
                }
            }
        }

        return false;
    }


    private Boolean compareAccountsWithPhones() {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());
        
        String contactsQuery =         contactFieldsString();
        
        contactsQuery += ' from Contact where (Account.Opportunity_Stage_Category__c = \'Apped Opp\' or Account.Opportunity_Stage_Category__c = \'Dead Opp\' or Account.Opportunity_Stage_Category__c = \'Submitted Opp\' or Account.Opportunity_Stage_Category__c = \'Contracted Opp\'or Account.Opportunity_Stage_Category__c = \'Funded Opp\') AND (Id = null ';


        for (String phoneField : phoneFields) {

            for (Account account : accounts) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));
                    
                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {
                    
                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');

                        contactsQuery += ' OR Contact_Phones__c like \'%' + phone + '%\'';
                    }

                }

                if (account.Contacts != null) {

                    for (Contact contact : account.Contacts) {

                        for (String contactPhoneField : contactPhoneFields) {

                            if (contact.get(contactPhoneField) != null) {

                                String contactPhone = String.valueOf(contact.get(contactPhoneField));

                                if (contactPhone != null && contactPhones.contains(contactPhoneField.toLowerCase())) {

                                    contactPhone = contactPhone.replace(' ', '')
                                                               .replace(')', '')
                                                               .replace('(', '')
                                                               .replace('-', '')
                                                               .replace('+', '');

                                    contactsQuery += ' OR Contact_Phones__c like \'%' + contactPhone + '%\'';
                                }
                            }                            
                        }
                    }
                }                
            }
        }

        contactsQuery += ')';

        system.debug('CONTACTS QUERY:   ' + contactsQuery);

        List<Contact> matchedContactsList = new List<Contact>((List<Contact>) Database.query(contactsQuery));

        Set<Id> accountsIds = new Set<id>();

        for (Contact currentContact : matchedContactsList){
            
            accountsIds.add(currentContact.AccountId);
        }

        String query = getAccountsQuery(accountsIds);

        System.debug('\n\n###QUERY: ' + query);
        System.debug('\n\n###HEAP: ' + Limits.getHeapSize());

        Account[] matchingAccounts = new Account[]{};

        
        for (Account aux : (Account[]) Database.query(query)) {
            matchingAccounts.add(aux);
        }


        if (!matchingAccounts.isEmpty()) {

            //Put all the contacts for each account to move them in case the account is a duplicate.
            for (Account myAccount : matchingAccounts){
                
                List<Contact> myContactsList = myAccount.getSObjects('Contacts');

                if (myContactsList != null && !myContactsList.isEmpty()) {
                    
                    contactsForDuplicatedAccount.put(myAccount.id, myContactsList);                    
                }
            }


            if (compareFundedOpp(matchingAccounts)) {
                
                return true;
            }
            else if (compareContractedOpp(matchingAccounts)) {
                
                return true;
            }
            else if (compareSubmittedOpp(matchingAccounts)) {
                
                return true;
            }else if (compareAppdOpp(matchingAccounts)) {
             
                return true;
            }
            else if (compareDeadOpp(matchingAccounts)) {

                return true;
            }
        }

        return false;
    }


    private Boolean compareAppdOpp(Account[] matchingAccounts) {
        
        for (Account account : accounts) {
            for (Account matchingAccount : matchingAccounts) {
                if (account.Id != matchingAccount.Id) {
                    if (matchingAccount.Opportunity_Stage_Category__c == 'Apped Opp' && containsAnyPhone(account, matchingAccount)) {                        
                        List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                        Opportunity oppty = myOpportunities[0];
                        
                        // Dead Opp > 14 days?
                        if ((oppty.Application_Missing_Info_Date_Time__c < system.today() - 14 && oppty.StageName == 'Application Missing Info') || (oppty.Application_Sent_Date_Time__c < system.today() - 14 && oppty.StageName == 'Application Sent')){                                // Flag Add'd Opp as duplicate to the Applicant Opp
                            setDuplicateOpportunity(getProspectOpportunity(account), getAppdOpportunity(matchingAccount), account, matchingAccount, 'Application Timed Out');
                            
                            return true;  
                        }else{
                            
                            setDuplicateOpportunity(getAppdOpportunity(matchingAccount), getProspectOpportunity(account), matchingAccount, account, 'Matched to recent Application');
                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }


    private Boolean compareDeadOpp(Account[] matchingAccounts) {
        
        for (Account account : accounts) {
            for (Account matchingAccount : matchingAccounts) {
                if (account.Id != matchingAccount.Id) {
                    if (matchingAccount.Opportunity_Stage_Category__c == 'Dead Opp' && containsAnyPhone(account, matchingAccount)) {
                        List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                        Opportunity oppty = myOpportunities[0];                                          
                        
                        // Dead Opp > 14 days?
                        if (oppty.Declined_Date_Time__c < system.today() - 14 && oppty.stageName == 'Declined' || oppty.Closed_Lost_Merchant_Date_Time__c < system.today() - 14 && oppty.StageName == 'Closed Lost - Merchant'|| oppty.Closed_Lost_Funding_Source_Date_Time__c < system.today() - 14 && oppty.StageName == 'Closed Lost - Funding Source'){

                            // Flag Dead Opp as duplicate to the Applicant Opp
                            setDuplicateOpportunity(getProspectOpportunity(account), getDeadOpportunity(matchingAccount), account, matchingAccount, 'Dead Opp Timed Out');

                            return true;        
                        }else{

                            setDuplicateOpportunity(getDeadOpportunity(matchingAccount), getProspectOpportunity(account), matchingAccount, account, 'Matched to recent Dead Opportunity');

                            return true;        
                        }
                    }
                }
            }
        }

        return false;
    }


    private Boolean compareLeadsWithPhones() {
        
        String query = getLeadsQuery();

        Lead[] matchingLeads = Database.query(query);

        if (!matchingLeads.isEmpty()) {

            if (compareActiveLeads(matchingLeads)) {

                return true;
            }
            else if (compareInactiveLeads(matchingLeads)) {

                return true;
            }
        }

        return false;
    }


    private Boolean compareActiveLeads(Lead[] matchingLeads) {
        
        for (Account account : accounts) {
            
            for (Lead matchingLead : matchingLeads) {
                
                if (matchingLead.Lead_Status_Category__c == 'Active' && containsAnyPhone(account, matchingLead)) {
                    
                    List<Opportunity> myOpportunities = account.getSObjects('Opportunities');
                    Opportunity oppty = myOpportunities[0];
                    List<Contact> matchingContactsList = account.getSObjects('Contacts');
                    
                    Date fourteenDaysAgo = Date.today().addDays(-14);

                    if (matchingLead.Working_Contacted_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Working - Contacted' || matchingLead.Open_Attempting_Contact_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Open - Attempting Contact' || matchingLead.Open_Not_Contacted_Date_Time__c < fourteenDaysAgo && matchingLead.Status == 'Open - Not Contacted' ){

                        // Flag Active Lead as duplicate to the Applicant Opp
                        setDuplicateLead(getProspectOpportunity(account), matchingLead, 'Active Lead Timed Out');
                        
                    } 
                    else {
                        
                        // Copy losing Lead info to winning Oppty
                        copyInfoToWinningRecord(matchingLead,matchingContactsList, oppty, account);

                        setDuplicateOpportunity(matchingLead,getProspectOpportunity(account), 'Matched to recent Active Lead');
                    }
                    
                    return true;
                }
            }
        }

        return false;
    }


    private Boolean compareInactiveLeads(Lead[] matchingLeads) {        
        for (Account account : accounts) {
            for (Lead matchingLead : matchingLeads) {
                if (matchingLead.Lead_Status_Category__c == 'Inactive' && containsAnyPhone(account, matchingLead)) {
                    List<Opportunity> myOpportunities = account.getSObjects('Opportunities');
                    Opportunity oppty = myOpportunities[0];
                    List<Contact> matchingContactsList = account.getSObjects('Contacts');

                    Date fourteenDaysAgo = Date.today().addDays(-14);

                    if (matchingLead.Closed_Lost_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Closed - Lost' || matchingLead.Closed_Future_Client_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Closed - Future Client' || matchingLead.Closed_Converted_Date_Time__c < fourteenDaysAgo && matchingLead.Status == 'Closed - Converted'){

                        // Copy losing Lead info to winning Oppty
                        copyInfoToWinningRecord(matchingLead,matchingContactsList, oppty, account);

                        // Flag Inactive Lead as duplicate to the Applicant Opp
                        setDuplicateLead(getProspectOpportunity(account), matchingLead, 'Inactive Lead Timed Out');
                    
                    }else{
                        setDuplicateOpportunity(matchingLead,getProspectOpportunity(account),'Matched to recent Inactive Lead');
                    }

                    return true;  
                }
            }
        }

        return false;
    }    



    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Lead winner, List<Contact> loosercontacts,Opportunity looser, Account looserAccount){

        boolean found = false;
        Integer index = 0;

        if(loosercontacts != null && !loosercontacts.isEmpty()){
            while(index < loosercontacts.size() && !found){
                Contact duplicatedContact = loosercontacts[index];
                        
                if(duplicatedContact.FirstName == winner.FirstName &&  duplicatedContact.LastName == winner.LastName){
                    if(duplicatedContact.Authorize_Run_Credit__c != null && winner.Authorize_Run_Credit__c == null)                   
                        winner.Authorize_Run_Credit__c = duplicatedContact.Authorize_Run_Credit__c ;

                    if(duplicatedContact.Birthdate_for_Workflow__c != null && winner.Owner_1_Birthdate__c == null)
                        winner.Owner_1_Birthdate__c = duplicatedContact.Birthdate_for_Workflow__c;
                
                    if(duplicatedContact.Home_Address_City_for_Workflow__c != null && winner.Owner_1_Home_Address_City__c == null)               
                        winner.Owner_1_Home_Address_City__c = duplicatedContact.Home_Address_City_for_Workflow__c;

                    if(duplicatedContact.Home_Address_for_Workflow__c != null && winner.Owner_1_Home_Address__c == null)
                        winner.Owner_1_Home_Address__c = duplicatedContact.Home_Address_for_Workflow__c;

                    if(duplicatedContact.Home_Address_State_for_Workflow__c != null && winner.Owner_1_Home_Address_State__c == null)
                        winner.Owner_1_Home_Address_State__c = duplicatedContact.Home_Address_State_for_Workflow__c;

                    if(duplicatedContact.Home_Address_Zip_for_Workflow__c != null && winner.Owner_1_Home_Address_Zip__c == null)
                        winner.Owner_1_Home_Address_Zip__c = duplicatedContact.Home_Address_Zip_for_Workflow__c;

                    if(duplicatedContact.McaApp__Of_Ownership__c != null && winner.Owner_1_Ownership__c == null)
                        winner.Owner_1_Ownership__c = duplicatedContact.McaApp__Of_Ownership__c;

                    if(duplicatedContact.McaApp__Social_Security_Number1__c != null && winner.McaApp__Social_Security_Number__c == null)                     
                        winner.McaApp__Social_Security_Number__c = duplicatedContact.McaApp__Social_Security_Number1__c;

                    found = true;
                }else{
                    index++;
                }
            }
        }
        
        if (looser.Account.McaApp__Monthly_CC_Avg_All__c != null && winner.McaApp__Average_Monthly_CC_Sale__c == null )
            winner.McaApp__Average_Monthly_CC_Sale__c = looser.Account.McaApp__Monthly_CC_Avg_All__c;

        if (looser.Account.Business_Main_Phone__c != null && winner.Business_Main_Phone__c == null )
            winner.Business_Main_Phone__c = looser.Account.Business_Main_Phone__c;

        if (looser.Account.McaApp__Gross_monthly_Sales__c != null && winner.McaApp__Monthly_Gross_Sales__c == null )
            winner.McaApp__Monthly_Gross_Sales__c = looser.Account.McaApp__Gross_monthly_Sales__c;

        if (looser.Account.McaApp__Years_in_Business__c != null && winner.McaApp__Years_in_Business__c == null )
            winner.McaApp__Years_in_Business__c = looser.Account.McaApp__Years_in_Business__c;

        if (looser.Account.McaApp__Business_Contact_Account__c != null && winner.Business_Contact_Account__c == null )
            winner.Business_Contact_Account__c = looser.Account.McaApp__Business_Contact_Account__c;

        if (looser.Account.Business_Contact_Account_2__c != null && winner.Business_Contact_Account_2__c == null )
            winner.Business_Contact_Account_2__c = looser.Account.Business_Contact_Account_2__c;

        if (looser.Account.Business_Contact_Account_3__c != null && winner.Business_Contact_Account_3__c == null )
            winner.Business_Contact_Account_3__c = looser.Account.Business_Contact_Account_3__c;

        if (looser.Account.McaApp__Business_Phone__c != null && winner.Business_Phone__c == null )
            winner.Business_Phone__c  = looser.Account.McaApp__Business_Phone__c;

        if (looser.Account.Business_Phone_2__c != null && winner.Business_Phone_2__c == null )
            winner.Business_Phone_2__c = looser.Account.Business_Phone_2__c;

        if (looser.Account.Business_Phone_3__c != null && winner.Business_Phone_3__c == null )
            winner.Business_Phone_3__c = looser.Account.Business_Phone_3__c;

        if (looser.Account.Business_Phone_3__c != null && winner.Business_Phone_3__c == null )
            winner.Business_Phone_3__c = looser.Account.Business_Phone_3__c;

        if (looser.Account.McaApp__ConvertedAccount__c != null && winner.McaApp__Convert__c == null )
            winner.McaApp__Convert__c = looser.Account.McaApp__ConvertedAccount__c;

        if (looser.Account.McaApp__Date_Business_Established__c != null && winner.Date_Business_Established__c == null )
            winner.Date_Business_Established__c = looser.Account.McaApp__Date_Business_Established__c;

        if (looser.Account.McaApp__Federal_Tax_ID_No__c != null && winner.Federal_Tax_ID__c == null )
            winner.Federal_Tax_ID__c = looser.Account.McaApp__Federal_Tax_ID_No__c;

        if (looser.Account.McaApp__Landlord_Mortgagee__c != null && winner.Landlord_Mortgagee__c == null )
            winner.Landlord_Mortgagee__c = looser.Account.McaApp__Landlord_Mortgagee__c;

        if (looser.Account.McaApp__Landlord_Contact_Name__c != null && winner.Landlord_Contact_Name__c == null )
            winner.Landlord_Contact_Name__c = looser.Account.McaApp__Landlord_Contact_Name__c;

        if (looser.Account.McaApp__Landlord_Phone__c != null && winner.Landlord_Phone__c == null )
            winner.Landlord_Phone__c = looser.Account.McaApp__Landlord_Phone__c;

        if (looser.Account.McaApp__Monthly_Payment__c != null && winner.Monthly_Payment__c == null )
            winner.Monthly_Payment__c = looser.Account.McaApp__Monthly_Payment__c;

        if (looser.Account.McaApp__NumberofLocations__c != null && winner.McaApp__NumberofLocations__c == null )
            winner.McaApp__NumberofLocations__c = looser.Account.McaApp__NumberofLocations__c;

        if (looser.Account.State_of_Incorporation__c != null && winner.State_of_Incorporation__c == null )
            winner.State_of_Incorporation__c = looser.Account.State_of_Incorporation__c;

        if (looser.McaApp__Credit_Score__c  != null && winner.McaApp__Credit_Score__c == null)
            winner.McaApp__Credit_Score__c = looser.McaApp__Credit_Score__c;

        if (looser.McaApp__Amount_Requested__c  != null && winner.McaApp__Desired_Amount__c == null)
            winner.McaApp__Desired_Amount__c = looser.McaApp__Amount_Requested__c;

        if (looser.McaApp__ISO__c  != null && winner.McaApp__ISO__c == null)
            winner.McaApp__ISO__c = looser.McaApp__ISO__c;

        if (looser.Primary_Campaign__c != null && winner.Original_Campaign__c == null)
            winner.Original_Campaign__c = looser.Primary_Campaign__c;

        if (looser.McaApp__Set_Opportunity_Status__c  != null && winner.McaApp__Set_Opportunity_Status__c == null)
            winner.McaApp__Set_Opportunity_Status__c = looser.McaApp__Set_Opportunity_Status__c;

        if (looser.Lead_ID__c != null && winner.Lead_ID__c == null)
            winner.Lead_ID__c = looser.Lead_ID__c;

        if (looser.McaApp__Lead_Created_Date__c != null && winner.McaApp__Lead_Created_Date_Copy_for_Mapping__c == null)
            winner.McaApp__Lead_Created_Date_Copy_for_Mapping__c = looser.McaApp__Lead_Created_Date__c;

        if (looser.Monthly_Bank_Deposits__c != null && winner.Monthly_Bank_Deposits__c == null)
            winner.Monthly_Bank_Deposits__c = looser.Monthly_Bank_Deposits__c;

        if (looser.Monthly_CC_Batches__c != null && winner.Monthly_CC_Batches__c == null)
            winner.Monthly_CC_Batches__c = looser.Monthly_CC_Batches__c;

        if (looser.Monthly_CC_Tickets__c != null && winner.Monthly_CC_Tickets__c == null)
            winner.Monthly_CC_Tickets__c = looser.Monthly_CC_Tickets__c;

        if (looser.Monthly_CC_Transactions__c != null && winner.Monthly_CC_Transactions__c == null)
            winner.Monthly_CC_Transactions__c = looser.Monthly_CC_Transactions__c;

        if (looser.Monthly_NDBs__c != null && winner.Monthly_NDBs__c == null)
            winner.Monthly_NDBs__c = looser.Monthly_NDBs__c;

        if (looser.Monthly_NSFs__c != null && winner.Monthly_NSFs__c == null)
            winner.Monthly_NSFs__c = looser.Monthly_NSFs__c;

        if (looser.Collateral__c != null && winner.Collateral__c == null)
            winner.Collateral__c = looser.Collateral__c;

        if (looser.Collateral_Amount__c != null && winner.Collateral_Amount__c == null)
            winner.Collateral_Amount__c = looser.Collateral_Amount__c;

        if (looser.Collateral_Type__c != null && winner.Collateral_Type__c == null)
            winner.Collateral_Type__c = looser.Collateral_Type__c;

        if (looser.McaApp__Credit_Score__c != null && winner.McaApp__Credit_Score__c == null)
            winner.McaApp__Credit_Score__c = looser.McaApp__Credit_Score__c;

        if (looser.McaApp__Amount_Requested__c != null && winner.McaApp__Desired_Amount__c == null)
            winner.McaApp__Desired_Amount__c = looser.McaApp__Amount_Requested__c;
        
        if (looser.McaApp__ISO__c != null && winner.McaApp__ISO__c == null) 
            winner.McaApp__ISO__c = looser.McaApp__ISO__c;
        
        if (looser.MCACE__ISO_1_Lead_Source_Sales_Rep__c != null && winner.MCACE__ISO_1_salesRep__c == null)
            winner.MCACE__ISO_1_salesRep__c = looser.MCACE__ISO_1_Lead_Source_Sales_Rep__c;
        
        if (looser.MCACE__ISO_2__c != null && winner.MCACE__ISO_2__c == null)
            winner.MCACE__ISO_2__c = looser.MCACE__ISO_2__c;

        if (looser.MCACE__ISO_2_Sales_Rep__c != null && winner.MCACE__ISO_2_Sales_Rep__c == null)
            winner.MCACE__ISO_2_Sales_Rep__c = looser.MCACE__ISO_2_Sales_Rep__c;

        if (looser.MCACE__ISO_3__c != null && winner.MCACE__ISO_3__c == null)
            winner.MCACE__ISO_3__c = looser.MCACE__ISO_3__c;

        if (looser.MCACE__ISO_3_Sales_Rep__c != null && winner.MCACE__ISO_3_Sales_Rep__c == null)
            winner.MCACE__ISO_3_Sales_Rep__c = looser.MCACE__ISO_3_Sales_Rep__c;

        if (looser.MCACE__ISO_4__c != null && winner.MCACE__ISO_4__c == null)
            winner.MCACE__ISO_4__c = looser.MCACE__ISO_4__c;

        if (looser.MCACE__ISO_4_Sales_Rep__c != null && winner.MCACE__ISO_4_Sales_Rep__c == null)
            winner.MCACE__ISO_4_Sales_Rep__c = looser.MCACE__ISO_4_Sales_Rep__c;

        if (looser.McaApp__Sales_Rep__c != null && winner.McaApp__Sales_Rep__c == null)
            winner.McaApp__Sales_Rep__c = looser.McaApp__Sales_Rep__c;

        if (looser.Judgements_Liens__c != null && winner.Judgements_Liens__c == null)
            winner.Judgements_Liens__c = looser.Judgements_Liens__c;

        if (looser.McaApp__Lead_Created_Date__c != null && winner.McaApp__Lead_Created_Date_Copy_for_Mapping__c == null)
            winner.McaApp__Lead_Created_Date_Copy_for_Mapping__c = looser.McaApp__Lead_Created_Date__c;
        
        if (looser.McaApp__Credit_Card_Sales__c != null && winner.McaApp__Average_Monthly_CC_Sale__c == null)
            winner.McaApp__Average_Monthly_CC_Sale__c = looser.McaApp__Credit_Card_Sales__c;
        
        if (looser.Monthly_Debt_Service__c != null && winner.Monthly_Debt_Service__c == null) 
            winner.Monthly_Debt_Service__c = looser.Monthly_Debt_Service__c;
        
        if (looser.Monthly_Online_Sales__c != null && winner.Monthly_Online_Sales__c == null) 
            winner.Monthly_Online_Sales__c = looser.Monthly_Online_Sales__c;
        
        if (looser.Online_Sales__c != null && winner.Online_Sales__c == null) 
            winner.Online_Sales__c = looser.Online_Sales__c;

        if (looser.Open_BK__c != null && winner.Open_BK__c == null) 
            winner.Open_BK__c = looser.Open_BK__c;

        if (looser.Peak_Months__c != null && winner.Peak_Months__c == null)
            winner.Peak_Months__c = looser.Peak_Months__c;

        if (looser.Previous_Financing_Type__c != null && winner.Previous_Financing_Type__c == null)
            winner.Previous_Financing_Type__c = looser.Previous_Financing_Type__c;
        
        if (looser.Profitable_last_year__c != null && winner.Profitable_last_year__c == null) 
            winner.Profitable_last_year__c = looser.Profitable_last_year__c;
        
        if (looser.McaApp__Use_of_Proceeds__c != null && winner.McaApp__Purpose_of_Funding__c == null)
            winner.McaApp__Purpose_of_Funding__c = looser.McaApp__Use_of_Proceeds__c;
        
        if (looser.Seasonal_Business__c != null && winner.Seasonal_Business__c == null) 
            winner.Seasonal_Business__c = looser.Seasonal_Business__c;
        
        if (looser.McaApp__Term_Requested__c != null && winner.McaApp__Term_Requested__c == null)
            winner.McaApp__Term_Requested__c = looser.McaApp__Term_Requested__c;

    }


    private string contactFieldsString(){

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());
        
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();

        String contactsQuery = 'select Id ' ;

        Set<String>  contactsFieldsSet  = contactFields.keySet();

        List<String> contactsFieldsList = new List<String>(contactsFieldsSet);

        for (Schema.SObjectField fld: contactFields.values()) {

            // Update
            if (fld.getDescribe().getName() != 'Id') {
                    
                contactsQuery += ', ' + fld.getDescribe().getName();
            } 
        }

        return contactsQuery;

    }

}