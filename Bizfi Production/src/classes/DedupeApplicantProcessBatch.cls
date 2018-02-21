global class DedupeApplicantProcessBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global DedupeApplicantProcessBatch(String query) {
        
        this.query = query;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        DedupeApplicantProcessService service = new DedupeApplicantProcessService((Account[]) scope);
        service.initDedupe();
    }

    
    global void finish(Database.BatchableContext BC) {} 


    public static void start() {

        String[] lst = new String[]{};
        
        for (String ac : DedupeApplicantProcessService.APPLICANT_CATEGORIES) {
            lst.add(String.escapeSingleQuotes(ac));
        }

        String applicantCategories = '(\'' + String.join(lst, '\',\'') + '\')';

        Database.executeBatch(new DedupeApplicantProcessBatch('select Id from Account where Opportunity_Stage_Category__c in ' + applicantCategories), 1);
    }
}