public with sharing class ProfileController {
    public Contact customerContact {get; set;}
    public Account customerAccount {get; set;}
    public Id customerAccountId {get; set;}
    public ProfileController() {
        List<User> lstUser =  [ SELECT  ContactId,
                                        Contact.AccountId
                                FROM    User
                                WHERE   Id = :UserInfo.getUserId()];
        if (!lstUser.isEmpty()) {
            customerAccountId = lstUser[0].Contact.AccountId == NULL ? '0017E00000MexXC' : lstUser[0].Contact.AccountId; // Contact Id hardcoded for now
        }
    }
}