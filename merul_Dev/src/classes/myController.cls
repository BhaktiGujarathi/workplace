public with sharing class myController {

    private final Account account;
    public string abc;
    public string getAbc() {
            system.debug('#####  getter abc');
            return 'its abc';
      }
    
     public void setAbc() {
            system.debug('#####  setter abc');
            
      }
    

      public myController() {
            account = [select id, name, site, NumberOfEmployees, Industry from Account 
                       where id = :ApexPages.currentPage().getParameters().get('id')];
             system.debug('@@@@@@ custom controller constructor');          
      }

      public Account getAccount() {
            return account;
      }

      public PageReference save() {
            system.debug('@@@@@@ controller save method'+abc);   
            update account;
            return null;
      }

      public PageReference cancel() {
            return null;
      }
}