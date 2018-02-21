global class UserSurveyUpdateBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,Is_Survey_Completed__c from User where Is_Survey_Completed__c = true and Survey_Completion_Date__c < LAST_90_DAYS');
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
        
        for(User userRecord : userList){
            userRecord.Is_Survey_Completed__c = false;
        }
        update userList;  
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}