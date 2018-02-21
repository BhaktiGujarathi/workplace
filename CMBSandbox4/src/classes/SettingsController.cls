public with sharing class SettingsController {
	
	private SettingsManager manager;
	public SettingsModel Model { get; set; }
	public Settings__c Settings { get; set; }
	public List<SelectOption> AutoSyncSelectOptions { get; set; }
	public String AutoSyncFrequencyLabel { 
		get {
			if (Model.AutoSyncFrequencyInHours == 0) {
				return 'Disabled';
			}
			else {
				return 'Every ' + Model.AutoSyncFrequencyInHours + ' hours';
			}
		} 
	} 
	
	public SettingsController() {
		manager = new SettingsManager();
		Settings = manager.getSettings();
		Model = manager.getModel(); 
		AutoSyncSelectOptions = new List<SelectOption> {
			new SelectOption('0', 'Disabled'), new SelectOption('1', '1 hour'), 
			new SelectOption('2', '2 hours'), new SelectOption('4', '4 hours'), 
			new SelectOption('6', '6 hours'), new SelectOption('12', '12 hours'), 
			new SelectOption('24', '24 hours')
		};
	}
	
	public PageReference edit() {
		PageReference pr = Page.Settings;
		pr.setRedirect(true);
		return pr;
	}
		
	public PageReference cancel() {
		PageReference pr = Page.SettingsDetail;
		pr.setRedirect(true);
		return pr;
	}

	public PageReference save() {
		manager.save();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Settings Saved.'));
		PageReference pr = Page.SettingsDetail;
		pr.setRedirect(true);
		return pr;
	}
	
	public PageReference startSync() {
		HarvestSyncProjectsBatchable.start();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
			'Project sync has been started.'));
		return null;
	}
}