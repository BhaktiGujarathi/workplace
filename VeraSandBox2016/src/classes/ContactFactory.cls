public with sharing class ContactFactory {

    /**
     * Creates Contact object data - Contact record type
     *
     * @param count    Number of records to be created
     * @param account  Account record to be used for lookup
     */
     
    public static List<Contact> createContact(Integer count, Account account) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= count; i++) {
            Contact contact = new Contact();
            contact.LastName = 'Test'+i;
            contact.AccountId = account != null ? account.Id : null;
            contact.Phone = '9876543210';
            contact.MobilePhone = '9876543210';
            contact.Email = 'test@example.com';
            contact.Gender__c = 'Male';
            contact.Birthdate = System.today().addYears(-30);
            contact.Current_Level_of_Employment_Position__c = 'Foo';
            contact.UN_security_BSITF_and_ASITF__c = 'No';
            contact.Existing_Medical_Condition_s__c = 'No';
            contact.EC_Name__c = 'Test';
            contact.EC_Relation__c = 'Test Relation';
            contact.EC_Mobile_Phone__c = '9876543210';
            contact.EC_Email__c = 'test@example.com';
            contact.EC_Location_City__c = 'Delhi';
            contact.EC_Location_Country__c = 'India';
            contact.MailingStreet = 'St';
            contact.MailingPostalCode = '100000';
            contact.MailingCity = 'Delhi';
            contact.MailingState = 'Delhi';
            contact.MailingCountry = 'India';
            contact.OtherPostalCode = '100000';
            contact.OtherStreet = 'St';
            contact.OtherCity = 'Delhi';
            contact.OtherState = 'Delhi';
            contact.OtherCountry = 'India';
            contact.RecordTypeId = RecordType_Utils.getRecordTypeId('Contact', 'Contact');
            contacts.add(contact);
        }
        return contacts;
    }

    /**
     * Creates Contact object data - Expert record type
     *
     * @param count    Number of records to be created
     * @param account  Account record to be used for lookup
     */
    public static List<Contact> createExperts(Integer count, Account account) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= count; i++) {
            Contact contact = new Contact();
            contact.LastName = 'Test'+i;
            contact.AccountId = account != null ? account.Id : null;
            contact.Phone = '9876543210';
            contact.MobilePhone = '9876543210';
            contact.Email = 'test@example.com';
            contact.Gender__c = 'Male';
            contact.Birthdate = System.today().addYears(-30);
            contact.Current_Level_of_Employment_Position__c = 'Foo';
            contact.UN_security_BSITF_and_ASITF__c = 'No';
            contact.Existing_Medical_Condition_s__c = 'No';
            contact.EC_Name__c = 'Test';
            contact.EC_Relation__c = 'Test Relation';
            contact.EC_Mobile_Phone__c = '9876543210';
            contact.EC_Email__c = 'test@example.com';
            contact.EC_Location_City__c = 'Delhi';
            contact.EC_Location_Country__c = 'India';
            contact.MailingStreet = 'St';
            contact.MailingPostalCode = '100000';
            contact.MailingCity = 'Delhi';
            contact.MailingState = 'Delhi';
            contact.MailingCountry = 'India';
            contact.OtherPostalCode = '100000';
            contact.OtherStreet = 'St';
            contact.OtherCity = 'Delhi';
            contact.OtherState = 'Delhi';
            contact.Training_Status__c = (Math.mod(i, 2) == 0 ? 'CERT' : 'TB-CERT');
            contact.Roster_Status__c = 'O';
            contact.OtherCountry = 'India';
            contact.RecordTypeId = RecordType_Utils.getRecordTypeId('Contact', 'Contact_Expert');
            contacts.add(contact);
        }
        return contacts;
    }

     public static List<Contact> insertData(List<Contact> contacts) {
         insert contacts;
         return contacts;
     }
}