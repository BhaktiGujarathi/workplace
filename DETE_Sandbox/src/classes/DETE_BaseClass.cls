public with sharing virtual class DETE_BaseClass {
    public String strUserName {get; set;}

    public DETE_BaseClass () {
        // strUserName = System.currentPageReference().getParameters().get(System.Label.DETE_UserNameParameter);
        // if ( strUserName == null || String.isBlank(strUserName) ) {
        //     strUserName = '';
        // }

        System.debug('...UserInfo.getUserType(): ' + UserInfo.getUserType());

        if( UserInfo.getUserType() != 'Guest') {
            strUserName = UserInfo.getUserName();
        }
    }
}