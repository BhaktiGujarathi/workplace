public with sharing class DETE_IndexPageController extends DETE_BaseClass {
    public Boolean isProfile                                                            {get; set;}
    public Boolean isJobSearch                                                          {get; set;}
    public Boolean isPassword                                                           {get; set;}
    public Boolean isLoggedIn                                                           {get; set;}
   // public String strUrlParameter                            {get; set;}
    public Contact objContact                                                           {get; set;}
    public String oldPasswordStr                                                        {get; set;}
    public String newPasswordStr                                                        {get; set;}
    public String verifyPasswordStr                                                     {get; set;}
    public User userObj;

    public DETE_IndexPageController() {
        isProfile = false;
        isJobSearch = false;
        isLoggedIn = false;
        isPassword = false;

        objContact = new Contact();
        userObj = new User();
        
       // strUrlParameter = '';

      //  String strUserName = System.currentPageReference().getParameters().get('unm');
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
               // strUrlParameter = '?unm=' + strUserName;

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
                                      Middle_Name__c,
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
                                      Address2__c
                               From Contact
                               Where Id =: listUser[0].ContactId
                               limit 1
                              ];
                if (!listContact.isEmpty()) {
                    objContact = listContact[0];
                }
            }
        }
        system.debug('aaaaaaaaa-> '+ isLoggedIn);
        system.debug('bbbbbbbbb-> '+ objContact);
        system.debug('**********'+isProfile);
        
        system.debug('&&&&&&&&'+UserInfo.getUserId());
        
    }

   /* public IndexPageController() {
        isProfile = false;
        isJobSearch = false;
        isLoggedIn = false;
        isPassword = false;

        objContact = new Contact();
        userObj = new User();

        String strUserName = System.currentPageReference().getParameters().get('unm');
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
                                      Skills__c,
                                      General_Technologies__c,
                                      Salutation
                               From Contact
                               Where Id =: listUser[0].ContactId
                               limit 1
                              ];
            
                if (!listContact.isEmpty()) {
                    objContact = listContact[0];
                }
            }
        }
        system.debug('aaaaaaaaa-> '+ isLoggedIn);
        system.debug('bbbbbbbbb-> '+ objContact);
        system.debug('**********'+isProfile);
        
        system.debug('&&&&&&&&'+UserInfo.getUserId());
        
        
    }*/
    
    public void fetchUsername() {
        //PageReference pg1 = Site.changePassword(newPasswordStr, verifyPasswordStr, oldPasswordStr);
        try {
            Site.validatePassword(userObj, newPasswordStr, verifyPasswordStr);
            System.setPassword(userObj.Id, newPasswordStr);
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your password has been reset!');
            ApexPages.addMessage(msgStr);
        }
        catch(Exception exObj) {
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.Error, +exObj.getMessage());
            ApexPages.addMessage(msgStr);
        }
        //system.debug('>>> pg1 : '+pg1);
    }
}