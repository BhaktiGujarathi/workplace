global class VolumeBonusRollUpHandlerBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global VolumeBonusRollUpHandlerBatch(Set<Id> accountIds) {

        List<String> accountIdsList = new List<String>();

        for (Id aid : accountIds) {
            accountIdsList.add(aid);
        }            

        String whereCondition = '\'' + String.join(accountIdsList, '\',\'') + '\'';

        query = 'select Id from Account where Id in (' + whereCondition + ')';
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        if (!scope.isEmpty()) {
        
            Account account = (Account) scope.get(0);
            VolumeBonusRollUpHandler handler = new VolumeBonusRollUpHandler(account.Id);
            handler.rollup();
        }
    }

    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}