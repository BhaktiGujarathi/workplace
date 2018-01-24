public with sharing class DETE_ForgotPasswordController {

    public String usernameStr                                                   {get; set;}
    public Boolean resetSuccess                                                 {get; set;}
    // public Boolean showMessage                                                  {get; set;}

    // constructor
    public DETE_ForgotPasswordController() {
        resetSuccess = false;
        usernameStr = '';
        ApexPages.getMessages().clear();
        // showmessage = false;
    }

    // method to fetch if the
    public void forgotPassword() {
        List<User> listUser = new List<User>();

        if(true == String.isBlank(usernameStr)) {
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.error,'Please enter the UserName!');
            ApexPages.addMessage(msgStr);
            return;
        }

        listUser = DETE_Util.fetchUserDetails(usernameStr);
        if(!listUser.isEmpty()) {
            //Site.validatePassword(listUser[0], newPasswordStr, verifyPasswordStr);
            resetSuccess = Site.forgotPassword(usernameStr);
            if (resetSuccess) {
                // showMessage = true;
              ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.Info,'We’ve sent you an email with a link to finish resetting your password. ');
              ApexPages.addMessage(msgStr);
            }
            else {
              ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.error,'Something went wrong');
              ApexPages.addMessage(msgStr);
            }
        }
        else {
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.error,'You have entered wrong UserName!');
            ApexPages.addMessage(msgStr);
        }
    }

    public void closeError() {
        // showMessage = false;
        usernameStr = '';
        ApexPages.getMessages().clear();
    }
}