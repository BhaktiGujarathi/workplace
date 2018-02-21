public class SettingsModel {
	
	public Boolean AutoSyncFrequencyChanged { get; private set; }
	public String HarvestUrl { get; set; }
	public DateTime LastSync { get; set; }
	public String Username { get; set; }
	public String Password { get; set; }
	public Integer AutoSyncFrequencyInHours { 
		get; 
		set {
			if (AutoSyncFrequencyInHours != value) {
				AutoSyncFrequencyInHours = value;
				AutoSyncFrequencyChanged = true;
			}
		} 
	}
	public String ScheduledJobId { get; set; }
	
	public SettingsModel() {
		
	}
	
	public SettingsModel(Settings__c settings) {
		HarvestUrl = settings.HarvestUrl__c;
		LastSync = settings.LastSync__c;
		Username = settings.Username__c;
		Password = settings.Password__c;
		if (settings.AutoSyncFrequencyInHours__c > 0 
			&& cronJobExists(settings.ScheduledJobId__c)) {
			AutoSyncFrequencyInHours = settings.AutoSyncFrequencyInHours__c.intValue();		
		}
		else {
			AutoSyncFrequencyInHours = 0;
		}
		ScheduledJobId = settings.ScheduledJobId__c;
		AutoSyncFrequencyChanged = false;
	}
	
	private Boolean cronJobExists(ID jobId) {
		Integer cronTriggerCount = [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId];
		return cronTriggerCount == 1;
	}
	
}