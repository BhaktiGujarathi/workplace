global with sharing class HarvestSchedulable implements Schedulable {
	
	private static final String JOB_NAME = 'Harvest Sync';
 	
	global void execute(SchedulableContext context) {
		HarvestSyncProjectsBatchable b = new HarvestSyncProjectsBatchable();
		Database.executeBatch(b, 1); 
	}
	
	public static String start(Integer frequencyInHours) {
		HarvestSchedulable s = new HarvestSchedulable();
		Integer minute = Math.floor((Math.random() * 59)).intValue();
		String everyHour = '0 ' + minute + ' 0/' + frequencyInHours + ' * * ?'; 
		String jobId = System.schedule(JOB_NAME, everyHour, s);
		return jobId;
	}
	
}