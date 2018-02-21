public with sharing class SettingsManager { 

	private Settings__c settings;
	private SettingsModel model;
	
	public SettingsManager() {
		settings = Settings__c.getValues('Production');
		if (settings == null) {
			settings = new Settings__c(Name = 'Production');
		}
	}
	
	public SettingsModel getModel() {
		if (model == null) {
			model = new SettingsModel(settings);
		} 
		return model;
	}
	
	public Settings__c getSettings() {
		return settings;
	}
	
	public void save() {
		if (model.AutoSyncFrequencyInHours > 0 && model.AutoSyncFrequencyChanged) {
			if (scheduledJobExists()) {
				stopSync(); 
			}
			String jobId = HarvestSchedulable.start(model.AutoSyncFrequencyInHours);
			model.ScheduledJobId = jobId;
		}
		else if (model.AutoSyncFrequencyInHours == 0) {
			stopSync();
			model.ScheduledJobId = null;
		}
		updateFromModel();
		upsert settings;
	} 
	
	private Boolean scheduledJobExists() {
		List<CronTrigger> crons = [SELECT Id FROM CronTrigger 
			WHERE Id = :model.ScheduledJobId];
		return crons.size() == 1;
	}

	private void stopSync() {
		String jobId = model.ScheduledJobId;
		if (jobId != null) {
			List<CronTrigger> crons = [SELECT Id FROM CronTrigger 
				WHERE Id = :jobId];
			System.debug('# crons' + crons.size());
			if (crons.size() > 0) {
				System.abortJob(jobId);
			}
		}
	}

	private void updateFromModel() {
		settings.HarvestUrl__c = model.HarvestUrl;
		settings.LastSync__c = model.LastSync;
		settings.Username__c = model.Username;
		settings.Password__c = model.Password;
		settings.AutoSyncFrequencyInHours__c = model.AutoSyncFrequencyInHours;
		settings.ScheduledJobId__c = model.ScheduledJobId; 
	}

}