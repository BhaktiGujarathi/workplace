public with sharing class BankIntegrationSetupController {
	
	public String mode {get; set;}
	public Opportunity auxLookup {get; set;}
	public Bank_API_Settings__c settings {get; set;}
	public Submission__c auxSubmission {get; set;}
	
	public string getBankRedirect(){
	    return MCAStringConstant.baseUrlOrg+'/apex/BankIntegrationSetup';
	}
	
	public BankIntegrationSetupController() {
		
		auxLookup = new Opportunity();
		auxSubmission = new Submission__c();
		settings = new Bank_API_Settings__c();
		
		mode = 'list';
		if (ApexPages.currentPage().getParameters().get('mode') == 'new') {
			newBank();
		}
		else if (ApexPages.currentPage().getParameters().get('name') != null) {
			settings = Bank_API_Settings__c.getInstance(ApexPages.currentPage().getParameters().get('name'));
			if (settings != null) {
				auxLookup.AccountId = settings.Funder_Account__c;
				auxSubmission.Program__c = settings.Program__c;
				mode = 'view';		
			}
		}
		//getBankRedirect();
	}
	
	public BankSetting[] getBankSettings() {
		BankSetting[] bankSettings = new BankSetting[]{};
		
		for (Bank_API_Settings__c bank : Bank_API_Settings__c.getAll().values()) {
			bankSettings.add(new BankSetting(bank));
		}
		
		return bankSettings;		
	}
	
	
	public String getSubtitle() {
		if (mode == 'type') {
			return 'Select Type';
		}
		else if (mode == 'new') {
			return ((settings.Id == null) ? 'New ' : 'Edit ') + settings.Name;
		}
		else {
			return 'Home';
		}
	}
	
	
	public void newBank() {
		mode = 'type';
		settings = new Bank_API_Settings__c();
	}
	
	
	public void cancel() {
		mode = 'list';
	}
	
	
	public void selectType() {
		if (settings.Name == null || settings.Name == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Bank Type'));
		}
		else if (Bank_API_Settings__c.getInstance(settings.Name) != null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This Bank was already defined'));
		}
		else {
			mode = 'new';
		}
	}
	
	
	public void editBank() {
		if (settings != null) {
			mode = 'new';
		}
	}
	
	
	public void saveBank() {
		try {
			settings.Funder_Account__c = auxLookup.AccountId;
			settings.Program__c = auxSubmission.Program__c;
			upsert settings;
			mode = 'list';
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
		}
	}
	
	
	public void deleteBank() {
		settings = Bank_API_Settings__c.getInstance(ApexPages.currentPage().getParameters().get('name'));
		if (settings != null) {
			try {
				delete settings;
			}
			catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
			}		
		}
	}
	
	
	public String getMaskedPassword() {
		String maskedPassword = '';
		if (settings.Password__c != null) {
			for (Integer i = 0; i < settings.Password__c.length(); i++) {
				maskedPassword += '*';				
			}
		}
		return maskedPassword;
	}
	
	
	
	
	
	private class BankSetting {
		public String name {get; set;}
		public String username {get; set;}
		
		public BankSetting(Bank_API_Settings__c bank) {
			name = bank.Name;
			username = bank.Username__c;
		}
	}
}