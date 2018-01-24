public with sharing class DETE_LoginService {
   // variable declaration
    public String usernameStr                                       {get; set;}
    public String passwordStr                                       {get; set;}
    public Boolean wrongInputFlag                                   {get; set;}
    public Boolean isLoggedIn                                       {get; set;}
    public String strUsername                                       {get; set;}
    public String strUrlParameter                                   {get; set;}
    public String strName                                           {get; set;}

    // Constructor
    public DETE_LoginService() {

        wrongInputFlag = false;
        usernameStr = '';
        strName = '';
    }

    public void getUsersName() {
        list<User> listUser = new list<User>();
        listUser = [Select Id,
                           Name,
                           FirstName,
                           LastName
                    From User
                    Where Username =: strUsername
                    limit 1
                   ];

        if (!listUser.isEmpty()) {
            if (!String.isBlank(listUser[0].FirstName)) {
                strName = listUser[0].FirstName;
            } else {
                strName = listUser[0].LastName;
            }
        }
    }

    // method to login existing user
    public PageReference userLogin() {

        String blankField = '';

        if( true == String.isBlank(usernameStr) ) {
            blankField = 'Username';
        }

        if( true == String.isBlank(passwordStr) ) {
            blankField += String.isBlank(blankField) ? 'Password' : ' and Password';
        }

        if(true == String.isBlank(usernameStr)
          || true == String.isBlank(passwordStr) ) {
               ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, blankField + ' can not be blank.'));
            return null;
        }

        //PageReference jobResultPg = Page.DETE_JobResultPage;
        PageReference pgRef = Site.Login(usernameStr, passwordStr, '/DETE_JobResultPage');

        System.debug('..pgRef' + pgRef);

        if(pgRef == null) {
            wrongInputFlag = true;
            return null;
        }

        pgRef.setRedirect(true);

        return pgRef;
    }

    // method to redirect to create new profile
    public PageReference newUserRegister() {
        return new PageReference(Label.DETE_Profilepage);
    }

    // mehtod to redirect to forget password page
    public void forgotPassword() {
        boolean success = Site.forgotPassword(usernameStr);
    }

    // method to clear any page messages if present
    public void clearPageMessages() {
        system.debug('>>> to clear error  :');
        wrongInputFlag = false;
        usernameStr = '';
        ApexPages.getMessages().clear();
    }
}