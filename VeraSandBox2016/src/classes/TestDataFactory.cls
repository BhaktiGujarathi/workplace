/***********************************************************************************
 * Class : TestDataFactory
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : This class provides methods which create test data.
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    20/04/2016    Initial Development
 **********************************************************************************/
@isTest
public class TestDataFactory {

    /**
     * Creates Training__c object data
     *
     * @param count   Number of records to be created
     * @param country Country__c record to be used as lookup
     */
    public static List<Training__c> createTrainingData(Integer count, Country__c country) {
        List<Training__c> trainings = new List<Training__c>();
        for (Integer i = 1; i <= count; i++) {
            Training__c training = new Training__c();
            training.Name = 'Test'+i;
            training.Country__c = country.Id;
            training.Status__c = 'PLAN';
            training.Start_Date__c = System.today();
            training.End_Date__c = System.today() + 5;
            trainings.add(training);
        }
        insert trainings;
        return trainings;
    }

    /**
     * Creates Account object data
     *
     * @param count   Number of records to be created
     */
    public static List<Account> createAccountData(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= count; i++) {
            Account account = new Account();
            account.Name = 'Test'+i;
            accounts.add(account);
        }
        insert accounts;
        return accounts;
    }

    /**
     * Creates Contact object data
     *
     * @param count    Number of records to be created
     * @param account  Account record to be used for lookup
     */
    public static List<Contact> createContactData(Integer count, Account account) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= count; i++) {
            Contact contact = new Contact();
            contact.LastName = 'Test'+i;
            contact.AccountId = account != null ? account.Id : null;
            contacts.add(contact);
        }
        insert contacts;
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
            contact.OtherCountry = 'India';
            contact.RecordTypeId = getRecordTypeId('Contact', 'Contact - Expert');
            contacts.add(contact);
        }
        insert contacts;
        return contacts;
    }

    /**
     * Creates Campaign object data
     *
     * @param count Number of records to be created
     */
    public static List<Campaign> createCampaignData(Integer count) {
        List<Campaign> campaigns = new List<Campaign>();
        for (Integer i = 1; i <= count; i++) {
            Campaign campaign = new Campaign();
            campaign.Name = 'Test'+i;
            campaigns.add(campaign);
        }
        insert campaigns;
        return campaigns;
    }

    /**
     * Creates Country__c object data
     *
     * @param count Number of records to be created
     */
    public static List<Country__c> createCountryData(Integer count) {
        List<Country__c> countries = new List<Country__c>();
        for (Integer i = 1; i <= count; i++) {
            Country__c country = new Country__c();
            country.Name = 'Test'+i;
            country.Official_Name__c = 'Test'+i;
            country.UN_Member__c = 'Yes';
            country.Region_UN__c = 'Asia';
            country.MENA_JRR__c = 'Yes';
            country.DAC_List__c = 'Yes';
            country.HRC_Member__c = 'Yes';
            country.Rome_Statute__c = 'Yes';
            countries.add(country);
        }
        insert countries;
        return countries;
    }

    /**
     * Creates Nomination__c object data
     *
     * @param count     Number of records to be created
     * @param campaign  Campaign record for lookup
     * @param training  Training__c record for lookup
     * @param expert    Expert(Contact) record for lookup
     */
    public static List<Nomination__c> createNominations(Integer count, Campaign campaign,
                                                        Training__c training, Contact expert) {
        List<Nomination__c> nominations = new List<Nomination__c>();
        for (Integer i = 1; i <= count; i++) {
            Nomination__c nomination = new Nomination__c(
                Training__c = training.Id,
                Contact__c = expert.Id,
                CFN__c = campaign.Id,
                Status__c = 'SUB',
                Nominating_Entity_Name__c = 'Test',
                Type_of_Organization__c = 'GOV',
                Salutation__c = 'Mr',
                Contact_Person_Name__c = expert.LastName,
                Title_Position__c = 'Test Title',
                Relationship_with_Nominee__c = 'Test Relationship',
                Phone__c = '9887654321',
                Mobile__c = '9887654321',
                Email_1__c = 'test@example.com',
                Financial_Support_Requested__c = 'Yes',
                Expression_of_interest_Statement__c = 'Test expression',
                Name_of_Entity_CFN_Received_From__c = 'Test Name'
            );
            nominations.add(nomination);
        }
        insert nominations;
        return nominations;
    }

    /**
     * Create Catalog object data
     *
     * @param recordTypeName    Record type name for Catalog__c
     */
    public static Catalog__c createCatlogData(String recordTypeName) {
        Id recId = RecordType_Utils.getRecordTypeId('Catalog__c', recordTypeName);
        Catalog__c catalog = new Catalog__c(
                                Name = 'English',
                                Language_Category__c = 'JRR',
                                RecordTypeId = recId
                            );
        //insert catalog;
        return catalog;
    }

    /**
     * Create Profile record object data
     *
     * @param contact           Contact record for lookup
     * @param catalog           Catalog__c record for lookup
     * @param recordTypeName    Record type name for Profile_Record__c
     */
    public static Profile_Record__c createprofileRecordData(
        Contact contact,
        Catalog__c catalog,
        String recordTypeName
    ) {
        Id recId = RecordType_Utils.getRecordTypeId('Profile_Record__c', recordTypeName);

        Profile_Record__c record = new Profile_Record__c(
                                        Title_Position__c = 'CEO',
                                        Duty_Station_Country__c = '',
                                        Contact__c = contact != null ? contact.Id : null,
                                        Expert__c = contact != null ? contact.Id : null,
                                        Entry_from_Catalog__c = catalog != null ? catalog.Id : null,
                                        RecordTypeId = recId
                                    );
        return record;
    }

    /**
     * Fetch profile records related to passed contact id
     *
     * @param id Contact record's id
     */
    public static List<Profile_Record__c> fetchProfileRecords(Id id) {
        List<Profile_Record__c> records = [
            SELECT
                Employer__c,
                Title_Position__c,
                Expert__c,
                RecordTypeId
            FROM
                Profile_Record__c
            WHERE
                Expert__c =: id
        ];
        return records;
    }

    /**
     * Create custom setting records for Full Profile Custom Setting
     */
    public static Void createFullProfileCustomSettings() {
        List<Full_Profile_Setting__c> fullProfileSettings = new List<Full_Profile_Setting__c>();
        Full_Profile_Setting__c employmentSetting = new Full_Profile_Setting__c(
                                                        Name = 'ExpertSearchFullProfile Employment',
                                                        Fields__c = 'Employment',
                                                        Page_Name__c = 'ExpertSearchFullProfile',
                                                        Section_Name__c = 'Employment',
                                                        Layout__c = 'Table',
                                                        Object_Api_Name__c = 'Profile_Record__c',
                                                        Filter_By_Record_Type__c = 'G_Employment'
                                                    );
        fullProfileSettings.add(employmentSetting);
        Full_Profile_Setting__c educationSetting = new Full_Profile_Setting__c(
                                                    Name = 'ExpertSearchFullProfile Education',
                                                    Fields__c = 'Education',
                                                    Page_Name__c = 'ExpertSearchFullProfile',
                                                    Section_Name__c = 'Education',
                                                    Layout__c = 'Table',
                                                    Object_Api_Name__c = 'Profile_Record__c',
                                                    Filter_By_Record_Type__c = ''
                                                );
        fullProfileSettings.add(educationSetting);
        Full_Profile_Setting__c expertDetailSetting = new Full_Profile_Setting__c(
                                                        Name = 'ExpertSearchFullProfile Expert Detail',
                                                        Fields__c = 'Expert_Detail',
                                                        Page_Name__c = 'ExpertSearchFullProfile',
                                                        Section_Name__c = 'Expert Detail'
                                                    );
        fullProfileSettings.add(expertDetailSetting);
        insert fullProfileSettings;
    }

    /**
     * Creates data for ExpertSearchPositionFilters custom setting
     */
    public static Void createExpertSearchPositionFiltersSettings() {
        List<ExpertSearchPositionFilters__c> filterSettings
            = new List<ExpertSearchPositionFilters__c>();
        ExpertSearchPositionFilters__c areaOfExpertise
            = new ExpertSearchPositionFilters__c(
                Name = 'Area of Expertise',
                Level_2_Criteria__c = 'AoE_Category__c',
                Level_2_Criteria_Type__c = 'Picklist',
                Level_2_ObjectName__c = 'Catalog__c',
                Level_3_Criteria__c = 'AoE_Category__c',
                Level_3_Criteria_Type__c = 'Object',
                Level_3_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(areaOfExpertise);
        ExpertSearchPositionFilters__c characteristics
            = new ExpertSearchPositionFilters__c(
                Name = 'Characteristics',
                Level_2_Criteria__c = 'Gender,Global South,Seniority,Sub-Roster',
                Level_2_Criteria_Type__c = 'Constant',
                Level_2_ObjectName__c = '',
                Level_3_Criteria__c = '',
                Level_3_Criteria_Type__c = 'ExceptionalFilter',
                Level_3_ObjectName__c = 'Contact'
            );
        filterSettings.add(characteristics);
        ExpertSearchPositionFilters__c coreExpertise
            = new ExpertSearchPositionFilters__c(
                Name = 'Core Expertise',
                Level_2_Criteria__c = 'AoE_Category__c',
                Level_2_Criteria_Type__c = 'Picklist',
                Level_2_ObjectName__c = 'Catalog__c',
                Level_3_Criteria__c = 'AoE_Category__c',
                Level_3_Criteria_Type__c = 'Object',
                Level_3_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(coreExpertise);
        ExpertSearchPositionFilters__c countryExpertise
            = new ExpertSearchPositionFilters__c(
                Name = 'Country Expertise',
                Level_2_Criteria__c = 'Region_UN__c',
                Level_2_Criteria_Type__c = 'Picklist',
                Level_2_ObjectName__c = 'Catalog__c',
                Level_3_Criteria__c = 'Region_UN__c',
                Level_3_Criteria_Type__c = 'Object',
                Level_3_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(countryExpertise);
        ExpertSearchPositionFilters__c language
            = new ExpertSearchPositionFilters__c(
                Name = 'Language',
                Level_2_Criteria__c = 'JRR Language,Other Language',
                Level_2_Criteria_Type__c = 'Constant',
                Level_2_ObjectName__c = '',
                Level_3_Criteria__c = '',
                Level_3_Criteria_Type__c = 'ExceptionalFilter',
                Level_3_ObjectName__c = 'Catalog__c',
                Level_4_Criteria__c = 'General_Level__c',
                Level_4_Criteria_Type__c = 'Picklist',
                Level_4_ObjectName__c = 'Profile_Record__c'
            );
        filterSettings.add(language);
        ExpertSearchPositionFilters__c legalSystems
            = new ExpertSearchPositionFilters__c(
                Name = 'Legal Systems',
                Level_2_Criteria__c = 'RecordType.DeveloperName = \'Legal_System\'',
                Level_2_Criteria_Type__c = 'Object',
                Level_2_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(legalSystems);
        ExpertSearchPositionFilters__c nationality
            = new ExpertSearchPositionFilters__c(
                Name = 'Nationality',
                Level_2_Criteria__c = 'Region_UN__c',
                Level_2_Criteria_Type__c = 'Picklist',
                Level_2_ObjectName__c = 'Catalog__c',
                Level_3_Criteria__c = 'Region_UN__c',
                Level_3_Criteria_Type__c = 'Object',
                Level_3_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(nationality);
        ExpertSearchPositionFilters__c profession
            = new ExpertSearchPositionFilters__c(
                Name = 'Profession',
                Level_2_Criteria__c = 'Profession_Category__c',
                Level_2_Criteria_Type__c = 'Picklist',
                Level_2_ObjectName__c = 'Catalog__c',
                Level_3_Criteria__c = 'Profession_Category__c',
                Level_3_Criteria_Type__c = 'Object',
                Level_3_ObjectName__c = 'Catalog__c'
            );
        filterSettings.add(profession);
        insert filterSettings;
    }

    /**
     * Creates data for ExpertSearchPositionFilters custom setting
     */
    public static Void createExpertSearchPopulateFiltersSettings() {
        List<ExpertSearchPopulateFilters__c> filterSettings
            = new List<ExpertSearchPopulateFilters__c>();
        ExpertSearchPopulateFilters__c nationalityProfileRecord
            = new ExpertSearchPopulateFilters__c(
                Name = 'A_Nationality PR',
                Level_1_Criteria__c = 'Nationality',
                Level_1_Criteria_Type__c = 'Constant',
                Level_2_Criteria__c = 'Entry_from_Catalog__r.Region_UN__c',
                Level_2_Criteria_Type__c = 'ApiFieldName',
                Level_3_Criteria__c = 'Entry_from_Catalog__c',
                Level_3_Criteria_Type__c = 'ApiFieldName',
                ValueType__c = 'Record'
            );
        filterSettings.add(nationalityProfileRecord);
        ExpertSearchPopulateFilters__c jrrLangProfileRecord
            = new ExpertSearchPopulateFilters__c(
                Name = 'B_JRR_Language PR',
                Level_1_Criteria__c = 'Language',
                Level_1_Criteria_Type__c = 'Constant',
                Level_2_Criteria__c = 'JRR Language',
                Level_2_Criteria_Type__c = 'Constant',
                Level_3_Criteria__c = 'Entry_from_Catalog__c',
                Level_3_Criteria_Type__c = 'ApiFieldName',
                Level_4_Criteria__c = 'General_Level__c',
                Level_4_Criteria_Type__c = 'ApiFieldName',
                ValueType__c = 'Record'
            );
        filterSettings.add(jrrLangProfileRecord);
        ExpertSearchPopulateFilters__c coreExpertise1
            = new ExpertSearchPopulateFilters__c(
                Name = 'Core_Expertise_1__c',
                Level_1_Criteria__c = 'Core Expertise',
                Level_1_Criteria_Type__c = 'Constant',
                Level_2_Criteria__c = 'Core_Expertise_1__r.AoE_Category__c',
                Level_2_Criteria_Type__c = 'ApiFieldName',
                Level_3_Criteria__c = 'Core_Expertise_1__c',
                Level_3_Criteria_Type__c = 'ApiFieldName',
                ValueType__c = 'Record'
            );
        filterSettings.add(coreExpertise1);
        insert filterSettings;
    }

    /**
     * Method to get record type id by name
     */
    private static Id getRecordTypeId(String objectName, String recordTypeName) {
        Id recordTypeId = null;
        if (String.isNotBlank(objectName) && String.isNotBlank(recordTypeName)) {
            Map<String, Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
            recordTypeId = sobjectTypeMap.get(objectName).getDescribe().getRecordTypeInfosByName()
                                .get(recordTypeName).getRecordTypeId();
        }
        return recordTypeId;
    }

}