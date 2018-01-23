global class ScoreCalculationScheduler implements Schedulable {

	public static final Integer DEFAULT_BATCH_SIZE = 100;
	public static final String DEFAULT_CRON_EXPR = '00:30';

	public static Integer batchSize = 0;
	global static void scheduleScore() {
	       String strJobName = 'Job-ScoreCalculationScheduler'+System.Now()+'';
		   Quality_Score_Settings__c qualityScoreObj = Quality_Score_Settings__c.getOrgDefaults();
		   batchSize = RecordScoreCalculationService.getBatchSize();
	       String cronExpression = qualityScoreObj.Cron_Expression_For_Batch__c != null ? String.ValueOf(qualityScoreObj.Cron_Expression_For_Batch__c) : DEFAULT_CRON_EXPR;
		   String cronForMinutes = cronExpression.substringAfter(':');
		   String cronForHours = cronExpression.substringBefore(':');
		   String finalCronExpression = '0'+' '+ cronForMinutes +' '+ cronForHours +' '+'*'+' ' +'*'+' '+'?';
	       System.schedule(strJobName, finalCronExpression, new ScoreCalculationScheduler());
	}

	//List<String> cronExpression = [SELECT Cron_Expression_For_Batch__c FROM Quality_Score_Settings__c];

	global void execute(SchedulableContext sc) {
    //
	 	OppScoreCalculationBatch batchObj = new OppScoreCalculationBatch();
	 	database.executebatch(batchObj,batchSize);
	}
}