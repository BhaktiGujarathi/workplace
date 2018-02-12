global class ScoreCalculationScheduler implements Schedulable {

	public static final Integer DEFAULT_BATCH_SIZE = 5;
	public static final String DEFAULT_CRON_EXPR = '00:30';

	global static void scheduleScore()
	   {
	       String strJobName = 'Job-ScoreCalculationScheduler'+System.Now()+'';
		   Quality_Score_Settings__c qualityScoreObj = Quality_Score_Settings__c.getOrgDefaults();
		   //batchSize = qualityScoreObj.Batch_Size__c != null ? Integer.ValueOf(qualityScoreObj.Batch_Size__c) : DEFAULT_BATCH_SIZE;
	       String cronExpression = qualityScoreObj.Cron_Expression_For_Batch__c != null ? String.ValueOf(qualityScoreObj.Cron_Expression_For_Batch__c) : DEFAULT_CRON_EXPR;
		   String cronForMinutes = cronExpression.substringAfter(':');
		   String cronForHours = cronExpression.substringBefore(':');
		   String finalCronExpression = '0'+' '+ cronForMinutes +' '+ cronForHours +' '+'*'+' ' +'*'+' '+'?';
	       System.schedule(strJobName, finalCronExpression, new ScoreCalculationScheduler());
	   }


	global void execute(SchedulableContext sc) {
		Quality_Score_Settings__c qualityScoreObj = Quality_Score_Settings__c.getOrgDefaults();
        Integer batchSize = qualityScoreObj.Batch_Size__c != null ? Integer.ValueOf(qualityScoreObj.Batch_Size__c) : DEFAULT_BATCH_SIZE;
		batchSize = batchSize == null || batchSize <=0 ? DEFAULT_BATCH_SIZE : batchSize;

		OppScoreCalculationBatch batchObj = new OppScoreCalculationBatch();
	 	database.executebatch(batchObj,batchSize);
	}
}