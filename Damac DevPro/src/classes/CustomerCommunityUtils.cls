public with sharing class CustomerCommunityUtils {

    private static Set<String> setUserFields = Schema.SObjectType.User.fields.getMap().keySet();

    public static Boolean isPortalUser(Id userId) {
        List<User> lstUser = new List<User>();
        if (setUserFields.contains('isportalenabled')) {
            lstUser = [ SELECT  Id, IsPortalEnabled
                        FROM    User
                        WHERE   Id = :userId];
        }
        return !lstUser.isEmpty() && lstUser[0].IsPortalEnabled;
    }
}