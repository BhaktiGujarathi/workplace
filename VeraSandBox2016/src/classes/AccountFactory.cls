public with sharing class AccountFactory {

    /**
     * Creates Account object data
     *
     * @param count   Number of records to be created
     */
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= count; i++) {
            Account account = new Account();
            account.Name = 'Account'+i;
            accounts.add(account);
        }
        return accounts;
    }
    
    /**
     * Insert Account
     */
     public static List<Account> insertAccounts(List<Account> accounts) {
        insert accounts;
        return accounts;
     }
     
      /**
     * Creates and insert Account records.
     *
     * @param count   Number of records to be created
     */
     public static List<Account> createAndInsertAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= count; i++) {
            Account account = new Account();
            account.Name = 'Account'+i;
            accounts.add(account);
        }
        insert accounts;
        return accounts;
     }
}