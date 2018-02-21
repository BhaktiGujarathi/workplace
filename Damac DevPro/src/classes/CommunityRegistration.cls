public class CommunityRegistration {
    
    public static final String PARTYID_ONLY='p';
    public static final String EMAIL_PHONE_ONLY='ep';
    public static final String ALL='a';

    public class AccountSearchModel{
        public String firstName {set;get;}
        public String lastName {set;get;}
        public String email {set;get;}
        public String phone {set;get;}
        public String password {get; set {password = value == null ? value : value.trim(); } }
        public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
        public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
        public String partyId {set;get;}
        public boolean hasMulipleAccounts  {get; set;} 
        public Account chosenAccount {set;get;}
        public Boolean hasError;
        public String  errorMessage;
        
        {
        	hasError = false;
        }
    }

    public static AccountSearchModel findAccount(AccountSearchModel model){

        Account chosenAccount;

        if( true == model.hasMulipleAccounts && false == String.isBlank(model.partyId) ) {
            List<Account> accountList =  queryAccount(model,PARTYID_ONLY);
            model = extractAccount(model, accountList);
            return model;
        }

        List<Account> accountList = queryAccount(model,EMAIL_PHONE_ONLY);
        model = extractAccount(model, accountList);


        if( true == model.hasMulipleAccounts ){
            List<Account> accountLevelTwoList = queryAccount(model,ALL);
            model = extractAccount(model, accountLevelTwoList);
        } 

        return model;
    }

    public static AccountSearchModel extractAccount(AccountSearchModel model, List<Account> accountList){

        if( accountList.isEmpty() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''));
            model.hasError = true;
        } else if( accountList.size() > 1 ) {
            //if already true , to verify we are at second level of validation
            if( model.hasMulipleAccounts == true ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''));
                model.hasError = true;
            }
            model.hasMulipleAccounts=true;
        } else if ( accountList.size() == 1 ){
            model.chosenAccount = accountList.get(0);
            model.hasMulipleAccounts=false;
        }

        return model;
    }

    public static List<Account> queryAccount(AccountSearchModel model,String searchType){

        String query =   ' SELECT Id '
                        +'      , Email__c'
                        +'   FROM Account '
                        +'  WHERE Email__c   = :model.email '
                        +'    AND Phone      = :model.phone '
                        +'  {0} ';

        String whereClause = '';
                     
                  

        if(  PARTYID_ONLY.equals(searchType)  ){
            whereClause +=  ' AND Party_ID__c = :model.partyId ';
        }  else if(  ALL.equals(searchType)  ){
            whereClause +=  ' AND FirstName = :model.firstName AND LastName   = :model.lastName  ';
        } 

        query = String.format(query, new String[]{whereClause});

        return Database.query(query);
        
        
    }
}