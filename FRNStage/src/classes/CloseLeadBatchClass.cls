global class CloseLeadBatchClass implements Schedulable, Database.Batchable<sObject>,Database.Stateful {
    string query; 
    
    global Database.querylocator start(Database.BatchableContext BC){
        Query = 'Select Id, Name, LastModifiedDate, Status, IsConverted From Lead';
        system.debug('Query________________________________'+Query);    
            return Database.getQueryLocator(query);
                
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope){
        date modifiedDate = System.today().addDays(-10);
        system.debug('ModifiedDate__________________________'+modifiedDate);
        system.debug('scope__________________________'+scope);
            List<Lead> toUpdate = new List<Lead>();
            for(Lead leadObj : scope){
                system.debug('LastModifiedDate_____________________________'+leadObj.LastModifiedDate);    
                system.debug('StageName____________________________'+leadObj.Status);    
                if(leadObj.LastModifiedDate <= modifiedDate && leadObj.IsConverted == false){
                    leadObj.Status = 'No Activity within 10 Days';  
                    toUpdate.add(leadObj);          
                }                   
            }
            if(toUpdate.size()>0){
                update toUpdate; 
                system.debug('toUpdate____________________________'+toUpdate);
            }
                        
    }

    global void finish(Database.BatchableContext BC){

    }
/*** Schedulable_Batch_Context ***/

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new CloseLeadBatchClass());
        
    }
    
}