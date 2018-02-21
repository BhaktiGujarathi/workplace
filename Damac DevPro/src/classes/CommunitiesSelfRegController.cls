/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController {

    public CommunityRegistration.AccountSearchModel model {set;get;}
    //extra to remove
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }

    public CommunitiesSelfRegController() {
        model =  new CommunityRegistration.AccountSearchModel();
    }
    {
        model =  new CommunityRegistration.AccountSearchModel();
    }
    private boolean isValidPassword() {
        return model.password == model.confirmPassword;
    }
    public PageReference registerUser() {
        // it's okay if password is null - we'll send the user a random password in that case
        list<Account> lstAccount = new list<Account>(); 
        Id Accountid;
        string partyId;
        system.debug('model.partyId'+model.partyId);
       if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }if(model.partyId != null){
            system.debug('model.partyId'+model.partyId);
            lstAccount = [SELECT id,
                                 Party_ID__c    
                            FROM account
                           WHERE Party_ID__c=: model.partyId ];
            if(!lstAccount.isEmpty() && lstAccount.size() == 1){
                    Accountid = lstAccount[0].id;
                    partyId = lstAccount[0].Party_ID__c;
              }
        }else{
            system.debug('model.email'+model.email);
            system.debug('model.phone'+model.phone);
            //model = CommunityRegistration.findAccount(model);
            if(model.email!= null && model.phone != null ) {
                lstAccount = [SELECT id,
                                     Party_ID__c    
                                FROM account
                               WHERE PersonEmail =: model.email
                                 AND Mobile__c =: model.phone];
            
            }
            system.debug('lstAccount'+lstAccount);
            if(!lstAccount.isEmpty() && lstAccount.size() == 1 ){
                Accountid = lstAccount[0].id;
                partyId = lstAccount[0].Party_ID__c;
                system.debug('lstAccount'+lstAccount);
            }else if(!lstAccount.isEmpty() && lstAccount.size() > 1 ){
                lstAccount  = [SELECT id,
                                     Party_ID__c    
                                FROM account
                               WHERE PersonEmail =: model.email
                                 AND Mobile__c =: model.phone
                                 AND firstname =:model.firstName 
                                 AND lastName =: model.lastName];
                if(!lstAccount.isEmpty() && lstAccount.size() == 1){
                    Accountid = lstAccount[0].id;
                    partyId = lstAccount[0].Party_ID__c;
                }
                else{
                    model.hasMulipleAccounts = true;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the Party id :');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
        }
        system.debug('model'+model);
        //#TODO : Public Hierarchy Custom Setting
        String profileId = '00e0Y000000R20O'; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        //String accountId = Accountid; // To be filled in by customer.
        String userName = model.email;
        //Create a new user
        User u = new User();
        u.Username = partyId+model.email;
        u.Email = model.email;
        u.FirstName = model.firstName;
        u.LastName = model.lastName;
        u.CommunityNickname = partyId+'name';
        u.ProfileId = profileId;
        u.Phone = phone;
        u.MobilePhone = phone;

        String userId;
        Boolean sendEmailConfirmation;
        try {
            if(AccountId != null){
                userId = Site.createExternalUser(u, accountId, model.password, sendEmailConfirmation=true);
            }
        } catch(Site.ExternalUserCreateException ex) {

            //System.assert(false, 'Exception='+ex );

            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
            return null;
        }
        if (userId != null) {
            if (model.password != null && model.password.length() > 1) {
                return Site.login(userName, model.password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}