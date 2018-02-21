public  class AccountListController {

    public list<Account> lstAccount                 {get; set;}
    public String strBaseURL                        {get; set;}
    public list<AccountWrapper> lstAccountWrapper   {get; set;}
    public string strBday                           {get; set;}
    public AccountListController(){
        lstAccount = new list<Account>();
        strBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('strBaseURL'+strBaseURL);
        strBday='';
        lstAccountWrapper =  new list<AccountWrapper>();
        fetchAccounts();
    }
    
    public void fetchAccounts(){
        lstAccount = [select id,
                             Name,
                             PersonEmail,
                             Date_Of_Birth__c,
                             Date_Of_Anniversary__c
                        from account
                       where IsPersonAccount = true Limit 10];
        if(!lstAccount.isEmpty()){
            for(Account objAccount : lstAccount){
                AccountWrapper obj = new AccountWrapper();
                obj.objAccount = objAccount;
                //obj.strEvent = 'Birthday Today';
               // obj.strUrl = 'eventbirthday.png';
                system.debug('objAccount.Date_Of_Birth__c---'+objAccount.Date_Of_Birth__c);
                if(objAccount.Date_Of_Birth__c != null
                && objAccount.Date_Of_Birth__c.day() ==  date.today().day() 
                && objAccount.Date_Of_Birth__c.month() ==  date.today().month()){
                    obj.strEvent = 'Birthday Today';
                    obj.strUrl = 'eventbirthday.png';
                }
                else if(objAccount.Date_Of_Anniversary__c != null
                && objAccount.Date_Of_Anniversary__c.day() ==  date.today().day() 
                && objAccount.Date_Of_Anniversary__c.month() ==  date.today().month()){
                    obj.strEvent = 'Anniversary Today';
                    obj.strUrl = 'eventbirthday.png';
                }
                else{
                    obj.strEvent = 'Completed Booking';
                    obj.strUrl = 'eventbooking.png';
                }
                lstAccountWrapper.add(obj);
            }
        }
    }

   public class AccountWrapper{
    	public Account objAccount {get;set;}
    	public string strUrl      {get;set;}
    	public string strEvent    {get;set;}
        public AccountWrapper(){
            objAccount = new Account();
            strUrl ='';
            strEvent ='';
        }
    }
}