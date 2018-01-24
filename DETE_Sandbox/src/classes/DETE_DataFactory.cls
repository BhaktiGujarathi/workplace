public with sharing class DETE_DataFactory {

    public static String STR_JOBLINK_RESPONSE = '[{"id":"460876","title":"Project Manager","description":"Project Manager\nTracking Code\n12959\n\n\nJob Description\n\nJohnson, Mirmiran &amp; Thompson is a dynamic, 100% employee-owned consulting firm of more than 1,400 professionals that provides a full range of multi-disciplined engineering, architecture, information technology, and related services to public agencies and private clients throughout the United States. JMT, currently…","url":"http://joblink.delaware.gov/ada/r/jobs/460876","employer":"Johnson, Mirmiran & Thompson","location":"Newark, DE"},{"id":"474041","title":"Construction Superintendent","description":"Construction Superintendent Construction Superintendent – Skills Required – Superintendent, Commercial Construction, Project Management, Scheduling, Budgeting, Life Science, Industrial Construction\nIf you are a Construction Superintendent with retail/office/life science experience, this is the job for you! Located in the beautiful Newark, Delaware area, we are one of the largest general contractor…","url":"http://joblink.delaware.gov/ada/r/jobs/474041","employer":"CyberCoders","location":"Newark, DE"},{"id":"476901","title":"CONSTRUCTION DISPUTE RESOLUTION CONSULTANTS - Quantum & Dela","description":"CONSTRUCTION DISPUTE RESOLUTION CONSULTANTS – Quantum &amp; Delay\nBased in Hamburg, Germany\nOur Hill Germany business has continued to grow and develop, now with offices in Munich, Dusseldorf and Hamburg. As part of our growth strategy our Hamburg office is looking to recruit consultants of all levels to join their…","url":"http://joblink.delaware.gov/ada/r/jobs/476901","employer":"Hill International, Inc.","location":"DE, DE"},{"id":"469458","title":"Site Manager","description":"Requisition Number 16-0710\nPost Date 9/28/2016\n\nTitle Site Manager\n\nCity Various Cities\n\nCountry Argentina\n\nDescription\nGranite Services International, Inc. (www.gsinc.com) helps power the world, building industries and creating solutions to some of our customers’ most complex energy problems. With offices in more than 50 countries, we are a global leader…","url":"http://joblink.delaware.gov/ada/r/jobs/469458","employer":"Granite Services","location":"Dover, DE"},{"id":"482033","title":"Project Superintendent - Heavy Civil/ Marine/Water","description":"Title: Project Superintendent – Heavy Civil/ Marine/Water-Wastewater\nSummary:Cianbro is seeking an experienced Project Superintendent with heavy marine/ on water/ waste water experience for the Infrastructure Market.  This positon provides overall on-site administrative and technical management on construction at the project site. The Project Superintendent will supervise multiple foreman and…","url":"http://joblink.delaware.gov/ada/r/jobs/482033","employer":"CIANBRO CORP","location":"Wilmington, DE"},{"id":"469080","title":"Technische Gebude Ausrstung Engineer","description":"Hill International Inc. (NYSE:HIL) the worldwide construction consulting firm is expanding. With more than 4200 employees in 100 offices worldwide Hill provides program management project management construction management and construction claims services worldwide.\nHill International (www.hillintl.com) seeks to recruit for one of our projects…","url":"http://joblink.delaware.gov/ada/r/jobs/469080","employer":"Hill International, Inc.","location":"HE, DE"},{"id":"454977","title":"Construction Field Engineer - Power Generation","description":"Requisition Number 16-0313\nPost Date 5/20/2016\n\nTitle Construction Field Engineer – Power Generation\n\nCity Various USA\n\nCountry United States\n\nDescription\nGranite Services International, Inc. (www.gsinc.com) helps power the world, building industries and creating solutions to some of our customers’ most complex energy problems. With offices in more than 50 countries…","url":"http://joblink.delaware.gov/ada/r/jobs/454977","employer":"Granite Services","location":"Dover, DE"}]';
    public static String STR_ONET_RESPONSE    = '<?xml version="1.0" encoding="utf-8"?><related_occupations code="11-9021.00" report="details"><occupation href="https://services.onetcenter.org/ws/online/occupations/11-9041.00/"><code>11-9041.00</code><title>Architectural and Engineering Managers</title></occupation><occupation href="https://services.onetcenter.org/ws/online/occupations/17-2051.00/"><code>17-2051.00</code><title>Civil Engineers</title></occupation><occupation href="https://services.onetcenter.org/ws/online/occupations/17-2051.01/"><code>17-2051.01</code><title>Transportation Engineers</title></occupation><occupation href="https://services.onetcenter.org/ws/online/occupations/17-2051.02/"><code>17-2051.02</code><title>Transportation Engineers</title></occupation></related_occupations>';

    // method to create test Contact record
    public static Contact getContactRecord(Boolean isInsert, Id accountId) {
        Contact contact = new Contact();
        contact.AccountId = accountId;
        contact.FirstName = 'Test FContact';
        contact.LastName = 'Test Contact';
        contact.BirthDate = Date.today().addYears(-10);
        contact.Position_Title__c = 'Construction Managers';
        contact.Specific_Technologies__c = 'SAS software,The MathWorks MatLAB,Minitab software,Other Technologies';
        contact.General_Technologies__c = 'Accounting software,Spreadsheet software,Computer based training software, Other Tech';
        contact.Skills__c = 'Clerical,Sales and Marketing,Production and Processing,Engineering and Technology,Other Skills';
        contact.Knowledge__c = 'Accounting software,The MathWorks MatLAB,Other Knowledge';
        contact.MailingStreet = 'Pune, India';
        contact.Email = 'test@dete.com';
        contact.Education__c = 'High School Education/ High School Equivalency';
        contact.Industries__c = 'Accommodation and Food Services';
        contact.Salary__c = '$50,000 to $74,999';
        // contact.Industries__c = ;

        if(true == isInsert) {
            insert contact;
        }

        return contact;
    }

    // method to create test Account record
    public static Account getAccountRecord(Boolean isInsert) {
        Account account = new Account();
        account.Name = Label.DETE_AccountName;

        if(true == isInsert) {
            insert account;
        }

        return account;
    }

    public static User getUSerRecord(Boolean isInsert) {
        Id profileId = [
            SELECT Id
              FROM Profile
             WHERE Name =: Label.DETE_ProfileName
             LIMIT 1
         ].Id;
		//Id roleId = [Select u.Name, u.Id From UserRole u limit 1].id;
         Account account = DETE_DataFactory.getAccountRecord(true);

        Contact contact =  DETE_DataFactory.getContactRecord(true, account.Id);

        User user = new User();
        user.ContactId = contact.Id;
        user.FirstName = contact.FirstName;
        user.LastName = contact.LastName;
        user.Alias = contact.LastName.substring(1,4)+'1';
        user.CommunityNickname = contact.LastName.substring(1,4)+'1';
        user.Email = contact.Email;
        user.Username = contact.Email;
        user.ProfileId = profileId;
        //user.UserRoleId = roleId;
        user.Emailencodingkey='UTF-8';
        user.Languagelocalekey='en_US';
        user.Localesidkey='en_US';
        user.Country='United States';
        user.IsActive =true;
        user.Timezonesidkey='America/Los_Angeles';
        user.PortalRole = 'Manager';

        if(true == isInsert) {
            insert user;
        }

        return user;
    }

    public static List<Occupation__c> getOccupList(Boolean isInsert) {
        List<Occupation__c> occupationList = new List<Occupation__c>();

        occupationList.add(getOccupationRecord(false, 'Construction Managers', '11-9021.00') );
        occupationList.add(getOccupationRecord(false, 'Architectural and Engineering Managers', '11-9041.00') );
        occupationList.add(getOccupationRecord(false, 'Civil Engineers', '17-2051.00') );
        occupationList.add(getOccupationRecord(false, 'Transportation Engineers', '17-2051.01') );

        if(true == isInsert) {
            insert occupationList;
        }

        return occupationList;
    }

    public static Occupation__c getOccupationRecord(Boolean isInsert, String title, String socCode) {
        Occupation__c occ = new Occupation__c();
        occ.Title__c = title;
        occ.Name = socCode;
        occ.Description__c = 'Description of ' + title;

        if(true == isInsert) {
            insert occ;
        }
        return occ;
    }

    public static DETE_ONET_Integration_Details__c getOnetIntegrationSetting(Boolean isInsert) {
        DETE_ONET_Integration_Details__c onetIntegrationSetting = new DETE_ONET_Integration_Details__c();
        onetIntegrationSetting.Endpoint_URL__c = 'https://services.onetcenter.org/ws/online/';
        onetIntegrationSetting.User_Name__c = 'bw';
        onetIntegrationSetting.Password__c = 'espl@1234';

        if(true == isInsert) {
            insert onetIntegrationSetting;
        }

        return onetIntegrationSetting;
    }

    public static List<Technology__c> getHotTechnologyRecords(Boolean isInsert) {
        Id recordTypeId = [
            SELECT Id
             FROM RecordType
             WHERE Name = 'Hot Skill'
             LIMIT 1
        ].Id;

        List<Technology__c> technologyList = new List<Technology__c>();
        technologyList.add(getTechnology(false, 'The MathWorks MatLAB', recordTypeId));
        technologyList.add(getTechnology(false, 'SAS software', recordTypeId));
        technologyList.add(getTechnology(false, 'Minitab software', recordTypeId));

        if(true == isInsert) {
            insert technologyList;
        }

        return technologyList;
    }

    public static List<Technology__c> getGeneralTechnologyRecords(Boolean isInsert) {
        Id recordTypeId = [
            SELECT Id
             FROM RecordType
             WHERE Name = 'General Technology'
             LIMIT 1
        ].Id;

        List<Technology__c> technologyList = new List<Technology__c>();
        technologyList.add(getTechnology(false, 'Accounting software', recordTypeId));
        technologyList.add(getTechnology(false, 'Spreadsheet software', recordTypeId));
        technologyList.add(getTechnology(false, 'Facilities management software', recordTypeId));

        if(true == isInsert) {
            insert technologyList;
        }

        return technologyList;
    }

    public static Technology__c getTechnology(Boolean isInsert, String name, Id recordTypeId) {
        Technology__c tech = new Technology__c();
        tech.Name = name;
        tech.RecordTypeId = recordTypeId;

        if(true == isInsert) {
            insert tech;
        }

        return tech;
    }

    public static List<OccupationTechLineItem__c> getOccupationTechList(Boolean isInsert,
    List<Occupation__c> occupationList, List<Technology__c> technologyList) {

         Integer count;
         if( occupationList.size() == technologyList.size() ) {
             count = occupationList.size();
         } else if( occupationList.size() > technologyList.size() ) {
             count = technologyList.size();
         }

         OccupationTechLineItem__c occupationTech;
         List<OccupationTechLineItem__c> occupationTechList = new List<OccupationTechLineItem__c>();

        for(Integer i=0; i < count; i++) {
            occupationTech = new OccupationTechLineItem__c();
            occupationTech.Occupation__c = occupationList[i].id;
            occupationTech.Technology__c = technologyList[i].id;
            occupationTech.Rank__c = 1;
            occupationTechList.add(occupationTech);
        }

        occupationTech = new OccupationTechLineItem__c();
        occupationTech.Occupation__c = occupationList[2].id;
        occupationTech.Technology__c = technologyList[1].id;
        occupationTech.Rank__c = 3;

        occupationTechList.add(occupationTech);

        occupationTech = new OccupationTechLineItem__c();
        occupationTech.Occupation__c = occupationList[3].id;
        occupationTech.Technology__c = technologyList[2].id;
        occupationTech.Rank__c = 16;
        occupationTechList.add(occupationTech);

        if(true == isInsert) {
            insert occupationTechList;
        }

        return occupationTechList;
    }

    public static List<Knowledges__c> getKnowledges(Boolean isInsert) {
        List<Knowledges__c> knowledgeList = new List<Knowledges__c>();

        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameOne',
                                                  Element_Name__c = 'Accounting software'
                                           ));
        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameTwo',
                                                  Element_Name__c = 'Spreadsheet software'
                                           ));
        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameThree',
                                                  Element_Name__c = 'Facilities management software'
                                           ));
        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameThree',
                                                  Element_Name__c = 'The MathWorks MatLAB'
                                           ));
        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameThree',
                                                  Element_Name__c = 'SAS software'
                                           ));
        knowledgeList.add(new Knowledges__c(
                                                  Name = 'NameThree',
                                                  Element_Name__c = 'Minitab software'
                                           ));

        if(true == isInsert) {
            insert knowledgeList;
        }

        return knowledgeList;
    }
}