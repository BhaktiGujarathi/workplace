global class scheduleSendAchTransBatch implements Schedulable {
    global void execute(SchedulableContext SC) {
        //List<Ach_Batch__c> lstBatch = new List<Ach_Batch__c>([select id from Ach_Batch__c where CreatedDate = TODAY and Status__c='Pending' order by CreatedDate desc limit 1]);
        //if(lstBatch.size()>0)
        AchWorksUtil.sendAchTransBatch(); 
    }
}