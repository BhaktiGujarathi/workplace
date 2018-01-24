public with sharing class DETE_Util {
	public static final String STR_GETMETHOD    = 'GET';
    public static final String STR_AUTHO_BASIC  = 'BASIC ';
    public static final String STR_AUTHO_HEADER = 'Authorization';
	public static final String STR_END_RANGE    = '&end=10000';
    public static final String STR_SPACE        = ' ';
    public static final String STR_PLUS         = '+';
    public static final Integer STATUS_CODE = 200;
    
    public DETE_Util() {
        
    }
    
    // method to fetch the user details from the org.
    public static List<User> fetchUserDetails(String pUserNameStr) {
        List<User> listUser = new List<User>();
        listUser = [SELECT Id,
                           ContactId,
                           Username,
                           LastName,
                           FirstName,
                           Email,
                           CommunityNickname
                    FROM User
                    WHERE Username =:pUserNameStr
                    limit 1
                   ];
        system.debug('>>> listUser : '+listUser);

        return listUser;
    }
}