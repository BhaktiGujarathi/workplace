global class DedupeProspectProcessBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global DedupeProspectProcessBatch(String query) {      
        this.query = query;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        DedupeProspectProcessService service = new DedupeProspectProcessService((Lead[]) scope);
        service.deduplicate();
    }

    
    global void finish(Database.BatchableContext BC) {} 


    public static void start() {
        //Prospect – Open-Not Contacted, Open- Attempting Contact, Working-Contacted, Closed-Future Client, Closed-Lost
        Database.executeBatch(new DedupeProspectProcessBatch('select Id from Lead where Status = \'Open - Not Contacted\' or Status = \'Open - Attempting Contact\' or status = \'Working - Contacted\' or status = \'Closed - Future Client\' or status = \'Closed - Lost\' order by createdDate asc'), 1);
    } 
}