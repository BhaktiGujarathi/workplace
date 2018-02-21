global class SendToInsideSalesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    
    
    global SendToInsideSalesBatch() {
        
        query = 'select First_Sent_to_InsideSales_Date_Time__c, Call_Path_Id__c from Lead where Send_to_InsideSales__c = true and IsConverted = false';
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        SendToInsideSales client = new SendToInsideSales((Lead[]) scope);
        client.send(false);             
    }
    
    
    global void finish(Database.BatchableContext BC) {
            
        start();
    }   


    public static void start() {

        System.scheduleBatch(new SendToInsideSalesBatch(), 'Send to InsideSales Service', 5);

    }
}