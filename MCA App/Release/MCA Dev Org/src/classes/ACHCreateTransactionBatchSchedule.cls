global with sharing class ACHCreateTransactionBatchSchedule implements Schedulable {
	
	global void execute(SchedulableContext SC) {
        string nextHitDate = string.valueOf(getValidDate(date.today().addDays(1))).split(' ')[0];
        ID batchprocessid = Database.executeBatch(new ACHCreateTransactionsBatch(nextHitDate));
    }


    private Date getValidDate(Date nextHitDate){
        return ACHUtils.getValidDate(nextHitDate); 
    }

}