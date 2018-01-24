public with sharing class DETE_ChangePassword extends DETE_BaseClass {
    public String oldPasswordStr                                                        {get; set;}
    public String newPasswordStr                                                        {get; set;}
    public String verifyPasswordStr                                                     {get; set;}
    public User userObj;

    public DETE_ChangePassword() {

        userObj = new User();

        system.debug('1111111'+strUserName);
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
            }
        }

    }

    public void fetchUsername() {

        if( true == String.isBlank(oldPasswordStr)
        || true == String.isBlank(newPasswordStr)
        || true == String.isBlank(verifyPasswordStr) ) {
            ApexPages.addMessage( new ApexPages.Message(
                                            ApexPages.Severity.Error
                                            ,'Incomplete password information.!'
                                            )
                                );
            return;
        }

        //    Site.validatePassword(userObj, newPasswordStr, verifyPasswordStr);
        //    System.setPassword(userObj.Id, newPasswordStr);
       try {
            PageReference pg = Site.changePassword(newPasswordStr, verifyPasswordStr, oldPasswordStr);

            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            if( pageMessages.size() == 0 ) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your password has been reset!'));
                }
           }
           catch(Exception exObj) {

           }


       }
}