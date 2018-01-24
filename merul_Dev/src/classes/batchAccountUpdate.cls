global class batchAccountUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name FROM Account';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
         
         BatchLogic.updateAccount(scope);
         
         /*
         
            // code for schedules run from apex class
            String CRON_EXP = '0 0 * * * ?';
            batchAccountUpdate  sch = new batchAccountUpdate ();
            system.scheduleBatch(sch,'ABC',1);
         
         */
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}