public without sharing class DETE_ProfilePageController extends DETE_BaseClass {
    static final String EMAIL_TEMPLATE_NAME = 'DETE_Profile Alert';
    public Boolean isLoggedIn                                         {get;set;}

    public Contact stdContact                                         {get; set;}
    public String loginStatusStr                                      {get; set;}

    public List<SkillSetWrapper> hotTechnologies                      {get; set;}
    public List<SkillSetWrapper> generalTechnologies                  {get; set;}
    public List<SkillSetWrapper> knowledgeList                        {get; set;}
    public List<SkillSetWrapper> industryLst                          {get; set;}
    public List<SkillSetWrapper> salaryRangeLst                       {get; set;}
    public List<Technology__c> technologylst                          {get; set;}

    public String occupationTitle                                     {get; set;}
    public String occupationString                                    {get; set;}
    public String passwordStr                                         {get; set;}
    public String confirmPswrdStr                                     {get; set;}
    public String emailStr                                            {get; set;}
    public String confirmEmailStr                                     {get; set;}
    public String conDOBDate                                          {get; set;}
    //public String strUserName                                         {get; set;}
    public Boolean isOtherTech                                        {get; set;}
    public String otherTech                                           {get; set;}
    public Boolean isOtherGeneralTechnology                           {get;set;}
    public String otherGeneralTechnology                              {get; set;}
    public Boolean isOtherKnowledge                                   {get; set;}
    public String otherKnowledge                                      {get; set;}
    public String messageStr                                          {get; set;}
    public String redirectUrl                                         {get; set;}
    private Id accountId;
    private Id profileId;
    private Id contactId;
    public User userObj;

    //private String userNameParam;
    //public String conAddress1Str                                      {get; set;}
    //public String conAddress2Str                                      {get; set;}

    // constructor
    public DETE_ProfilePageController() {
        stdContact = new Contact();
        userObj = new User();
        isLoggedIn = false;

        isOtherTech = true;
        otherTech = '';
        isOtherGeneralTechnology = true;
        otherGeneralTechnology = '';
        isOtherKnowledge = true;
        otherKnowledge = '';

        // strUserName = System.currentPageReference().getParameters().get(Label.DETE_UserNameParameter);
        if (!String.isBlank(strUserName)) {
            list<User> listUser = new list<User>();
            listUser = [SELECT Id,
                               ContactId,
                               Username,
                               LastName,
                               FirstName,
                               CommunityNickname
                        FROM User
                        WHERE Username =: strUserName
                        limit 1
                       ];

            if (!listUser.isEmpty() && listUser[0].ContactId != null) {
                userObj = listUser[0];
                isLoggedIn = true;
                list<Contact> listContact = new list<Contact>();
                listContact = [Select Id,
                                      FirstName,
                                      LastName,
                                      MailingCity,
                                      MailingState,
                                      MailingPostalCode,
                                      Phone,
                                      Email,
                                      Education__c,
                                      Other_Education__c,
                                      Position_Title__c,
                                      Company__c,
                                      Knowledge__c,
                                      General_Technologies__c,
                                      Salutation,
                                    //   Middle_Name__c,
                                      Birthdate,
                                      Additional_Abilities__c,
                                      Salary__c,
                                      Priorities_for_next_Role__c,
                                      Travelling_Distance__c,
                                      Mode_of_Communication__c,
                                      Industries__c,
                                      MailingStreet,
                                      Specific_Technologies__c,
                                      Address1__c,
                                      Address2__c,
                                      Enable_Notifications__c,
                                      Other_Mode_of_Communication__c,
                                      Interested_in_community_of_entrepreneurs__c
                               From Contact
                               Where Id =: listUser[0].ContactId
                               limit 1
                              ];
                if (!listContact.isEmpty()) {
                    stdContact = listContact[0];
                    contactId = listContact[0].Id;
                    stdContact.Id = null;
                }
            }
        } else {
            stdContact = new Contact();
            fetchProfileAndAccount();
            strUserName = '';
        }
        technologylst = fetchTechnologiesLst();
        hotTechnologies = getHotSkills(technologylst);
        generalTechnologies = getGeneralSkills(technologylst);
        knowledgeList = fetchKnowledge();
        industryLst = fetchIndustries();
        salaryRangeLst = fetchSalaryRange();
        loginStatusStr = 'Log Out';
        emailStr = stdContact.Email;
        confirmEmailStr = stdContact.Email;
        occupationString = stdContact.Position_Title__c;
        //conDOBDate = stdContact.Birthdate;
        if (stdContact.Birthdate != null) {
            conDOBDate = stdContact.Birthdate.month() + '/'
                        + stdContact.Birthdate.day() + '/'
                        + stdContact.Birthdate.year();
        } else {
            conDOBDate = '';
        }
        passwordStr = '';
        confirmPswrdStr = '';
      //  userNameParam = System.currentPageReference().getParameters().get('unm');
    }

    // To fetch related account and Profile to create new User and Contact
    private void fetchProfileAndAccount() {
        list<Account> listAccount = new list<Account>();
        listAccount = [Select Id,
                              Name
                       From Account
                       Where Name =: Label.DETE_AccountName
                       limit 1
                      ];
        if (!listAccount.isEmpty()) {
            accountId = listAccount[0].Id;
        }

        list<Profile> listProfile = new list<Profile>();
        listProfile = [Select Id
                       From Profile
                       Where Name =: Label.DETE_ProfileName
                       limit 1
                      ];
        if (!listProfile.isEmpty()) {
            profileId = listProfile[0].Id;
        }
    }

    // method to get list of general skills form the list of HOT skills
    public List<SkillSetWrapper> getHotSkills(List<Technology__c> pTechnologylst) {
        hotTechnologies = new List<SkillSetWrapper>();
        set<String> setSkills = new set<String>();

        if (stdContact != null && !String.isBlank(stdContact.Specific_Technologies__c)) {
            setSkills.addAll(stdContact.Specific_Technologies__c.trim().toLowerCase().split(','));
        }

        set<String> setSelectedSkills = new set<String>(setSkills);

        for(Technology__c techItr : pTechnologylst) {
            if(techItr.RecordType.DeveloperName.equalsIgnoreCase('Hot_Skill')) {
                if (!setSkills.contains(techItr.Name.toLowerCase())) {
                    hotTechnologies.add(new SkillSetWrapper(techItr.Name, false));
                } else {
                    hotTechnologies.add(new SkillSetWrapper(techItr.Name, true));
                    setSelectedSkills.remove(techItr.Name.toLowerCase());
                }
            }
        }
        if (!setSelectedSkills.isEmpty()) {
            isOtherTech = true;
            otherTech = String.join(new list<String>(setSelectedSkills), ',');
        }
        return hotTechnologies;
    }

    // method to get list of general skills form the list of general skills
    public List<SkillSetWrapper> getGeneralSkills(List<Technology__c> pTechnologylst) {
        generalTechnologies = new List<SkillSetWrapper>();
        set<String> setGeneralTechnologies = new set<String>();

        if (stdContact != null && !String.isBlank(stdContact.General_Technologies__c)) {
            setGeneralTechnologies.addAll(
                stdContact.General_Technologies__c.trim().toLowerCase().split(',')
            );
        }

        set<String> setSelectedGeneralTechnologies = new set<String>(setGeneralTechnologies);

        for(Technology__c techItr : pTechnologylst) {
            if(techItr.RecordType.DeveloperName.equalsIgnoreCase('General_Technology')) {
                if (!setGeneralTechnologies.contains(techItr.Name.toLowerCase())) {
                    generalTechnologies.add(new SkillSetWrapper(techItr.Name, false));
                } else {
                    generalTechnologies.add(new SkillSetWrapper(techItr.Name, true));
                    setSelectedGeneralTechnologies.remove(techItr.Name.toLowerCase());
                }
            }
        }

        if (!setSelectedGeneralTechnologies.isEmpty()) {
            isOtherGeneralTechnology = true;
            otherGeneralTechnology = String.join(new list<String>(setSelectedGeneralTechnologies), ',');
        }

        return generalTechnologies;
    }

    // method to get list of general skills form the list of general skills
    public List<SkillSetWrapper> fetchKnowledge() {
        List<SkillSetWrapper> listSkillSetWrapperKnowledge = new List<SkillSetWrapper>();
        set<String> setSkills = new set<String>();

        if (stdContact != null && !String.isBlank(stdContact.Knowledge__c)) {
            setSkills.addAll(
                stdContact.Knowledge__c.trim().toLowerCase().split(',')
            );
        }

        set<String> setSelectedKnowledge = new set<String>(setSkills);
        for(
                Knowledges__c knowledgeItr :
                    [SELECT Id,
                            Element_name__c
                     FROM Knowledges__c]
        ) {
            if (!setSkills.contains(knowledgeItr.Element_name__c.toLowerCase())) {
                listSkillSetWrapperKnowledge.add(new SkillSetWrapper(knowledgeItr.Element_name__c, false));
            } else {
                listSkillSetWrapperKnowledge.add(new SkillSetWrapper(knowledgeItr.Element_name__c, true));
                setSelectedKnowledge.remove(knowledgeItr.Element_name__c.toLowerCase());
            }
        }

        if (!setSelectedKnowledge.isEmpty()) {
            isOtherKnowledge = true;
            otherKnowledge = String.join(new list<String>(setSelectedKnowledge), ',');
        }

        return listSkillSetWrapperKnowledge;
    }

    // method to get list for Industries from DB
    public List<SkillSetWrapper> fetchIndustries() {
        List<SkillSetWrapper> industryWrpprLst = new List<SkillSetWrapper>();
        set<String> setIndustries = new set<String>();

        if (stdContact != null && !String.isBlank(stdContact.Industries__c)) {
            setIndustries.addAll(
                stdContact.Industries__c.trim().toLowerCase().split(';')
            );
        }
        for(
                Schema.PicklistEntry picklistObj :
                    Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getmap().get('Industries__c').getDescribe().getpicklistValues()
        ) {
            if (!setIndustries.contains(picklistObj.getLabel().toLowerCase())) {
                industryWrpprLst.add(new SkillSetWrapper(picklistObj.getLabel(), false));
            } else {
                industryWrpprLst.add(new SkillSetWrapper(picklistObj.getLabel(), true));
            }
        }
        return industryWrpprLst;
    }

    // method to get list for Salary Range from DB
    public List<SkillSetWrapper> fetchSalaryRange() {
        List<SkillSetWrapper> salaryWrpprLst = new List<SkillSetWrapper>();
        set<String> setSalaries = new set<String>();

        if (stdContact != null && !String.isBlank(stdContact.Salary__c)) {
            setSalaries.addAll(
                stdContact.Salary__c.trim().toLowerCase().split(';')
            );
        }
        for(
                Schema.PicklistEntry picklistObj :
                    Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getmap().get('Salary__c').getDescribe().getpicklistValues()
        ) {
            if (!setSalaries.contains(picklistObj.getLabel().toLowerCase())) {
                salaryWrpprLst.add(new SkillSetWrapper(picklistObj.getLabel(), false));
            } else {
                salaryWrpprLst.add(new SkillSetWrapper(picklistObj.getLabel(), true));
            }
        }
        return salaryWrpprLst;
    }

    // method to fetch all skills from the DB
    private List<Technology__c> fetchTechnologiesLst() {
        return [SELECT Id,
                       Name,
                       RecordType.DeveloperName
                FROM Technology__c
                ORDER BY Name];
    }

    public PageReference submitprofile() {
        Id userId;
        Savepoint rollBackSavePoint = Database.setSavepoint();

        try {

            //stdContact.FirstName = stdContact.FirstName + ' ' + stdContact.Middle_Name__c + '.';
            stdContact.Position_Title__c = occupationString;
            stdContact.Specific_Technologies__c = String.join(fetchSelectedSkillTechnologies(hotTechnologies, otherTech ),',');
            stdContact.General_Technologies__c = String.join(fetchSelectedSkillTechnologies(generalTechnologies, otherGeneralTechnology),',');
            stdContact.Knowledge__c = String.join(fetchSelectedSkillTechnologies(knowledgeList, otherKnowledge),',');
            stdContact.MailingStreet = stdContact.Address1__c;

            if (String.isNotBlank(stdContact.Address2__c)) {
                stdContact.MailingStreet += ', '+ stdContact.Address2__c;
            }
            stdContact.Industries__c = String.join(fetchSelectedSkillTechnologies(industryLst, ''),';');
            stdContact.Salary__c = String.join(fetchSelectedSkillTechnologies(salaryRangeLst, ''),';');

            if (String.isNotBlank(conDOBDate)) {
                list<String> listDateSplit = conDOBDate.split('/');
                stdContact.BirthDate = date.valueOf(listDateSplit[2] + '-' + listDateSplit[0] + '-' + listDateSplit[1]);
            }

            if (!stdContact.Education__c.equalsIgnoreCase('Other (please specify)')) {
                stdContact.Other_Education__c = '';
            }

            if (!stdContact.Mode_of_Communication__c.equalsIgnoreCase('Other(please specify)')) {
                stdContact.Other_Mode_of_Communication__c = '';
            }

            if (isLoggedIn == null || !isLoggedIn) {
                if(accountId != null) {
                    stdContact.AccountId = accountId;
                 }
                // create user
                User userObj = new User();

                    stdContact.Email = emailStr;
                    stdContact.Id = null;
                    insert stdContact;

                    userObj.ContactId = stdContact.Id;
                    userObj.FirstName = stdContact.FirstName;
                    userObj.LastName = stdContact.LastName;
                    userObj.Alias = String.valueOf(stdContact.Id).right(8);
                    userObj.CommunityNickname = emailStr + '1' ;
                    userObj.Email = emailStr;
                    userObj.Username = emailStr;
                    userObj.ProfileId = profileId;
                    /*userObj.EmailEncodingKey='UTF-8';
                    userObj.LanguageLocaleKey='en_US';
                    userObj.LocaleSidKey='en_US';
                    userObj.TimeZoneSidKey='America/Los_Angeles';
                    insert userObj;
                    userId = userObj.Id;*/
                    userId = Site.createPortalUser(userObj, accountId, passwordStr);

                    if (userId == null) {
                        ApexPages.Message msgStr = new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'Error: Some other user might have same specified email address as you have mentioned. Please contact administrator regarding same.'
                        );
                        ApexPages.addMessage(msgStr);
                        Database.rollback(rollBackSavePoint);
                        return null;
                    } else {
                        strUserName = userObj.Username;

                        messageStr = 'Make the most of your job search <br/> Creating a Talent Exchange Profile '
                            + 'will enable you to begin exploring new fields and new job opportunities.';

                        redirectUrl = Site.getPathPrefix()
                                    + '/DETE_HomePage';
                        sendMail(stdContact);
                }
            } else {

                messageStr = 'Profile changes are saved successfully.';
                stdContact.Id = contactId;
                update stdContact;
            }

            if (String.isBlank(strUserName)) {
                strUserName = '';
            }

        } catch(Exception exObj) {
            system.debug('>>> exObj : '+exObj);
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.ERROR, exObj.getMessage());
            ApexPages.addMessage(msgStr);
            Database.rollback(rollBackSavePoint);
            return null;
        }
        return null;
    }

    @remoteAction
    public static List<sObject> getOccupations(String searchText) {
        return [SELECT Id,
                       Title__c
                  FROM Occupation__c
                 WHERE Title__c LIKE:  ('%' + String.escapeSingleQuotes(searchText) + '%')];
    }


    /*private List<String> fetchSelectedSkills() {
        List<String> selectedStrings = new List<String>();
        for(SkillSetWrapper wrapItr : hotTechnologies) {
            if(wrapItr.isSelected) {
                selectedStrings.add(wrapItr.title);
            }
        }
        return selectedStrings;
    }

    private List<String> fetchSelectedGeneralTechnologies() {
        List<String> selectedStrings = new List<String>();
        for(SkillSetWrapper objSkillSetWrapper : generalTechnologies) {
            if(objSkillSetWrapper.isSelected) {
                selectedStrings.add(objSkillSetWrapper.title);
            }
        }
        return selectedStrings;
    }*/

    // method to get selected skills/technologies from page
    public List<String> fetchSelectedSkillTechnologies(List<SkillSetWrapper> listSkillsWrapper, String OtherSkills) {
        List<String> listSelectedStrings = new List<String>();
        for(SkillSetWrapper wrapItr : listSkillsWrapper) {
            if(wrapItr.isSelected){
                listSelectedStrings.add(wrapItr.title);
            }
        }
        if (String.isNotBlank(OtherSkills)) {
            listSelectedStrings.add(OtherSkills);
        }
        return listSelectedStrings;
    }

    // method to validate the password
    // public boolean isPassowrdValid(String pPasswordStr, String pPswrdCnfrmStr) {
    //     //Site.validatePassword(pUserObj, pPasswordStr, pPswrdCnfrmStr);
    //     Boolean isValid = false;
    //     String passwordRegex = '(?=[#@$-/:-?{-~!^_a-zA-Z]*([0-9#@$-/:-?{-~!^_]))(?=[#@$-/:-?{-~!^_a-zA-Z0-9]*[a-zA-Z])[#@$-/:-?{-~!^_a-zA-Z0-9]{8,20}';
    //     Pattern passwordPattern = Pattern.compile(passwordRegex);
    //     Matcher PasswordMatcher = passwordPattern.matcher(pPasswordStr);
    //     if (PasswordMatcher.matches()) {
    //         if(pPswrdCnfrmStr == pPasswordStr) {
    //             isvalid = true;
    //         }
    //     }
    //
    //     return isValid;
    // }

    public void sendMail(Contact contact) {
        list<EmailTemplate> listEmailTemplate = new list<EmailTemplate>();
        listEmailTemplate = [Select Name,
                                    Id
                             From EmailTemplate
                             Where Name =: EMAIL_TEMPLATE_NAME
                             limit 1
                            ];
        if (!listEmailTemplate.isEmpty()) {
            Id templateId = listEmailTemplate[0].Id;
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
            message.setTargetObjectId(contact.Id);
            message.setToAddresses(new list<string>{Label.DETE_AlertEmailAddress});
            message.setTemplateId(templateId);
            message.setTreatTargetObjectAsRecipient(false);
            allMails.add(message);

            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails);
        }
    }

    public class SkillSetWrapper{
        public String title {get;set;}
        public boolean isSelected {get;set;}

        public SkillSetWrapper(String title, boolean isSelected){
            this.title = title;
            this.isSelected = isSelected;
        }
    }
}