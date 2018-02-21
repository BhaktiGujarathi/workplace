public class DedupeProspectProcessService{

    public static final Set<String> PROSPECT_CATEGORIES = new Set<String>{ 'Apped Opp', 'Submitted Opp', 'Contracted Opp', 'Dead Opp', 'Funded Opp'};

    private static final String REASON_LOST_DUPLICATE             = 'Duplicate';
    private static final String DUPLICATE_REASON_PAID_OFF         = 'Funded Opportunity paid off for more than 60 days';
    private static final String STAGE_CLOSED_LOST_DUPLICATE       = 'Closed Lost - Duplicate';
    private static final String DUPLICATE_REASON_TIMED_OUT        = 'Application Timed Out';
    private static final String LEAD_STATUS_CLOSED_LOST           = 'Closed - Unqualified';
    private static final String MATCHED_TO_RECENT_ACTIVE_LEAD     = 'Matched to recent Active Lead';
    private static final String MATCHED_TO_RECENT_INACTIVE_LEAD   = 'Matched to recent Inactive Lead';
    private static final String MATCHED_TO_FUNDED_OPPORTUNITY     = 'Matched to Funded Opportunity';
    private static final String MATCHED_TO_CONTRACTED_OPPORTUNITY = 'Matched to Contracted Opportunity';
    private static final String MATCHED_TO_SUBMITTED_OPPORTUNITY  = 'Matched to existing Submitted Opportunity';
    private static final String MATCHED_TO_DEAD_OPPORTUNITY       = 'Matched to recent Dead Opportunity';
    private static final String ACTIVE_LEAD_TIMED_OUT             = 'Active Lead Timed Out';
    private static final String INACTIVE_LEAD_TIMED_OUT           = 'Inactive Lead Timed Out';
    private static final String DEAD_OPP_TIMED_OUT                = 'Dead Opp Timed Out';
    private static final String ACCOUNT_STAGE_APP        = 'Apped Opp';
    private static final String ACCOUNT_STAGE_SUBMITTED  = 'Submitted Opp';
    private static final String ACCOUNT_STAGE_CONTRACTED = 'Contracted Opp';
    private static final String ACCOUNT_STAGE_FUNDED     = 'Funded Opp';
    private static final String ACCOUNT_STAGE_DEAD       = 'Dead Opp';

    private List<Lead>                activeLeads;
    private List<Lead>                inactiveLeads;
    private List<Lead>                leadsList;
    private Map<Id, Opportunity>      opportunitiesToUpdate;
    private Map<Id, Lead>             leadsToUpdate;
    private Map<id, Contact>          contactsToUpdate;
    private Map<Id, Account>          accountsToUpdate;
    private Deduplication_Settings__c settings;
    private Set<String>               leadPhones;
    private Set<String>               leadCopyFields;    


    public DedupeProspectProcessService(List<Lead> paramLeadsList) {

        settings = Deduplication_Settings__c.getOrgDefaults();
        leadPhones = new Set<String>();

        if (settings.Lead_Phones__c != null) {
            for (String leadPhone : settings.Lead_Phones__c.split(',')) {
                leadPhones.add(leadPhone.toLowerCase());
            }
        }

        leadCopyFields = new Set<String>();

        for (Deduplication_Field__c dedupeField : [SELECT Field_API_Name__c
                                                     FROM Deduplication_Field__c
                                                    WHERE Object__c = 'Lead'
                                                      AND Field_API_Name__c <> NULL]) {
            
            leadCopyFields.add(dedupeField.Field_API_Name__c.toLowerCase());             
        }

        leadsList = new List<Lead>();

        List<String> leadIdsList = new List<String>();
        opportunitiesToUpdate    = new Map<Id, Opportunity>();
        leadsToUpdate            = new Map<Id, Lead>();
        accountsToUpdate         = new Map<Id, Account>();
        contactsToUpdate         = new Map<Id, Contact>();

        String[] phoneFields = getLeadPhoneFields();

        for(Lead myLead : paramLeadsList){
            leadIdsList.add(myLead.Id);
        }


        Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();

        String tmpQuery = 'select Original_Campaign__r.Name, ' ;

        Set<String>  leadsFieldsSet  = leadFields.keySet();

        List<String> leadsFieldsList = new List<String>(leadsFieldsSet);

        Integer index = 1;
        
        for (Schema.SObjectField fld: leadFields.values()) {
            
            if (index < leadsFieldsSet.size()) {
                
                tmpQuery += fld.getDescribe().getName() + ',';
                index++;
            }
            else{
                
               tmpQuery += fld.getDescribe().getName();
            }   
        }

        tmpQuery += ' from Lead where Id IN :leadIdsList';

        system.debug('TMPQUERY:     ' + tmpQuery);

        leadsList = (Lead[]) Database.query(tmpQuery);
    }


    public void deduplicate(){        

        if (CustomLeadConversion.runOnce() && (settings.Enable_Prospect_Process__c || Test.isRunningTest())) {

            if (!compareAccountsWithPhones()){
                
                compareLeadsWithPhones();                
            }
            if (!opportunitiesToUpdate.isEmpty()){
                
                update opportunitiesToUpdate.values();
            }
            if (!leadsToUpdate.isEmpty()){
                
                System.debug('\n\n###leadsToUpdate: ' + leadsToUpdate.values());

                update leadsToUpdate.values();
            }
            
            if (!contactsToUpdate.isEmpty()){
                update contactsToUpdate.values();
            }
            
            if (!accountsToUpdate.isEmpty()){
                update accountsToUpdate.values();
            }
        }
    }

    private Boolean compareAccountsWithPhones() {        

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Lead.fields.getMap());

        String[] lst = new String[]{};
        
        for (String ac : PROSPECT_CATEGORIES) {
            lst.add(String.escapeSingleQuotes(ac));
        }

        String prospectCategories = '(\'' + String.join(lst, '\',\'') + '\')';
        
        String contactsQuery = 'select Id, AccountId, Email from Contact where (Account.Opportunity_Stage_Category__c in ' + prospectCategories + ') AND (Id = null';

        System.debug('\n\n###phoneFields: ' + phoneFields);
        System.debug('\n\n###leadsList: ' + leadsList);

        for (String phoneField : phoneFields) {            
            
            for (Lead myLead : leadsList) {

                System.debug('\n\n###myLead.get(phoneField): ' + myLead.get(phoneField));
                
                if (myLead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {
                    
                    String phone = String.valueOf(myLead.get(phoneField));
                    
                    phone = phone.replace(' ', '')
                                 .replace(')', '')
                                 .replace('(', '')
                                 .replace('-', '')
                                 .replace('+', '');

                    contactsQuery += ' OR Contact_Phones__c like \'%' + phone + '%\'';
                }                
            }
        }

        contactsQuery += ')';

        system.debug('CONTACTS QUERY:   ' + contactsQuery);

        List<Contact> matchedAccountsList = new List<Contact>((List<Contact>)Database.query(contactsQuery));
        Set<String> accountsIds = new Set<String>();

        for (Contact currentContact : matchedAccountsList){
            accountsIds.add(currentContact.AccountId);
        }

        String query = getAccountsQuery(accountsIds);


        System.debug('\n\n###: ' + query);

        Account[] matchingAccounts = Database.query(query);

        if (!matchingAccounts.isEmpty()) {
            
            if (compareFundedOpp(matchingAccounts)) {

                return true;
            }
            else if (compareContractedOpp(matchingAccounts)) {
            
                return true;
            }
            else if(compareSubmittedOpp(matchingAccounts)){
            
                return true;
            }
            else if(compareOpptedOpp(matchingAccounts)){
            
                return true;
            }
            else if(compareDeadOpp(matchingAccounts)){                
            
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

        for (Lead myLead : leadsList) {
            
            for (Lead matchingLead : matchingLeads) {
            
                if (matchingLead.Lead_Status_Category__c == 'Active' && containsAnyPhone(myLead, matchingLead) && matchingLead.id != myLead.id) {
            
                    Date fourteenDaysAgo = Date.today().addDays(-14);

                    if (matchingLead.Working_Contacted_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Working - Contacted' || matchingLead.Open_Attempting_Contact_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Open - Attempting Contact' || matchingLead.Open_Not_Contacted_Date_Time__c < fourteenDaysAgo && matchingLead.Status == 'Open - Not Contacted' ){

                        flagLeadAsDuplicate(matchingLead); // Flag Active Lead as duplicate to the Applicant Opp

                        copyInfoToWinningRecord(myLead, matchingLead);

                        matchingLead.Duplicate_Reason__c  = ACTIVE_LEAD_TIMED_OUT;
                        matchingLead.DupRefLeadId__c      = myLead.id;

                        matchingLead.DupRefLeadLink__c     = matchingLead.SalesforceInstance__c + myLead.Id;
                        matchingLead.DupRefLeadCampaign__c = myLead.Campaign_Source__c;
                        matchingLead.DupRefLeadCompany__c  = myLead.Company;

                        leadsToUpdate.put(matchingLead.Id, matchingLead);
                    }
                    else {

                        flagLeadAsDuplicate(myLead); // Flag Active Lead as duplicate to the Applicant Opp

                        copyInfoToWinningRecord(matchingLead, myLead);

                        myLead.Duplicate_Reason__c  = MATCHED_TO_RECENT_ACTIVE_LEAD;
                        myLead.DupRefLeadId__c      = matchingLead.id;

                        myLead.DupRefLeadLink__c     = myLead.SalesforceInstance__c + myLead.Id;
                        myLead.DupRefLeadCampaign__c = matchingLead.Campaign_Source__c;

                        leadsToUpdate.put(myLead.Id, myLead);

                        System.debug('\n\n###: ' + myLead);                     
                    }

                    return true;  
                }
            }
        }

        return false;
    }


    private Boolean compareInactiveLeads(Lead[] matchingLeads) {
        
        for (Lead myLead : leadsList) {
        
            for (Lead matchingLead : matchingLeads) {
                
                if (matchingLead.Lead_Status_Category__c == 'Inactive' && containsAnyPhone(myLead, matchingLead) && matchingLead.id != myLead.id) {
                    
                    Date fourteenDaysAgo = Date.today().addDays(-14);
                    
                    if (matchingLead.Closed_Lost_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Closed - Lost' || matchingLead.Closed_Future_Client_Date_Time__c < fourteenDaysAgo && matchingLead.status == 'Closed - Future Client' || matchingLead.Closed_Converted_Date_Time__c < fourteenDaysAgo && matchingLead.Status == 'Closed - Converted'){

                        copyInfoToWinningRecord(myLead, matchingLead);

                        flagLeadAsDuplicate(matchingLead); // Flag Active Lead as duplicate to the Applicant Opp

                        matchingLead.DupRefLeadId__c     = myLead.id;
                        matchingLead.Duplicate_Reason__c = INACTIVE_LEAD_TIMED_OUT;

                        matchingLead.DupRefLeadLink__c     = matchingLead.SalesforceInstance__c + myLead.Id;
                        matchingLead.DupRefLeadCampaign__c = myLead.Campaign_Source__c;
                        matchingLead.DupRefLeadCompany__c  = myLead.Company;

                        leadsToUpdate.put(matchingLead.Id, matchingLead);
                        
                    }
                    else {

                        copyInfoToWinningRecord(matchingLead, myLead);
                        
                        flagLeadAsDuplicate(myLead); // Flag Active Lead as duplicate to the Applicant Opp
                        
                        myLead.Duplicate_Reason__c  = MATCHED_TO_RECENT_INACTIVE_LEAD;
                        myLead.DupRefLeadId__c = matchingLead.id;

                        myLead.DupRefLeadLink__c     = myLead.SalesforceInstance__c + myLead.Id;
                        myLead.DupRefLeadCampaign__c = matchingLead.Campaign_Source__c;
                        myLead.DupRefLeadCompany__c  = matchingLead.Company;
                                     
                        leadsToUpdate.put(myLead.Id, myLead);
                                           
                    }
                    return true;  
                }
            }
        }

        return false;
    } 

    
    // Prospect Record flagged as Duplicate.
    private void flagLeadAsDuplicate(Lead myLead){                          
        //  Status of Prospect Record changed to “Closed-Lost” with reason,
        //  “Duplicate” or Stage changed to “Closed Lost- Duplicate”                    
        myLead.Status = LEAD_STATUS_CLOSED_LOST;
        myLead.McaApp__Sub_Status__c = REASON_LOST_DUPLICATE;
    }

    
    private String[] getAccountPhoneFields() {

        String[] phoneFields = new String[]{};

        Map<String,Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();

        for (String fieldName : accountFields.keySet()) {
            
            Schema.DescribeFieldResult fieldInfo = accountFields.get(fieldName).getDescribe();
            
            if (fieldInfo.getType() == Schema.DisplayType.PHONE) {
                
                phoneFields.add(fieldName);
            }
        }

        return phoneFields;
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

    
    // Compare all phone numbers on Prospect Record to all phone numbers on existing records
    private Boolean containsAnyPhone(Account matchingAccount, Lead lead) {
        
        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Lead.fields.getMap());
        boolean result = false;
        
        for (String phoneField : phoneFields) {
            
            if (!String.isEmpty(phoneField) && !String.isEmpty(matchingAccount.Account_Phones__c)) {
                
                if (lead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {

                    String phone = String.valueOf(lead.get(phoneField));
                    phone = phone.replace(' ', '')
                                 .replace(')', '')
                                 .replace('(', '')
                                 .replace('-', '')
                                 .replace('+', '');

                    if (matchingAccount.Account_Phones__c.contains(phone)) {
                        result = true;
                    }
                }
            }
        }

        //Check only if was is no match already 
        if(!result){
            // As there is no matching Account will have to check with the Contacts.
            List<Contact> myContactsList = new List<Contact>();
                          myContactsList = matchingAccount.getSObjects('Contacts');

            // Check matchingAcocunbts.Contacts to check the phone
            for (String phoneField : phoneFields) {
                
                if (myContactsList != null && !myContactsList.isEmpty()){
                    
                    for(Contact myContact : myContactsList){
                        
                        if (!String.isEmpty(phoneField) && !String.isEmpty(myContact.Contact_Phones__c)) {
                            
                            if (lead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {

                              String phone = String.valueOf(lead.get(phoneField));
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

        return result;
    }


    // Compare all phone numbers on Prospect Record to all phone numbers on existing records
    private Boolean containsAnyPhone(Lead myLead, Lead matchingLead) {
        
        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Lead.fields.getMap());

        for (String phoneField : phoneFields) {
            
            if (phoneField != null && matchingLead.Lead_Phones__c != null) {
                
                if (myLead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {

                    String phone = String.valueOf(myLead.get(phoneField));
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

        return false;
    }

    private String[] getLeadPhoneFields() {

        String[] phoneFields = new String[]{};

        Map<String,Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();

        for (String fieldName : leadFields.keySet()) {
            
            Schema.DescribeFieldResult fieldInfo = leadFields.get(fieldName).getDescribe();
            
            if (fieldInfo.getType() == Schema.DisplayType.PHONE) {
                
                phoneFields.add(fieldName);
            }
        }

        return phoneFields;
    }


    private String getLeadsQuery() {

        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Lead.fields.getMap());
        
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

        query +=  ' from Lead where IsConverted = false AND McaApp__Sub_Status__c <> ' + '\'' +  REASON_LOST_DUPLICATE + '\''  + ' AND (Id = null ';

        for (String phoneField : phoneFields) {

            for (Lead lead : leadsList) {

                if (lead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {

                    String phone = String.valueOf(lead.get(phoneField));
                    phone = phone.replace(' ', '')
                                 .replace(')', '')
                                 .replace('(', '')
                                 .replace('-', '')
                                 .replace('+', '');


                    query += ' OR Lead_Phones__c like \'%' + phone + '%\'';

                }
            }
        }

        query += ')';

        system.debug('LEADS QUERY:    ' + query);

        return query;
    } 


    private Boolean compareDeadOpp(Account[] matchingAccounts) {
        
        for (Lead myLead : leadsList) {
            
            for (Account matchingAccount : matchingAccounts) {
                
                if (matchingAccount.Opportunity_Stage_Category__c == ACCOUNT_STAGE_DEAD && containsAnyPhone(matchingAccount, myLead)) {
                    
                    List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                    
                    for(Opportunity oppty : myOpportunities){
                        
                        List<Contact> matchingContactsList = matchingAccount.getSObjects('Contacts');
                        
                        // Dead Opp > 14 days?
                        if (oppty.Declined_Date_Time__c < system.today() - 14 && oppty.stageName == 'Declined' || oppty.Closed_Lost_Merchant_Date_Time__c < system.today() - 14 && oppty.StageName == 'Closed Lost - Merchant'|| oppty.Closed_Lost_Funding_Source_Date_Time__c < system.today() - 14 && oppty.StageName == 'Closed Lost - Funding Source'){
                            // Copy losing Lead info to winning Oppty
                            copyInfoToWinningRecord(myLead,matchingContactsList, oppty, matchingAccount);

                            oppty.DupRefLeadId2__c        = myLead.id;                   // Set DupRefID on App’d Opp to Prospect Record ID. 
                            oppty.stageName              = STAGE_CLOSED_LOST_DUPLICATE; // Stage of App’d Opp changed to “Closed Lost-Duplicate”
                            oppty.Duplicate_Reason__c    = DEAD_OPP_TIMED_OUT;

                            oppty.DupRefLeadLink__c     = oppty.SalesforceInstance__c + myLead.Id;
                            oppty.DupRefLeadCampaign__c = myLead.Campaign_Source__c;
                            oppty.DupRefLeadCompany__c  = myLead.Company;

                           // copyInfoToWinningRecord(myLead,matchingContactsList, oppty, matchingAccount);

                            // If Opportunity is to be updated is not in the map, add it.
                            if (!opportunitiesToUpdate.containsKey(oppty.Id)){
                                opportunitiesToUpdate.put(oppty.Id, oppty);
                            }

                            // If Lead to be updated is not in the map, add it.
                            if (!leadsToUpdate.containsKey(myLead.Id)) {                
                                leadsToUpdate.put(myLead.Id, myLead);
                            }
                        }else{
                            // Copy losing Lead info to winning Oppty
                            copyInfoToWinningRecord(oppty, myLead);

                            flagLeadAsDuplicate(myLead); // Prospect Record flagged as Duplicate.
                    
                            myLead.DupRefOppID__c      = oppty.Id;                // Set DupRefID on Prospect Record to Dead Opp ID.  
                            myLead.Duplicate_Reason__c = MATCHED_TO_DEAD_OPPORTUNITY;

                            // If Lead to be updated is not in the map, add it.
                            if (!leadsToUpdate.containsKey(myLead.Id)) {                
                                leadsToUpdate.put(myLead.Id, myLead);
                            }

                            // If Opportunity is to be updated is not in the map, add it.
                            if (!opportunitiesToUpdate.containsKey(oppty.Id)){
                                opportunitiesToUpdate.put(oppty.Id, oppty);
                            }

                        }            
                    }
                    return true;  
                }
            }
        }

        return false;
    }    

    private Boolean compareContractedOpp(Account[] matchingAccounts){
        for (Lead myLead : leadsList) {
            for (Account matchingAccount : matchingAccounts) {
                if (matchingAccount.Opportunity_Stage_Category__c == ACCOUNT_STAGE_CONTRACTED && containsAnyPhone(matchingAccount, myLead)) {
                    List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                    for(Opportunity oppty : myOpportunities){
                        if(oppty.StageName == 'Agreement Sent' || oppty.StageName == 'Agreement Signed'){                        
                             // Copy losing Lead info to winning Oppty
                            copyInfoToWinningRecord(oppty, myLead);

                            myLead.DupRefOppID__c = oppty.Id; // Set DupRefID on Prospect Record to App’d Opp ID.
                            
                            flagLeadAsDuplicate(myLead);// Prospect Record flagged as Duplicate.                            
                            
                            myLead.status = 'Closed - Lost';
                            myLead.McaApp__Sub_Status__c = REASON_LOST_DUPLICATE;                            
                            myLead.Duplicate_Reason__c   = MATCHED_TO_CONTRACTED_OPPORTUNITY;
                            
                            leadsToUpdate.put(myLead.Id, myLead);

                            opportunitiesToUpdate.put(oppty.Id, oppty);
                        }
                    }
                    return true;
                }
            }
        }
        return false;
    }


    private Boolean compareSubmittedOpp(Account[] matchingAccounts){
        for (Lead myLead : leadsList) {
            for (Account matchingAccount : matchingAccounts) {
                if (matchingAccount.Opportunity_Stage_Category__c == ACCOUNT_STAGE_SUBMITTED && containsAnyPhone(matchingAccount, myLead)) {
                    List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                    for(Opportunity oppty : myOpportunities){
                        if(oppty.StageName == 'Application In' || oppty.StageName == 'Underwriting' || oppty.StageName == 'Approved' || oppty.StageName == 'Agreement Requested'){
                        
                            // Copy losing Lead info to winning Oppty
                            copyInfoToWinningRecord(oppty, myLead);

                            myLead.DupRefOppID__c = oppty.Id; // Set DupRefID on Prospect Record to App’d Opp ID.

                            flagLeadAsDuplicate(myLead); // Prospect Record flagged as Duplicate.
                            
                            myLead.Duplicate_Reason__c   = MATCHED_TO_SUBMITTED_OPPORTUNITY;          

                            leadsToUpdate.put(myLead.Id, myLead);
                            opportunitiesToUpdate.put(oppty.Id, oppty);
                        }
                    }
                    return true;
                }
            }
        }
        return false;
    }


    private boolean compareOpptedOpp(Account[] matchingAccounts){
        for (Lead myLead : leadsList) {
            for (Account matchingAccount : matchingAccounts) {
                if (matchingAccount.Opportunity_Stage_Category__c == ACCOUNT_STAGE_APP && containsAnyPhone(matchingAccount,myLead)) {
                    List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');
                    for(Opportunity oppty : myOpportunities){    
                        if(oppty.StageName == 'Application Sent' || oppty.StageName == 'Application Missing Info'){
                            List<Contact> matchingContactsList = matchingAccount.getSObjects('Contacts');

                            // App Date > 14 days?
                            if ((oppty.Application_Missing_Info_Date_Time__c < system.today() - 14 && oppty.StageName == 'Application Missing Info') || (oppty.Application_Sent_Date_Time__c < system.today() - 14 && oppty.StageName == 'Application Sent')){
                                // Copy losing Lead info to winning Oppty
                                copyInfoToWinningRecord(oppty, myLead);

                                // App’d Opp flagged as Duplicate.
                                oppty.DupRefLeadId2__c = myLead.id;                         // Set DupRefID on Prospect Record to Contracted Opp ID. 
                                oppty.stageName = STAGE_CLOSED_LOST_DUPLICATE;              // Set DupRefID on App’d Opp to Prospect Record ID. Stage of App’d Opp changed to “Closed Lost-Duplicate”
                                oppty.Duplicate_Reason__c = DUPLICATE_REASON_TIMED_OUT;     // App’d Opp Duplicate Reason: Application Timed Out.
                            
                                oppty.DupRefLeadLink__c     = oppty.SalesforceInstance__c + myLead.Id;
                                oppty.DupRefLeadCampaign__c = myLead.Campaign_Source__c;
                                oppty.DupRefLeadCompany__c  = myLead.Company;

                                leadsToUpdate.put(myLead.Id, myLead);
                                opportunitiesToUpdate.put(oppty.Id, oppty);

                            }else{
                                // Copy losing Lead info to winning Oppty
                                copyInfoToWinningRecord(myLead,matchingContactsList, oppty, matchingAccount);

                                // Prospect Record flagged as Duplicate.
                                flagLeadAsDuplicate(myLead); // Prospect Record flagged as Duplicate. 
                                myLead.DupRefOppID__c = oppty.Id; // Set DupRefID on Prospect Record to App’d Opp ID.
                                myLead.Duplicate_Reason__c = 'Matched to recent Application';

                                leadsToUpdate.put(myLead.Id, myLead);
                                opportunitiesToUpdate.put(oppty.Id, oppty);
                            }
                        }
                    }
                    return true;
                }
            }
        }
        return false;
    }


    private boolean compareFundedOpp(Account[] matchingAccounts){

        for (Lead myLead : leadsList) {

            for (Account matchingAccount : matchingAccounts) {
                    
                if (matchingAccount.Opportunity_Stage_Category__c == ACCOUNT_STAGE_FUNDED && containsAnyPhone(matchingAccount, myLead)) {

                    List<Opportunity> myOpportunities = matchingAccount.getSObjects('Opportunities');

                    if(myOpportunities != null && !myOpportunities.isEmpty()){
                        
                        for(Opportunity oppty : myOpportunities){
                        
                            if(oppty.StageName == 'Funded' || oppty.StageName == 'Renewal Prospecting' || oppty.StageName == 'Renewal Requested'){
                        
                                List<Contact> matchingContactsList = matchingAccount.getSObjects('Contacts');

                                if(oppty.Paid_Off__c && oppty.Paid_Off_60_Days_Ago__c){ // Paid off > 60 days?
                                    copyInfoToWinningRecord(myLead,matchingContactsList, oppty, matchingAccount);

                                    oppty.DupRefLeadId2__c = myLead.id;                     // Set DupRefID on Funded Opp to Prospect Record ID.
                                    oppty.Duplicate_Reason__c = DUPLICATE_REASON_PAID_OFF; // Funded Opp Duplicate Reason: Funded Opportunity paid off for more than 60 days.
                
                                    oppty.DupRefLeadLink__c     = oppty.SalesforceInstance__c + myLead.Id;
                                    oppty.DupRefLeadCampaign__c = myLead.Campaign_Source__c;
                                    oppty.DupRefLeadCompany__c  = myLead.Company;

                                    opportunitiesToUpdate.put(oppty.Id, oppty);
                                    leadsToUpdate.put(myLead.Id, myLead);
                                }
                                else {
                                    copyInfoToWinningRecord(oppty, myLead);

                                    flagLeadAsDuplicate(myLead);// Prospect Record flagged as Duplicate.
                                    // Set DupRefID on Prospect Record to Funded Opp ID. Status of Prospect Record changed to “Closed-Lost” with reason, “Duplicate” or Stage changed to “Closed Lost- Duplicate”
                                    myLead.DupRefOppID__c = oppty.Id; 
                                    myLead.Status = LEAD_STATUS_CLOSED_LOST;             
                                    myLead.Duplicate_Reason__c = MATCHED_TO_FUNDED_OPPORTUNITY;

                                    leadsToUpdate.put(myLead.Id, myLead);
                                    opportunitiesToUpdate.put(oppty.Id, oppty);
                                }

                                return true;
                            }
                        }                        
                    }
                }
            }
        }

        return false;
    }


    private String getAccountsQuery(Set<String> accountIdsSet) {
        
        String[] phoneFields = getObjectPhoneFields(Schema.SObjectType.Lead.fields.getMap());

        String opportunitiesAuxQuery = opptiesQueryAux();
        String contactsAuxQuery      = contactsQueryAux();

        String query = 'select Id, Account_Dedupe_Key__c, Opportunity_Stage_Category__c, Account_Phones__c,' + opportunitiesAuxQuery +    ',' + contactsAuxQuery + ' from Account where Flagged_for_Duplicate_Review__c = false and (Opportunity_Stage_Category__c =\'Dead Opp\' or Opportunity_Stage_Category__c =\'Apped Opp\' or Opportunity_Stage_Category__c = \'Funded Opp\' or Opportunity_Stage_Category__c = \'Contracted Opp\' or Opportunity_Stage_Category__c = \'Submitted Opp\') AND (Id = null';

        for (String phoneField : phoneFields) {
            
            for (Lead myLead : leadsList) {
                
                if (myLead.get(phoneField) != null && leadPhones.contains(phoneField.toLowerCase())) {

                    String phone = String.valueOf(myLead.get(phoneField));
                    phone = phone.replace(' ', '')
                                 .replace(')', '')
                                 .replace('(', '')
                                 .replace('-', '')
                                 .replace('+', '');


                    query += ' OR Account_Phones__c like \'%' + phone + '%\'';
                }
            }
        }

        if (!accountIdsSet.isEmpty()) {
            
            for (String myAccountId : accountIdsSet) {
                
                query += ' OR id =\'' + myAccountId + '\'';
            }
        }         

        query += ')';

        query = query.replace('{', '(');
        query = query.replace('}', ')');

        system.debug('ACCOUNTS QUERY:    ' + query);

        return query;
    }


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Lead winner, Lead looser){
        Map<String, Schema.SObjectField> leadFieldsMap = Schema.SObjectType.Lead.fields.getMap();

        String query = 'select ';

        Set<String> fieldsSet = leadFieldsMap.keySet();

        List<String> fieldsList = new List<String>(fieldsSet);

        Integer index = 1;
        
        for(Schema.SObjectField fld: leadFieldsMap.values()){
            if(index < fieldsSet.size()){
                query += fld.getDescribe().getName() + ',';
                index++;
            }else{
                query += fld.getDescribe().getName();
            }
        }

        query += ' from Lead where id = \'' + winner.Id + '\' or Id = \'' + looser.Id + '\' limit 2';

        system.debug('LEADS TO COMPARE QUERY:   ' + query);

        Lead[] leadsToCompare = (Lead[]) Database.query(query);

        Lead lead1 = (Lead)leadsToCompare[0];
        Lead lead2 = (Lead)leadsToCompare[1];


        for (String fieldName : leadFieldsMap.keySet()) {
            
            if (leadCopyFields.contains(fieldName.toLowerCase())) {

                if (lead1.id == winner.Id) {
                
                    //if (leadFieldsMap.get(fieldName).getDescribe().isUpdateable() && (winner.get(fieldName) == null  || winner.get(fieldName) == '') && (looser.get(fieldName) != null && looser.get(fieldName) != '')){
                    if (leadFieldsMap.get(fieldName).getDescribe().isUpdateable() && (lead1.get(fieldName) == null  || lead1.get(fieldName) == '') && (lead2.get(fieldName) != null && lead2.get(fieldName) != '')){

                        lead1.put(fieldName, lead2.get(fieldName));
                    } 
                }
                else{
                
                    if (leadFieldsMap.get(fieldName).getDescribe().isUpdateable() && (lead2.get(fieldName) == null  || lead2.get(fieldName) == '') && (lead1.get(fieldName) != null && lead1.get(fieldName) != '')){

                        lead2.put(fieldName, lead1.get(fieldName));
                    } 
                }
            }
        }   


        if (!leadsToUpdate.containsKey(lead1.id)){
            leadsToUpdate.put(lead1.id, lead1);
        } 

        if (!leadsToUpdate.containsKey(lead2.id)){
            leadsToUpdate.put(lead2.id, lead2);
        }
    }

 
    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Opportunity winner, Lead looser){

        //System.assert(false, 'LEAD SHOULD COPY INTO OPPTY');

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

        if(!accountsToUpdate.containsKey(winner.accountId)){
            accountsToUpdate.put(winner.AccountId, winner.Account);
        }

        List<Contact> winningContactList = new List<Contact>();

        // Query account for contact with earliest created date where first and last name matches the first and last name of the lead. If match found, copy fields over to contact where contact field == null
        winningContactList = [select id, Authorize_Run_Credit__c, Birthdate_for_Workflow__c, Home_Address_City_for_Workflow__c, Home_Address_for_Workflow__c, Home_Address_State_for_Workflow__c, Home_Address_Zip_for_Workflow__c, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Email from Contact where AccountId =: winner.AccountId and FirstName =: looser.FirstName and LastName =: looser.LastName order by CreatedDate desc limit 1];

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

                if(!contactsToUpdate.containsKey(winningContact.id)){
                    contactsToUpdate.put(winningContact.id,winningContact);
                }
            }
        }
    }


    // If losing record has more information that the winning record, copy to winning record, where applicable.
    private void copyInfoToWinningRecord(Lead winner, List<Contact> loosercontacts,Opportunity looser, Account looserAccount){

        boolean found = false;
        Integer index = 0;

        if(loosercontacts != null && !loosercontacts.isEmpty() ){

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


    // Query for all the fields in the Opportunity to avoid errors.
    private String opptiesQueryAux(){
        Map<String, Schema.SObjectField> opportunityFields = Schema.SObjectType.Opportunity.fields.getMap();

        String opportunitiesAuxQuery = '(select Original_Campaign__r.Name, Account.Name, Account.McaApp__Gross_monthly_Sales__c,Account.McaApp__Years_in_Business__c, Account.Business_Main_Phone__c, Account.McaApp__Monthly_CC_Avg_All__c, Account.McaApp__Business_Contact_Account__c, Account.Business_Contact_Account_2__c, Account.Business_Contact_Account_3__c, Account.McaApp__Business_Phone__c, Account.Business_Phone_2__c, Account.Business_Phone_3__c, Account.McaApp__ConvertedAccount__c, Account.McaApp__Date_Business_Established__c, Account.McaApp__Federal_Tax_ID_No__c, Account.McaApp__Landlord_Mortgagee__c, Account.McaApp__Landlord_Contact_Name__c, Account.McaApp__Landlord_Phone__c, Account.McaApp__Monthly_Payment__c, Account.McaApp__NumberofLocations__c, Account.State_of_Incorporation__c,';

        Set<String>  opportunitiesFieldsSet  = opportunityFields.keySet();

        List<String> opportunitiesFieldsList = new List<String>(opportunitiesFieldsSet);

        Integer index = 1;
        
        for (Schema.SObjectField fld: opportunityFields.values()) {
            
            if (index < opportunitiesFieldsSet.size()) {
                
                opportunitiesAuxQuery += fld.getDescribe().getName() + ',';
                index++;
            }
            else{
                
                opportunitiesAuxQuery += fld.getDescribe().getName();
            }
        }

        opportunitiesAuxQuery += ' from Opportunities order by CreatedDate desc limit 200)';

        system.debug('OPPORTUNITIES AUX QUERY:  ' + opportunitiesAuxQuery);

        return opportunitiesAuxQuery;
    }

    // Query for all the fields in the Contact to avoid errors.
    private String contactsQueryAux(){
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();

        String contactsAuxQuery = '(select ' ;

        Set<String>  contactsFieldsSet  = contactFields.keySet();

        List<String> contactsFieldsList = new List<String>(contactsFieldsSet);

        Integer index = 1;
        
        for (Schema.SObjectField fld: contactFields.values()) {
            
            if (index < contactsFieldsSet.size()) {
                
                contactsAuxQuery += fld.getDescribe().getName() + ',';
                index++;
            }
            else{
                
               contactsAuxQuery += fld.getDescribe().getName();
            }   
        }
        
        contactsAuxQuery += ' from Contacts order by CreatedDate desc limit 200)';

        system.debug('CONTACTS AUX QUERY:   ' + contactsAuxQuery);

        return contactsAuxQuery;
    }
}