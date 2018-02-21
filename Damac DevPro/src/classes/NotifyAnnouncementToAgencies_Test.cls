@isTest
public class NotifyAnnouncementToAgencies_Test {
    
    @testSetup static void methodName() {
        List<Announcement_Emails_for_Profiles__c> lstAnnoucementEmail = new List<Announcement_Emails_for_Profiles__c>();
        lstAnnoucementEmail .add(new Announcement_Emails_for_Profiles__c(Name='Agent + Admin + Auth',Profile_Name__c='Customer Community - Agent + Admin + Auth',Is_Subcribed__c = true));
        lstAnnoucementEmail .add(new Announcement_Emails_for_Profiles__c(Name='Customer Community - Admin',Profile_Name__c='Customer Community - Admin',Is_Subcribed__c = true));
        lstAnnoucementEmail .add(new Announcement_Emails_for_Profiles__c(Name='Customer Community - Agent + Admin',Profile_Name__c='Customer Community - Agent + Admin',Is_Subcribed__c = true));
        lstAnnoucementEmail .add(new Announcement_Emails_for_Profiles__c(Name='Customer Community - Auth + Admin',Profile_Name__c='Customer Community - Auth + Admin',Is_Subcribed__c = true));
        
        insert lstAnnoucementEmail;
    } 
    
    static testmethod void testnotifyAgents1(){
        
        Id AgencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        
        ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;

        Account A1 = new Account(Name = 'Test Account', Agency_Type__c = 'Corporate');
        insert A1;
        
        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User', 
        email = 'test-user@fakeemail.com' );
        insert C1; 
        
        User u1 = new User( email='test-user@fakeemail.com', contactid = c1.id, profileid = profileID, 
                  UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1', 
                  TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                  LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
        insert u1;

        Account acc = new account();
        acc.name='Real estate brokers';
        acc.recordtypeId = AgencyRecordTypeId;
        acc.Agency_Type__c='Corporate';
        insert acc;
        
        Announcement__c aObj = new Announcement__c();
        aObj.Active__c = true;
        aObj.Start_date__c = System.today();
        aObj.End_date__c = System.today().addDays(30);
        aObj.Description__c = 'blah blah blah';
        aObj.title__c='Bumper OFfer';
        aObj.Agency_Type__c='All';
        aObj.Agency_tier__c='All';
        insert aObj;
        
        NotifyAnnouncementToAgencies.notifyAgencyAdminswithanAnnouncement(aObj.Id);
        
    }
    
    static testmethod void testnotifyAgents2(){
        
        Id AgencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        
        Account acc = new account();
        acc.name='Real estate brokers';
        acc.recordtypeId = AgencyRecordTypeId;
        acc.Agency_Type__c='Corporate';
        insert acc;
        
        Announcement__c aObj = new Announcement__c();
        aObj.Active__c = false;
        aObj.Start_date__c = System.today();
        aObj.End_date__c = System.today().addDays(30);
        aObj.Description__c = 'blah blah blah';
        aObj.title__c='Bumper OFfer';
        aObj.Agency_Type__c='Corporate';
        aObj.Agency_tier__c='Silver';
        insert aObj;
        
        NotifyAnnouncementToAgencies.notifyAgencyAdminswithanAnnouncement(aObj.Id);
        
    }
    
    static testmethod void testnotifyAgents3(){
        
        Id AgencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        
        Account acc = new account();
        acc.name='Real estate brokers';
        acc.recordtypeId = AgencyRecordTypeId;
        acc.Agency_Type__c='Corporate';
        insert acc;
        
        Announcement__c aObj = new Announcement__c();
        aObj.Active__c = false;
        aObj.Start_date__c = System.today();
        aObj.End_date__c = System.today().addDays(30);
        aObj.Description__c = 'blah blah blah';
        aObj.title__c='Bumper OFfer';
        aObj.Agency_Type__c='Corporate';
        aObj.Agency_tier__c='All';
        insert aObj;
        
        NotifyAnnouncementToAgencies.notifyAgencyAdminswithanAnnouncement(aObj.Id);
        
        
        aObj.Active__c = true;
        update aObj;
        NotifyAnnouncementToAgencies.notifyAgencyAdminswithanAnnouncement(aObj.Id);
        
    }
    
    
}