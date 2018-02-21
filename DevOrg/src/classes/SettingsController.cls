public with sharing class SettingsController {
	
	public Map<String,Boolean> formStateEditMode { get; set; }
	public Admin_Bank_Directory_Settings__c bankDirectorySettings { get; set; }
	public Application_Portal_Settings__c portalSettings { get; set; }


	public SettingsController() {
		init();		
	}

public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
	private void init() {
		formStateEditMode = new Map<String,Boolean>{
			'BankDirectoryImportOptions' => false,
			'ApplicationOptions' => false
		};

		bankDirectorySettings = Admin_Bank_Directory_Settings__c.getOrgDefaults();	

		portalSettings = Application_Portal_Settings__c.getOrgDefaults();
	}


	public void edit() {
		String formId = ApexPages.currentPage().getParameters().get('formId');

		if (formStateEditMode.containsKey(formId)) {
			formStateEditMode.put(formId, true);
		}
	}

	public void cancel() {
		String formId = ApexPages.currentPage().getParameters().get('formId');

		if (formStateEditMode.containsKey(formId)) {
			formStateEditMode.put(formId, false);

			init();
		}	
	}

	public void saveBankDirectorySettings() {
		if (bankDirectorySettings.Scheduled_Service_Enabled__c) {
			try {
				BankDirectoryService service = new BankDirectoryService();

	            String scheduleTime = '0 0 0 ? * 1,2,3,4,5,6,7';
	            //String scheduleTime = '0 15 * ? * 1,2,3,4,5,6,7';
	            bankDirectorySettings.Scheduled_Service_Job_Id__c = System.schedule('Bank Directory Import Service', scheduleTime, new BankDirectoryService());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
			
		}
		else {
			if (bankDirectorySettings.Scheduled_Service_Job_Id__c != null) {
				try {
					System.abortJob(bankDirectorySettings.Scheduled_Service_Job_Id__c);
				}
				catch (Exception e) {}
			}
			bankDirectorySettings.Scheduled_Service_Job_Id__c = null;
		}

		upsert bankDirectorySettings;
		cancel();		
	}

	public PageReference saveApplicationOptions() {

		upsert portalSettings;
		cancel();

		return null;
	}


	public SelectOption[] getAccountRecordTypes() {
		SelectOption[] options = new SelectOption[]{ new SelectOption('', '--None--') };

		for (RecordType rt : [select Name from RecordType 
							   where SObjectType = 'Account' 
							     and IsActive = true order by Name]) {

			options.add(new SelectOption(rt.Id, rt.Name));
		}

		return options;
	}


	public String getBankDirectorySettingsAccountRecordTypeName() {
		if (bankDirectorySettings.Account_Record_Type_Id__c != null) {
			for (RecordType rt : [select Name from RecordType 
								   where SObjectType = 'Account' 
								   	 and Id = :bankDirectorySettings.Account_Record_Type_Id__c
								     and IsActive = true order by Name]) {

				return rt.Name;
			}
		}
		return '';
	}
}