public class DedupeCustomerProcessService {
    
    private static final String CUSTOMER_FUNDED_DUP_REASON     = 'Matched to Funded Opportunity';
    private static final String CUSTOMER_CLOSED_LOST_DUPLICATE = 'Duplicate';
    private static final String CUSTOMER_UNQUALIFIED           = 'Closed - Unqualified';

    private Account[] accounts;
    private Map<Id, Opportunity> opportunitiesToUpdate;
    private Map<Id, Lead> leadsToUpdate;
    private Map<Id, List<Contact>> contactsForDuplicatedAccount = new Map<Id, List<Contact>>();
    private List<Contact> contactsToUpdate = new List<Contact>();
    private Deduplication_Settings__c settings;
    private Set<String> accountPhones;    
    private Set<String> contactPhones;

    
    public DedupeCustomerProcessService(Account[] newAccounts) {

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

        Set<Id> accountIds = new Set<Id>();    

        for (Account account : newAccounts) {
            accountIds.add(account.Id);            
        }  

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        String query = 'select Id, Account_Dedupe_Key__c, Account_Phones__c, Opportunity_Stage_Category__c, (select id, StageName, AccountId, Primary_Campaign__r.Id from Opportunities), ' + String.join(phoneFields, ',') + ', (select id, ' + String.join(contactPhoneFields, ',') + ' ,Contact_Phones__c, AccountId from Contacts order by CreatedDate desc limit 200) from Account where Id in :accountIds and Flagged_for_Duplicate_Review__c = false';
        
        system.debug('QUERY:    ' + query);

        accounts = (Account[]) Database.query(query);

        opportunitiesToUpdate = new Map<Id, Opportunity>();
        leadsToUpdate         = new Map<Id, Lead>();
    }


    public void initDedupe() {

        if (settings.Enable_Customer_Process__c || Test.isRunningTest()) {
        
            if (!compareAccountsWithAccountKey()) {
                
                if (!compareAccountsWithPhones()) {
                    
                    compareLeadsWithPhones();       
                }
            }

            if (!opportunitiesToUpdate.isEmpty()){
                update opportunitiesToUpdate.values();
            }
                

            if (!leadsToUpdate.isEmpty()){
                update leadsToUpdate.values();
            }       

            if(!contactsToUpdate.isEmpty()){
                update contactsToUpdate;
            }
        }
    }


    private String getAccountsQuery(Set<Id> accountIdsSet) {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        String query = 'select Id, Account_Dedupe_Key__c, Opportunity_Stage_Category__c, Account_Phones__c, (select id, StageName, AccountId from Opportunities order by CreatedDate desc), (select id, ' + String.join(contactPhoneFields, ',') + ' ,Contact_Phones__c, AccountId from Contacts order by CreatedDate desc limit 200) from Account where Flagged_for_Duplicate_Review__c = false and (Opportunity_Stage_Category__c = \'Apped Opp\' or Opportunity_Stage_Category__c = \'Dead Opp\') AND (Id = null';

        
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
                
            for (Id myAccountId : accountIdsSet) {
                
                query += ' OR id =\'' + myAccountId + '\'';
            }
        }        

        query += ')';

        system.debug('ACCOUNTS QUERY:   ' + query);

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


    private Boolean containsAnyPhone(Account account, Account matchingAccount) {
        boolean result = false;
        
        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        //Check if there is an Account with the same phone.
        for (String phoneField : phoneFields) {

            if (!String.isEmpty(phoneField) && !String.isEmpty(matchingAccount.Account_Phones__c)) {

                if (account.get(phoneField) != null) {

                    String phone = String.valueOf(account.get(phoneField));

                    if (phone != null && accountPhones.contains(phoneField.toLowerCase())) {

                        phone = phone.replace(' ', '')
                                     .replace(')', '')
                                     .replace('(', '')
                                     .replace('-', '')
                                     .replace('+', '');

                        if (matchingAccount.Account_Phones__c != null && matchingAccount.Account_Phones__c.contains(phone)) {
                            
                            result = true;
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


    // Returns the Opportunity with Funded Category
    private Opportunity getFundedOpportunity(Account account) {
        return getOpportunityWithStage(account, new Set<String>{ 'Funded', 'Renewal Prospecting', 'Renewal Requested' });
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


    // Compares duplicated Accounts based on custom key (FedTaxId, Street and ZipCode)
    private Boolean compareAccountsWithAccountKey() {
        
        Set<String> accountDedupeKeys = new Set<String>();

        for (Account account : accounts) {

            accountDedupeKeys.add(account.Account_Dedupe_Key__c);
        }


        Account[] matchingAccounts = [SELECT Opportunity_Stage_Category__c,
                                             Account_Dedupe_Key__c,
                                             Account_Phones__c,
                                             (SELECT Paid_Off__c,
                                                     Paid_Off_60_Days_Ago__c,
                                                     McaApp__Funded__c,
                                                     StageName,
                                                     AccountId
                                                FROM Opportunities 
                                            ORDER BY CreatedDate DESC), 
                                             (SELECT Contact_Phones__c, 
                                                     AccountId 
                                                FROM Contacts 
                                            ORDER BY CreatedDate DESC 
                                               LIMIT 200)
                                        FROM  Account
                                       WHERE Account_Dedupe_Key__c IN :accountDedupeKeys
                                         AND   Flagged_for_Duplicate_Review__c  = false 
                                         AND  (Opportunity_Stage_Category__c    = 'Funded Opp' 
                                          OR    Opportunity_Stage_Category__c   = 'Contracted Opp' 
                                          OR    Opportunity_Stage_Category__c   = 'Submitted Opp')];
        
        if (!matchingAccounts.isEmpty()) {

            //Put all the contacts for each account to move them in case the account is a duplicate.
            for (Account myAccount : matchingAccounts){
                List<Contact> myContactsList = new List<Contact>();
                myContactsList = myAccount.getSObjects('Contacts');

                if(myContactsList != null && !myContactsList.isEmpty()){
                    contactsForDuplicatedAccount.put(myAccount.id, myContactsList);                    
                }
            }

            if (compareFundedOpp(matchingAccounts)){
                return true;                    
            }
            else if(compareContractedOpp(matchingAccounts)){
                return true;
            }
            else if(compareSubmittedOpp(matchingAccounts)){
                return true;
            }
        }

        return false;
    }


    private void setDuplicateOpportunityWithKey(Opportunity original, Opportunity duplicate){

        if (original != null && duplicate != null) {

            original.Flagged_for_Duplicate_Review__c  = true;
            duplicate.Flagged_for_Duplicate_Review__c = true;
            duplicate.DupRefOppId__c = original.Id;

            // If opp to be updated is not in the map, add it.
            if (!opportunitiesToUpdate.containsKey(duplicate.Id)) {
                
                opportunitiesToUpdate.put(duplicate.Id, duplicate);
            }

            // If opp to be updated is not in the map, add it.
            if (!opportunitiesToUpdate.containsKey(original.Id)) {
                
                opportunitiesToUpdate.put(original.Id, original);
            }

        }        
    }


    private Boolean compareAccountsWithPhones() {        

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        String contactsQuery = 'select Id, AccountId from Contact where (Account.Opportunity_Stage_Category__c = \'Apped Opp\' or Account.Opportunity_Stage_Category__c = \'Dead Opp\') AND (AccountId = null ';

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

        List<Contact> matchedAccountsList = new List<Contact>((List<Contact>) Database.query(contactsQuery));

        Set<Id> accountsIds = new Set<Id>();

        for (Contact currentContact : matchedAccountsList){
            
            accountsIds.add(currentContact.AccountId);
        }

        String query = getAccountsQuery(accountsIds);

        Account[] matchingAccounts = Database.query(query);        

        if (!matchingAccounts.isEmpty()) {

            //Put all the contacts for each account to move them in case the account is a duplicate.
            for (Account myAccount : matchingAccounts){
                
                List<Contact> myContactsList = myAccount.getSObjects('Contacts');

                if (myContactsList != null && !myContactsList.isEmpty()) {
                    
                    contactsForDuplicatedAccount.put(myAccount.id, myContactsList);                    
                }
            }

            if (compareAppdOpp(matchingAccounts)) {

                return true;
            }
            else if (compareDeadOpp(matchingAccounts)) {

                return true;
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

                    // Flag Active Lead as duplicate to the Applicant Opp
                    setDuplicateLead(getCustomerOpportunity(account), matchingLead);

                    return true;  
                }
            }            
        }

        return false;
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


    // Returns the Applicant Opp for the specified Account
    private Opportunity getCustomerOpportunity(Account account) {

        if (account.Opportunities != null) {

            for (Opportunity opp : account.Opportunities) {

                return opp;
            }
        }

        return null;
    }


    private Boolean compareInactiveLeads(Lead[] matchingLeads) {

        for (Account account : accounts) {

            for (Lead matchingLead : matchingLeads) {

                if (matchingLead.Lead_Status_Category__c == 'Inactive' && containsAnyPhone(account, matchingLead)) {

                    // Flag Inactive Lead as duplicate to the Applicant Opp
                    setDuplicateLead(getCustomerOpportunity(account), matchingLead);

                    return true;  
                }
            }
        }

        return false;
    }    


    private Boolean compareFundedOpp(Account[] matchingAccounts) {

        for (Account account : accounts) {

            for (Account matchingAccount : matchingAccounts) {

                if (account.Id != matchingAccount.Id) {

                    if (matchingAccount.Opportunity_Stage_Category__c == 'Funded Opp' && account.Account_Dedupe_Key__c == matchingAccount.Account_Dedupe_Key__c) {

                        // Flag Funded as duplicate to the Applicant Opp
                        setDuplicateOpportunityWithKey(getCustomerOpportunity(account), getFundedOpportunity(matchingAccount));

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

                    if (matchingAccount.Opportunity_Stage_Category__c == 'Contracted Opp' && account.Account_Dedupe_Key__c == matchingAccount.Account_Dedupe_Key__c) {

                        // Flag Contracted as duplicate to the Applicant Opp
                        setDuplicateOpportunityWithKey(getCustomerOpportunity(account), getContractedOpportunity(matchingAccount));

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

                    if (matchingAccount.Opportunity_Stage_Category__c == 'Submitted Opp' && account.Account_Dedupe_Key__c == matchingAccount.Account_Dedupe_Key__c) {

                        // Flag Add'd Opp as duplicate to the Applicant Opp
                        setDuplicateOpportunityWithKey(getCustomerOpportunity(account), getSubmittedOpportunity(matchingAccount));

                        return true;  
                    }
                }
            }
        }

        return false;
    }


    private Boolean compareAppdOpp(Account[] matchingAccounts) {
        
        for (Account account : accounts) {
        
            for (Account matchingAccount : matchingAccounts) {
        
                if (account.Id != matchingAccount.Id) {
        
                    if (matchingAccount.Opportunity_Stage_Category__c == 'Apped Opp' && containsAnyPhone(account, matchingAccount)) {

                        // Flag Add'd Opp as duplicate to the Applicant Opp
                        setDuplicateOpportunity(getCustomerOpportunity(account), getAppdOpportunity(matchingAccount), CUSTOMER_FUNDED_DUP_REASON);

                        return true;  
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

                        // Flag Dead Opp as duplicate to the Applicant Opp
                        setDuplicateOpportunity(getCustomerOpportunity(account), getDeadOpportunity(matchingAccount), CUSTOMER_FUNDED_DUP_REASON);

                        return true;  
                    }
                }
            }
        }

        return false;
    }


    private String getLeadsQuery() {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Account.fields.getMap());
        String[] contactPhoneFields = getObjectPhoneFields(Schema.SObjectType.Contact.fields.getMap());

        String query = 'select Id, Lead_Status_Category__c, Lead_Phones__c from Lead where IsConverted = false AND (Id = null ';

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


    // Sets the duplicate Lead values for update
    private void setDuplicateLead(Opportunity original, Lead duplicate) {

        if (original != null && duplicate != null) {

            // Set original record to the dup one
            duplicate.DupRefOppId__c = original.Id;
            duplicate.Status = CUSTOMER_UNQUALIFIED;
            duplicate.McaApp__Sub_Status__c = CUSTOMER_CLOSED_LOST_DUPLICATE;
            duplicate.Duplicate_Reason__c = 'Matched to Funded Opportunity';

            // If opp to be updated is not in the map, add it.
            if (!leadsToUpdate.containsKey(duplicate.Id)) {
                
                leadsToUpdate.put(duplicate.Id, duplicate);
            }
        }         
    }


    // Sets the duplicate Opportunity values for update
    private void setDuplicateOpportunity(Opportunity original, Opportunity duplicate, String reasonLost) {

        if (original != null && duplicate != null) {

            // Set original record to the dup one
            duplicate.DupRefOppId__c = original.Id;
            duplicate.StageName = 'Closed Lost - Duplicate';
            duplicate.Duplicate_Reason__c = reasonLost;

            if (contactsForDuplicatedAccount.containsKey(duplicate.AccountId)){
                
                List<Contact> contacts = contactsForDuplicatedAccount.get(duplicate.AccountId);

                for (Contact myContact : contacts){
                    myContact.AccountId = original.AccountId;
                    contactsToUpdate.add(myContact);
                }
            }


            // If opp to be updated is not in the map, add it.
            if (!opportunitiesToUpdate.containsKey(duplicate.Id)) {
                
                opportunitiesToUpdate.put(duplicate.Id, duplicate);
            }
        }        
    }
}