global class AutoReassignOpenLeadsBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global AutoReassignOpenLeadsBatch() {

        query = 'select Id from Lead where Status = \'Open - Not Contacted\' and Days_since_Reassigned_to_Rep_48_Hr_Rule__c >= 2 and IsConverted = false';
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        for (Lead l : (Lead[]) scope) {

            l.cmblre__Reassign_Lead__c = true;
            l.Reassigned_to_Rep_48_Hr_Rule_Date_Time__c = Datetime.now();
        
        }

        update scope;
    }

    
    global void finish(Database.BatchableContext BC) {
        
    }    


    public static void start() {

        Database.executeBatch(new AutoReassignOpenLeadsBatch(), 100);
    }
}