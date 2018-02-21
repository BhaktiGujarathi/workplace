public with sharing class CustomCommunityLoginController {

    public String username  {get; set;}
    public String password  {get; set;}
    public String loginType {get; set;}

    private List<String> lstLoginType = new List<String> { 'PartyId', 'Username' };

    public List<SelectOption> getLoginTypes() {
        List<SelectOption> lstLoginOption = new List<SelectOption>();
        for (String loginType : lstLoginType) {
            lstLoginOption.add(new SelectOption(loginType, loginType));
        }
        return lstLoginOption;
    }

    public CustomCommunityLoginController() {
        loginType = lstLoginType[0];
    }

    public pageReference doLogin() {

        if (lstLoginType[0].equalsIgnoreCase(loginType)) {
            List<User> lstUser = [  SELECT  Id, Username, Email, Contact.Account.Party_ID__c
                                    FROM    User
                                    WHERE   IsActive = TRUE
                                        AND Party_ID__c = :username];
            System.debug('username = ' + username);
            if (!lstUser.isEmpty()) {
                username = lstUser[0].Username;
            }
            System.debug('username = ' + username);
        }

        Id networkId = Network.getNetworkId();
        List<Network> lstNetwork = [SELECT  Id, Name
                                    FROM    Network
                                    WHERE   Name = 'Damac Customer Community Portal'
                                        AND Id = NULL];
        if (!lstNetwork.isEmpty()) {
            networkId = lstNetwork[0].Id;
        }
        System.debug('networkId = ' + networkId);
        PageReference pageRef = Site.login(username, password, networkId);
        System.debug('pageRef = ' + pageRef);
        return pageRef;
    }

}