public class ProfileFactory {

    /**
    * Creates Profile record with for A- Nationality record type
    */
    public static List<Profile_Record__c> createNationalityProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 'A_Nationality');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId,
                Passport_Number__c = '123456789'+i,
                Passport_Expiry_Date__c = System.Today().addDays(i),
                Comments__c = 'Comment for A-Nationality Record type',
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for B- JRR Language record type
    */
    public static List<Profile_Record__c> createJRRProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 'B_JRR_Language');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId,
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                JRR_Language__c = 'English',
                General_Level__c = 'Basic',
                Reading__c = 'Basic',
                Writing__c = 'Basic',
                Oral_Understanding__c = 'Basic',
                Oral_Expression__c = 'Basic',
                Can_Conduct_Interview_Without_Interpret__c = 'Yes',
                Able_to_draft_report_without_translator__c = 'Yes',
                Can_Funtion_in_a_Professional_Setting__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for C- Other Language record type
    */
    public static List<Profile_Record__c> createOtherLanguageProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 'C_Other_Language');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId != null ? catalogId : null,
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                Other_Language__c = 'Greek',
                General_Level__c = 'Basic',
                Reading__c = 'Basic',
                Writing__c = 'Basic',
                Oral_Understanding__c = 'Basic',
                Oral_Expression__c = 'Basic',
                Can_Conduct_Interview_Without_Interpret__c = 'Yes',
                Able_to_draft_report_without_translator__c = 'Yes',
                Can_Funtion_in_a_Professional_Setting__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for D- Area of Expertise record type
    */
    public static List<Profile_Record__c> createAreaOfExpertiseProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'D_Area_of_Expertise');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId,
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                Other_Expertise__c = 'Experitse'+i,
                Explanation__c = 'Explanation for '+i+ 'Record',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for E- Legal System Expertise record type
    */
    public static List<Profile_Record__c> createLegalExpertiseProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'E_Legal_System_Expertise');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId,
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                Traditional_Justice_Def__c = 'Traditional Justice'+i,
                Countries_of_Jurisdiction__c = 'Albania;Algeria',
                Explanation__c = 'Explanation'+i,
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for F- Country Expertise record type
    */
    public static List<Profile_Record__c> createCountryExpertiseProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'F_Country_Expertise');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Entry_from_Catalog__c = catalogId,
                Expert__c = expertId != null ? expertId : null,
                Position__c = positionId != null ? positionId : null,
                Months_Spent_in_Country__c = 04,
                Type_of_Knowledge__c = 'Theor.',
                Explanation__c = 'Explanation for Country Expertise Profile',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for G- Employment record type
    */
    public static List<Profile_Record__c> createEmploymentProfile(Integer numberOfRecords, 
                                                Id expertId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'G_Employment');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Expert__c = expertId != null ? expertId : null,
                Employer__c = 'Employer'+i,
                Title_Position__c = 'Teacher',
                Department__c = 'Employment',
                Duty_Station_City__c = 'AlbaniaCity',
                Duty_Station_Country__c = 'Albania',
                Start_Date__c = system.Today().addDays(i),
                End_Date__c = system.Today().addDays(i+10),
                Duties__c = 'Duties for Employment Profile',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for H- Education record type
    */
    public static List<Profile_Record__c> createEducationProfile(Integer numberOfRecords, 
                                                Id expertId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'H_Education');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Expert__c = expertId != null ? expertId : null,
                Degree_Type__c = 'Management',
                Degree_Name__c = 'MBA',
                Institution__c = 'EducationInstitution',
                City__c = 'AlbaniaCity',
                Country__c = 'Albania',
                Start_Date__c = system.Today().addDays(i),
                End_Date__c = system.Today().addDays(i+10),
                Course_of_Study__c = 'Course of Study for Education Profile',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for I- Trainings and Qual. record type
    */
    public static List<Profile_Record__c> createTrainingProfile(Integer numberOfRecords, 
                                                Id expertId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'I_Trainings_and_Qual');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Expert__c = expertId != null ? expertId : null,
                Course_Name__c = 'Engineering',
                Institution__c = 'TrainingInstitution',
                City__c = 'AlbaniaCity',
                Country__c = 'Albania',
                Start_Date__c = system.Today().addDays(i),
                End_Date__c = system.Today().addDays(i+10),
                Number_of_Hours__c = 04.50,
                Course_of_Study__c = 'Course of Study for Education Profile',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
    
    /**
    * Creates Profile record with for J- Referee Expertise record type
    */
    public static List<Profile_Record__c> createRefereeProfile(Integer numberOfRecords, 
                                                Id catalogId,
                                                Id expertId,
                                                Id positionId) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Profile_Record__c', 
                                                           'J_Referee');
        List<Profile_Record__c> profiles = new List<Profile_Record__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Profile_Record__c profile = new Profile_Record__c(
                Expert__c = expertId != null ? expertId : null,
                Salutation__c = 'Mr.',
                Name__c = 'TestName'+i,
                Surname__c ='TestSurname'+i,
                Organisation__c = 'Organization'+i,
                Title__c = 'Title'+i,
                Speaks_English_French_or_Spanish__c = 'Yes',
                Relationship__c = 'previous colleague',
                Telephone_Number_1__c = '98765432'+i,
                Telephone_Number_2__c = '12345678'+i,
                Email_Address_1__c = 'firstEmail@gmail.com',
                Email_Address_2__c = 'secondEmail@gmail.com',
                Language__c = 'English',
                RecordTypeId = recordTypeId
            );
            profiles.add(profile);
        }
        return profiles;
    }
}